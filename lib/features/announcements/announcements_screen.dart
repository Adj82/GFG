import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../core/theme/palette.dart';
import '../../core/utils/format.dart';
import '../../core/widgets/basics.dart';
import '../../core/widgets/forms.dart';
import '../../core/widgets/page.dart';
import '../../data/derived.dart';
import '../../data/models/models.dart';
import '../../data/providers.dart';
import '../../domain/actions/work_actions.dart';

class AnnouncementsScreen extends ConsumerWidget {
  const AnnouncementsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final a = ref.watch(accessProvider);
    if (a == null) return const SizedBox.shrink();
    final items = ref.watch(visibleAnnouncementsProvider).toList()
      ..sort((x, y) {
        if (x.pinned != y.pinned) return x.pinned ? -1 : 1;
        return y.createdAt.compareTo(x.createdAt);
      });
    final canPost = a.can(Permission.postAnnouncements);

    return AppPage(
      title: 'Announcements',
      subtitle: items.isEmpty ? null : Fmt.plural(items.length, 'post'),
      floatingActionButton: canPost
          ? FloatingActionButton.extended(
              heroTag: null,
              onPressed: () => showAnnouncementForm(context),
              icon: const Icon(Icons.campaign_rounded),
              label: const Text('Post'),
            )
          : null,
      slivers: [
        if (items.isEmpty)
          SliverToBoxAdapter(
            child: EmptyState(
              icon: Icons.campaign_rounded,
              title: 'No announcements yet',
              message: canPost
                  ? 'Post an update for the whole chapter or one domain.'
                  : 'Updates from your leads will show up here.',
              actionLabel: canPost ? 'Post one' : null,
              onAction: canPost ? () => showAnnouncementForm(context) : null,
            ),
          )
        else
          PagePad(
            child: ContentWidth(
              child: Column(
                children: [
                  for (final x in items)
                    Padding(
                      padding: const EdgeInsets.only(bottom: Gap.md),
                      child: AnnouncementCard(item: x),
                    ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class AnnouncementCard extends ConsumerWidget {
  const AnnouncementCard({super.key, required this.item});

  final Announcement item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = context.palette;
    final a = ref.watch(accessProvider)!;
    final members = ref.watch(memberMapProvider);
    final domains = ref.watch(domainMapProvider);
    final unread = !item.readBy.contains(a.me.id);
    final audience = switch (item.audience) {
      Audience.society => 'Everyone',
      Audience.department => item.department?.label ?? 'Department',
      Audience.domain => domains[item.domainId]?.name ?? 'Domain',
    };
    final canManage =
        a.can(Permission.postAnnouncements) &&
        (item.authorId == a.me.id || a.isSocietyWide);
    final author = members[item.authorId];

    return Panel(
      onTap: unread
          ? () => ref.read(announcementActionsProvider).markRead(item)
          : null,
      borderColor: unread ? p.green : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Avatar(author?.name ?? '?', size: 32),
              const SizedBox(width: Gap.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      memberName(members, item.authorId),
                      style: context.text.titleSmall,
                    ),
                    Text(
                      '${Fmt.ago(item.createdAt)} · $audience',
                      style: context.text.bodySmall,
                    ),
                  ],
                ),
              ),
              if (item.pinned)
                Icon(Icons.push_pin_rounded, size: 18, color: p.amber),
              if (unread) ...[
                const SizedBox(width: 6),
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: p.green,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
              if (canManage)
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert_rounded, size: 20),
                  onSelected: (v) async {
                    final act = ref.read(announcementActionsProvider);
                    if (v == 'pin') await act.togglePin(item);
                    if (v == 'delete') {
                      if (!context.mounted) return;
                      final ok = await confirmDialog(
                        context,
                        title: 'Delete this post?',
                        message: 'It will disappear for everyone.',
                        confirmLabel: 'Delete',
                        destructive: true,
                      );
                      if (ok) await act.delete(item);
                    }
                  },
                  itemBuilder: (_) => [
                    PopupMenuItem(
                      value: 'pin',
                      child: Text(item.pinned ? 'Unpin' : 'Pin to top'),
                    ),
                    const PopupMenuItem(value: 'delete', child: Text('Delete')),
                  ],
                ),
            ],
          ),
          const SizedBox(height: Gap.md),
          Text(item.title, style: context.text.titleMedium),
          const SizedBox(height: 6),
          Text(
            item.body,
            style: context.text.bodyMedium?.copyWith(
              color: p.inkMuted,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

Future<void> showAnnouncementForm(BuildContext context) =>
    showFormSheet<void>(context, builder: (_) => const _AnnouncementForm());

class _AnnouncementForm extends ConsumerStatefulWidget {
  const _AnnouncementForm();

  @override
  ConsumerState<_AnnouncementForm> createState() => _AnnouncementFormState();
}

class _AnnouncementFormState extends ConsumerState<_AnnouncementForm> {
  final _form = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _body = TextEditingController();
  Audience _audience = Audience.society;
  String? _domainId;
  Department? _dept;
  var _pinned = false;
  var _busy = false;

  @override
  void dispose() {
    _title.dispose();
    _body.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    if (_audience == Audience.domain && _domainId == null) {
      Toast.show(context, 'Pick a domain', error: true);
      return;
    }
    if (_audience == Audience.department && _dept == null) {
      Toast.show(context, 'Pick a department', error: true);
      return;
    }
    setState(() => _busy = true);
    await ref
        .read(announcementActionsProvider)
        .post(
          title: _title.text,
          body: _body.text,
          audience: _audience,
          domainId: _domainId,
          dept: _dept,
          pinned: _pinned,
        );
    if (!mounted) return;
    Navigator.pop(context);
    Toast.show(context, 'Posted');
  }

  @override
  Widget build(BuildContext context) {
    final a = ref.watch(accessProvider)!;
    final domains = a.domainsInReach;
    final audiences = [
      if (a.isSocietyWide) Audience.society,
      if (a.isSocietyWide || a.department != null) Audience.department,
      Audience.domain,
    ];
    if (!audiences.contains(_audience)) _audience = audiences.first;
    return FormSheet(
      formKey: _form,
      title: 'New announcement',
      submitLabel: 'Post',
      busy: _busy,
      onSubmit: _submit,
      children: [
        TextFormField(
          controller: _title,
          autofocus: true,
          textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(labelText: 'Headline'),
          validator: (v) => requiredText(v, 'Give it a headline.'),
        ),
        TextFormField(
          controller: _body,
          minLines: 4,
          maxLines: 8,
          textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(
            labelText: 'Message',
            alignLabelWithHint: true,
          ),
          validator: (v) => requiredText(v, 'Write the message.'),
        ),
        FieldLabel(
          'Who sees it',
          child: ChoiceChips<Audience>(
            values: audiences,
            selected: _audience,
            label: (x) => x.label,
            onSelected: (v) => setState(() => _audience = v),
          ),
        ),
        if (_audience == Audience.department)
          FieldLabel(
            'Department',
            child: ChoiceChips<Department>(
              values: a.isSocietyWide ? Department.values : [a.department!],
              selected: _dept,
              label: (d) => d.label,
              onSelected: (v) => setState(() => _dept = v),
            ),
          ),
        if (_audience == Audience.domain)
          DropdownButtonFormField<String>(
            initialValue: _domainId,
            isExpanded: true,
            decoration: const InputDecoration(labelText: 'Domain'),
            items: [
              for (final d in domains)
                DropdownMenuItem(value: d.id, child: Text(d.name)),
            ],
            onChanged: (v) => setState(() => _domainId = v),
          ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          value: _pinned,
          onChanged: (v) => setState(() => _pinned = v),
          title: const Text('Pin to the top'),
        ),
      ],
    );
  }
}

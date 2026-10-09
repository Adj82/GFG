import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

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

class MeetingDetailScreen extends ConsumerWidget {
  const MeetingDetailScreen({super.key, required this.meetingId});

  final String meetingId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final a = ref.watch(accessProvider);
    final m = ref
        .watch(meetingsProvider)
        .where((x) => x.id == meetingId)
        .firstOrNull;
    if (a == null) return const SizedBox.shrink();
    if (m == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(
          child: EmptyState(
            icon: Icons.search_off_rounded,
            title: 'Meeting not found',
          ),
        ),
      );
    }
    final p = context.palette;
    final members = ref.watch(memberMapProvider);
    final domains = ref.watch(domainMapProvider);
    final present = ref
        .watch(attendanceProvider)
        .where(
          (r) => r.target == AttendanceTarget.meeting && r.targetId == m.id,
        )
        .map((r) => r.memberId)
        .toSet();
    final canRun =
        a.can(Permission.scheduleMeetings) &&
        (m.createdBy == a.me.id || a.isSocietyWide);
    final acts = ref.read(meetingActionsProvider);
    final invited = ref
        .watch(activeMembersProvider)
        .where((x) => a.can(Permission.scheduleMeetings) && _invited(m, x))
        .toList();
    final scope = switch (m.audience) {
      Audience.society => 'Everyone',
      Audience.department => m.department?.label ?? '',
      Audience.domain => domains[m.domainId]?.name ?? '',
    };

    return AppPage(
      title: m.title,
      subtitle: '${Fmt.dateTime(m.startsAt)} · $scope',
      actions: [
        if (canRun)
          IconButton(
            tooltip: 'Delete meeting',
            icon: const Icon(Icons.delete_outline_rounded),
            onPressed: () async {
              final ok = await confirmDialog(
                context,
                title: 'Delete this meeting?',
                message: 'Minutes and action items go with it.',
                confirmLabel: 'Delete',
                destructive: true,
              );
              if (!ok) return;
              await acts.delete(m);
              if (context.mounted) context.pop();
            },
          ),
      ],
      slivers: [
        PagePad(
          child: ContentWidth(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Panel(
                  child: Column(
                    children: [
                      InfoRow(
                        icon: Icons.schedule_rounded,
                        label: 'Time',
                        value:
                            '${Fmt.time(m.startsAt)} · ${m.durationMinutes} min',
                      ),
                      if (m.venue.isNotEmpty)
                        InfoRow(
                          icon: Icons.place_outlined,
                          label: 'Venue',
                          value: m.venue,
                        ),
                      if (m.link.isNotEmpty)
                        InfoRow(
                          icon: Icons.videocam_outlined,
                          label: 'Link',
                          value: m.link,
                          onTap: () => launchUrl(
                            Uri.parse(
                              m.link.startsWith('http')
                                  ? m.link
                                  : 'https://${m.link}',
                            ),
                          ),
                        ),
                      InfoRow(
                        icon: Icons.person_outline_rounded,
                        label: 'Organiser',
                        value: memberName(members, m.createdBy),
                      ),
                    ],
                  ),
                ),
                if (m.agenda.isNotEmpty) ...[
                  const SizedBox(height: Gap.xl),
                  Text('Agenda', style: context.text.titleMedium),
                  const SizedBox(height: Gap.md),
                  Panel(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (var i = 0; i < m.agenda.length; i++)
                          Padding(
                            padding: EdgeInsets.only(
                              bottom: i == m.agenda.length - 1 ? 0 : Gap.sm,
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width: 26,
                                  child: Text(
                                    '${i + 1}.',
                                    style: context.text.titleSmall?.copyWith(
                                      color: p.greenStrong,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    m.agenda[i],
                                    style: context.text.bodyMedium,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: Gap.xl),
                Row(
                  children: [
                    Expanded(
                      child: Text('Minutes', style: context.text.titleMedium),
                    ),
                    if (canRun)
                      TextButton.icon(
                        icon: const Icon(Icons.edit_outlined, size: 18),
                        label: Text(m.minutes.isEmpty ? 'Write' : 'Edit'),
                        onPressed: () => _editMinutes(context, acts, m),
                      ),
                  ],
                ),
                const SizedBox(height: Gap.sm),
                Panel(
                  child: SizedBox(
                    width: double.infinity,
                    child: Text(
                      m.minutes.isEmpty
                          ? (canRun
                                ? 'No minutes yet. Capture decisions while they are fresh.'
                                : 'Minutes will be posted after the meeting.')
                          : m.minutes,
                      style: context.text.bodyMedium?.copyWith(
                        color: m.minutes.isEmpty ? p.inkFaint : p.ink,
                        height: 1.5,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: Gap.xl),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Action items',
                        style: context.text.titleMedium,
                      ),
                    ),
                    if (canRun)
                      TextButton.icon(
                        icon: const Icon(Icons.add_rounded, size: 18),
                        label: const Text('Add'),
                        onPressed: () => _addAction(context, ref, m),
                      ),
                  ],
                ),
                const SizedBox(height: Gap.sm),
                if (m.actionItems.isEmpty)
                  Panel(
                    child: SizedBox(
                      width: double.infinity,
                      child: Text(
                        'Nothing assigned yet.',
                        style: context.text.bodyMedium?.copyWith(
                          color: p.inkFaint,
                        ),
                      ),
                    ),
                  )
                else
                  Panel(
                    padding: EdgeInsets.zero,
                    child: Column(
                      children: [
                        for (var i = 0; i < m.actionItems.length; i++) ...[
                          if (i > 0) Divider(color: p.line),
                          _ActionRow(
                            meeting: m,
                            item: m.actionItems[i],
                            canRun: canRun,
                          ),
                        ],
                      ],
                    ),
                  ),
                if (canRun) ...[
                  const SizedBox(height: Gap.xl),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Attendance',
                          style: context.text.titleMedium,
                        ),
                      ),
                      Text(
                        '${present.length}/${invited.length}',
                        style: context.text.labelLarge?.copyWith(
                          color: p.greenStrong,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: Gap.sm),
                  Panel(
                    padding: EdgeInsets.zero,
                    child: Column(
                      children: [
                        for (var i = 0; i < invited.length; i++) ...[
                          if (i > 0) Divider(color: p.line, height: 1),
                          CheckboxListTile(
                            value: present.contains(invited[i].id),
                            onChanged: (_) =>
                                acts.toggleAttendance(m, invited[i].id),
                            secondary: Avatar(invited[i].name, size: 34),
                            title: Text(invited[i].name),
                            controlAffinity: ListTileControlAffinity.trailing,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  static bool _invited(Meeting m, Member x) => switch (m.audience) {
    Audience.society => true,
    Audience.department => x.department == m.department,
    Audience.domain => x.domainId == m.domainId,
  };

  Future<void> _editMinutes(
    BuildContext context,
    MeetingActions acts,
    Meeting m,
  ) async {
    final c = TextEditingController(text: m.minutes);
    final text = await showFormSheet<String>(
      context,
      builder: (ctx) => FormSheet(
        title: 'Meeting minutes',
        submitLabel: 'Save minutes',
        onSubmit: () => Navigator.pop(ctx, c.text.trim()),
        children: [
          TextField(
            controller: c,
            autofocus: true,
            minLines: 8,
            maxLines: 16,
            decoration: const InputDecoration(
              hintText: 'What was decided?',
              alignLabelWithHint: true,
            ),
          ),
        ],
      ),
    );
    c.dispose();
    if (text != null) await acts.saveMinutes(m, text);
  }

  Future<void> _addAction(
    BuildContext context,
    WidgetRef ref,
    Meeting m,
  ) async {
    final c = TextEditingController();
    var assignee = <String>[];
    final members = ref.read(activeMembersProvider);
    final ok = await showFormSheet<bool>(
      context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, set) => FormSheet(
          title: 'Add action item',
          submitLabel: 'Add',
          onSubmit: () => Navigator.pop(ctx, c.text.trim().isNotEmpty),
          children: [
            TextField(
              controller: c,
              autofocus: true,
              decoration: const InputDecoration(labelText: 'What needs doing?'),
            ),
            MemberPickerField(
              label: 'Owner',
              members: members,
              selectedIds: assignee,
              multiple: false,
              onChanged: (v) => set(() => assignee = v),
            ),
          ],
        ),
      ),
    );
    if (ok == true) {
      await ref
          .read(meetingActionsProvider)
          .addActionItem(m, c.text, assignee.isEmpty ? null : assignee.first);
    }
    c.dispose();
  }
}

class _ActionRow extends ConsumerWidget {
  const _ActionRow({
    required this.meeting,
    required this.item,
    required this.canRun,
  });

  final Meeting meeting;
  final ActionItem item;
  final bool canRun;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = context.palette;
    final members = ref.watch(memberMapProvider);
    final acts = ref.read(meetingActionsProvider);
    return Padding(
      padding: const EdgeInsets.all(Gap.lg),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.text, style: context.text.titleSmall),
                if (item.assigneeId != null)
                  Text(
                    memberName(members, item.assigneeId),
                    style: context.text.bodySmall,
                  ),
              ],
            ),
          ),
          if (item.taskId != null)
            ActionChip(
              avatar: Icon(
                Icons.task_alt_rounded,
                size: 16,
                color: p.greenStrong,
              ),
              label: const Text('On board'),
              onPressed: () => context.push('/tasks/${item.taskId}'),
            )
          else if (canRun) ...[
            FilledButton.tonal(
              onPressed: () async {
                await acts.convertToTask(meeting, item);
                if (context.mounted) {
                  Toast.show(context, 'Added to the task board');
                }
              },
              child: const Text('Make task'),
            ),
            IconButton(
              icon: const Icon(Icons.close_rounded, size: 18),
              onPressed: () => acts.removeActionItem(meeting, item.id),
            ),
          ],
        ],
      ),
    );
  }
}

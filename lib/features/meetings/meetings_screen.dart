import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

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

class MeetingsScreen extends ConsumerWidget {
  const MeetingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final a = ref.watch(accessProvider);
    if (a == null) return const SizedBox.shrink();
    final p = context.palette;
    final now = DateTime.now();
    final all = ref.watch(visibleMeetingsProvider);
    final upcoming =
        all
            .where(
              (m) => m.startsAt
                  .add(Duration(minutes: m.durationMinutes))
                  .isAfter(now),
            )
            .toList()
          ..sort((x, y) => x.startsAt.compareTo(y.startsAt));
    final past = all.where((m) => !upcoming.contains(m)).toList()
      ..sort((x, y) => y.startsAt.compareTo(x.startsAt));
    final canSchedule = a.can(Permission.scheduleMeetings);

    Widget list(List<Meeting> ms) => Panel(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          for (var i = 0; i < ms.length; i++) ...[
            if (i > 0) Divider(color: p.line),
            _MeetingTile(meeting: ms[i]),
          ],
        ],
      ),
    );

    return AppPage(
      title: 'Meetings',
      floatingActionButton: canSchedule
          ? FloatingActionButton.extended(
              heroTag: null,
              onPressed: () => showMeetingForm(context),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Schedule'),
            )
          : null,
      slivers: [
        if (all.isEmpty)
          SliverToBoxAdapter(
            child: EmptyState(
              icon: Icons.groups_rounded,
              title: 'No meetings yet',
              message:
                  'Schedule one and attendees get notified, with agenda, minutes and action items in one place.',
              actionLabel: canSchedule ? 'Schedule a meeting' : null,
              onAction: canSchedule ? () => showMeetingForm(context) : null,
            ),
          )
        else
          PagePad(
            child: ContentWidth(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (upcoming.isNotEmpty) ...[
                    const SectionHeader(
                      'Upcoming',
                      padding: EdgeInsets.only(bottom: Gap.sm),
                    ),
                    list(upcoming),
                    const SizedBox(height: Gap.xl),
                  ],
                  if (past.isNotEmpty) ...[
                    const SectionHeader(
                      'Past',
                      padding: EdgeInsets.only(bottom: Gap.sm),
                    ),
                    list(past),
                  ],
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _MeetingTile extends ConsumerWidget {
  const _MeetingTile({required this.meeting});

  final Meeting meeting;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = context.palette;
    final m = meeting;
    final domains = ref.watch(domainMapProvider);
    final scope = switch (m.audience) {
      Audience.society => 'Everyone',
      Audience.department => m.department?.label ?? '',
      Audience.domain => domains[m.domainId]?.name ?? '',
    };
    final open = m.actionItems.where((x) => x.taskId == null).length;
    return InkWell(
      onTap: () => context.push('/meetings/${m.id}'),
      child: Padding(
        padding: const EdgeInsets.all(Gap.lg),
        child: Row(
          children: [
            Container(
              width: 52,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: p.greenTint,
                borderRadius: BorderRadius.circular(Radii.md),
              ),
              child: Column(
                children: [
                  Text(
                    Fmt.month(m.startsAt),
                    style: context.text.labelSmall?.copyWith(
                      color: p.greenStrong,
                    ),
                  ),
                  Text(
                    '${m.startsAt.day}',
                    style: context.text.titleLarge?.copyWith(
                      color: p.greenStrong,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: Gap.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    m.title,
                    style: context.text.titleSmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${Fmt.time(m.startsAt)} · $scope${m.venue.isEmpty ? '' : ' · ${m.venue}'}',
                    style: context.text.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (m.minutes.isNotEmpty)
              Pill('Minutes', tone: Tone.green(context), dense: true),
            if (open > 0)
              Padding(
                padding: const EdgeInsets.only(left: 6),
                child: Pill(
                  '$open to assign',
                  tone: Tone.amber(context),
                  dense: true,
                ),
              ),
            const Icon(Icons.chevron_right_rounded),
          ],
        ),
      ),
    );
  }
}

Future<void> showMeetingForm(BuildContext context) =>
    showFormSheet<void>(context, builder: (_) => const _MeetingForm());

class _MeetingForm extends ConsumerStatefulWidget {
  const _MeetingForm();

  @override
  ConsumerState<_MeetingForm> createState() => _MeetingFormState();
}

class _MeetingFormState extends ConsumerState<_MeetingForm> {
  final _form = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _venue = TextEditingController();
  final _link = TextEditingController();
  final _agenda = TextEditingController();
  late DateTime _at = DateTime.now()
      .add(const Duration(days: 1))
      .copyWith(hour: 17, minute: 0, second: 0, millisecond: 0, microsecond: 0);
  int _minutes = 60;
  Audience _audience = Audience.society;
  String? _domainId;
  Department? _dept;
  var _busy = false;

  @override
  void dispose() {
    for (final c in [_title, _venue, _link, _agenda]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    if (_audience == Audience.domain && _domainId == null) {
      return Toast.show(context, 'Pick a domain', error: true);
    }
    if (_audience == Audience.department && _dept == null) {
      return Toast.show(context, 'Pick a department', error: true);
    }
    setState(() => _busy = true);
    await ref
        .read(meetingActionsProvider)
        .schedule(
          title: _title.text,
          startsAt: _at,
          durationMinutes: _minutes,
          audience: _audience,
          domainId: _domainId,
          dept: _dept,
          venue: _venue.text,
          link: _link.text,
          agenda: _agenda.text.split('\n'),
        );
    if (!mounted) return;
    Navigator.pop(context);
    Toast.show(context, 'Meeting scheduled');
  }

  @override
  Widget build(BuildContext context) {
    final a = ref.watch(accessProvider)!;
    final audiences = [
      if (a.isSocietyWide) Audience.society,
      if (a.isSocietyWide || a.department != null) Audience.department,
      Audience.domain,
    ];
    if (!audiences.contains(_audience)) _audience = audiences.first;
    return FormSheet(
      formKey: _form,
      title: 'Schedule a meeting',
      submitLabel: 'Schedule',
      busy: _busy,
      onSubmit: _submit,
      children: [
        TextFormField(
          controller: _title,
          autofocus: true,
          textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(labelText: 'Title'),
          validator: (v) => requiredText(v, 'Name the meeting.'),
        ),
        DateTimeField(
          label: 'When',
          value: _at,
          onChanged: (v) => setState(() => _at = v ?? _at),
        ),
        FieldLabel(
          'Length',
          child: ChoiceChips<int>(
            values: const [30, 45, 60, 90, 120],
            selected: _minutes,
            label: (m) => '$m min',
            onSelected: (v) => setState(() => _minutes = v),
          ),
        ),
        FieldLabel(
          'Who is invited',
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
              for (final d in a.domainsInReach)
                DropdownMenuItem(value: d.id, child: Text(d.name)),
            ],
            onChanged: (v) => setState(() => _domainId = v),
          ),
        TextFormField(
          controller: _venue,
          decoration: const InputDecoration(
            labelText: 'Venue (optional)',
            prefixIcon: Icon(Icons.place_outlined),
          ),
        ),
        TextFormField(
          controller: _link,
          keyboardType: TextInputType.url,
          decoration: const InputDecoration(
            labelText: 'Meeting link (optional)',
            prefixIcon: Icon(Icons.videocam_outlined),
          ),
        ),
        TextFormField(
          controller: _agenda,
          minLines: 3,
          maxLines: 6,
          decoration: const InputDecoration(
            labelText: 'Agenda, one item per line',
            alignLabelWithHint: true,
          ),
        ),
      ],
    );
  }
}

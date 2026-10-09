import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';
import '../../core/theme/palette.dart';
import '../../core/utils/format.dart';
import '../../core/widgets/basics.dart';
import '../../core/widgets/page.dart';
import '../../data/derived.dart';
import '../../data/models/models.dart';
import '../../data/providers.dart';
import '../../domain/actions/people_actions.dart';

Tone _stageTone(BuildContext c, ApplicationStage s) => switch (s) {
  ApplicationStage.applied => Tone.neutral(c),
  ApplicationStage.shortlisted => Tone.blue(c),
  ApplicationStage.interview => Tone.amber(c),
  ApplicationStage.selected => Tone.green(c),
  ApplicationStage.rejected => Tone.red(c),
};

class RequestsScreen extends ConsumerWidget {
  const RequestsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final a = ref.watch(accessProvider);
    if (a == null) return const SizedBox.shrink();
    final p = context.palette;
    final org = ref.watch(organizationProvider);
    final members = ref.watch(memberMapProvider);
    final domains = ref.watch(domainMapProvider);
    final open = ref.watch(pendingRequestsProvider);
    final decided =
        ref
            .watch(applicationsProvider)
            .where((x) => !x.stage.isOpen && a.reaches(domainId: x.domainId))
            .toList()
          ..sort(
            (x, y) => (y.decidedAt ?? y.createdAt).compareTo(
              x.decidedAt ?? x.createdAt,
            ),
          );
    final canToggle = a.can(Permission.manageMembers);
    final recruiting = org?.recruitmentOpen ?? false;

    Widget tile(Application x) => ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: Gap.lg,
        vertical: 2,
      ),
      leading: Avatar(memberName(members, x.memberId), size: 40),
      title: Text(memberName(members, x.memberId)),
      subtitle: Text(
        '${domains[x.domainId]?.name ?? ''} · ${Fmt.ago(x.createdAt)}',
      ),
      trailing: Pill(
        x.stage.label,
        tone: _stageTone(context, x.stage),
        dense: true,
      ),
      onTap: () => context.push('/people/requests/${x.id}'),
    );

    return AppPage(
      title: 'Join requests',
      subtitle: open.isEmpty ? 'Nothing pending' : '${open.length} to review',
      slivers: [
        if (canToggle)
          PagePad(
            top: Gap.sm,
            child: ContentWidth(
              child: Panel(
                color: recruiting ? p.greenTint : null,
                child: Row(
                  children: [
                    Icon(
                      recruiting
                          ? Icons.campaign_rounded
                          : Icons.pause_circle_outline_rounded,
                      color: recruiting ? p.greenStrong : p.inkMuted,
                    ),
                    const SizedBox(width: Gap.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            recruiting
                                ? 'Recruitment is open'
                                : 'Recruitment is closed',
                            style: context.text.titleSmall,
                          ),
                          Text(
                            recruiting
                                ? 'New students can apply from the sign-in screen.'
                                : 'Applications are paused.',
                            style: context.text.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: recruiting,
                      onChanged: (v) => ref
                          .read(peopleActionsProvider)
                          .setRecruitment(
                            open: v,
                            note: org?.recruitmentNote ?? '',
                          ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        PagePad(
          top: Gap.xl,
          child: ContentWidth(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionHeader(
                  'To review',
                  padding: EdgeInsets.only(bottom: Gap.sm),
                ),
                if (open.isEmpty)
                  const EmptyState(
                    icon: Icons.inbox_rounded,
                    title: 'No open requests',
                    compact: true,
                  )
                else
                  Panel(
                    padding: EdgeInsets.zero,
                    child: Column(
                      children: [
                        for (var i = 0; i < open.length; i++) ...[
                          if (i > 0) Divider(color: p.line, height: 1),
                          tile(open[i]),
                        ],
                      ],
                    ),
                  ),
                if (decided.isNotEmpty) ...[
                  const SizedBox(height: Gap.xl),
                  const SectionHeader(
                    'Decided',
                    padding: EdgeInsets.only(bottom: Gap.sm),
                  ),
                  Panel(
                    padding: EdgeInsets.zero,
                    child: Column(
                      children: [
                        for (var i = 0; i < decided.length; i++) ...[
                          if (i > 0) Divider(color: p.line, height: 1),
                          tile(decided[i]),
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
}

class RequestDetailScreen extends ConsumerWidget {
  const RequestDetailScreen({super.key, required this.applicationId});

  final String applicationId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final a = ref.watch(accessProvider);
    final x = ref
        .watch(applicationsProvider)
        .where((e) => e.id == applicationId)
        .firstOrNull;
    if (a == null) return const SizedBox.shrink();
    if (x == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(
          child: EmptyState(
            icon: Icons.search_off_rounded,
            title: 'Request not found',
          ),
        ),
      );
    }
    final p = context.palette;
    final members = ref.watch(memberMapProvider);
    final domains = ref.watch(domainMapProvider);
    final m = members[x.memberId];
    final acts = ref.read(peopleActionsProvider);
    final can =
        x.stage.isOpen &&
        a.can(Permission.approveMembers) &&
        a.reaches(domainId: x.domainId);
    final next = switch (x.stage) {
      ApplicationStage.applied => ApplicationStage.shortlisted,
      ApplicationStage.shortlisted => ApplicationStage.interview,
      _ => null,
    };

    return AppPage(
      title: m?.name ?? 'Applicant',
      subtitle: domains[x.domainId]?.name,
      bottomBar: can
          ? SafeArea(
              child: Container(
                padding: const EdgeInsets.all(Gap.md),
                decoration: BoxDecoration(
                  color: p.surface,
                  border: Border(top: BorderSide(color: p.line)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(foregroundColor: p.red),
                        onPressed: () async {
                          final note = await promptDialog(
                            context,
                            title: 'Decline application',
                            message: 'Add a short note for your records.',
                            label: 'Note',
                            confirmLabel: 'Decline',
                            required: false,
                            destructive: true,
                          );
                          if (note == null) return;
                          await acts.decline(x, note: note);
                          if (context.mounted) {
                            Toast.show(context, 'Application declined');
                          }
                        },
                        child: const Text('Decline'),
                      ),
                    ),
                    if (next != null) ...[
                      const SizedBox(width: Gap.sm),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () async {
                            DateTime? at;
                            if (next == ApplicationStage.interview) {
                              at = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now().add(
                                  const Duration(days: 2),
                                ),
                                firstDate: DateTime.now(),
                                lastDate: DateTime.now().add(
                                  const Duration(days: 60),
                                ),
                              );
                              if (at == null) return;
                              at = DateTime(at.year, at.month, at.day, 17);
                            }
                            await acts.moveApplication(
                              x,
                              next,
                              interviewAt: at,
                            );
                          },
                          child: Text(
                            next == ApplicationStage.interview
                                ? 'Interview'
                                : 'Shortlist',
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(width: Gap.sm),
                    Expanded(
                      child: FilledButton(
                        onPressed: () async {
                          await acts.accept(x);
                          if (context.mounted) {
                            Toast.show(
                              context,
                              '${m?.name ?? 'Applicant'} is in',
                            );
                          }
                        },
                        child: const Text('Accept'),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : null,
      slivers: [
        PagePad(
          child: ContentWidth(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Pill(x.stage.label, tone: _stageTone(context, x.stage)),
                    const SizedBox(width: 8),
                    Text(
                      'Applied ${Fmt.ago(x.createdAt)}',
                      style: context.text.bodySmall,
                    ),
                  ],
                ),
                const SizedBox(height: Gap.lg),
                Panel(
                  child: Column(
                    children: [
                      InfoRow(
                        icon: Icons.badge_outlined,
                        label: 'Roll number',
                        value: m?.rollNo ?? '',
                      ),
                      InfoRow(
                        icon: Icons.school_outlined,
                        label: 'Studying',
                        value: [
                          if (x.year != null) 'Year ${x.year}',
                          if (x.branch.isNotEmpty) x.branch,
                        ].join(' · '),
                      ),
                      if (x.interviewAt != null)
                        InfoRow(
                          icon: Icons.event_rounded,
                          label: 'Interview',
                          value: Fmt.dateTime(x.interviewAt!),
                        ),
                      if (x.portfolio.isNotEmpty)
                        InfoRow(
                          icon: Icons.link_rounded,
                          label: 'Portfolio',
                          value: x.portfolio,
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: Gap.xl),
                _Block('Why they want to join', x.why),
                if (x.experience.isNotEmpty) ...[
                  const SizedBox(height: Gap.lg),
                  _Block('Experience', x.experience),
                ],
                const SizedBox(height: Gap.xl),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Reviewer notes',
                        style: context.text.titleMedium,
                      ),
                    ),
                    if (can)
                      TextButton.icon(
                        icon: const Icon(Icons.add_rounded, size: 18),
                        label: const Text('Note'),
                        onPressed: () async {
                          final t = await promptDialog(
                            context,
                            title: 'Add a note',
                            label: 'Note',
                            confirmLabel: 'Save',
                          );
                          if (t != null) await acts.addNote(x, t);
                        },
                      ),
                  ],
                ),
                const SizedBox(height: Gap.sm),
                if (x.notes.isEmpty)
                  Text(
                    'No notes yet.',
                    style: context.text.bodyMedium?.copyWith(color: p.inkFaint),
                  )
                else
                  for (final n in x.notes)
                    Padding(
                      padding: const EdgeInsets.only(bottom: Gap.sm),
                      child: Panel(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${memberName(members, n.authorId)} · ${Fmt.ago(n.at)}',
                              style: context.text.labelMedium,
                            ),
                            const SizedBox(height: 4),
                            Text(n.text),
                          ],
                        ),
                      ),
                    ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _Block extends StatelessWidget {
  const _Block(this.title, this.body);

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(title, style: context.text.titleMedium),
      const SizedBox(height: Gap.sm),
      Panel(
        child: SizedBox(
          width: double.infinity,
          child: Text(
            body,
            style: context.text.bodyMedium?.copyWith(height: 1.5),
          ),
        ),
      ),
    ],
  );
}

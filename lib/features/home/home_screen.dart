import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/shell.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/palette.dart';
import '../../core/utils/format.dart';
import '../../core/widgets/basics.dart';
import '../../core/widgets/contribution_grid.dart';
import '../../core/widgets/icons.dart';
import '../../core/widgets/page.dart';
import '../../data/derived.dart';
import '../../data/models/models.dart';
import '../../data/providers.dart';
import '../../domain/activity.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 5) return 'Still up';
    if (h < 12) return 'Good morning';
    if (h < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final a = ref.watch(accessProvider);
    if (a == null) return const SizedBox.shrink();
    final p = context.palette;
    final domains = ref.watch(domainMapProvider);
    final org = ref.watch(organizationProvider);
    final days = ref.watch(activityProvider(a.me.id));
    final streak = Activity.streak(days);
    final termTotal = org == null
        ? 0
        : Activity.total(days, since: org.termStartedAt);
    final upcoming = ref.watch(upcomingEventsProvider);
    final announcements = ref.watch(visibleAnnouncementsProvider);
    final myTasks = ref.watch(myTasksProvider).where((t) => !t.isDone).toList()
      ..sort(
        (x, y) => (x.due ?? DateTime(2100)).compareTo(y.due ?? DateTime(2100)),
      );
    final pending = ref.watch(pendingApprovalsProvider);
    final requests = ref.watch(pendingRequestsProvider);
    final attendance = ref.watch(attendanceProvider);

    final liveEvent =
        upcoming.where((e) => e.checkInOpen && e.isLive()).firstOrNull ??
        upcoming.where((e) => e.checkInOpen).firstOrNull;
    final checkedIn =
        liveEvent != null &&
        attendance.any(
          (r) =>
              r.target == AttendanceTarget.event &&
              r.targetId == liveEvent.id &&
              r.memberId == a.me.id,
        );
    final overdue = myTasks.where((t) => t.isOverdue()).length;
    final dueToday = myTasks
        .where((t) => t.due != null && Fmt.dueIn(t.due!) == 'Due today')
        .length;

    final attention = <Widget>[
      if (liveEvent != null && !checkedIn)
        _AttentionRow(
          icon: Icons.qr_code_scanner_rounded,
          tone: Tone.green(context),
          title: 'Check in to ${liveEvent.title}',
          subtitle: 'Open now at ${liveEvent.venue}',
          onTap: () => context.push('/events/${liveEvent.id}/check-in'),
        ),
      if (pending > 0)
        _AttentionRow(
          icon: Icons.receipt_long_rounded,
          tone: Tone.amber(context),
          title: '${Fmt.plural(pending, 'expense')} to review',
          subtitle: 'Waiting on you',
          onTap: () => context.push('/funds/approvals'),
        ),
      if (requests.isNotEmpty)
        _AttentionRow(
          icon: Icons.person_add_alt_1_rounded,
          tone: Tone.blue(context),
          title: Fmt.plural(requests.length, 'join request'),
          subtitle: 'From people wanting to join your domains',
          onTap: () => context.push('/people/requests'),
        ),
      if (overdue > 0)
        _AttentionRow(
          icon: Icons.warning_amber_rounded,
          tone: Tone.red(context),
          title: '${Fmt.plural(overdue, 'task')} overdue',
          subtitle: 'Update the status or move the deadline',
          onTap: () => context.go('/tasks'),
        )
      else if (dueToday > 0)
        _AttentionRow(
          icon: Icons.today_rounded,
          tone: Tone.amber(context),
          title: '${Fmt.plural(dueToday, 'task')} due today',
          subtitle: myTasks
              .firstWhere(
                (t) => t.due != null && Fmt.dueIn(t.due!) == 'Due today',
              )
              .title,
          onTap: () => context.go('/tasks'),
        ),
    ];

    return AppPage(
      title: '${_greeting()}, ${Fmt.firstName(a.me.name)}',
      subtitle:
          '${a.role.name}${a.me.domainId == null ? '' : ' · ${domains[a.me.domainId]?.name ?? ''}'}',
      showBack: false,
      actions: const [TopActions()],
      slivers: [
        // ── Contribution slab ────────────────────────────────────────────
        PagePad(
          top: Gap.sm,
          child: ContentWidth(
            child: Container(
              padding: const EdgeInsets.all(Gap.lg),
              decoration: BoxDecoration(
                color: p.forest,
                borderRadius: BorderRadius.circular(Radii.xl),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '$termTotal',
                              style: context.text.displayMedium?.copyWith(
                                color: p.onForest,
                              ),
                            ),
                            Text(
                              'contributions this term',
                              style: context.text.bodyMedium?.copyWith(
                                color: p.onForest.withValues(alpha: 0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                      _StreakBadge(streak: streak),
                    ],
                  ),
                  const SizedBox(height: Gap.lg),
                  ContributionGrid(
                    days: days,
                    colors: [
                      p.onForest.withValues(alpha: 0.08),
                      const Color(0xFF1D5A31),
                      const Color(0xFF2F8D46),
                      const Color(0xFF4FC06E),
                      const Color(0xFF9CF0B3),
                    ],
                    labelColor: p.onForest.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: Gap.md),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          'Tasks, events, expenses',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: context.text.labelSmall?.copyWith(
                            color: p.onForest.withValues(alpha: 0.5),
                          ),
                        ),
                      ),
                      const SizedBox(width: Gap.sm),
                      HeatLegend(
                        colors: [
                          p.onForest.withValues(alpha: 0.08),
                          const Color(0xFF1D5A31),
                          const Color(0xFF2F8D46),
                          const Color(0xFF4FC06E),
                          const Color(0xFF9CF0B3),
                        ],
                        labelColor: p.onForest.withValues(alpha: 0.5),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),

        // ── Needs you ────────────────────────────────────────────────────
        if (attention.isNotEmpty) ...[
          const SliverToBoxAdapter(child: SectionHeader('Needs you')),
          SliverToBoxAdapter(
            child: ContentWidth(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: Gap.page),
                child: Column(
                  children: [
                    for (var i = 0; i < attention.length; i++) ...[
                      if (i > 0) const SizedBox(height: Gap.sm),
                      attention[i],
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],

        // ── Next events ──────────────────────────────────────────────────
        SliverToBoxAdapter(
          child: SectionHeader(
            'Coming up',
            action: 'All events',
            onAction: () => context.go('/events'),
          ),
        ),
        SliverToBoxAdapter(
          child: upcoming.isEmpty
              ? const EmptyState(
                  icon: Icons.event_available_rounded,
                  title: 'No events planned',
                  message:
                      'New events show up here as soon as they’re created.',
                  compact: true,
                )
              : SizedBox(
                  height: 168,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: Gap.page),
                    itemCount: upcoming.take(5).length,
                    separatorBuilder: (_, _) => const SizedBox(width: Gap.md),
                    itemBuilder: (context, i) =>
                        _EventTile(event: upcoming[i], myId: a.me.id),
                  ),
                ),
        ),

        // ── My tasks ─────────────────────────────────────────────────────
        SliverToBoxAdapter(
          child: SectionHeader(
            'Your tasks',
            action: 'Board',
            onAction: () => context.go('/tasks'),
          ),
        ),
        SliverToBoxAdapter(
          child: ContentWidth(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: Gap.page),
              child: myTasks.isEmpty
                  ? const Panel(
                      child: EmptyState(
                        icon: Icons.task_alt_rounded,
                        title: 'You’re all caught up',
                        message: 'Nothing is assigned to you right now.',
                        compact: true,
                      ),
                    )
                  : Panel(
                      padding: EdgeInsets.zero,
                      child: Column(
                        children: [
                          for (var i = 0; i < myTasks.take(4).length; i++) ...[
                            if (i > 0) Divider(color: p.line),
                            _MiniTask(task: myTasks[i]),
                          ],
                        ],
                      ),
                    ),
            ),
          ),
        ),

        // ── Announcements ────────────────────────────────────────────────
        SliverToBoxAdapter(
          child: SectionHeader(
            'Announcements',
            action: 'See all',
            onAction: () => context.push('/announcements'),
          ),
        ),
        SliverToBoxAdapter(
          child: ContentWidth(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: Gap.page),
              child: announcements.isEmpty
                  ? const Panel(
                      child: EmptyState(
                        icon: Icons.campaign_rounded,
                        title: 'No announcements yet',
                        compact: true,
                      ),
                    )
                  : Column(
                      children: [
                        for (final n in announcements.take(3)) ...[
                          _AnnouncementTile(a: n, myId: a.me.id),
                          const SizedBox(height: Gap.sm),
                        ],
                      ],
                    ),
            ),
          ),
        ),
      ],
    );
  }
}

class _StreakBadge extends StatelessWidget {
  const _StreakBadge({required this.streak});

  final int streak;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: p.onForest.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(Radii.md),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.local_fire_department_rounded,
            size: 20,
            color: streak > 0
                ? const Color(0xFFFFB84D)
                : p.onForest.withValues(alpha: 0.4),
          ),
          const SizedBox(width: 6),
          Text(
            streak == 0 ? 'No streak' : '$streak-day streak',
            style: context.text.labelMedium?.copyWith(color: p.onForest),
          ),
        ],
      ),
    );
  }
}

class _AttentionRow extends StatelessWidget {
  const _AttentionRow({
    required this.icon,
    required this.tone,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final Tone tone;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Panel(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: Gap.md, vertical: Gap.md),
      child: Row(
        children: [
          IconTile(icon, tone: tone),
          const SizedBox(width: Gap.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: context.text.titleSmall),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: context.text.bodySmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: p.inkFaint),
        ],
      ),
    );
  }
}

class _EventTile extends ConsumerWidget {
  const _EventTile({required this.event, required this.myId});

  final SocietyEvent event;
  final String myId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = context.palette;
    final going = event.rsvpIds.contains(myId);
    final live = event.isLive() || event.checkInOpen;
    return SizedBox(
      width: 252,
      child: Panel(
        onTap: () => context.push('/events/${event.id}'),
        padding: const EdgeInsets.all(Gap.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconTile(AppIcons.event(event.type), size: 36),
                const Spacer(),
                if (live)
                  Pill(
                    'Live now',
                    tone: Tone.green(context),
                    icon: Icons.circle,
                    dense: true,
                  )
                else
                  Text(
                    Fmt.countdown(event.startsAt),
                    style: context.text.labelMedium?.copyWith(
                      color: p.greenStrong,
                    ),
                  ),
              ],
            ),
            const Spacer(),
            Text(
              event.title,
              style: context.text.titleMedium,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              '${Fmt.when(event.startsAt)} · ${event.venue}',
              style: context.text.bodySmall,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: Gap.sm),
            Row(
              children: [
                Icon(
                  going
                      ? Icons.check_circle_rounded
                      : Icons.people_outline_rounded,
                  size: 16,
                  color: going ? p.green : p.inkFaint,
                ),
                const SizedBox(width: 4),
                Text(
                  going ? 'You’re going' : '${event.rsvpIds.length} going',
                  style: context.text.bodySmall,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniTask extends ConsumerWidget {
  const _MiniTask({required this.task});

  final SocietyTask task;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = context.palette;
    final overdue = task.isOverdue();
    return InkWell(
      onTap: () => context.push('/tasks/${task.id}'),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: Gap.lg,
          vertical: Gap.md,
        ),
        child: Row(
          children: [
            Container(
              width: 4,
              height: 36,
              decoration: BoxDecoration(
                color: switch (task.priority) {
                  TaskPriority.high => p.red,
                  TaskPriority.medium => p.amber,
                  TaskPriority.low => p.inkFaint,
                },
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: Gap.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    style: context.text.titleSmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    task.due == null
                        ? task.status.label
                        : '${task.status.label} · ${Fmt.dueIn(task.due!)}',
                    style: context.text.bodySmall?.copyWith(
                      color: overdue ? p.red : null,
                      fontWeight: overdue ? FontWeight.w700 : null,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: p.inkFaint),
          ],
        ),
      ),
    );
  }
}

class _AnnouncementTile extends ConsumerWidget {
  const _AnnouncementTile({required this.a, required this.myId});

  final Announcement a;
  final String myId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = context.palette;
    final members = ref.watch(memberMapProvider);
    final unread = !a.readBy.contains(myId);
    return Panel(
      onTap: () => context.push('/announcements'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (a.pinned) ...[
                Icon(Icons.push_pin_rounded, size: 14, color: p.greenStrong),
                const SizedBox(width: 4),
              ],
              if (unread) ...[
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: p.green,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
              ],
              Expanded(
                child: Text(
                  a.title,
                  style: context.text.titleSmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            a.body,
            style: context.text.bodyMedium?.copyWith(color: p.inkMuted),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: Gap.sm),
          Text(
            '${memberName(members, a.authorId)} · ${Fmt.ago(a.createdAt)}',
            style: context.text.bodySmall,
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../app/shell.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/palette.dart';
import '../../core/utils/format.dart';
import '../../core/widgets/basics.dart';
import '../../core/widgets/icons.dart';
import '../../core/widgets/page.dart';
import '../../data/derived.dart';
import '../../data/models/models.dart';
import '../../data/providers.dart';
import 'event_form.dart';

final _showPastProvider = StateProvider<bool>((ref) => false);

class EventsScreen extends ConsumerWidget {
  const EventsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final a = ref.watch(accessProvider);
    if (a == null) return const SizedBox.shrink();
    final past = ref.watch(_showPastProvider);
    final upcoming = ref.watch(upcomingEventsProvider);
    final done = ref.watch(pastEventsProvider);
    final list = past ? done : upcoming;
    final canCreate = a.can(Permission.manageEvents);
    final live = upcoming.where((e) => e.isLive() || e.checkInOpen).toList();

    return AppPage(
      title: 'Events',
      subtitle: '${upcoming.length} upcoming',
      showBack: false,
      actions: const [TopActions()],
      floatingActionButton: canCreate
          ? FloatingActionButton.extended(
              heroTag: null,
              onPressed: () async {
                final e = await showEventForm(context);
                if (e != null && context.mounted) {
                  context.push('/events/${e.id}');
                }
              },
              icon: const Icon(Icons.add_rounded),
              label: const Text('New event'),
            )
          : null,
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: Gap.page),
            child: SegmentedButton<bool>(
              showSelectedIcon: false,
              segments: [
                ButtonSegment(
                  value: false,
                  label: Text('Upcoming (${upcoming.length})'),
                ),
                ButtonSegment(
                  value: true,
                  label: Text('Past (${done.length})'),
                ),
              ],
              selected: {past},
              onSelectionChanged: (s) =>
                  ref.read(_showPastProvider.notifier).state = s.first,
            ),
          ),
        ),
        if (!past && live.isNotEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(Gap.page, Gap.lg, Gap.page, 0),
              child: ContentWidth(child: _LiveBanner(event: live.first)),
            ),
          ),
        const SliverToBoxAdapter(child: SizedBox(height: Gap.lg)),
        if (list.isEmpty)
          SliverToBoxAdapter(
            child: EmptyState(
              icon: Icons.event_available_rounded,
              title: past ? 'No past events' : 'Nothing planned yet',
              message: past
                  ? 'Finished events are kept here with their attendance and outcome.'
                  : 'Events your chapter creates will appear here.',
              actionLabel: !past && canCreate ? 'Create an event' : null,
              onAction: !past && canCreate
                  ? () => showEventForm(context)
                  : null,
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: Gap.page),
            sliver: SliverToBoxAdapter(
              child: ContentWidth(
                child: Column(
                  children: [
                    for (final e in list) ...[
                      EventCard(event: e, myId: a.me.id),
                      const SizedBox(height: Gap.md),
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

class _LiveBanner extends ConsumerWidget {
  const _LiveBanner({required this.event});

  final SocietyEvent event;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = context.palette;
    final me = ref.watch(authUserIdProvider);
    final count = ref.watch(eventAttendanceProvider(event.id)).length;
    final checkedIn = ref
        .watch(eventAttendanceProvider(event.id))
        .any((r) => r.memberId == me);
    return Container(
      padding: const EdgeInsets.all(Gap.lg),
      decoration: BoxDecoration(
        color: p.forest,
        borderRadius: BorderRadius.circular(Radii.lg),
      ),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: const BoxDecoration(
              color: Color(0xFF4FC06E),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: Gap.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.title,
                  style: context.text.titleMedium?.copyWith(color: p.onForest),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '$count checked in · ${event.venue}',
                  style: context.text.bodySmall?.copyWith(
                    color: p.onForest.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
          FilledButton(
            onPressed: () => context.push(
              checkedIn
                  ? '/events/${event.id}'
                  : '/events/${event.id}/check-in',
            ),
            style: FilledButton.styleFrom(
              backgroundColor: p.onForest,
              foregroundColor: p.forest,
              minimumSize: const Size(0, 40),
              padding: const EdgeInsets.symmetric(horizontal: 16),
            ),
            child: Text(checkedIn ? 'Open' : 'Check in'),
          ),
        ],
      ),
    );
  }
}

/// Date block + details. The date is the loudest thing, because it's what
/// people scan a list of events for.
class EventCard extends ConsumerWidget {
  const EventCard({super.key, required this.event, required this.myId});

  final SocietyEvent event;
  final String myId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = context.palette;
    final domains = ref.watch(domainMapProvider);
    final tasks = ref
        .watch(tasksProvider)
        .where((t) => t.eventId == event.id)
        .toList();
    final going = event.rsvpIds.contains(myId);
    final live = event.isLive() || event.checkInOpen;
    final past = event.isPast();
    final attended = ref.watch(eventAttendanceProvider(event.id)).length;
    final doneTasks = tasks.where((t) => t.isDone).length;

    return Panel(
      onTap: () => context.push('/events/${event.id}'),
      padding: const EdgeInsets.all(Gap.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 64,
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: event.cancelled
                  ? p.surfaceAlt
                  : (past ? p.surfaceAlt : p.greenTint),
              borderRadius: BorderRadius.circular(Radii.md),
            ),
            child: Column(
              children: [
                Text(
                  DateFormat('MMM').format(event.startsAt),
                  style: context.text.labelMedium?.copyWith(
                    color: past ? p.inkMuted : p.greenStrong,
                  ),
                ),
                Text(
                  '${event.startsAt.day}',
                  style: context.text.headlineLarge?.copyWith(
                    color: past ? p.inkMuted : p.greenStrong,
                    height: 1.1,
                  ),
                ),
                Text(
                  DateFormat('EEE').format(event.startsAt),
                  style: context.text.labelSmall?.copyWith(color: p.inkMuted),
                ),
              ],
            ),
          ),
          const SizedBox(width: Gap.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      AppIcons.event(event.type),
                      size: 14,
                      color: p.inkMuted,
                    ),
                    const SizedBox(width: 4),
                    Text(event.type.label, style: context.text.bodySmall),
                    if (event.domainId != null) ...[
                      Text('  ·  ', style: context.text.bodySmall),
                      Flexible(
                        child: Text(
                          domains[event.domainId]?.name ?? '',
                          style: context.text.bodySmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                    const Spacer(),
                    if (event.cancelled)
                      Pill('Cancelled', tone: Tone.red(context), dense: true)
                    else if (live)
                      Pill(
                        'Live',
                        tone: Tone.green(context),
                        icon: Icons.circle,
                        dense: true,
                      )
                    else if (going && !past)
                      Pill(
                        'Going',
                        tone: Tone.green(context),
                        icon: Icons.check_rounded,
                        dense: true,
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  event.title,
                  style: context.text.titleMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '${Fmt.time(event.startsAt)} · ${event.venue}',
                  style: context.text.bodySmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: Gap.md),
                if (past)
                  Row(
                    children: [
                      Icon(
                        Icons.how_to_reg_rounded,
                        size: 16,
                        color: p.inkFaint,
                      ),
                      const SizedBox(width: 4),
                      Text('$attended attended', style: context.text.bodySmall),
                    ],
                  )
                else ...[
                  Row(
                    children: [
                      Icon(
                        Icons.people_outline_rounded,
                        size: 16,
                        color: p.inkFaint,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        event.capacity == null
                            ? '${event.rsvpIds.length} going'
                            : '${event.rsvpIds.length}/${event.capacity} going',
                        style: context.text.bodySmall,
                      ),
                      if (tasks.isNotEmpty) ...[
                        const Spacer(),
                        Text(
                          'Prep ${Fmt.percent(doneTasks / tasks.length)}',
                          style: context.text.bodySmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (tasks.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    ThinProgress(value: doneTasks / tasks.length, height: 4),
                  ],
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

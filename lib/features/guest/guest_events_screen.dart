import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_theme.dart';
import '../../core/theme/palette.dart';
import '../../core/utils/format.dart';
import '../../core/widgets/basics.dart';
import '../../core/widgets/icons.dart';
import '../../core/widgets/page.dart';
import '../../data/models/models.dart';
import '../../data/providers.dart';
import '../../domain/actions/guest_actions.dart';
import '../../domain/registration_rules.dart';
import 'guest_shell.dart';
import 'study_screen.dart';

final _showPastProvider = StateProvider<bool>((ref) => false);

/// First thing a visitor sees: what's on, and how to get a seat.
class GuestEventsScreen extends ConsumerWidget {
  const GuestEventsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = context.palette;
    final org = ref.watch(organizationProvider);
    final all = ref.watch(publicEventsProvider);
    final showPast = ref.watch(_showPastProvider);
    final now = DateTime.now();

    final live = all.where((e) => e.isLive(now)).toList();
    final soon = all.where((e) => !e.isPast(now) && !e.isLive(now)).toList();
    final past = all.where((e) => e.isPast(now)).toList()
      ..sort((a, b) => b.startsAt.compareTo(a.startsAt));
    final onNow = live.length + soon.length;

    return AppPage(
      title: org?.shortName ?? 'GFG KIIT',
      subtitle: 'Events, study help and a little fun',
      showBack: false,
      actions: const [MemberLoginButton()],
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: Gap.page),
            child: ContentWidth(
              child: SegmentedButton<bool>(
                showSelectedIcon: false,
                segments: [
                  ButtonSegment(
                    value: false,
                    label: Text('On now & next ($onNow)'),
                  ),
                  ButtonSegment(
                    value: true,
                    label: Text('Past (${past.length})'),
                  ),
                ],
                selected: {showPast},
                onSelectionChanged: (s) =>
                    ref.read(_showPastProvider.notifier).state = s.first,
              ),
            ),
          ),
        ),
        if (showPast) ...[
          if (past.isEmpty)
            const SliverToBoxAdapter(
              child: EmptyState(
                icon: Icons.history_rounded,
                title: 'No past events yet',
                message: 'Finished events are listed here.',
              ),
            )
          else
            _EventList(events: past),
        ] else ...[
          if (live.isNotEmpty) ...[
            const SliverToBoxAdapter(
              child: _Heading('Happening now', live: true),
            ),
            _EventList(events: live),
          ],
          if (soon.isNotEmpty) ...[
            SliverToBoxAdapter(
              child: _Heading(live.isEmpty ? 'Coming up' : 'Next up'),
            ),
            _EventList(events: soon),
          ],
          if (onNow == 0)
            SliverToBoxAdapter(
              child: EmptyState(
                icon: Icons.event_available_rounded,
                title: 'Nothing on right now',
                message:
                    'New events show up here as soon as the team announces them. Until then, a snake needs feeding.',
                actionLabel: 'Play snake',
                onAction: () => context.go('/welcome/play'),
              ),
            ),
        ],
        PagePad(
          top: Gap.xl,
          child: ContentWidth(
            child: Panel(
              onTap: () => openKatalog(context),
              color: p.forest,
              borderColor: Colors.transparent,
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: p.onForest.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(Radii.md),
                    ),
                    child: Icon(Icons.menu_book_rounded, color: p.onForest),
                  ),
                  const SizedBox(width: Gap.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'PYQs before the exam, not after',
                          style: context.text.titleMedium?.copyWith(
                            color: p.onForest,
                          ),
                        ),
                        Text(
                          'Papers, notes and section swaps on KIIT Katalog',
                          style: context.text.bodySmall?.copyWith(
                            color: p.onForest.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.north_east_rounded, color: p.onForest),
                ],
              ),
            ),
          ),
        ),
        if (org?.recruitmentOpen != false)
          PagePad(
            top: Gap.md,
            child: ContentWidth(
              child: Panel(
                onTap: () => context.push('/join'),
                color: p.greenTint,
                borderColor: Colors.transparent,
                child: Row(
                  children: [
                    Icon(Icons.group_add_rounded, color: p.greenStrong),
                    const SizedBox(width: Gap.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Want to build with us?',
                            style: context.text.titleSmall,
                          ),
                          Text(
                            'Request to join a domain and become a member.',
                            style: context.text.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.chevron_right_rounded, color: p.greenStrong),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _Heading extends StatelessWidget {
  const _Heading(this.text, {this.live = false});

  final String text;
  final bool live;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Padding(
      padding: const EdgeInsets.fromLTRB(Gap.page, Gap.xl, Gap.page, Gap.md),
      child: ContentWidth(
        child: Row(
          children: [
            if (live) ...[
              Container(
                width: 9,
                height: 9,
                decoration: BoxDecoration(
                  color: p.green,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
            ],
            Text(text, style: context.text.titleLarge),
          ],
        ),
      ),
    );
  }
}

class _EventList extends StatelessWidget {
  const _EventList({required this.events});

  final List<SocietyEvent> events;

  @override
  Widget build(BuildContext context) => SliverPadding(
    padding: const EdgeInsets.fromLTRB(Gap.page, Gap.md, Gap.page, 0),
    sliver: SliverToBoxAdapter(
      child: ContentWidth(
        child: Column(
          children: [
            for (final e in events) ...[
              GuestEventCard(event: e),
              const SizedBox(height: Gap.md),
            ],
          ],
        ),
      ),
    ),
  );
}

class GuestEventCard extends ConsumerWidget {
  const GuestEventCard({super.key, required this.event});

  final SocietyEvent event;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = context.palette;
    final past = event.isPast();
    final live = event.isLive();
    final regs = ref.watch(eventRegistrationsProvider(event.id)).length;
    final mine = ref.watch(myRegistrationProvider(event.id));
    final left = RegistrationRules.spotsLeft(event, regs);
    final domains = ref.watch(domainMapProvider);

    return Panel(
      onTap: () => context.push('/welcome/events/${event.id}'),
      padding: const EdgeInsets.all(Gap.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 64,
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: past ? p.surfaceAlt : p.greenTint,
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
                    if (live)
                      Pill(
                        'Live',
                        tone: Tone.green(context),
                        icon: Icons.circle,
                        dense: true,
                      )
                    else if (mine != null && !past)
                      Pill(
                        'Registered',
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
                if (!past) ...[
                  const SizedBox(height: Gap.md),
                  Row(
                    children: [
                      Icon(
                        left == 0
                            ? Icons.event_busy_rounded
                            : Icons.event_seat_rounded,
                        size: 16,
                        color: left == 0 ? p.red : p.inkFaint,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        left == null
                            ? (event.isTeam
                                  ? event.teamLabel
                                  : 'Open to everyone')
                            : left == 0
                            ? 'Full'
                            : '${Fmt.plural(left, event.isTeam ? 'team slot' : 'seat')} left',
                        style: context.text.bodySmall?.copyWith(
                          color: left == 0 ? p.red : null,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

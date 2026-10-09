import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';
import '../../core/theme/palette.dart';
import '../../core/utils/format.dart';
import '../../core/widgets/basics.dart';
import '../../core/widgets/comments.dart';
import '../../core/widgets/icons.dart';
import '../../core/widgets/page.dart';
import '../../data/derived.dart';
import '../../data/models/models.dart';
import '../../data/providers.dart';
import '../../domain/actions/guest_actions.dart';
import '../../domain/actions/work_actions.dart';
import '../../domain/expense_rules.dart';
import '../funds/expense_form.dart';
import '../tasks/task_form.dart';
import '../tasks/task_widgets.dart';
import 'event_form.dart';

enum _Tab { overview, prep, budget, people }

final _tabProvider = StateProvider.family<_Tab, String>(
  (ref, id) => _Tab.overview,
);

class EventDetailScreen extends ConsumerWidget {
  const EventDetailScreen({super.key, required this.eventId});

  final String eventId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final a = ref.watch(accessProvider);
    final event = ref
        .watch(eventsProvider)
        .where((e) => e.id == eventId)
        .firstOrNull;
    if (a == null) return const SizedBox.shrink();
    if (event == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(
          child: EmptyState(
            icon: Icons.search_off_rounded,
            title: 'This event isn’t available',
          ),
        ),
      );
    }
    final p = context.palette;
    final tab = ref.watch(_tabProvider(eventId));
    final canManage = a.canManageEvent(event);
    final domains = ref.watch(domainMapProvider);
    final going = event.rsvpIds.contains(a.me.id);
    final past = event.isPast();
    final full =
        event.capacity != null &&
        event.rsvpIds.length >= event.capacity! &&
        !going;
    final attendance = ref.watch(eventAttendanceProvider(eventId));
    final checkedIn = attendance.any((r) => r.memberId == a.me.id);
    final actions = ref.read(eventActionsProvider);
    final canSeeMoney =
        a.can(Permission.viewScopedFinance) ||
        a.can(Permission.viewWallet) ||
        event.organizerIds.contains(a.me.id);

    final tabs = [
      _Tab.overview,
      if (canManage ||
          event.organizerIds.contains(a.me.id) ||
          a.can(Permission.assignTasks))
        _Tab.prep,
      if (canSeeMoney) _Tab.budget,
      if (canManage) _Tab.people,
    ];
    final active = tabs.contains(tab) ? tab : _Tab.overview;

    return AppPage(
      title: event.title,
      subtitle:
          '${event.type.label}${event.domainId == null ? '' : ' · ${domains[event.domainId]?.name ?? ''}'}',
      actions: [
        if (canManage && !past && !event.cancelled)
          PopupMenuButton<String>(
            tooltip: 'More',
            onSelected: (v) async {
              if (v == 'edit') {
                showEventForm(context, event: event);
              } else if (v == 'cancel') {
                final ok = await confirmDialog(
                  context,
                  title: 'Cancel this event?',
                  message:
                      'Everyone who RSVP’d will be notified. Tasks and budget stay on record.',
                  confirmLabel: 'Cancel event',
                  destructive: true,
                );
                if (ok) await actions.cancel(event);
              }
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'edit', child: Text('Edit event')),
              PopupMenuItem(value: 'cancel', child: Text('Cancel event')),
            ],
          ),
      ],
      bottomBar: event.cancelled || past
          ? null
          : SafeArea(
              child: Container(
                padding: const EdgeInsets.fromLTRB(
                  Gap.page,
                  Gap.md,
                  Gap.page,
                  Gap.md,
                ),
                decoration: BoxDecoration(
                  color: p.surface,
                  border: Border(top: BorderSide(color: p.line)),
                ),
                child: ContentWidth(
                  child: Row(
                    children: [
                      if (canManage) ...[
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () =>
                                context.push('/events/$eventId/host'),
                            icon: const Icon(Icons.qr_code_2_rounded),
                            label: Text(
                              event.checkInOpen
                                  ? 'Check-in screen'
                                  : 'Start check-in',
                            ),
                          ),
                        ),
                        const SizedBox(width: Gap.md),
                      ],
                      Expanded(
                        child: event.checkInOpen && !checkedIn
                            ? FilledButton.icon(
                                onPressed: () =>
                                    context.push('/events/$eventId/check-in'),
                                icon: const Icon(Icons.qr_code_scanner_rounded),
                                label: const Text('Check in'),
                              )
                            : going
                            ? OutlinedButton.icon(
                                onPressed: () => actions.toggleRsvp(event),
                                icon: Icon(
                                  checkedIn
                                      ? Icons.verified_rounded
                                      : Icons.check_rounded,
                                  color: p.green,
                                ),
                                label: Text(
                                  checkedIn ? 'Checked in' : 'Going · Cancel',
                                ),
                              )
                            : FilledButton(
                                onPressed: full
                                    ? null
                                    : () => actions.toggleRsvp(event),
                                child: Text(full ? 'Event is full' : 'RSVP'),
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
      slivers: [
        if (tabs.length > 1)
          SliverToBoxAdapter(
            child: SizedBox(
              height: 44,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: Gap.page),
                children: [
                  for (final t in tabs)
                    Padding(
                      padding: const EdgeInsets.only(right: Gap.xl),
                      child: InkWell(
                        onTap: () =>
                            ref.read(_tabProvider(eventId).notifier).state = t,
                        child: Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: t == active
                                    ? p.green
                                    : Colors.transparent,
                                width: 3,
                              ),
                            ),
                          ),
                          child: Text(
                            switch (t) {
                              _Tab.overview => 'Overview',
                              _Tab.prep => 'Prep',
                              _Tab.budget => 'Budget',
                              _Tab.people => 'Attendance',
                            },
                            style: context.text.labelLarge?.copyWith(
                              color: t == active ? p.ink : p.inkMuted,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        const SliverToBoxAdapter(child: SizedBox(height: Gap.lg)),
        SliverToBoxAdapter(
          child: ContentWidth(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: Gap.page),
              child: switch (active) {
                _Tab.overview => _Overview(event: event, access: a),
                _Tab.prep => _Prep(event: event),
                _Tab.budget => _Budget(event: event),
                _Tab.people => _People(event: event),
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _Overview extends ConsumerWidget {
  const _Overview({required this.event, required this.access});

  final SocietyEvent event;
  final dynamic access;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = context.palette;
    final members = ref.watch(memberMapProvider);
    final tasks = ref
        .watch(tasksProvider)
        .where((t) => t.eventId == event.id)
        .toList();
    final done = tasks.where((t) => t.isDone).length;
    final attendance = ref.watch(eventAttendanceProvider(event.id));
    final past = event.isPast();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (event.cancelled)
          Padding(
            padding: const EdgeInsets.only(bottom: Gap.lg),
            child: Container(
              padding: const EdgeInsets.all(Gap.md),
              decoration: BoxDecoration(
                color: p.redTint,
                borderRadius: BorderRadius.circular(Radii.md),
              ),
              child: Row(
                children: [
                  Icon(Icons.event_busy_rounded, color: p.red),
                  const SizedBox(width: Gap.md),
                  Expanded(
                    child: Text(
                      'This event was cancelled.',
                      style: context.text.titleSmall?.copyWith(color: p.red),
                    ),
                  ),
                ],
              ),
            ),
          ),
        Panel(
          child: Column(
            children: [
              InfoRow(
                icon: Icons.schedule_rounded,
                label: 'When',
                value:
                    '${Fmt.weekdayDate(event.startsAt)}, ${Fmt.time(event.startsAt)} – ${Fmt.time(event.endsAt)}',
              ),
              InfoRow(
                icon: Icons.place_outlined,
                label: 'Where',
                value: event.venue,
              ),
              InfoRow(
                icon: Icons.people_outline_rounded,
                label: 'Going',
                value: event.capacity == null
                    ? '${event.rsvpIds.length} people'
                    : '${event.rsvpIds.length} of ${event.capacity} seats',
              ),
            ],
          ),
        ),
        if (event.description.isNotEmpty) ...[
          const SizedBox(height: Gap.xl),
          Text('About', style: context.text.titleMedium),
          const SizedBox(height: Gap.sm),
          Text(event.description, style: context.text.bodyLarge),
        ],
        if (event.organizerIds.isNotEmpty) ...[
          const SizedBox(height: Gap.xl),
          Text('Organisers', style: context.text.titleMedium),
          const SizedBox(height: Gap.sm),
          Wrap(
            spacing: Gap.sm,
            runSpacing: Gap.sm,
            children: [
              for (final id in event.organizerIds)
                if (members[id] != null)
                  ActionChip(
                    avatar: Avatar(members[id]!.name, size: 24),
                    label: Text(members[id]!.name),
                    onPressed: () => context.push('/people/$id'),
                  ),
            ],
          ),
        ],
        if (!past && tasks.isNotEmpty) ...[
          const SizedBox(height: Gap.xl),
          Panel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Preparation',
                        style: context.text.titleMedium,
                      ),
                    ),
                    Text(
                      Fmt.percent(done / tasks.length),
                      style: context.text.headlineSmall?.copyWith(
                        color: p.greenStrong,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: Gap.sm),
                ThinProgress(value: done / tasks.length, height: 8),
                const SizedBox(height: Gap.sm),
                Text(
                  '$done of ${tasks.length} tasks done',
                  style: context.text.bodySmall,
                ),
              ],
            ),
          ),
        ],
        if (past) ...[
          const SizedBox(height: Gap.xl),
          Panel(
            child: Row(
              children: [
                Expanded(
                  child: Stat(value: '${attendance.length}', label: 'attended'),
                ),
                Expanded(
                  child: Stat(value: '${event.rsvpIds.length}', label: 'RSVPs'),
                ),
                Expanded(
                  child: Stat(
                    value: event.rsvpIds.isEmpty
                        ? '–'
                        : Fmt.percent(
                            attendance
                                    .where(
                                      (r) => event.rsvpIds.contains(r.memberId),
                                    )
                                    .length /
                                event.rsvpIds.length,
                          ),
                    label: 'of RSVPs came',
                  ),
                ),
              ],
            ),
          ),
          if (event.outcome.isNotEmpty) ...[
            const SizedBox(height: Gap.lg),
            Text('Outcome', style: context.text.titleMedium),
            const SizedBox(height: Gap.sm),
            Text(event.outcome, style: context.text.bodyLarge),
          ],
        ],
        const SizedBox(height: Gap.xl),
        Text('Discussion', style: context.text.titleMedium),
        const SizedBox(height: Gap.md),
        CommentsThread(
          parent: CommentParent.event,
          parentId: event.id,
          subject: event.title,
          route: '/events/${event.id}',
          notifyIds: event.organizerIds,
        ),
      ],
    );
  }
}

class _Prep extends ConsumerWidget {
  const _Prep({required this.event});

  final SocietyEvent event;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final a = ref.watch(accessProvider)!;
    final tasks =
        ref.watch(tasksProvider).where((t) => t.eventId == event.id).toList()
          ..sort((x, y) {
            if (x.isDone != y.isDone) return x.isDone ? 1 : -1;
            return (x.due ?? DateTime(2100)).compareTo(y.due ?? DateTime(2100));
          });
    final canAdd = a.can(Permission.assignTasks);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                tasks.isEmpty
                    ? 'No prep tasks yet'
                    : '${tasks.where((t) => t.isDone).length} of ${tasks.length} done',
                style: context.text.titleMedium,
              ),
            ),
            if (canAdd)
              FilledButton.tonalIcon(
                onPressed: () => showTaskForm(
                  context,
                  eventId: event.id,
                  domainId: event.domainId,
                ),
                icon: const Icon(Icons.add_rounded),
                label: const Text('Add task'),
                style: FilledButton.styleFrom(
                  backgroundColor: context.palette.greenTint,
                  foregroundColor: context.palette.greenStrong,
                  minimumSize: const Size(0, 40),
                ),
              ),
          ],
        ),
        const SizedBox(height: Gap.md),
        if (tasks.isEmpty)
          const Panel(
            child: EmptyState(
              icon: Icons.checklist_rounded,
              title: 'Break the event into tasks',
              message:
                  'Add tasks for venue, creatives, volunteers and so on, and assign each to someone.',
              compact: true,
            ),
          )
        else
          for (final t in tasks) ...[
            TaskCard(
              task: t,
              showStatus: true,
              onTap: () => context.push('/tasks/${t.id}'),
            ),
            const SizedBox(height: Gap.sm),
          ],
      ],
    );
  }
}

class _Budget extends ConsumerWidget {
  const _Budget({required this.event});

  final SocietyEvent event;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = context.palette;
    final a = ref.watch(accessProvider)!;
    final members = ref.watch(memberMapProvider);
    final expenses =
        ref.watch(expensesProvider).where((e) => e.eventId == event.id).toList()
          ..sort((x, y) => y.submittedAt.compareTo(x.submittedAt));
    final income = ref
        .watch(incomeProvider)
        .where((i) => i.eventId == event.id)
        .toList();
    final spent = Ledger.spentTotal(expenses);
    final committed = Ledger.pendingTotal(expenses);
    final remaining = event.budget - spent - committed;
    final over = event.budget > 0 && remaining < 0;
    final used = event.budget == 0 ? 0.0 : (spent / event.budget);
    final usedWithPending = event.budget == 0
        ? 0.0
        : ((spent + committed) / event.budget);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Panel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                over ? 'Over budget by' : 'Left to spend',
                style: context.text.bodySmall,
              ),
              const SizedBox(height: 2),
              Text(
                event.budget == 0
                    ? 'No budget set'
                    : Fmt.money(remaining.abs()),
                style: context.text.displaySmall?.copyWith(
                  color: over ? p.red : p.ink,
                ),
              ),
              if (event.budget > 0) ...[
                const SizedBox(height: Gap.lg),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: SizedBox(
                    height: 10,
                    child: Stack(
                      children: [
                        Container(color: p.surfaceAlt),
                        FractionallySizedBox(
                          widthFactor: usedWithPending.clamp(0, 1),
                          child: Container(
                            color: p.amber.withValues(alpha: 0.45),
                          ),
                        ),
                        FractionallySizedBox(
                          widthFactor: used.clamp(0, 1),
                          child: Container(color: over ? p.red : p.green),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: Gap.md),
                Row(
                  children: [
                    Expanded(
                      child: _Legend(
                        color: p.green,
                        label: 'Spent',
                        value: Fmt.money(spent),
                      ),
                    ),
                    Expanded(
                      child: _Legend(
                        color: p.amber,
                        label: 'Awaiting approval',
                        value: Fmt.money(committed),
                      ),
                    ),
                    Expanded(
                      child: _Legend(
                        color: p.inkFaint,
                        label: 'Budget',
                        value: Fmt.money(event.budget),
                      ),
                    ),
                  ],
                ),
              ],
              if (income.isNotEmpty) ...[
                const Divider(height: Gap.xl),
                Row(
                  children: [
                    Icon(Icons.trending_up_rounded, color: p.green, size: 20),
                    const SizedBox(width: Gap.sm),
                    Expanded(
                      child: Text(
                        'Income tied to this event',
                        style: context.text.bodyMedium,
                      ),
                    ),
                    Text(
                      Fmt.money(Ledger.incomeTotal(income)),
                      style: context.text.titleSmall,
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: Gap.xl),
        Row(
          children: [
            Expanded(child: Text('Expenses', style: context.text.titleMedium)),
            if (a.can(Permission.submitExpense))
              FilledButton.tonalIcon(
                onPressed: () => showExpenseForm(context, eventId: event.id),
                icon: const Icon(Icons.add_rounded),
                label: const Text('Add expense'),
                style: FilledButton.styleFrom(
                  backgroundColor: p.greenTint,
                  foregroundColor: p.greenStrong,
                  minimumSize: const Size(0, 40),
                ),
              ),
          ],
        ),
        const SizedBox(height: Gap.md),
        if (expenses.isEmpty)
          const Panel(
            child: EmptyState(
              icon: Icons.receipt_long_rounded,
              title: 'No expenses yet',
              message: 'Receipts filed against this event show up here.',
              compact: true,
            ),
          )
        else
          Panel(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                for (var i = 0; i < expenses.length; i++) ...[
                  if (i > 0) Divider(color: p.line),
                  InkWell(
                    onTap: () =>
                        context.push('/funds/expense/${expenses[i].id}'),
                    child: Padding(
                      padding: const EdgeInsets.all(Gap.md),
                      child: Row(
                        children: [
                          IconTile(
                            AppIcons.expense(expenses[i].category),
                            size: 36,
                          ),
                          const SizedBox(width: Gap.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  expenses[i].title,
                                  style: context.text.titleSmall,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  '${memberName(members, expenses[i].submittedBy)} · ${expenses[i].stage.label}',
                                  style: context.text.bodySmall,
                                ),
                              ],
                            ),
                          ),
                          Text(
                            Fmt.money(expenses[i].amount),
                            style: context.text.titleSmall,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
      ],
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend({
    required this.color,
    required this.label,
    required this.value,
  });

  final Color color;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                style: context.text.bodySmall,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(value, style: context.text.titleSmall),
      ],
    );
  }
}

class _People extends ConsumerWidget {
  const _People({required this.event});

  final SocietyEvent event;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = context.palette;
    final members = ref.watch(memberMapProvider);
    final attendance = ref.watch(eventAttendanceProvider(event.id));
    final present = {for (final r in attendance) r.memberId: r};
    final everyone =
        {
          ...event.rsvpIds,
          ...present.keys,
        }.map((id) => members[id]).whereType<Member>().toList()..sort((x, y) {
          final px = present.containsKey(x.id), py = present.containsKey(y.id);
          if (px != py) return px ? -1 : 1;
          return x.name.compareTo(y.name);
        });
    final guests = ref.watch(eventRegistrationsProvider(event.id));
    final actions = ref.read(eventActionsProvider);
    final canMark =
        !event.cancelled &&
        !event.startsAt.isAfter(DateTime.now().add(const Duration(hours: 6)));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Panel(
          child: Row(
            children: [
              Expanded(
                child: Stat(value: '${present.length}', label: 'checked in'),
              ),
              Expanded(
                child: Stat(value: '${event.rsvpIds.length}', label: 'RSVPs'),
              ),
              Expanded(
                child: Stat(
                  value:
                      '${present.keys.where((id) => !event.rsvpIds.contains(id)).length}',
                  label: 'walk-ins',
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: Gap.lg),
        if (everyone.isEmpty)
          const Panel(
            child: EmptyState(
              icon: Icons.people_outline_rounded,
              title: 'Nobody yet',
              message: 'People who RSVP or check in appear here.',
              compact: true,
            ),
          )
        else
          Panel(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                for (var i = 0; i < everyone.length; i++) ...[
                  if (i > 0) Divider(color: p.line),
                  ListTile(
                    leading: Avatar(everyone[i].name),
                    title: Text(everyone[i].name),
                    subtitle: Text(
                      present[everyone[i].id] == null
                          ? 'RSVP only'
                          : '${present[everyone[i].id]!.method.label} · ${Fmt.time(present[everyone[i].id]!.at)}',
                    ),
                    trailing: canMark
                        ? Switch(
                            value: present.containsKey(everyone[i].id),
                            onChanged: (v) => v
                                ? actions.markPresent(event, everyone[i].id)
                                : actions.unmark(event, everyone[i].id),
                          )
                        : (present.containsKey(everyone[i].id)
                              ? Icon(Icons.check_circle_rounded, color: p.green)
                              : null),
                  ),
                ],
              ],
            ),
          ),
        if (event.isPublic) ...[
          const SizedBox(height: Gap.xl),
          Text(
            'Guest registrations (${guests.length})',
            style: context.text.titleMedium,
          ),
          const SizedBox(height: 2),
          Text(
            'Non-members who signed up from the public page.',
            style: context.text.bodySmall,
          ),
          const SizedBox(height: Gap.md),
          if (guests.isEmpty)
            const Panel(
              child: EmptyState(
                icon: Icons.person_add_alt_rounded,
                title: 'No guests yet',
                message: 'Share the app link so students can register.',
                compact: true,
              ),
            )
          else
            Panel(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  for (var i = 0; i < guests.length; i++) ...[
                    if (i > 0) Divider(color: p.line),
                    ListTile(
                      leading: Avatar(guests[i].name),
                      title: Text(guests[i].name),
                      subtitle: Text(
                        [
                          guests[i].email,
                          if (guests[i].rollNo.isNotEmpty) guests[i].rollNo,
                          if (guests[i].college.isNotEmpty) guests[i].college,
                        ].join(' · '),
                      ),
                      trailing: Text(
                        guests[i].reference,
                        style: context.text.labelMedium,
                      ),
                    ),
                  ],
                ],
              ),
            ),
        ],
      ],
    );
  }
}

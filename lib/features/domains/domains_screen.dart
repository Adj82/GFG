import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';
import '../../core/theme/palette.dart';
import '../../core/utils/format.dart';
import '../../core/widgets/basics.dart';
import '../../core/widgets/icons.dart';
import '../../core/widgets/page.dart';
import '../../data/models/models.dart';
import '../../data/providers.dart';
import '../../domain/default_roles.dart';

/// One row of the overview: what a domain did most recently.
class DomainActivity {
  const DomainActivity({
    required this.domain,
    required this.lead,
    required this.members,
    required this.openTasks,
    required this.lastAt,
    required this.lastText,
  });

  final Domain domain;
  final Member? lead;
  final int members;
  final int openTasks;
  final DateTime? lastAt;
  final String lastText;
}

/// Newest thing in each domain (announcement, task or event), newest first.
final domainActivityProvider = Provider<List<DomainActivity>>((ref) {
  final domains = ref.watch(domainsProvider);
  final members = ref.watch(membersProvider).where((m) => m.isActive).toList();
  final tasks = ref.watch(tasksProvider);
  final events = ref.watch(eventsProvider);
  final notes = ref.watch(announcementsProvider);

  final rows = <DomainActivity>[];
  for (final d in domains) {
    final mine = members.where((m) => m.domainId == d.id).toList();
    Member? lead;
    for (final m in mine) {
      if (m.roleId == DefaultRoles.domainLead) lead = m;
    }
    final items = <(DateTime, String)>[
      for (final n in notes.where((n) => n.domainId == d.id))
        (n.createdAt, 'Announcement: ${n.title}'),
      for (final t in tasks.where((t) => t.domainId == d.id))
        (
          t.completedAt ?? t.updatedAt ?? t.createdAt,
          t.isDone ? 'Done: ${t.title}' : 'Task: ${t.title}',
        ),
      for (final e in events.where((e) => e.domainId == d.id))
        (e.startsAt, 'Event: ${e.title}'),
    ]..sort((a, b) => b.$1.compareTo(a.$1));
    final now = DateTime.now();
    final past = items.where((i) => !i.$1.isAfter(now)).toList();
    final last = past.isNotEmpty ? past.first : null;
    rows.add(
      DomainActivity(
        domain: d,
        lead: lead,
        members: mine.length,
        openTasks: tasks.where((t) => t.domainId == d.id && !t.isDone).length,
        lastAt: last?.$1,
        lastText: last?.$2 ?? 'No activity yet',
      ),
    );
  }
  rows.sort((a, b) {
    final x = a.lastAt, y = b.lastAt;
    if (x == null && y == null) return a.domain.name.compareTo(b.domain.name);
    if (x == null) return 1;
    if (y == null) return -1;
    return y.compareTo(x);
  });
  return rows;
});

/// The core team's "all domains at a glance", laid out like a chat list.
class DomainsScreen extends ConsumerWidget {
  const DomainsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final a = ref.watch(accessProvider);
    if (a == null) return const SizedBox.shrink();
    final p = context.palette;
    if (!a.can(Permission.viewAllDomains)) {
      return const AppPage(
        title: 'All domains',
        slivers: [
          SliverToBoxAdapter(
            child: EmptyState(
              icon: Icons.lock_outline_rounded,
              title: 'Core team only',
              message: 'The all-domains overview is for the six core roles.',
            ),
          ),
        ],
      );
    }
    final rows = ref.watch(domainActivityProvider);
    return AppPage(
      title: 'All domains',
      subtitle: '${rows.length} domains, newest activity first',
      slivers: [
        PagePad(
          child: ContentWidth(
            child: Panel(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  for (var i = 0; i < rows.length; i++) ...[
                    if (i > 0) Divider(color: p.line, height: 1, indent: 72),
                    _DomainRow(row: rows[i]),
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

class _DomainRow extends StatelessWidget {
  const _DomainRow({required this.row});

  final DomainActivity row;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return InkWell(
      onTap: () => context.push('/domains/${row.domain.id}'),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: Gap.lg,
          vertical: Gap.md,
        ),
        child: Row(
          children: [
            IconTile(AppIcons.domain(row.domain.icon), size: 44),
            const SizedBox(width: Gap.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          row.domain.name,
                          style: context.text.titleMedium,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (row.lastAt != null)
                        Text(
                          Fmt.ago(row.lastAt!),
                          style: context.text.bodySmall,
                        ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    row.lastText,
                    style: context.text.bodyMedium?.copyWith(
                      color: p.inkMuted,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${row.lead?.name ?? 'No lead yet'} · '
                    '${Fmt.plural(row.members, 'member')}',
                    style: context.text.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (row.openTasks > 0) ...[
              const SizedBox(width: Gap.sm),
              Badge(
                label: Text('${row.openTasks}'),
                backgroundColor: p.green,
                textColor: Colors.white,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// One domain's people, open work, events and announcements.
class DomainDetailScreen extends ConsumerWidget {
  const DomainDetailScreen({super.key, required this.domainId});

  final String domainId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final a = ref.watch(accessProvider);
    final domain = ref.watch(domainMapProvider)[domainId];
    if (a == null || domain == null) return const SizedBox.shrink();
    if (!a.can(Permission.viewAllDomains)) return const SizedBox.shrink();
    final members = ref
        .watch(membersProvider)
        .where((m) => m.isActive && m.domainId == domainId)
        .toList();
    final tasks = ref
        .watch(tasksProvider)
        .where((t) => t.domainId == domainId && !t.isDone)
        .toList();
    final events = ref
        .watch(eventsProvider)
        .where((e) => e.domainId == domainId && !e.isPast() && !e.cancelled)
        .toList();
    final notes = ref
        .watch(announcementsProvider)
        .where((n) => n.domainId == domainId)
        .toList()
      ..sort((x, y) => y.createdAt.compareTo(x.createdAt));

    Widget heading(String t) =>
        SectionHeader(t, padding: const EdgeInsets.only(bottom: Gap.sm));
    Widget gap() => const SizedBox(height: Gap.xl);

    return AppPage(
      title: domain.name,
      subtitle: domain.blurb.isEmpty ? null : domain.blurb,
      slivers: [
        PagePad(
          child: ContentWidth(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                heading('People (${members.length})'),
                Panel(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      for (final m in members)
                        ListTile(
                          leading: Avatar(m.name),
                          title: Text(m.name),
                          subtitle: Text(
                            m.roleId == DefaultRoles.domainLead
                                ? 'Domain lead'
                                : 'Member',
                          ),
                          onTap: () => context.push('/people/${m.id}'),
                        ),
                      if (members.isEmpty)
                        const ListTile(title: Text('No members yet')),
                    ],
                  ),
                ),
                gap(),
                heading('Open tasks (${tasks.length})'),
                Panel(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      for (final t in tasks.take(8))
                        ListTile(
                          title: Text(t.title),
                          subtitle: t.due == null
                              ? null
                              : Text('Due ${Fmt.dateShort(t.due!)}'),
                          onTap: () => context.push('/tasks/${t.id}'),
                        ),
                      if (tasks.isEmpty)
                        const ListTile(title: Text('Nothing open')),
                    ],
                  ),
                ),
                gap(),
                heading('Coming up (${events.length})'),
                Panel(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      for (final e in events)
                        ListTile(
                          title: Text(e.title),
                          subtitle: Text(Fmt.dateTime(e.startsAt)),
                          onTap: () => context.push('/events/${e.id}'),
                        ),
                      if (events.isEmpty)
                        const ListTile(title: Text('No events planned')),
                    ],
                  ),
                ),
                gap(),
                heading('Announcements'),
                Panel(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      for (final n in notes.take(5))
                        ListTile(
                          title: Text(n.title),
                          subtitle: Text(Fmt.ago(n.createdAt)),
                        ),
                      if (notes.isEmpty)
                        const ListTile(title: Text('None yet')),
                    ],
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

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:go_router/go_router.dart';

import '../../app/shell.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/palette.dart';
import '../../core/widgets/basics.dart';
import '../../core/widgets/page.dart';
import '../../data/derived.dart';
import '../../data/models/models.dart';
import '../../data/providers.dart';
import '../../domain/actions/work_actions.dart';
import 'task_form.dart';
import 'task_widgets.dart';

enum _Scope { mine, team }

final _scopeProvider = StateProvider<_Scope>((ref) => _Scope.mine);
final _domainFilterProvider = StateProvider<String?>((ref) => null);
final _viewProvider = StateProvider<bool>((ref) => true); // true = board
final _mobileStatusProvider = StateProvider<TaskStatus>(
  (ref) => TaskStatus.todo,
);

class TasksScreen extends ConsumerWidget {
  const TasksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final a = ref.watch(accessProvider);
    if (a == null) return const SizedBox.shrink();
    final scope = ref.watch(_scopeProvider);
    final domainFilter = ref.watch(_domainFilterProvider);
    final board = ref.watch(_viewProvider);
    final domains = ref.watch(domainMapProvider);
    final all = ref.watch(visibleTasksProvider);
    final wide = MediaQuery.sizeOf(context).width >= 700;

    var tasks = scope == _Scope.mine
        ? all.where((t) => t.assigneeIds.contains(a.me.id)).toList()
        : all;
    if (domainFilter != null) {
      tasks = tasks.where((t) => t.domainId == domainFilter).toList();
    }

    // Past completed work clutters the board: show the last two weeks of done.
    final cutoff = DateTime.now().subtract(const Duration(days: 14));
    tasks = tasks
        .where(
          (t) => !t.isDone || (t.completedAt ?? t.createdAt).isAfter(cutoff),
        )
        .toList();

    final domainsInView =
        {
            for (final t in all)
              if (t.domainId != null) t.domainId!,
          }.map((id) => domains[id]).whereType<Domain>().toList()
          ..sort((x, y) => x.name.compareTo(y.name));

    final canCreate = a.can(Permission.assignTasks);

    return AppPage(
      title: 'Tasks',
      subtitle: '${tasks.where((t) => !t.isDone).length} open',
      showBack: false,
      actions: [
        IconButton(
          tooltip: board ? 'Show as list' : 'Show as board',
          icon: Icon(
            board ? Icons.view_list_rounded : Icons.view_kanban_rounded,
          ),
          onPressed: () => ref.read(_viewProvider.notifier).state = !board,
        ),
        const TopActions(),
      ],
      floatingActionButton: canCreate
          ? FloatingActionButton.extended(
              heroTag: null,
              onPressed: () => showTaskForm(context),
              icon: const Icon(Icons.add_rounded),
              label: const Text('New task'),
            )
          : null,
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: Gap.page),
            child: Row(
              children: [
                SegmentedButton<_Scope>(
                  showSelectedIcon: false,
                  segments: const [
                    ButtonSegment(value: _Scope.mine, label: Text('Mine')),
                    ButtonSegment(value: _Scope.team, label: Text('Everyone')),
                  ],
                  selected: {scope},
                  onSelectionChanged: (s) =>
                      ref.read(_scopeProvider.notifier).state = s.first,
                ),
              ],
            ),
          ),
        ),
        if (domainsInView.length > 1)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: Gap.md),
              child: SizedBox(
                height: 40,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: Gap.page),
                  children: [
                    _Chip(
                      label: 'All domains',
                      selected: domainFilter == null,
                      onTap: () =>
                          ref.read(_domainFilterProvider.notifier).state = null,
                    ),
                    for (final d in domainsInView)
                      _Chip(
                        label: d.name,
                        selected: domainFilter == d.id,
                        onTap: () =>
                            ref.read(_domainFilterProvider.notifier).state =
                                d.id,
                      ),
                  ],
                ),
              ),
            ),
          ),
        const SliverToBoxAdapter(child: SizedBox(height: Gap.md)),
        if (tasks.isEmpty)
          SliverToBoxAdapter(
            child: EmptyState(
              icon: Icons.task_alt_rounded,
              title: scope == _Scope.mine
                  ? 'Nothing assigned to you'
                  : 'No tasks match',
              message: scope == _Scope.mine
                  ? 'When a lead assigns you something, it shows up here.'
                  : 'Try another domain, or create a task.',
              actionLabel: canCreate ? 'Create a task' : null,
              onAction: canCreate ? () => showTaskForm(context) : null,
            ),
          )
        else if (!board)
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: Gap.page),
            sliver: _ListView(tasks: tasks),
          )
        else if (wide)
          SliverToBoxAdapter(
            child: _Board(tasks: tasks, access: a),
          )
        else
          SliverToBoxAdapter(child: _CompactBoard(tasks: tasks)),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Padding(
      padding: const EdgeInsets.only(right: Gap.sm),
      child: Material(
        color: selected ? p.ink : p.surface,
        shape: StadiumBorder(
          side: BorderSide(color: selected ? p.ink : p.line),
        ),
        child: InkWell(
          customBorder: const StadiumBorder(),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Center(
              child: Text(
                label,
                style: context.text.labelMedium?.copyWith(
                  color: selected ? p.surface : p.ink,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Phones: one column at a time, switched with status tabs.
class _CompactBoard extends ConsumerWidget {
  const _CompactBoard({required this.tasks});

  final List<SocietyTask> tasks;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(_mobileStatusProvider);
    final p = context.palette;
    final list = _sorted(tasks.where((t) => t.status == status).toList());
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 44,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: Gap.page),
            children: [
              for (final s in TaskStatus.values)
                Padding(
                  padding: const EdgeInsets.only(right: Gap.lg),
                  child: InkWell(
                    onTap: () =>
                        ref.read(_mobileStatusProvider.notifier).state = s,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: s == status
                                ? statusColor(context, s)
                                : Colors.transparent,
                            width: 3,
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: statusColor(context, s),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            s.label,
                            style: context.text.labelLarge?.copyWith(
                              color: s == status ? p.ink : p.inkMuted,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${tasks.where((t) => t.status == s).length}',
                            style: context.text.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(Gap.page, Gap.md, Gap.page, 0),
          child: list.isEmpty
              ? Panel(
                  child: SizedBox(
                    width: double.infinity,
                    child: EmptyState(
                      icon: Icons.inbox_rounded,
                      title: 'Nothing ${status.label.toLowerCase()}',
                      message: 'Tasks in this stage appear here.',
                      compact: true,
                    ),
                  ),
                )
              : Column(
                  children: [
                    for (final t in list) ...[
                      TaskCard(
                        task: t,
                        onTap: () => context.push('/tasks/${t.id}'),
                      ),
                      const SizedBox(height: Gap.sm),
                    ],
                  ],
                ),
        ),
      ],
    );
  }
}

List<SocietyTask> _sorted(List<SocietyTask> l) => l
  ..sort((a, b) {
    final pr = b.priority.index.compareTo(a.priority.index) * -1;
    if (a.status != TaskStatus.done) {
      final d = (a.due ?? DateTime(2100)).compareTo(b.due ?? DateTime(2100));
      if (d != 0) return d;
    }
    return pr != 0 ? pr : a.title.compareTo(b.title);
  });

/// Tablets and desktop: all four columns side by side with drag and drop.
class _Board extends ConsumerWidget {
  const _Board({required this.tasks, required this.access});

  final List<SocietyTask> tasks;
  final dynamic access;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Gap.page),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final s in TaskStatus.values)
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  right: s == TaskStatus.done ? 0 : Gap.md,
                ),
                child: _Column(
                  status: s,
                  tasks: _sorted(tasks.where((t) => t.status == s).toList()),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _Column extends ConsumerWidget {
  const _Column({required this.status, required this.tasks});

  final TaskStatus status;
  final List<SocietyTask> tasks;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = context.palette;
    final a = ref.watch(accessProvider)!;
    return DragTarget<SocietyTask>(
      onWillAcceptWithDetails: (d) =>
          d.data.status != status && a.canMoveTask(d.data),
      onAcceptWithDetails: (d) =>
          ref.read(taskActionsProvider).move(d.data, status),
      builder: (context, candidates, _) {
        final hovering = candidates.isNotEmpty;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          padding: const EdgeInsets.all(Gap.sm),
          decoration: BoxDecoration(
            color: hovering ? p.greenTint : p.surfaceAlt.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(Radii.lg),
            border: Border.all(
              color: hovering ? p.green : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  Gap.sm,
                  Gap.sm,
                  Gap.sm,
                  Gap.md,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: statusColor(context, status),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(status.label, style: context.text.titleSmall),
                    ),
                    Text(
                      '${tasks.length}',
                      style: context.text.labelMedium?.copyWith(
                        color: p.inkMuted,
                      ),
                    ),
                  ],
                ),
              ),
              if (tasks.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: Gap.xl),
                  child: Center(
                    child: Text(
                      'Drop tasks here',
                      style: context.text.bodySmall,
                    ),
                  ),
                ),
              for (final t in tasks)
                Padding(
                  padding: const EdgeInsets.only(bottom: Gap.sm),
                  child: a.canMoveTask(t)
                      ? LongPressDraggable<SocietyTask>(
                          data: t,
                          delay: const Duration(milliseconds: 180),
                          feedback: Material(
                            color: Colors.transparent,
                            child: SizedBox(
                              width: 240,
                              child: Opacity(
                                opacity: 0.92,
                                child: TaskCard(task: t, onTap: () {}),
                              ),
                            ),
                          ),
                          childWhenDragging: Opacity(
                            opacity: 0.35,
                            child: TaskCard(task: t, onTap: () {}),
                          ),
                          child: TaskCard(
                            task: t,
                            onTap: () => context.push('/tasks/${t.id}'),
                          ),
                        )
                      : TaskCard(
                          task: t,
                          onTap: () => context.push('/tasks/${t.id}'),
                        ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _ListView extends StatelessWidget {
  const _ListView({required this.tasks});

  final List<SocietyTask> tasks;

  @override
  Widget build(BuildContext context) {
    final open = _sorted(tasks.where((t) => !t.isDone).toList());
    final done = _sorted(tasks.where((t) => t.isDone).toList());
    return SliverList.list(
      children: [
        for (final t in open) ...[
          TaskCard(
            task: t,
            showStatus: true,
            onTap: () => context.push('/tasks/${t.id}'),
          ),
          const SizedBox(height: Gap.sm),
        ],
        if (done.isNotEmpty) ...[
          const SectionHeader(
            'Done',
            padding: EdgeInsets.fromLTRB(0, Gap.xl, 0, Gap.sm),
          ),
          for (final t in done) ...[
            TaskCard(task: t, onTap: () => context.push('/tasks/${t.id}')),
            const SizedBox(height: Gap.sm),
          ],
        ],
      ],
    );
  }
}

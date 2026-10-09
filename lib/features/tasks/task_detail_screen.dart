import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
import '../../domain/actions/work_actions.dart';
import 'task_form.dart';
import 'task_widgets.dart';

class TaskDetailScreen extends ConsumerWidget {
  const TaskDetailScreen({super.key, required this.taskId});

  final String taskId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final a = ref.watch(accessProvider);
    final task = ref
        .watch(tasksProvider)
        .where((t) => t.id == taskId)
        .firstOrNull;
    if (a == null) return const SizedBox.shrink();
    if (task == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(
          child: EmptyState(
            icon: Icons.search_off_rounded,
            title: 'This task is gone',
            message: 'It may have been deleted.',
          ),
        ),
      );
    }
    final p = context.palette;
    final members = ref.watch(memberMapProvider);
    final domains = ref.watch(domainMapProvider);
    final event = ref.watch(eventMapProvider)[task.eventId];
    final canEdit = a.canEditTask(task);
    final canMove = a.canMoveTask(task);
    final actions = ref.read(taskActionsProvider);

    return AppPage(
      title: task.title,
      actions: [
        if (canEdit)
          PopupMenuButton<String>(
            tooltip: 'More',
            onSelected: (v) async {
              if (v == 'edit') {
                showTaskForm(context, task: task);
              } else if (v == 'delete') {
                final ok = await confirmDialog(
                  context,
                  title: 'Delete this task?',
                  message:
                      'It will be removed for everyone. This can’t be undone.',
                  confirmLabel: 'Delete task',
                  destructive: true,
                );
                if (ok && context.mounted) {
                  await actions.delete(task);
                  if (context.mounted) {
                    context.pop();
                    Toast.show(context, 'Task deleted');
                  }
                }
              }
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'edit', child: Text('Edit task')),
              PopupMenuItem(value: 'delete', child: Text('Delete task')),
            ],
          ),
      ],
      slivers: [
        PagePad(
          child: ContentWidth(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    Pill(
                      task.priority.label,
                      tone: priorityTone(context, task.priority),
                      icon: AppIcons.priority(task.priority),
                    ),
                    if (task.isOverdue())
                      Pill(
                        'Overdue',
                        tone: Tone.red(context),
                        icon: Icons.warning_amber_rounded,
                      ),
                    if (task.domainId != null)
                      Pill(
                        domains[task.domainId]?.name ?? '',
                        tone: Tone.neutral(context),
                      ),
                  ],
                ),
                if (task.description.isNotEmpty) ...[
                  const SizedBox(height: Gap.lg),
                  Text(task.description, style: context.text.bodyLarge),
                ],
                const SizedBox(height: Gap.xl),
                _StatusTrack(task: task, enabled: canMove),
                const SizedBox(height: Gap.xl),
                Panel(
                  child: Column(
                    children: [
                      InfoRow(
                        icon: Icons.flag_outlined,
                        label: 'Due',
                        value: task.due == null
                            ? 'No deadline'
                            : '${Fmt.weekdayDate(task.due!)} · ${Fmt.dueIn(task.due!)}',
                      ),
                      if (event != null)
                        InfoRow(
                          icon: Icons.event_rounded,
                          label: 'Event',
                          value: event.title,
                          onTap: () => context.push('/events/${event.id}'),
                        ),
                      InfoRow(
                        icon: Icons.person_outline_rounded,
                        label: 'Created by',
                        value:
                            '${memberName(members, task.createdBy)} · ${Fmt.ago(task.createdAt)}',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: Gap.lg),
                Text('Assigned to', style: context.text.titleMedium),
                const SizedBox(height: Gap.sm),
                if (task.assigneeIds.isEmpty)
                  Text(
                    'Nobody yet. Edit the task to assign someone.',
                    style: context.text.bodyMedium?.copyWith(color: p.inkMuted),
                  )
                else
                  for (final id in task.assigneeIds)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: InkWell(
                        onTap: members[id] == null
                            ? null
                            : () => context.push('/people/$id'),
                        borderRadius: BorderRadius.circular(Radii.sm),
                        child: Row(
                          children: [
                            Avatar(memberName(members, id), size: 36),
                            const SizedBox(width: Gap.md),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    memberName(members, id),
                                    style: context.text.titleSmall,
                                  ),
                                  Text(
                                    domains[members[id]?.domainId]?.name ?? '',
                                    style: context.text.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                const SizedBox(height: Gap.xl),
                Row(
                  children: [
                    Expanded(
                      child: Text('Checklist', style: context.text.titleMedium),
                    ),
                    if (task.checklist.isNotEmpty)
                      Text(
                        '${task.checklistDone}/${task.checklist.length}',
                        style: context.text.labelMedium,
                      ),
                  ],
                ),
                if (task.checklist.isNotEmpty) ...[
                  const SizedBox(height: Gap.sm),
                  ThinProgress(
                    value: task.checklistDone / task.checklist.length,
                  ),
                ],
                const SizedBox(height: Gap.sm),
                for (final item in task.checklist)
                  CheckboxListTile(
                    value: item.done,
                    contentPadding: EdgeInsets.zero,
                    controlAffinity: ListTileControlAffinity.leading,
                    onChanged: canMove
                        ? (_) => actions.toggleChecklist(task, item.id)
                        : null,
                    title: Text(
                      item.text,
                      style: context.text.bodyLarge?.copyWith(
                        decoration: item.done
                            ? TextDecoration.lineThrough
                            : null,
                        color: item.done ? p.inkMuted : null,
                      ),
                    ),
                  ),
                if (canMove) _AddStep(task: task),
                const SizedBox(height: Gap.xl),
                Text('Comments', style: context.text.titleMedium),
                const SizedBox(height: Gap.md),
                CommentsThread(
                  parent: CommentParent.task,
                  parentId: task.id,
                  subject: task.title,
                  route: '/tasks/${task.id}',
                  notifyIds: {...task.assigneeIds, task.createdBy},
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _StatusTrack extends ConsumerWidget {
  const _StatusTrack({required this.task, required this.enabled});

  final SocietyTask task;
  final bool enabled;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = context.palette;
    return Row(
      children: [
        for (final s in TaskStatus.values)
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: s == TaskStatus.done ? 0 : 6),
              child: Material(
                color: s == task.status ? statusColor(context, s) : p.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(Radii.md),
                  side: BorderSide(
                    color: s == task.status ? statusColor(context, s) : p.line,
                  ),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(Radii.md),
                  onTap: enabled && s != task.status
                      ? () => ref.read(taskActionsProvider).move(task, s)
                      : null,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 4,
                    ),
                    child: Text(
                      s.label,
                      textAlign: TextAlign.center,
                      style: context.text.labelMedium?.copyWith(
                        color: s == task.status
                            ? Colors.white
                            : (enabled ? p.ink : p.inkFaint),
                        fontWeight: s == task.status
                            ? FontWeight.w800
                            : FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _AddStep extends ConsumerStatefulWidget {
  const _AddStep({required this.task});

  final SocietyTask task;

  @override
  ConsumerState<_AddStep> createState() => _AddStepState();
}

class _AddStepState extends ConsumerState<_AddStep> {
  final _c = TextEditingController();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  void _add() {
    final t = _c.text.trim();
    if (t.isEmpty) return;
    ref.read(taskActionsProvider).addChecklistItem(widget.task, t);
    _c.clear();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _c,
      textInputAction: TextInputAction.done,
      decoration: InputDecoration(
        hintText: 'Add a step',
        suffixIcon: IconButton(
          tooltip: 'Add step',
          icon: const Icon(Icons.add_rounded),
          onPressed: _add,
        ),
      ),
      onSubmitted: (_) => _add(),
    );
  }
}

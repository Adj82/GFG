import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/palette.dart';
import '../../core/utils/format.dart';
import '../../core/widgets/basics.dart';
import '../../core/widgets/icons.dart';
import '../../data/derived.dart';
import '../../data/models/models.dart';
import '../../data/providers.dart';

Tone priorityTone(BuildContext c, TaskPriority p) => switch (p) {
  TaskPriority.high => Tone.red(c),
  TaskPriority.medium => Tone.amber(c),
  TaskPriority.low => Tone.neutral(c),
};

Color statusColor(BuildContext c, TaskStatus s) {
  final p = c.palette;
  return switch (s) {
    TaskStatus.todo => p.inkFaint,
    TaskStatus.inProgress => p.blue,
    TaskStatus.review => p.violet,
    TaskStatus.done => p.green,
  };
}

/// Task card used on the board and in lists.
class TaskCard extends ConsumerWidget {
  const TaskCard({
    super.key,
    required this.task,
    required this.onTap,
    this.showStatus = false,
  });

  final SocietyTask task;
  final VoidCallback onTap;
  final bool showStatus;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = context.palette;
    final members = ref.watch(memberMapProvider);
    final domains = ref.watch(domainMapProvider);
    final events = ref.watch(eventMapProvider);
    final overdue = task.isOverdue();
    final event = events[task.eventId];
    final names = task.assigneeIds
        .map((id) => memberName(members, id))
        .toList();

    return Panel(
      onTap: onTap,
      padding: const EdgeInsets.all(Gap14.v),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Pill(
                task.priority.label,
                tone: priorityTone(context, task.priority),
                icon: AppIcons.priority(task.priority),
                dense: true,
              ),
              if (showStatus) ...[
                const SizedBox(width: 6),
                Pill(
                  task.status.label,
                  tone: Tone(statusColor(context, task.status), p.surfaceAlt),
                  dense: true,
                ),
              ],
              const Spacer(),
              if (task.domainId != null)
                Flexible(
                  child: Text(
                    domains[task.domainId]?.name ?? '',
                    style: context.text.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            task.title,
            style: context.text.titleSmall?.copyWith(
              decoration: task.isDone ? TextDecoration.lineThrough : null,
              color: task.isDone ? p.inkMuted : null,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          if (event != null) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(Icons.event_rounded, size: 14, color: p.greenStrong),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    event.title,
                    style: context.text.bodySmall?.copyWith(
                      color: p.greenStrong,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
          if (task.checklist.isNotEmpty) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: ThinProgress(
                    value: task.checklistDone / task.checklist.length,
                    height: 4,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${task.checklistDone}/${task.checklist.length}',
                  style: context.text.bodySmall,
                ),
              ],
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              if (task.due != null) ...[
                Icon(
                  overdue
                      ? Icons.warning_amber_rounded
                      : Icons.schedule_rounded,
                  size: 15,
                  color: overdue ? p.red : p.inkFaint,
                ),
                const SizedBox(width: 4),
                Text(
                  task.isDone ? Fmt.dateShort(task.due!) : Fmt.dueIn(task.due!),
                  style: context.text.bodySmall?.copyWith(
                    color: overdue ? p.red : null,
                    fontWeight: overdue ? FontWeight.w700 : null,
                  ),
                ),
              ],
              const Spacer(),
              AvatarStack(names, size: 24, max: 3),
            ],
          ),
        ],
      ),
    );
  }
}

/// Padding constants local to cards.
abstract final class Gap14 {
  static const v = 14.0;
}

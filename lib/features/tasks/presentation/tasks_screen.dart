import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/premium_header.dart';
import '../domain/models/task.dart';
import 'tasks_notifier.dart';
import 'widgets/create_task_sheet.dart';
import '../../../core/services/permissions_service.dart';

class TasksScreen extends ConsumerWidget {
  const TasksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canAssign = ref.watch(permissionsServiceProvider).canAssignDomainTasks || 
                     ref.watch(permissionsServiceProvider).canAssignGlobalTasks;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            PremiumHeader(
              title: 'Project Hub',
              subtitle: 'Track tasks and society workflows',
              expandedHeight: 150,
              bottom: Container(
                margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: TabBar(
                  dividerHeight: 0, // Removed the odd underline
                  indicator: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  labelColor: isDark ? AppColors.midnightGreen : AppColors.primaryGreen,
                  unselectedLabelColor: Colors.white70,
                  indicatorSize: TabBarIndicatorSize.tab,
                  labelStyle: GoogleFonts.inter(fontWeight: FontWeight.w900, fontSize: 11),
                  tabs: const [
                    Tab(text: 'PENDING'),
                    Tab(text: 'ACTIVE'),
                    Tab(text: 'DONE'),
                  ],
                ),
              ),
            ),
          ],
          body: const TabBarView(
            children: [
              TaskColumn(status: TaskStatus.pending),
              TaskColumn(status: TaskStatus.inProgress),
              TaskColumn(status: TaskStatus.completed),
            ],
          ),
        ),
        floatingActionButton: canAssign ? Container(
          decoration: BoxDecoration(
            gradient: AppColors.getButtonGradient(isDark),
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: (isDark ? Colors.black : AppColors.primaryGreen).withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 6),
              )
            ],
          ),
          child: FloatingActionButton.extended(
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) => const CreateTaskSheet(),
              );
            },
            backgroundColor: Colors.transparent, // Using container gradient
            elevation: 0,
            icon: const Icon(Icons.add_rounded, color: Colors.white, size: 24),
            label: Text(
              'NEW TASK',
              style: GoogleFonts.inter(fontWeight: FontWeight.w900, letterSpacing: 1, color: Colors.white, fontSize: 12),
            ),
          ),
        ) : null,
      ),
    );
  }
}

class TaskColumn extends ConsumerWidget {
  final TaskStatus status;
  const TaskColumn({super.key, required this.status});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasks = ref.watch(filteredTasksProvider(status));
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (tasks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white, 
                shape: BoxShape.circle
              ),
              child: const Icon(Icons.assignment_turned_in_rounded, size: 60, color: AppColors.lightGrey),
            ),
            const SizedBox(height: 24),
            Text(
              'Workspace is Clear',
              style: GoogleFonts.plusJakartaSans(color: AppColors.mediumGrey, fontWeight: FontWeight.w700, fontSize: 16),
            ),
            Text(
              'No ${status.name} tasks found.',
              style: GoogleFonts.inter(color: AppColors.mediumGrey, fontSize: 13),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
      physics: const BouncingScrollPhysics(),
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        return _buildModernTaskCard(context, ref, task);
      },
    );
  }

  Widget _buildModernTaskCard(BuildContext context, WidgetRef ref, SocietyTask task) {
    final priorityColor = _getPriorityColor(task.priority);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.02), 
            blurRadius: 15, 
            offset: const Offset(0, 8)
          )
        ],
        border: Border.all(color: isDark ? Colors.white10 : Colors.grey[100]!),
      ),
      child: InkWell(
        onTap: () => _showTaskActions(context, ref, task),
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: priorityColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      task.priority.name.toUpperCase(),
                      style: GoogleFonts.inter(
                        color: priorityColor,
                        fontWeight: FontWeight.w800,
                        fontSize: 10,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  Icon(Icons.more_horiz_rounded, color: Colors.grey[400]),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                task.title,
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w800, 
                  fontSize: 18, 
                  color: isDark ? Colors.white : AppColors.ink,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                task.description,
                style: GoogleFonts.inter(
                  color: isDark ? Colors.white70 : AppColors.mediumGrey,
                  fontSize: 14,
                  height: 1.5,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 24),
              Divider(color: isDark ? Colors.white10 : null),
              const SizedBox(height: 16),
              Row(
                children: [
                  CircleAvatar(
                    radius: 14,
                    backgroundColor: AppColors.primaryGreen.withValues(alpha: 0.1),
                    child: const Icon(Icons.person_rounded, size: 16, color: AppColors.primaryGreen),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Dev: ${task.assigneeId.split('-').last}',
                      style: GoogleFonts.inter(fontSize: 12, color: isDark ? Colors.white : AppColors.ink, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white10 : AppColors.softGrey, 
                      borderRadius: BorderRadius.circular(8)
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_month_rounded, size: 12, color: AppColors.mediumGrey),
                        const SizedBox(width: 6),
                        Text(
                          '${task.deadline.day}/${task.deadline.month}',
                          style: GoogleFonts.inter(fontSize: 11, color: isDark ? Colors.white70 : AppColors.ink, fontWeight: FontWeight.w900),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showTaskActions(BuildContext context, WidgetRef ref, SocietyTask task) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor, 
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32))
        ),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Task Commands',
                style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w900, fontSize: 20),
              ),
              const SizedBox(height: 32),
              ...TaskStatus.values.where((s) => s != task.status).map((s) => ListTile(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                leading: Icon(
                  s == TaskStatus.completed ? Icons.verified_rounded : Icons.sync_rounded,
                  color: s == TaskStatus.completed ? AppColors.success : AppColors.info,
                ),
                title: Text('Transition to ${s.name.toUpperCase()}', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 14)),
                onTap: () {
                  ref.read(tasksProvider.notifier).updateTaskStatus(task.id, s);
                  Navigator.pop(context);
                },
              )),
              ListTile(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                leading: const Icon(Icons.delete_sweep_rounded, color: AppColors.error),
                title: Text('PURGE TASK', style: GoogleFonts.inter(color: AppColors.error, fontWeight: FontWeight.bold, fontSize: 14)),
                onTap: () {
                  ref.read(tasksProvider.notifier).deleteTask(task.id);
                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Color _getPriorityColor(TaskPriority p) {
    switch (p) {
      case TaskPriority.high: return AppColors.priorityHigh;
      case TaskPriority.medium: return AppColors.priorityMedium;
      case TaskPriority.low: return AppColors.priorityLow;
    }
  }
}

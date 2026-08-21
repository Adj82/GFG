import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/mock/mock_data.dart';
import '../../domain/models/task.dart';
import '../tasks_notifier.dart';
import '../../../auth/presentation/auth_state_provider.dart';

class CreateTaskSheet extends ConsumerStatefulWidget {
  const CreateTaskSheet({super.key});

  @override
  ConsumerState<CreateTaskSheet> createState() => _CreateTaskSheetState();
}

class _CreateTaskSheetState extends ConsumerState<CreateTaskSheet> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  TaskPriority _priority = TaskPriority.medium;
  String? _selectedDomain;

  @override
  void initState() {
    super.initState();
    _selectedDomain = MockData.domains.first.id;
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Assign New Task',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 22, 
                fontWeight: FontWeight.bold, 
                color: isDark ? Colors.white : AppColors.ink
              ),
            ),
            const SizedBox(height: 32),
            _buildField(context, _titleController, 'Task Title', isDark),
            const SizedBox(height: 16),
            _buildField(context, _descriptionController, 'Requirements', isDark, maxLines: 3),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              dropdownColor: isDark ? AppColors.darkSurface : Colors.white,
              initialValue: _selectedDomain,
              style: GoogleFonts.inter(color: isDark ? Colors.white : AppColors.ink),
              decoration: InputDecoration(
                labelText: 'Target Domain',
                labelStyle: GoogleFonts.inter(color: AppColors.mediumGrey),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                filled: true,
                fillColor: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey[50],
              ),
              items: MockData.domains.map((d) => DropdownMenuItem(value: d.id, child: Text(d.name))).toList(),
              onChanged: (val) => setState(() => _selectedDomain = val),
            ),
            const SizedBox(height: 24),
            Text(
              'Set Priority',
              style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.mediumGrey),
            ),
            const SizedBox(height: 12),
            Row(
              children: TaskPriority.values.map((p) => Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: InkWell(
                    onTap: () => setState(() => _priority = p),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: _priority == p ? _getPriorityColor(p).withValues(alpha: 0.1) : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _priority == p ? _getPriorityColor(p) : (isDark ? Colors.white12 : Colors.grey[300]!),
                          width: 1.5,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          p.name.toUpperCase(),
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: _priority == p ? _getPriorityColor(p) : AppColors.mediumGrey,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              )).toList(),
            ),
            const SizedBox(height: 40),
            Container(
              decoration: BoxDecoration(
                gradient: AppColors.getButtonGradient(isDark),
                borderRadius: BorderRadius.circular(16),
              ),
              child: ElevatedButton(
                onPressed: () {
                  if (_titleController.text.isNotEmpty && currentUser != null) {
                    final task = SocietyTask(
                      id: const Uuid().v4(),
                      orgId: MockData.orgId,
                      domainId: _selectedDomain!,
                      title: _titleController.text,
                      description: _descriptionController.text,
                      assigneeId: ' Rahul (Mock)', 
                      deadline: DateTime.now().add(const Duration(days: 7)),
                      priority: _priority,
                      status: TaskStatus.pending,
                      createdBy: currentUser.uid,
                      createdAt: DateTime.now(),
                    );
                    ref.read(tasksProvider.notifier).addTask(task);
                    Navigator.pop(context);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: Text(
                  'INITIALIZE TASK',
                  style: GoogleFonts.inter(fontWeight: FontWeight.bold, letterSpacing: 1),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(BuildContext context, TextEditingController controller, String label, bool isDark, {int maxLines = 1}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: GoogleFonts.inter(color: isDark ? Colors.white : AppColors.ink),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.inter(color: AppColors.mediumGrey),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
        filled: true,
        fillColor: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey[50],
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

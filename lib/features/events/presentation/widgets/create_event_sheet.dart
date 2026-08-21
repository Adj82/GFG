import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/mock/mock_data.dart';
import '../../domain/models/event.dart';
import '../events_notifier.dart';
import '../../../auth/presentation/auth_state_provider.dart';

class CreateEventSheet extends ConsumerStatefulWidget {
  const CreateEventSheet({super.key});

  @override
  ConsumerState<CreateEventSheet> createState() => _CreateEventSheetState();
}

class _CreateEventSheetState extends ConsumerState<CreateEventSheet> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _venueController = TextEditingController();
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
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
              'Schedule Event',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 22, 
                fontWeight: FontWeight.bold, 
                color: isDark ? Colors.white : AppColors.ink
              ),
            ),
            const SizedBox(height: 32),
            _buildField(context, _titleController, 'Event Name', Icons.event_note_rounded, isDark),
            const SizedBox(height: 16),
            _buildField(context, _descriptionController, 'Agenda / Description', null, isDark, maxLines: 3),
            const SizedBox(height: 16),
            _buildField(context, _venueController, 'Venue / Link', Icons.location_on_rounded, isDark),
            const SizedBox(height: 24),
            Container(
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey[50],
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: isDark ? Colors.white12 : Colors.grey[200]!),
              ),
              child: ListTile(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                leading: const Icon(Icons.calendar_month_rounded, color: AppColors.primaryGreen),
                title: Text(
                  'Event Date',
                  style: GoogleFonts.inter(fontSize: 12, color: AppColors.mediumGrey, fontWeight: FontWeight.w500),
                ),
                subtitle: Text(
                  '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                  style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.ink),
                ),
                trailing: const Icon(Icons.edit_calendar_rounded, size: 20),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                    builder: (context, child) {
                      return Theme(
                        data: Theme.of(context).copyWith(
                          colorScheme: ColorScheme.light(
                            primary: AppColors.primaryGreen,
                            onPrimary: Colors.white,
                            onSurface: isDark ? Colors.white : AppColors.ink,
                            surface: isDark ? AppColors.darkSurface : Colors.white,
                          ),
                        ),
                        child: child!,
                      );
                    },
                  );
                  if (picked != null) setState(() => _selectedDate = picked);
                },
              ),
            ),
            const SizedBox(height: 40),
            Container(
              decoration: BoxDecoration(
                gradient: AppColors.getButtonGradient(isDark),
                borderRadius: BorderRadius.circular(16),
              ),
              child: ElevatedButton(
                onPressed: () {
                  if (_titleController.text.isNotEmpty && user != null) {
                    final event = SocietyEvent(
                      id: const Uuid().v4(),
                      orgId: MockData.orgId,
                      title: _titleController.text,
                      description: _descriptionController.text,
                      venue: _venueController.text,
                      date: _selectedDate,
                      createdBy: user.uid,
                      createdAt: DateTime.now(),
                    );
                    ref.read(eventsProvider.notifier).addEvent(event);
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
                  'LAUNCH EVENT',
                  style: GoogleFonts.inter(fontWeight: FontWeight.bold, letterSpacing: 1),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(BuildContext context, TextEditingController controller, String label, IconData? icon, bool isDark, {int maxLines = 1}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: GoogleFonts.inter(color: isDark ? Colors.white : AppColors.ink),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.inter(color: AppColors.mediumGrey),
        prefixIcon: icon != null ? Icon(icon, size: 18) : null,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
        filled: true,
        fillColor: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey[50],
      ),
    );
  }
}

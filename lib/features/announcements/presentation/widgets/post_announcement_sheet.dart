import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/mock/mock_data.dart';
import '../../domain/models/announcement.dart';
import '../announcements_notifier.dart';
import '../../../auth/presentation/auth_state_provider.dart';
import '../../../../core/services/permissions_service.dart';

class PostAnnouncementSheet extends ConsumerStatefulWidget {
  const PostAnnouncementSheet({super.key});

  @override
  ConsumerState<PostAnnouncementSheet> createState() => _PostAnnouncementSheetState();
}

class _PostAnnouncementSheetState extends ConsumerState<PostAnnouncementSheet> {
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  String? _selectedDomain;

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider);
    final permissions = ref.watch(permissionsServiceProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final canPostGlobal = permissions.canPostGlobalAnnouncement;
    final canPostDomain = permissions.canPostDomainAnnouncement;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: SingleChildScrollView(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          left: 32,
          right: 32,
          top: 32,
        ),
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
              'Post Announcement',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 22, 
                fontWeight: FontWeight.bold, 
                color: isDark ? Colors.white : AppColors.ink
              ),
            ),
            const SizedBox(height: 32),
            _buildField(context, _titleController, 'Title', isDark),
            const SizedBox(height: 16),
            _buildField(context, _bodyController, 'Body Content', isDark, maxLines: 4),
            const SizedBox(height: 16),
            DropdownButtonFormField<String?>(
              dropdownColor: isDark ? AppColors.darkSurface : Colors.white,
              initialValue: _selectedDomain,
              style: GoogleFonts.inter(color: isDark ? Colors.white : AppColors.ink),
              decoration: InputDecoration(
                labelText: 'Target Audience',
                labelStyle: GoogleFonts.inter(color: AppColors.mediumGrey),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                filled: true,
                fillColor: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey[50],
              ),
              items: [
                if (canPostGlobal) const DropdownMenuItem(value: null, child: Text('Global (All Members)')),
                if (canPostDomain) ...MockData.domains.map((d) => DropdownMenuItem(value: d.id, child: Text('${d.name} Domain'))),
              ],
              onChanged: (val) => setState(() => _selectedDomain = val),
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
                    final announcement = Announcement(
                      id: const Uuid().v4(),
                      orgId: MockData.orgId,
                      domainId: _selectedDomain,
                      title: _titleController.text,
                      body: _bodyController.text,
                      postedBy: currentUser.name,
                      createdAt: DateTime.now(),
                    );
                    ref.read(announcementsProvider.notifier).postAnnouncement(announcement);
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
                  'POST ALERT',
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
}

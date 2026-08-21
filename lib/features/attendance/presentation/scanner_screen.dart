import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../domain/models/attendance.dart';
import 'attendance_notifier.dart';
import '../../auth/presentation/auth_state_provider.dart';
import '../../../core/mock/mock_data.dart';
import 'package:uuid/uuid.dart';

class ScannerScreen extends ConsumerWidget {
  final String? eventId;
  const ScannerScreen({super.key, this.eventId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      backgroundColor: AppColors.ink,
      appBar: AppBar(
        title: Text('Scan Event QR', style: GoogleFonts.plusJakartaSans(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          MobileScanner(
            onDetect: (capture) {
              final List<Barcode> barcodes = capture.barcodes;
              for (final barcode in barcodes) {
                if (barcode.rawValue != null) {
                  _processScan(context, ref, barcode.rawValue!, user);
                }
              }
            },
          ),
          // Scanner Overlay
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 260,
                  height: 260,
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.primaryGreen, width: 3),
                    borderRadius: BorderRadius.circular(32),
                  ),
                ),
                const SizedBox(height: 32),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Position the QR code within the frame',
                    style: GoogleFonts.inter(color: Colors.white70, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 60,
            left: 24,
            right: 24,
            child: ElevatedButton.icon(
              onPressed: () => _processScan(context, ref, 'event_checkin:${eventId ?? "mock-event"}', user),
              icon: const Icon(Icons.flash_on_rounded),
              label: Text('SIMULATE SCAN (DEBUG)', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _processScan(BuildContext context, WidgetRef ref, String data, dynamic user) {
    if (data.startsWith('event_checkin:')) {
      final id = data.split(':')[1];
      
      final record = AttendanceRecord(
        id: const Uuid().v4(),
        orgId: MockData.orgId,
        eventId: id,
        userId: user!.uid,
        userName: user.name,
        timestamp: DateTime.now(),
        markedBy: 'Self (QR Scan)',
      );
      
      ref.read(attendanceProvider.notifier).markAttendance(record);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Attendance Marked for Event: $id', style: const TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pop(context);
    }
  }
}

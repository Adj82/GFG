import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/models/attendance.dart';
import '../../../core/persistence/local_storage_service.dart';
import '../../../main.dart';

class AttendanceNotifier extends StateNotifier<List<AttendanceRecord>> {
  final LocalStorageService _storage;
  static const String _storageKey = 'society_attendance';

  AttendanceNotifier(this._storage) : super([]) {
    _loadAttendance();
  }

  void _loadAttendance() {
    final data = _storage.getData(_storageKey);
    if (data != null) {
      final List<dynamic> list = data;
      state = list.map((e) => AttendanceRecord.fromJson(e)).toList();
    }
  }

  void _saveAttendance() {
    _storage.saveData(_storageKey, state.map((e) => e.toJson()).toList());
  }

  void markAttendance(AttendanceRecord record) {
    // Prevent double marking
    if (state.any((r) => r.eventId == record.eventId && r.userId == record.userId)) return;
    
    state = [...state, record];
    _saveAttendance();
  }

  List<AttendanceRecord> getAttendanceForEvent(String eventId) {
    return state.where((r) => r.eventId == eventId).toList();
  }
}

final attendanceProvider = StateNotifierProvider<AttendanceNotifier, List<AttendanceRecord>>((ref) {
  final storage = ref.watch(localStorageServiceProvider);
  return AttendanceNotifier(storage);
});

final eventAttendanceProvider = Provider.family<List<AttendanceRecord>, String>((ref, eventId) {
  return ref.watch(attendanceProvider).where((r) => r.eventId == eventId).toList();
});

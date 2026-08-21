import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/mock/mock_data.dart';
import '../domain/models/announcement.dart';
import '../../../core/persistence/local_storage_service.dart';
import '../../../main.dart';

class AnnouncementsNotifier extends StateNotifier<List<Announcement>> {
  final LocalStorageService _storage;
  static const String _storageKey = 'society_announcements';

  AnnouncementsNotifier(this._storage) : super([]) {
    _loadAnnouncements();
  }

  void _loadAnnouncements() {
    final data = _storage.getData(_storageKey);
    if (data != null) {
      final List<dynamic> list = data;
      state = list.map((e) => Announcement.fromJson(e)).toList();
    } else {
      state = MockData.initialAnnouncements;
      _saveAnnouncements();
    }
  }

  void _saveAnnouncements() {
    _storage.saveData(_storageKey, state.map((e) => e.toJson()).toList());
  }

  void postAnnouncement(Announcement announcement) {
    state = [announcement, ...state];
    _saveAnnouncements();
  }

  void deleteAnnouncement(String id) {
    state = state.where((a) => a.id != id).toList();
    _saveAnnouncements();
  }
}

final announcementsProvider = StateNotifierProvider<AnnouncementsNotifier, List<Announcement>>((ref) {
  final storage = ref.watch(localStorageServiceProvider);
  return AnnouncementsNotifier(storage);
});

final filteredAnnouncementsProvider = Provider.family<List<Announcement>, String?>((ref, domainId) {
  final all = ref.watch(announcementsProvider);
  return all.where((a) => a.domainId == null || a.domainId == domainId).toList();
});

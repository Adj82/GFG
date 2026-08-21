import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/models/event.dart';
import '../../../core/persistence/local_storage_service.dart';
import '../../../main.dart';
import '../../../core/mock/mock_data.dart';
import 'package:uuid/uuid.dart';

class EventsNotifier extends StateNotifier<List<SocietyEvent>> {
  final LocalStorageService _storage;
  static const String _storageKey = 'society_events';

  EventsNotifier(this._storage) : super([]) {
    _loadEvents();
  }

  void _loadEvents() {
    final data = _storage.getData(_storageKey);
    if (data != null) {
      final List<dynamic> list = data;
      state = list.map((e) => SocietyEvent.fromJson(e)).toList();
    } else {
      // Seed with initial mock events
      state = [
        SocietyEvent(
          id: const Uuid().v4(),
          orgId: MockData.orgId,
          title: 'GFG Orientation 2026',
          description: 'Official orientation for the new batch.',
          venue: 'Audi-1',
          date: DateTime.now().add(const Duration(days: 5)),
          createdBy: 'user-pres',
          createdAt: DateTime.now(),
        ),
        SocietyEvent(
          id: const Uuid().v4(),
          orgId: MockData.orgId,
          domainId: 'dom-tech',
          title: 'Flutter Workshop',
          description: 'Hands-on session on Flutter basics.',
          venue: 'Lab-4',
          date: DateTime.now().add(const Duration(days: 10)),
          createdBy: 'user-lead',
          createdAt: DateTime.now(),
        ),
      ];
      _saveEvents();
    }
  }

  void _saveEvents() {
    _storage.saveData(_storageKey, state.map((e) => e.toJson()).toList());
  }

  void addEvent(SocietyEvent event) {
    state = [...state, event];
    _saveEvents();
  }

  void toggleRsvp(String eventId, String userId) {
    state = [
      for (final event in state)
        if (event.id == eventId)
          event.copyWith(
            rsvpUserIds: event.rsvpUserIds.contains(userId)
                ? event.rsvpUserIds.where((id) => id != userId).toList()
                : [...event.rsvpUserIds, userId],
          )
        else
          event
    ];
    _saveEvents();
  }

  void deleteEvent(String id) {
    state = state.where((e) => e.id != id).toList();
    _saveEvents();
  }
}

final eventsProvider = StateNotifierProvider<EventsNotifier, List<SocietyEvent>>((ref) {
  final storage = ref.watch(localStorageServiceProvider);
  return EventsNotifier(storage);
});

final upcomingEventsProvider = Provider<List<SocietyEvent>>((ref) {
  final all = ref.watch(eventsProvider);
  return all.where((e) => e.date.isAfter(DateTime.now())).toList()
    ..sort((a, b) => a.date.compareTo(b.date));
});

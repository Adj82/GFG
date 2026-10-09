import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/models.dart';
import '../../data/providers.dart';
import '../registration_rules.dart';
import 'base.dart';

/// Events a non-member may see: public, not cancelled, soonest first.
final publicEventsProvider = Provider<List<SocietyEvent>>((ref) {
  return ref
      .watch(eventsProvider)
      .where((e) => e.isPublic && !e.cancelled)
      .toList()
    ..sort((a, b) => a.startsAt.compareTo(b.startsAt));
});

final eventRegistrationsProvider =
    Provider.family<List<EventRegistration>, String>(
      (ref, eventId) =>
          ref
              .watch(registrationsProvider)
              .where((r) => r.eventId == eventId)
              .toList()
            ..sort((a, b) => a.createdAt.compareTo(b.createdAt)),
    );

/// The visitor on this device, remembered so they don't retype their details.
class GuestProfileController extends Notifier<GuestProfile?> {
  static const _key = 'guest.profile';

  @override
  GuestProfile? build() {
    final raw = ref.read(localStoreProvider).setting(_key);
    if (raw == null || raw.isEmpty) return null;
    try {
      return GuestProfile.fromJson(
        Map<String, dynamic>.from(jsonDecode(raw) as Map),
      );
    } catch (_) {
      return null;
    }
  }

  void save(GuestProfile p) {
    state = p;
    ref.read(localStoreProvider).setSetting(_key, jsonEncode(p.toJson()));
  }
}

final guestProfileProvider =
    NotifierProvider<GuestProfileController, GuestProfile?>(
      GuestProfileController.new,
    );

/// This visitor's registration for an event, matched by email.
final myRegistrationProvider = Provider.family<EventRegistration?, String>((
  ref,
  eventId,
) {
  final me = ref.watch(guestProfileProvider);
  if (me == null) return null;
  final id = EventRegistration.idFor(eventId, me.email);
  for (final r in ref.watch(eventRegistrationsProvider(eventId))) {
    if (r.id == id) return r;
  }
  return null;
});

final guestActionsProvider = Provider((ref) => GuestActions(ref));

class GuestActions extends ActionsBase {
  GuestActions(super.ref);

  /// Takes a seat. Re-registering with the same email updates the details
  /// instead of taking a second seat.
  Future<EventRegistration> register(
    SocietyEvent event,
    GuestProfile who,
  ) async {
    final id = EventRegistration.idFor(event.id, who.email);
    final regs = ref.read(eventRegistrationsProvider(event.id));
    final existing = regs.where((r) => r.id == id).firstOrNull;
    final block = RegistrationRules.blockFor(
      event,
      guestCount: regs.length,
      alreadyRegistered: existing != null,
      now: now,
    );
    if (block != null) throw StateError(block.message);

    final reg = EventRegistration(
      id: id,
      eventId: event.id,
      name: who.name.trim(),
      email: who.email.trim().toLowerCase(),
      rollNo: who.rollNo.trim(),
      college: who.college.trim(),
      createdAt: existing?.createdAt ?? now,
    );
    await ref.read(registrationRepo).save(reg);
    ref.read(guestProfileProvider.notifier).save(who);
    return reg;
  }

  Future<void> cancel(EventRegistration reg) =>
      ref.read(registrationRepo).delete(reg.id);
}

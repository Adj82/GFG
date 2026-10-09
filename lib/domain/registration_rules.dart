import 'dart:math';

import '../data/models/models.dart';

/// Why a visitor can't take a seat right now.
enum RegistrationBlock {
  cancelled('This event was cancelled.'),
  ended('This event has already ended.'),
  closed('This event is for chapter members only.'),
  full('All seats are taken.');

  const RegistrationBlock(this.message);
  final String message;
}

/// Seat rules for public events. Members RSVP and guests register; both draw
/// from the same capacity.
///
/// Backend: enforce [blockFor] again inside the registration Cloud Function
/// (in a transaction) so two people can't take the last seat.
abstract final class RegistrationRules {
  static int taken(SocietyEvent e, int guestCount) =>
      e.rsvpIds.length + guestCount;

  /// Null means unlimited.
  static int? spotsLeft(SocietyEvent e, int guestCount) =>
      e.capacity == null ? null : max(0, e.capacity! - taken(e, guestCount));

  static RegistrationBlock? blockFor(
    SocietyEvent e, {
    required int guestCount,
    required bool alreadyRegistered,
    DateTime? now,
  }) {
    if (e.cancelled) return RegistrationBlock.cancelled;
    if (e.isPast(now)) return RegistrationBlock.ended;
    if (!e.isPublic) return RegistrationBlock.closed;
    if (alreadyRegistered) return null;
    final left = spotsLeft(e, guestCount);
    if (left != null && left == 0) return RegistrationBlock.full;
    return null;
  }

  static String? validateName(String? v) {
    final t = (v ?? '').trim();
    if (t.isEmpty) return 'Tell us your name.';
    if (t.length < 2) return 'That looks too short.';
    return null;
  }

  static String? validateEmail(String? v) {
    final t = (v ?? '').trim();
    if (t.isEmpty) return 'Enter your email.';
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(t)) {
      return 'That doesn’t look like an email address.';
    }
    return null;
  }

  /// Checks a team before it is saved. Null means fine. Solo events ignore
  /// the team fields.
  static String? validateTeam(
    SocietyEvent e, {
    required String leaderEmail,
    required String teamName,
    required List<TeamMember> members,
  }) {
    if (!e.isTeam) return null;
    if (teamName.trim().isEmpty) return 'Give your team a name.';
    final size = 1 + members.length;
    if (size < e.teamMin) {
      final need = e.teamMin - 1;
      return 'This event needs at least ${e.teamMin} people. Add $need ${need == 1 ? 'teammate' : 'teammates'}.';
    }
    if (size > e.teamMax) {
      return 'Teams can have at most ${e.teamMax} people.';
    }
    final seen = <String>{leaderEmail.trim().toLowerCase()};
    for (final m in members) {
      final bad = validateName(m.name) ?? validateEmail(m.email);
      if (bad != null) return 'Teammate details: $bad';
      if (!seen.add(m.email.trim().toLowerCase())) {
        return '${m.email.trim()} is listed twice in your team.';
      }
    }
    return null;
  }

  /// Anyone already on a different registration for the same event, so one
  /// person can't hold two places.
  static String? conflictFor(
    Iterable<EventRegistration> others,
    EventRegistration reg,
  ) {
    for (final o in others) {
      if (o.id == reg.id) continue;
      for (final e in reg.emails) {
        if (o.includes(e)) {
          return '$e is already registered for this event${o.isTeam ? ' with another team' : ''}.';
        }
      }
    }
    return null;
  }
}

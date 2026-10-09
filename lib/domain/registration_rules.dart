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
}

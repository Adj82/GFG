import 'dart:convert';

import 'package:crypto/crypto.dart';

import 'json.dart';

/// A non-member signing up for a public event.
///
/// Guests have no account. They are identified by the email they register
/// with, so the id is deterministic and the same person can't take two seats.
/// Backend: create-only for the public, readable by members who manage events
/// (see firestore.rules).
class EventRegistration implements Entity {
  const EventRegistration({
    required this.id,
    required this.eventId,
    required this.name,
    required this.email,
    required this.createdAt,
    this.rollNo = '',
    this.college = '',
  });

  @override
  final String id;
  final String eventId;
  final String name;
  final String email;
  final String rollNo;
  final String college;
  final DateTime createdAt;

  static String idFor(String eventId, String email) =>
      'reg_${eventId}_${email.trim().toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '_')}';

  /// Short reference the guest can quote at the door.
  String get reference =>
      sha1.convert(utf8.encode(id)).toString().substring(0, 6).toUpperCase();

  factory EventRegistration.fromJson(Json j) => EventRegistration(
    id: j['id'] as String,
    eventId: j['eventId'] as String,
    name: j['name'] as String,
    email: j['email'] as String,
    rollNo: j['rollNo'] as String? ?? '',
    college: j['college'] as String? ?? '',
    createdAt: readDate(j['createdAt']),
  );

  @override
  Json toJson() => {
    'id': id,
    'eventId': eventId,
    'name': name,
    'email': email,
    'rollNo': rollNo,
    'college': college,
    'createdAt': writeDate(createdAt),
  };
}

/// Who this device's visitor is, so the second registration is one tap.
/// Device-only; never synced.
class GuestProfile {
  const GuestProfile({
    required this.name,
    required this.email,
    this.rollNo = '',
    this.college = 'KIIT',
  });

  final String name;
  final String email;
  final String rollNo;
  final String college;

  factory GuestProfile.fromJson(Json j) => GuestProfile(
    name: j['name'] as String? ?? '',
    email: j['email'] as String? ?? '',
    rollNo: j['rollNo'] as String? ?? '',
    college: j['college'] as String? ?? 'KIIT',
  );

  Json toJson() => {
    'name': name,
    'email': email,
    'rollNo': rollNo,
    'college': college,
  };
}

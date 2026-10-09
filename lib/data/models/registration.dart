import 'dart:convert';

import 'package:crypto/crypto.dart';

import 'json.dart';

/// One teammate on a team registration. Not a member and not signed in.
class TeamMember {
  const TeamMember({required this.name, required this.email, this.rollNo = ''});

  final String name;
  final String email;
  final String rollNo;

  factory TeamMember.fromJson(Json j) => TeamMember(
    name: j['name'] as String? ?? '',
    email: j['email'] as String? ?? '',
    rollNo: j['rollNo'] as String? ?? '',
  );

  Json toJson() => {'name': name, 'email': email, 'rollNo': rollNo};
}

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
    this.teamName = '',
    this.members = const [],
  });

  @override
  final String id;
  final String eventId;
  final String name;
  final String email;
  final String rollNo;
  final String college;
  final DateTime createdAt;

  /// Empty for solo events. For teams, the person above is the leader.
  final String teamName;
  final List<TeamMember> members;

  bool get isTeam => members.isNotEmpty || teamName.isNotEmpty;

  /// People on this registration, leader included.
  int get size => 1 + members.length;

  /// Every email on the registration, lowercase.
  List<String> get emails => [
    email.toLowerCase(),
    for (final m in members) m.email.toLowerCase(),
  ];

  bool includes(String e) => emails.contains(e.trim().toLowerCase());

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
    teamName: j['teamName'] as String? ?? '',
    members: readList(j['members'], TeamMember.fromJson),
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
    'teamName': teamName,
    'members': [for (final m in members) m.toJson()],
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

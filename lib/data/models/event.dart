import 'json.dart';

enum EventType {
  workshop('Workshop'),
  hackathon('Hackathon'),
  contest('Coding contest'),
  talk('Talk'),
  bootcamp('Bootcamp'),
  meetup('Meetup'),
  orientation('Orientation');

  const EventType(this.label);
  final String label;
}

/// An event is a workspace (doc §5): tasks, budget, attendance and comments
/// all hang off it by `eventId`.
class SocietyEvent implements Entity {
  const SocietyEvent({
    required this.id,
    required this.title,
    required this.type,
    required this.startsAt,
    required this.endsAt,
    required this.venue,
    required this.createdBy,
    required this.createdAt,
    required this.checkInSecret,
    this.description = '',
    this.domainId,
    this.organizerIds = const [],
    this.budget = 0,
    this.capacity,
    this.rsvpIds = const [],
    this.checkInOpen = false,
    this.cancelled = false,
    this.outcome = '',
  });

  @override
  final String id;
  final String title;
  final EventType type;
  final String description;
  final DateTime startsAt;
  final DateTime endsAt;
  final String venue;

  /// Null = whole-society event.
  final String? domainId;
  final List<String> organizerIds;

  /// Allocated budget in rupees.
  final double budget;
  final int? capacity;
  final List<String> rsvpIds;

  /// Seed for rotating check-in codes.
  /// Backend: keep this server-side and verify codes in a Cloud Function.
  final String checkInSecret;
  final bool checkInOpen;
  final bool cancelled;

  /// Short write-up after the event, used in the term report.
  final String outcome;
  final String createdBy;
  final DateTime createdAt;

  bool isPast([DateTime? now]) => endsAt.isBefore(now ?? DateTime.now());
  bool isLive([DateTime? now]) {
    final n = now ?? DateTime.now();
    return !cancelled && startsAt.isBefore(n) && endsAt.isAfter(n);
  }

  SocietyEvent copyWith({
    String? title,
    EventType? type,
    String? description,
    DateTime? startsAt,
    DateTime? endsAt,
    String? venue,
    Object? domainId = unset,
    List<String>? organizerIds,
    double? budget,
    Object? capacity = unset,
    List<String>? rsvpIds,
    bool? checkInOpen,
    bool? cancelled,
    String? outcome,
  }) => SocietyEvent(
    id: id,
    title: title ?? this.title,
    type: type ?? this.type,
    description: description ?? this.description,
    startsAt: startsAt ?? this.startsAt,
    endsAt: endsAt ?? this.endsAt,
    venue: venue ?? this.venue,
    domainId: identical(domainId, unset) ? this.domainId : domainId as String?,
    organizerIds: organizerIds ?? this.organizerIds,
    budget: budget ?? this.budget,
    capacity: identical(capacity, unset) ? this.capacity : capacity as int?,
    rsvpIds: rsvpIds ?? this.rsvpIds,
    checkInSecret: checkInSecret,
    checkInOpen: checkInOpen ?? this.checkInOpen,
    cancelled: cancelled ?? this.cancelled,
    outcome: outcome ?? this.outcome,
    createdBy: createdBy,
    createdAt: createdAt,
  );

  factory SocietyEvent.fromJson(Json j) => SocietyEvent(
    id: j['id'] as String,
    title: j['title'] as String,
    type: readEnum(EventType.values, j['type'], EventType.workshop),
    description: j['description'] as String? ?? '',
    startsAt: readDate(j['startsAt']),
    endsAt: readDate(j['endsAt']),
    venue: j['venue'] as String? ?? '',
    domainId: j['domainId'] as String?,
    organizerIds: readStrings(j['organizerIds']),
    budget: readDouble(j['budget']),
    capacity: j['capacity'] as int?,
    rsvpIds: readStrings(j['rsvpIds']),
    checkInSecret: j['checkInSecret'] as String,
    checkInOpen: j['checkInOpen'] as bool? ?? false,
    cancelled: j['cancelled'] as bool? ?? false,
    outcome: j['outcome'] as String? ?? '',
    createdBy: j['createdBy'] as String,
    createdAt: readDate(j['createdAt']),
  );

  @override
  Json toJson() => {
    'id': id,
    'title': title,
    'type': type.name,
    'description': description,
    'startsAt': writeDate(startsAt),
    'endsAt': writeDate(endsAt),
    'venue': venue,
    'domainId': domainId,
    'organizerIds': organizerIds,
    'budget': budget,
    'capacity': capacity,
    'rsvpIds': rsvpIds,
    'checkInSecret': checkInSecret,
    'checkInOpen': checkInOpen,
    'cancelled': cancelled,
    'outcome': outcome,
    'createdBy': createdBy,
    'createdAt': writeDate(createdAt),
  };
}

enum CheckInMethod {
  qr('QR scan'),
  code('Code'),
  manual('Marked by organiser');

  const CheckInMethod(this.label);
  final String label;
}

enum AttendanceTarget { event, meeting }

class AttendanceRecord implements Entity {
  const AttendanceRecord({
    required this.id,
    required this.target,
    required this.targetId,
    required this.memberId,
    required this.at,
    required this.method,
    required this.markedBy,
  });

  @override
  final String id;
  final AttendanceTarget target;
  final String targetId;
  final String memberId;
  final DateTime at;
  final CheckInMethod method;
  final String markedBy;

  /// Deterministic id so the same person can't be checked in twice.
  static String idFor(AttendanceTarget t, String targetId, String memberId) =>
      '${t.name}_${targetId}_$memberId';

  factory AttendanceRecord.fromJson(Json j) => AttendanceRecord(
    id: j['id'] as String,
    target: readEnum(
      AttendanceTarget.values,
      j['target'],
      AttendanceTarget.event,
    ),
    targetId: j['targetId'] as String,
    memberId: j['memberId'] as String,
    at: readDate(j['at']),
    method: readEnum(CheckInMethod.values, j['method'], CheckInMethod.manual),
    markedBy: j['markedBy'] as String,
  );

  @override
  Json toJson() => {
    'id': id,
    'target': target.name,
    'targetId': targetId,
    'memberId': memberId,
    'at': writeDate(at),
    'method': method.name,
    'markedBy': markedBy,
  };
}

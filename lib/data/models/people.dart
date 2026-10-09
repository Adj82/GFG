import 'json.dart';

/// Recruitment pipeline (doc §5 People & Knowledge). A sign-up during
/// induction season creates a pending member plus one of these.
enum ApplicationStage {
  applied('Applied'),
  shortlisted('Shortlisted'),
  interview('Interview'),
  selected('Selected'),
  rejected('Not selected');

  const ApplicationStage(this.label);
  final String label;

  bool get isOpen => this != selected && this != rejected;
  static const pipeline = [applied, shortlisted, interview];
}

class ReviewNote {
  const ReviewNote({
    required this.authorId,
    required this.text,
    required this.at,
  });

  final String authorId;
  final String text;
  final DateTime at;

  factory ReviewNote.fromJson(Json j) => ReviewNote(
    authorId: j['authorId'] as String,
    text: j['text'] as String,
    at: readDate(j['at']),
  );

  Json toJson() => {'authorId': authorId, 'text': text, 'at': writeDate(at)};
}

class Application implements Entity {
  const Application({
    required this.id,
    required this.memberId,
    required this.domainId,
    required this.createdAt,
    this.stage = ApplicationStage.applied,
    this.year,
    this.branch = '',
    this.why = '',
    this.experience = '',
    this.portfolio = '',
    this.notes = const [],
    this.interviewAt,
    this.decidedBy,
    this.decidedAt,
  });

  /// Same as the member id — one application per person.
  @override
  final String id;
  final String memberId;
  final String domainId;
  final ApplicationStage stage;
  final int? year;
  final String branch;
  final String why;
  final String experience;
  final String portfolio;
  final List<ReviewNote> notes;
  final DateTime? interviewAt;
  final String? decidedBy;
  final DateTime? decidedAt;
  final DateTime createdAt;

  Application copyWith({
    ApplicationStage? stage,
    List<ReviewNote>? notes,
    DateTime? interviewAt,
    String? decidedBy,
    DateTime? decidedAt,
    String? domainId,
  }) => Application(
    id: id,
    memberId: memberId,
    domainId: domainId ?? this.domainId,
    stage: stage ?? this.stage,
    year: year,
    branch: branch,
    why: why,
    experience: experience,
    portfolio: portfolio,
    notes: notes ?? this.notes,
    interviewAt: interviewAt ?? this.interviewAt,
    decidedBy: decidedBy ?? this.decidedBy,
    decidedAt: decidedAt ?? this.decidedAt,
    createdAt: createdAt,
  );

  factory Application.fromJson(Json j) => Application(
    id: j['id'] as String,
    memberId: j['memberId'] as String,
    domainId: j['domainId'] as String,
    stage: readEnum(
      ApplicationStage.values,
      j['stage'],
      ApplicationStage.applied,
    ),
    year: j['year'] as int?,
    branch: j['branch'] as String? ?? '',
    why: j['why'] as String? ?? '',
    experience: j['experience'] as String? ?? '',
    portfolio: j['portfolio'] as String? ?? '',
    notes: readList(j['notes'], ReviewNote.fromJson),
    interviewAt: readDateOrNull(j['interviewAt']),
    decidedBy: j['decidedBy'] as String?,
    decidedAt: readDateOrNull(j['decidedAt']),
    createdAt: readDate(j['createdAt']),
  );

  @override
  Json toJson() => {
    'id': id,
    'memberId': memberId,
    'domainId': domainId,
    'stage': stage.name,
    'year': year,
    'branch': branch,
    'why': why,
    'experience': experience,
    'portfolio': portfolio,
    'notes': notes.map((n) => n.toJson()).toList(),
    'interviewAt': writeDate(interviewAt),
    'decidedBy': decidedBy,
    'decidedAt': writeDate(decidedAt),
    'createdAt': writeDate(createdAt),
  };
}

enum NoticeKind { task, event, finance, announcement, people, meeting, system }

/// In-app inbox item. Backend: write these from Cloud Functions and mirror
/// them to FCM push.
class Notice implements Entity {
  const Notice({
    required this.id,
    required this.recipientId,
    required this.kind,
    required this.title,
    required this.body,
    required this.createdAt,
    this.route,
    this.read = false,
  });

  @override
  final String id;
  final String recipientId;
  final NoticeKind kind;
  final String title;
  final String body;

  /// In-app route to open when tapped, e.g. /tasks/abc.
  final String? route;
  final DateTime createdAt;
  final bool read;

  Notice copyWith({bool? read}) => Notice(
    id: id,
    recipientId: recipientId,
    kind: kind,
    title: title,
    body: body,
    route: route,
    createdAt: createdAt,
    read: read ?? this.read,
  );

  factory Notice.fromJson(Json j) => Notice(
    id: j['id'] as String,
    recipientId: j['recipientId'] as String,
    kind: readEnum(NoticeKind.values, j['kind'], NoticeKind.system),
    title: j['title'] as String,
    body: j['body'] as String,
    route: j['route'] as String?,
    createdAt: readDate(j['createdAt']),
    read: j['read'] as bool? ?? false,
  );

  @override
  Json toJson() => {
    'id': id,
    'recipientId': recipientId,
    'kind': kind.name,
    'title': title,
    'body': body,
    'route': route,
    'createdAt': writeDate(createdAt),
    'read': read,
  };
}

/// Append-only log of sensitive actions (money, roles, term changes).
class AuditEntry implements Entity {
  const AuditEntry({
    required this.id,
    required this.actorId,
    required this.action,
    required this.summary,
    required this.at,
    required this.term,
    this.targetId,
  });

  @override
  final String id;
  final String actorId;

  /// Machine-readable code, e.g. `expense.approved`, `member.role_changed`.
  final String action;
  final String summary;
  final String? targetId;
  final DateTime at;
  final String term;

  factory AuditEntry.fromJson(Json j) => AuditEntry(
    id: j['id'] as String,
    actorId: j['actorId'] as String,
    action: j['action'] as String,
    summary: j['summary'] as String,
    targetId: j['targetId'] as String?,
    at: readDate(j['at']),
    term: j['term'] as String? ?? '',
  );

  @override
  Json toJson() => {
    'id': id,
    'actorId': actorId,
    'action': action,
    'summary': summary,
    'targetId': targetId,
    'at': writeDate(at),
    'term': term,
  };
}

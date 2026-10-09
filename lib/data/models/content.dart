import 'json.dart';
import 'org.dart';

/// Who can see a post or meeting: everyone, one department, or one domain.
enum Audience {
  society('Everyone'),
  department('Department'),
  domain('Domain');

  const Audience(this.label);
  final String label;
}

class Announcement implements Entity {
  const Announcement({
    required this.id,
    required this.title,
    required this.body,
    required this.audience,
    required this.authorId,
    required this.createdAt,
    this.department,
    this.domainId,
    this.pinned = false,
    this.readBy = const [],
  });

  @override
  final String id;
  final String title;
  final String body;
  final Audience audience;
  final Department? department;
  final String? domainId;
  final String authorId;
  final DateTime createdAt;
  final bool pinned;
  final List<String> readBy;

  Announcement copyWith({bool? pinned, List<String>? readBy}) => Announcement(
    id: id,
    title: title,
    body: body,
    audience: audience,
    department: department,
    domainId: domainId,
    authorId: authorId,
    createdAt: createdAt,
    pinned: pinned ?? this.pinned,
    readBy: readBy ?? this.readBy,
  );

  factory Announcement.fromJson(Json j) => Announcement(
    id: j['id'] as String,
    title: j['title'] as String,
    body: j['body'] as String,
    audience: readEnum(Audience.values, j['audience'], Audience.society),
    department: readEnumOrNull(Department.values, j['department']),
    domainId: j['domainId'] as String?,
    authorId: j['authorId'] as String,
    createdAt: readDate(j['createdAt']),
    pinned: j['pinned'] as bool? ?? false,
    readBy: readStrings(j['readBy']),
  );

  @override
  Json toJson() => {
    'id': id,
    'title': title,
    'body': body,
    'audience': audience.name,
    'department': department?.name,
    'domainId': domainId,
    'authorId': authorId,
    'createdAt': writeDate(createdAt),
    'pinned': pinned,
    'readBy': readBy,
  };
}

class ActionItem {
  const ActionItem({
    required this.id,
    required this.text,
    this.assigneeId,
    this.taskId,
  });

  final String id;
  final String text;
  final String? assigneeId;

  /// Set once the action item has been turned into a task.
  final String? taskId;

  ActionItem copyWith({String? taskId}) => ActionItem(
    id: id,
    text: text,
    assigneeId: assigneeId,
    taskId: taskId ?? this.taskId,
  );

  factory ActionItem.fromJson(Json j) => ActionItem(
    id: j['id'] as String,
    text: j['text'] as String,
    assigneeId: j['assigneeId'] as String?,
    taskId: j['taskId'] as String?,
  );

  Json toJson() => {
    'id': id,
    'text': text,
    'assigneeId': assigneeId,
    'taskId': taskId,
  };
}

class Meeting implements Entity {
  const Meeting({
    required this.id,
    required this.title,
    required this.startsAt,
    required this.durationMinutes,
    required this.audience,
    required this.createdBy,
    required this.createdAt,
    this.department,
    this.domainId,
    this.venue = '',
    this.link = '',
    this.agenda = const [],
    this.minutes = '',
    this.actionItems = const [],
  });

  @override
  final String id;
  final String title;
  final DateTime startsAt;
  final int durationMinutes;
  final Audience audience;
  final Department? department;
  final String? domainId;
  final String venue;
  final String link;
  final List<String> agenda;
  final String minutes;
  final List<ActionItem> actionItems;
  final String createdBy;
  final DateTime createdAt;

  DateTime get endsAt => startsAt.add(Duration(minutes: durationMinutes));
  bool isPast([DateTime? now]) => endsAt.isBefore(now ?? DateTime.now());

  Meeting copyWith({
    String? minutes,
    List<ActionItem>? actionItems,
    List<String>? agenda,
  }) => Meeting(
    id: id,
    title: title,
    startsAt: startsAt,
    durationMinutes: durationMinutes,
    audience: audience,
    department: department,
    domainId: domainId,
    venue: venue,
    link: link,
    agenda: agenda ?? this.agenda,
    minutes: minutes ?? this.minutes,
    actionItems: actionItems ?? this.actionItems,
    createdBy: createdBy,
    createdAt: createdAt,
  );

  factory Meeting.fromJson(Json j) => Meeting(
    id: j['id'] as String,
    title: j['title'] as String,
    startsAt: readDate(j['startsAt']),
    durationMinutes: readInt(j['durationMinutes'], 60),
    audience: readEnum(Audience.values, j['audience'], Audience.society),
    department: readEnumOrNull(Department.values, j['department']),
    domainId: j['domainId'] as String?,
    venue: j['venue'] as String? ?? '',
    link: j['link'] as String? ?? '',
    agenda: readStrings(j['agenda']),
    minutes: j['minutes'] as String? ?? '',
    actionItems: readList(j['actionItems'], ActionItem.fromJson),
    createdBy: j['createdBy'] as String,
    createdAt: readDate(j['createdAt']),
  );

  @override
  Json toJson() => {
    'id': id,
    'title': title,
    'startsAt': writeDate(startsAt),
    'durationMinutes': durationMinutes,
    'audience': audience.name,
    'department': department?.name,
    'domainId': domainId,
    'venue': venue,
    'link': link,
    'agenda': agenda,
    'minutes': minutes,
    'actionItems': actionItems.map((a) => a.toJson()).toList(),
    'createdBy': createdBy,
    'createdAt': writeDate(createdAt),
  };
}

enum VaultCategory {
  brand('Brand kit'),
  templates('Templates'),
  eventAssets('Event assets'),
  docs('Docs & policies'),
  learning('Learning');

  const VaultCategory(this.label);
  final String label;
}

class VaultItem implements Entity {
  const VaultItem({
    required this.id,
    required this.title,
    required this.category,
    required this.addedBy,
    required this.addedAt,
    this.url = '',
    this.fileName,
    this.fileRef,
    this.sizeBytes,
    this.description = '',
  });

  @override
  final String id;
  final String title;
  final VaultCategory category;

  /// A link (Drive, Figma, GitHub…). Empty for uploaded files.
  final String url;
  final String? fileName;

  /// Local path today; Storage path once the backend is in.
  final String? fileRef;
  final int? sizeBytes;
  final String description;
  final String addedBy;
  final DateTime addedAt;

  bool get isLink => url.isNotEmpty;

  String get extension {
    final n = fileName ?? '';
    final i = n.lastIndexOf('.');
    return i < 0 ? '' : n.substring(i + 1).toUpperCase();
  }

  factory VaultItem.fromJson(Json j) => VaultItem(
    id: j['id'] as String,
    title: j['title'] as String,
    category: readEnum(VaultCategory.values, j['category'], VaultCategory.docs),
    url: j['url'] as String? ?? '',
    fileName: j['fileName'] as String?,
    fileRef: j['fileRef'] as String?,
    sizeBytes: j['sizeBytes'] as int?,
    description: j['description'] as String? ?? '',
    addedBy: j['addedBy'] as String,
    addedAt: readDate(j['addedAt']),
  );

  @override
  Json toJson() => {
    'id': id,
    'title': title,
    'category': category.name,
    'url': url,
    'fileName': fileName,
    'fileRef': fileRef,
    'sizeBytes': sizeBytes,
    'description': description,
    'addedBy': addedBy,
    'addedAt': writeDate(addedAt),
  };
}

enum CommentParent { task, event, expense }

class Comment implements Entity {
  const Comment({
    required this.id,
    required this.parent,
    required this.parentId,
    required this.authorId,
    required this.text,
    required this.createdAt,
  });

  @override
  final String id;
  final CommentParent parent;
  final String parentId;
  final String authorId;
  final String text;
  final DateTime createdAt;

  factory Comment.fromJson(Json j) => Comment(
    id: j['id'] as String,
    parent: readEnum(CommentParent.values, j['parent'], CommentParent.task),
    parentId: j['parentId'] as String,
    authorId: j['authorId'] as String,
    text: j['text'] as String,
    createdAt: readDate(j['createdAt']),
  );

  @override
  Json toJson() => {
    'id': id,
    'parent': parent.name,
    'parentId': parentId,
    'authorId': authorId,
    'text': text,
    'createdAt': writeDate(createdAt),
  };
}

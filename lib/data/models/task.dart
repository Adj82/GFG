import 'json.dart';

enum TaskStatus {
  todo('To do'),
  inProgress('In progress'),
  review('In review'),
  done('Done');

  const TaskStatus(this.label);
  final String label;
}

enum TaskPriority {
  low('Low'),
  medium('Medium'),
  high('High');

  const TaskPriority(this.label);
  final String label;
}

class ChecklistItem {
  const ChecklistItem({
    required this.id,
    required this.text,
    this.done = false,
  });

  final String id;
  final String text;
  final bool done;

  ChecklistItem copyWith({String? text, bool? done}) =>
      ChecklistItem(id: id, text: text ?? this.text, done: done ?? this.done);

  factory ChecklistItem.fromJson(Json j) => ChecklistItem(
    id: j['id'] as String,
    text: j['text'] as String,
    done: j['done'] as bool? ?? false,
  );

  Json toJson() => {'id': id, 'text': text, 'done': done};
}

class SocietyTask implements Entity {
  const SocietyTask({
    required this.id,
    required this.title,
    required this.createdBy,
    required this.createdAt,
    this.description = '',
    this.domainId,
    this.eventId,
    this.meetingId,
    this.assigneeIds = const [],
    this.due,
    this.priority = TaskPriority.medium,
    this.status = TaskStatus.todo,
    this.checklist = const [],
    this.completedAt,
    this.updatedAt,
  });

  @override
  final String id;
  final String title;
  final String description;

  /// Null = society-wide task.
  final String? domainId;

  /// Set when the task belongs to an event workspace.
  final String? eventId;

  /// Set when the task came from a meeting action item.
  final String? meetingId;
  final List<String> assigneeIds;
  final DateTime? due;
  final TaskPriority priority;
  final TaskStatus status;
  final List<ChecklistItem> checklist;
  final String createdBy;
  final DateTime createdAt;
  final DateTime? completedAt;
  final DateTime? updatedAt;

  bool get isDone => status == TaskStatus.done;

  bool isOverdue([DateTime? now]) {
    if (isDone || due == null) return false;
    final n = now ?? DateTime.now();
    return due!.isBefore(DateTime(n.year, n.month, n.day));
  }

  int get checklistDone => checklist.where((c) => c.done).length;

  SocietyTask copyWith({
    String? title,
    String? description,
    Object? domainId = unset,
    Object? eventId = unset,
    List<String>? assigneeIds,
    Object? due = unset,
    TaskPriority? priority,
    TaskStatus? status,
    List<ChecklistItem>? checklist,
    Object? completedAt = unset,
    DateTime? updatedAt,
  }) => SocietyTask(
    id: id,
    title: title ?? this.title,
    description: description ?? this.description,
    domainId: identical(domainId, unset) ? this.domainId : domainId as String?,
    eventId: identical(eventId, unset) ? this.eventId : eventId as String?,
    meetingId: meetingId,
    assigneeIds: assigneeIds ?? this.assigneeIds,
    due: identical(due, unset) ? this.due : due as DateTime?,
    priority: priority ?? this.priority,
    status: status ?? this.status,
    checklist: checklist ?? this.checklist,
    createdBy: createdBy,
    createdAt: createdAt,
    completedAt: identical(completedAt, unset)
        ? this.completedAt
        : completedAt as DateTime?,
    updatedAt: updatedAt ?? this.updatedAt,
  );

  factory SocietyTask.fromJson(Json j) => SocietyTask(
    id: j['id'] as String,
    title: j['title'] as String,
    description: j['description'] as String? ?? '',
    domainId: j['domainId'] as String?,
    eventId: j['eventId'] as String?,
    meetingId: j['meetingId'] as String?,
    assigneeIds: readStrings(j['assigneeIds']),
    due: readDateOrNull(j['due']),
    priority: readEnum(TaskPriority.values, j['priority'], TaskPriority.medium),
    status: readEnum(TaskStatus.values, j['status'], TaskStatus.todo),
    checklist: readList(j['checklist'], ChecklistItem.fromJson),
    createdBy: j['createdBy'] as String,
    createdAt: readDate(j['createdAt']),
    completedAt: readDateOrNull(j['completedAt']),
    updatedAt: readDateOrNull(j['updatedAt']),
  );

  @override
  Json toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'domainId': domainId,
    'eventId': eventId,
    'meetingId': meetingId,
    'assigneeIds': assigneeIds,
    'due': writeDate(due),
    'priority': priority.name,
    'status': status.name,
    'checklist': checklist.map((c) => c.toJson()).toList(),
    'createdBy': createdBy,
    'createdAt': writeDate(createdAt),
    'completedAt': writeDate(completedAt),
    'updatedAt': writeDate(updatedAt),
  };
}

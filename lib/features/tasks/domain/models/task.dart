import 'package:freezed_annotation/freezed_annotation.dart';

part 'task.freezed.dart';
part 'task.g.dart';

enum TaskPriority { high, medium, low }
enum TaskStatus { pending, inProgress, completed }

@freezed
class SocietyTask with _$SocietyTask {
  const factory SocietyTask({
    required String id,
    required String orgId,
    required String domainId,
    required String title,
    required String description,
    required String assigneeId,
    required DateTime deadline,
    required TaskPriority priority,
    required TaskStatus status,
    required String createdBy,
    required DateTime createdAt,
  }) = _SocietyTask;

  factory SocietyTask.fromJson(Map<String, dynamic> json) => _$SocietyTaskFromJson(json);
}

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SocietyTaskImpl _$$SocietyTaskImplFromJson(Map<String, dynamic> json) =>
    _$SocietyTaskImpl(
      id: json['id'] as String,
      orgId: json['orgId'] as String,
      domainId: json['domainId'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      assigneeId: json['assigneeId'] as String,
      deadline: DateTime.parse(json['deadline'] as String),
      priority: $enumDecode(_$TaskPriorityEnumMap, json['priority']),
      status: $enumDecode(_$TaskStatusEnumMap, json['status']),
      createdBy: json['createdBy'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$SocietyTaskImplToJson(_$SocietyTaskImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'orgId': instance.orgId,
      'domainId': instance.domainId,
      'title': instance.title,
      'description': instance.description,
      'assigneeId': instance.assigneeId,
      'deadline': instance.deadline.toIso8601String(),
      'priority': _$TaskPriorityEnumMap[instance.priority]!,
      'status': _$TaskStatusEnumMap[instance.status]!,
      'createdBy': instance.createdBy,
      'createdAt': instance.createdAt.toIso8601String(),
    };

const _$TaskPriorityEnumMap = {
  TaskPriority.high: 'high',
  TaskPriority.medium: 'medium',
  TaskPriority.low: 'low',
};

const _$TaskStatusEnumMap = {
  TaskStatus.pending: 'pending',
  TaskStatus.inProgress: 'inProgress',
  TaskStatus.completed: 'completed',
};

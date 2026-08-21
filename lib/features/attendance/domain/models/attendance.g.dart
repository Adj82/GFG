// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'attendance.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AttendanceRecordImpl _$$AttendanceRecordImplFromJson(
  Map<String, dynamic> json,
) => _$AttendanceRecordImpl(
  id: json['id'] as String,
  orgId: json['orgId'] as String,
  eventId: json['eventId'] as String,
  userId: json['userId'] as String,
  userName: json['userName'] as String,
  timestamp: DateTime.parse(json['timestamp'] as String),
  markedBy: json['markedBy'] as String,
);

Map<String, dynamic> _$$AttendanceRecordImplToJson(
  _$AttendanceRecordImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'orgId': instance.orgId,
  'eventId': instance.eventId,
  'userId': instance.userId,
  'userName': instance.userName,
  'timestamp': instance.timestamp.toIso8601String(),
  'markedBy': instance.markedBy,
};

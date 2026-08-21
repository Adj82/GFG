// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meeting.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SocietyMeetingImpl _$$SocietyMeetingImplFromJson(Map<String, dynamic> json) =>
    _$SocietyMeetingImpl(
      id: json['id'] as String,
      orgId: json['orgId'] as String,
      domainId: json['domainId'] as String?,
      title: json['title'] as String,
      agenda: json['agenda'] as String,
      time: DateTime.parse(json['time'] as String),
      venue: json['venue'] as String,
      link: json['link'] as String?,
      scheduledBy: json['scheduledBy'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$SocietyMeetingImplToJson(
  _$SocietyMeetingImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'orgId': instance.orgId,
  'domainId': instance.domainId,
  'title': instance.title,
  'agenda': instance.agenda,
  'time': instance.time.toIso8601String(),
  'venue': instance.venue,
  'link': instance.link,
  'scheduledBy': instance.scheduledBy,
  'createdAt': instance.createdAt.toIso8601String(),
};

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SocietyEventImpl _$$SocietyEventImplFromJson(Map<String, dynamic> json) =>
    _$SocietyEventImpl(
      id: json['id'] as String,
      orgId: json['orgId'] as String,
      domainId: json['domainId'] as String?,
      title: json['title'] as String,
      description: json['description'] as String,
      venue: json['venue'] as String,
      date: DateTime.parse(json['date'] as String),
      rsvpUserIds:
          (json['rsvpUserIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      createdBy: json['createdBy'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$SocietyEventImplToJson(_$SocietyEventImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'orgId': instance.orgId,
      'domainId': instance.domainId,
      'title': instance.title,
      'description': instance.description,
      'venue': instance.venue,
      'date': instance.date.toIso8601String(),
      'rsvpUserIds': instance.rsvpUserIds,
      'createdBy': instance.createdBy,
      'createdAt': instance.createdAt.toIso8601String(),
    };

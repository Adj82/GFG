// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'announcement.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AnnouncementImpl _$$AnnouncementImplFromJson(Map<String, dynamic> json) =>
    _$AnnouncementImpl(
      id: json['id'] as String,
      orgId: json['orgId'] as String,
      domainId: json['domainId'] as String?,
      title: json['title'] as String,
      body: json['body'] as String,
      postedBy: json['postedBy'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$AnnouncementImplToJson(_$AnnouncementImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'orgId': instance.orgId,
      'domainId': instance.domainId,
      'title': instance.title,
      'body': instance.body,
      'postedBy': instance.postedBy,
      'createdAt': instance.createdAt.toIso8601String(),
    };

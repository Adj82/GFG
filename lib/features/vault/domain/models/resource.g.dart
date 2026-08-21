// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'resource.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SocietyResourceImpl _$$SocietyResourceImplFromJson(
  Map<String, dynamic> json,
) => _$SocietyResourceImpl(
  id: json['id'] as String,
  orgId: json['orgId'] as String,
  title: json['title'] as String,
  type: json['type'] as String,
  downloadUrl: json['downloadUrl'] as String,
  uploadedBy: json['uploadedBy'] as String,
  createdAt: DateTime.parse(json['createdAt'] as String),
  sizeKb: (json['sizeKb'] as num).toDouble(),
);

Map<String, dynamic> _$$SocietyResourceImplToJson(
  _$SocietyResourceImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'orgId': instance.orgId,
  'title': instance.title,
  'type': instance.type,
  'downloadUrl': instance.downloadUrl,
  'uploadedBy': instance.uploadedBy,
  'createdAt': instance.createdAt.toIso8601String(),
  'sizeKb': instance.sizeKb,
};

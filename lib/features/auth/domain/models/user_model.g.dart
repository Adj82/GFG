// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SocietyUserImpl _$$SocietyUserImplFromJson(Map<String, dynamic> json) =>
    _$SocietyUserImpl(
      uid: json['uid'] as String,
      orgId: json['orgId'] as String,
      domainId: json['domainId'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      roleName: json['roleName'] as String,
      status: $enumDecode(_$UserStatusEnumMap, json['status']),
      createdAt: DateTime.parse(json['createdAt'] as String),
      needsPasswordReset: json['needsPasswordReset'] as bool? ?? false,
    );

Map<String, dynamic> _$$SocietyUserImplToJson(_$SocietyUserImpl instance) =>
    <String, dynamic>{
      'uid': instance.uid,
      'orgId': instance.orgId,
      'domainId': instance.domainId,
      'name': instance.name,
      'email': instance.email,
      'roleName': instance.roleName,
      'status': _$UserStatusEnumMap[instance.status]!,
      'createdAt': instance.createdAt.toIso8601String(),
      'needsPasswordReset': instance.needsPasswordReset,
    };

const _$UserStatusEnumMap = {
  UserStatus.pending: 'pending',
  UserStatus.active: 'active',
  UserStatus.disabled: 'disabled',
};

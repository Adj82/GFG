// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'domain.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SocietyDomainImpl _$$SocietyDomainImplFromJson(Map<String, dynamic> json) =>
    _$SocietyDomainImpl(
      id: json['id'] as String,
      orgId: json['orgId'] as String,
      name: json['name'] as String,
      type: $enumDecode(_$DomainTypeEnumMap, json['type']),
    );

Map<String, dynamic> _$$SocietyDomainImplToJson(_$SocietyDomainImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'orgId': instance.orgId,
      'name': instance.name,
      'type': _$DomainTypeEnumMap[instance.type]!,
    };

const _$DomainTypeEnumMap = {
  DomainType.technical: 'technical',
  DomainType.nonTechnical: 'nonTechnical',
};

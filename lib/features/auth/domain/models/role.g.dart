// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'role.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PermissionsImpl _$$PermissionsImplFromJson(Map<String, dynamic> json) =>
    _$PermissionsImpl(
      canAssignTasksGlobal: json['canAssignTasksGlobal'] as bool? ?? false,
      canAssignTasksDomain: json['canAssignTasksDomain'] as bool? ?? false,
      canPostAnnouncementsGlobal:
          json['canPostAnnouncementsGlobal'] as bool? ?? false,
      canPostAnnouncementsDomain:
          json['canPostAnnouncementsDomain'] as bool? ?? false,
      canApproveMembers: json['canApproveMembers'] as bool? ?? false,
      canManageRoles: json['canManageRoles'] as bool? ?? false,
      canCreateLeads: json['canCreateLeads'] as bool? ?? false,
      canViewFinance: json['canViewFinance'] as bool? ?? false,
      canManageFinance: json['canManageFinance'] as bool? ?? false,
    );

Map<String, dynamic> _$$PermissionsImplToJson(_$PermissionsImpl instance) =>
    <String, dynamic>{
      'canAssignTasksGlobal': instance.canAssignTasksGlobal,
      'canAssignTasksDomain': instance.canAssignTasksDomain,
      'canPostAnnouncementsGlobal': instance.canPostAnnouncementsGlobal,
      'canPostAnnouncementsDomain': instance.canPostAnnouncementsDomain,
      'canApproveMembers': instance.canApproveMembers,
      'canManageRoles': instance.canManageRoles,
      'canCreateLeads': instance.canCreateLeads,
      'canViewFinance': instance.canViewFinance,
      'canManageFinance': instance.canManageFinance,
    };

_$SocietyRoleImpl _$$SocietyRoleImplFromJson(Map<String, dynamic> json) =>
    _$SocietyRoleImpl(
      id: json['id'] as String,
      orgId: json['orgId'] as String,
      name: json['name'] as String,
      permissions: Permissions.fromJson(
        json['permissions'] as Map<String, dynamic>,
      ),
    );

Map<String, dynamic> _$$SocietyRoleImplToJson(_$SocietyRoleImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'orgId': instance.orgId,
      'name': instance.name,
      'permissions': instance.permissions,
    };

import 'package:freezed_annotation/freezed_annotation.dart';

part 'role.freezed.dart';
part 'role.g.dart';

@freezed
class Permissions with _$Permissions {
  const factory Permissions({
    @Default(false) bool canAssignTasksGlobal,
    @Default(false) bool canAssignTasksDomain,
    @Default(false) bool canPostAnnouncementsGlobal,
    @Default(false) bool canPostAnnouncementsDomain,
    @Default(false) bool canApproveMembers,
    @Default(false) bool canManageRoles,
    @Default(false) bool canCreateLeads,
    @Default(false) bool canViewFinance,
    @Default(false) bool canManageFinance,
  }) = _Permissions;

  factory Permissions.fromJson(Map<String, dynamic> json) => _$PermissionsFromJson(json);
}

@freezed
class SocietyRole with _$SocietyRole {
  const factory SocietyRole({
    required String id,
    required String orgId,
    required String name,
    required Permissions permissions,
  }) = _SocietyRole;

  factory SocietyRole.fromJson(Map<String, dynamic> json) => _$SocietyRoleFromJson(json);
}

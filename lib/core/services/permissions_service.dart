import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/domain/models/role.dart';
import '../../features/auth/domain/models/user_model.dart';
import '../../features/auth/presentation/auth_state_provider.dart';

class PermissionsService {
  final SocietyUser? user;
  final SocietyRole? role;

  PermissionsService({this.user, this.role});

  bool can(bool Function(Permissions p) check) {
    if (user == null || role == null) return false;
    if (user!.status != UserStatus.active) return false;
    return check(role!.permissions);
  }

  // Convenience methods
  bool get canPostGlobalAnnouncement => can((p) => p.canPostAnnouncementsGlobal);
  bool get canPostDomainAnnouncement => can((p) => p.canPostAnnouncementsDomain);
  bool get canAssignGlobalTasks => can((p) => p.canAssignTasksGlobal);
  bool get canAssignDomainTasks => can((p) => p.canAssignTasksDomain);
  bool get canApproveMembers => can((p) => p.canApproveMembers);
  bool get canViewFinance => can((p) => p.canViewFinance);
  bool get canManageFinance => can((p) => p.canManageFinance);
}

final permissionsServiceProvider = Provider<PermissionsService>((ref) {
  final auth = ref.watch(authStateProvider);
  return PermissionsService(user: auth.user, role: auth.role);
});

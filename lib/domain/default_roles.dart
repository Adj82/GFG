import '../data/models/role.dart';

/// Default hierarchy from doc §2: President → VP → Core Heads → Domain Leads → Members,
/// plus a Treasurer. Stored as data, so the President can add roles later.
abstract final class DefaultRoles {
  static const president = 'president';
  static const vicePresident = 'vice_president';
  static const treasurer = 'treasurer';
  static const technicalHead = 'technical_head';
  static const nonTechnicalHead = 'non_technical_head';
  static const domainLead = 'domain_lead';
  static const member = 'member';

  static final all = <Role>[
    Role(
      id: president,
      name: 'President',
      rank: 0,
      scope: RoleScope.society,
      tier: RoleTier.leadership,
      isOfficeBearer: true,
      permissions: Permission.values.toSet(),
    ),
    Role(
      id: vicePresident,
      name: 'Vice President',
      rank: 1,
      scope: RoleScope.society,
      tier: RoleTier.leadership,
      isOfficeBearer: true,
      permissions: Permission.values.toSet()
        ..removeAll({Permission.manageTerm, Permission.manageRoles}),
    ),
    const Role(
      id: treasurer,
      name: 'Treasurer',
      rank: 2,
      scope: RoleScope.society,
      tier: RoleTier.leadership,
      isOfficeBearer: true,
      permissions: {
        Permission.submitExpense,
        Permission.viewWallet,
        Permission.viewScopedFinance,
        Permission.logIncome,
        Permission.reimburse,
        Permission.viewAnalytics,
        Permission.viewAudit,
        Permission.manageVault,
      },
    ),
    ..._coreHeads,
    const Role(
      id: domainLead,
      name: 'Domain Lead',
      rank: 4,
      scope: RoleScope.domain,
      tier: RoleTier.lead,
      isOfficeBearer: true,
      permissions: {
        Permission.submitExpense,
        Permission.reviewExpense,
        Permission.viewScopedFinance,
        Permission.assignTasks,
        Permission.postAnnouncements,
        Permission.manageEvents,
        Permission.scheduleMeetings,
        Permission.approveMembers,
      },
    ),
    const Role(
      id: member,
      name: 'Member',
      rank: 5,
      scope: RoleScope.self,
      tier: RoleTier.member,
      permissions: {Permission.submitExpense},
    ),
  ];

  static const _corePermissions = {
    Permission.submitExpense,
    Permission.reviewExpense,
    Permission.verifyExpense,
    Permission.viewScopedFinance,
    Permission.assignTasks,
    Permission.postAnnouncements,
    Permission.manageEvents,
    Permission.scheduleMeetings,
    Permission.approveMembers,
    Permission.manageVault,
    Permission.viewAnalytics,
  };

  static const _coreHeads = [
    Role(
      id: technicalHead,
      name: 'Technical Head',
      rank: 3,
      scope: RoleScope.department,
      tier: RoleTier.core,
      isOfficeBearer: true,
      permissions: _corePermissions,
    ),
    Role(
      id: nonTechnicalHead,
      name: 'Non-Technical Head',
      rank: 3,
      scope: RoleScope.department,
      tier: RoleTier.core,
      isOfficeBearer: true,
      permissions: _corePermissions,
    ),
  ];
}

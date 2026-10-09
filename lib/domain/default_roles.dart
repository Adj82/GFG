import '../data/models/role.dart';

/// Default hierarchy from doc §2: President → VP → Core Heads → Domain Leads → Members,
/// plus a Treasurer. Stored as data, so the President can add roles later.
abstract final class DefaultRoles {
  static const president = 'president';
  static const vicePresident = 'vice_president';
  static const technicalHead = 'technical_head';
  static const eventHead = 'event_head';
  static const sponsorshipHead = 'sponsorship_head';
  static const marketingHead = 'marketing_head';
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
    // The six-person core team sees the treasury and every domain.
    Permission.viewWallet,
    Permission.viewAllDomains,
  };

  /// The six core roles: President, VP and the four heads below.
  static const coreIds = {
    president,
    vicePresident,
    technicalHead,
    eventHead,
    sponsorshipHead,
    marketingHead,
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
      id: eventHead,
      name: 'Event Head',
      rank: 3,
      scope: RoleScope.department,
      tier: RoleTier.core,
      isOfficeBearer: true,
      permissions: _corePermissions,
    ),
    Role(
      id: sponsorshipHead,
      name: 'Sponsorship Head',
      rank: 3,
      scope: RoleScope.department,
      tier: RoleTier.core,
      isOfficeBearer: true,
      permissions: _corePermissions,
    ),
    Role(
      id: marketingHead,
      name: 'Marketing Head',
      rank: 3,
      scope: RoleScope.department,
      tier: RoleTier.core,
      isOfficeBearer: true,
      permissions: _corePermissions,
    ),
  ];
}

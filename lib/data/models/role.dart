import 'json.dart';

/// What a role is allowed to do. How far it reaches (whole society, one
/// department, one domain) comes from [RoleScope], so the same permission
/// means "society-wide" for the President and "my domain" for a Domain Lead.
enum Permission {
  // Finance (doc §6)
  submitExpense('Submit expenses'),
  reviewExpense('Review expenses (lead step)'),
  verifyExpense('Verify expenses (core head step)'),
  approveExpense('Final expense approval'),
  viewWallet('See society balance'),
  viewScopedFinance('See budgets and spend in scope'),
  logIncome('Log income'),
  reimburse('Mark reimbursements paid'),

  // Work
  assignTasks('Assign tasks'),
  postAnnouncements('Post announcements'),
  manageEvents('Create and run events'),
  scheduleMeetings('Schedule meetings'),
  manageVault('Manage the vault'),

  // People
  approveMembers('Review join requests'),
  manageMembers('Add members, change roles, disable accounts'),
  manageRoles('Edit roles and permissions'),

  // Oversight
  viewAnalytics('See analytics'),
  viewAudit('See the audit log'),
  manageTerm('Run term handover');

  const Permission(this.label);
  final String label;
}

enum RoleScope {
  society('Whole society'),
  department('Their department'),
  domain('Their domain'),
  self('Only themselves');

  const RoleScope(this.label);
  final String label;
}

/// A role is data, not code (doc §2): new roles such as Faculty Advisor can be
/// added without a schema change.
class Role implements Entity {
  const Role({
    required this.id,
    required this.name,
    required this.rank,
    required this.scope,
    required this.permissions,
    this.isOfficeBearer = false,
    this.tier = RoleTier.member,
  });

  @override
  final String id;
  final String name;

  /// 0 = top of the hierarchy. Used for ordering and approval-chain skipping.
  final int rank;
  final RoleScope scope;
  final Set<Permission> permissions;

  /// Office bearers are reassigned during term handover.
  final bool isOfficeBearer;
  final RoleTier tier;

  bool has(Permission p) => permissions.contains(p);

  factory Role.fromJson(Json j) => Role(
    id: j['id'] as String,
    name: j['name'] as String,
    rank: readInt(j['rank'], 99),
    scope: readEnum(RoleScope.values, j['scope'], RoleScope.self),
    permissions: readStrings(j['permissions'])
        .map((p) => readEnumOrNull(Permission.values, p))
        .whereType<Permission>()
        .toSet(),
    isOfficeBearer: j['isOfficeBearer'] as bool? ?? false,
    tier: readEnum(RoleTier.values, j['tier'], RoleTier.member),
  );

  @override
  Json toJson() => {
    'id': id,
    'name': name,
    'rank': rank,
    'scope': scope.name,
    'permissions': permissions.map((p) => p.name).toList(),
    'isOfficeBearer': isOfficeBearer,
    'tier': tier.name,
  };
}

/// The five bands from doc §2 — used to group people in the directory and to
/// decide which approval steps a submitter skips.
enum RoleTier {
  leadership('Leadership'),
  core('Core team'),
  lead('Domain leads'),
  member('Members');

  const RoleTier(this.label);
  final String label;
}

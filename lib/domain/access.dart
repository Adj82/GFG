import '../data/models/models.dart';

/// "What can the signed-in person do, and over whom?"
///
/// Every permission check in the UI goes through here. The same rules must be
/// mirrored in firestore.rules — the UI hides things, the rules enforce them.
class Access {
  Access({
    required this.me,
    required this.role,
    required Map<String, Domain> domains,
  }) : _domains = domains;

  final Member me;
  final Role role;
  final Map<String, Domain> _domains;

  bool get isActive => me.status == MemberStatus.active;

  bool can(Permission p) => isActive && role.has(p);

  Department? get department =>
      me.department ?? _domains[me.domainId]?.department;

  bool get isSocietyWide => role.scope == RoleScope.society;

  /// Does this role's scope cover [domainId] / [dept]?
  /// A null domain with no department means "society-wide", which only
  /// society-scoped roles reach.
  bool reaches({String? domainId, Department? dept}) {
    switch (role.scope) {
      case RoleScope.society:
        return true;
      case RoleScope.department:
        if (domainId != null) {
          return _domains[domainId]?.department == department;
        }
        return dept != null && dept == department;
      case RoleScope.domain:
        return domainId != null && domainId == me.domainId;
      case RoleScope.self:
        return false;
    }
  }

  /// Permission + reach in one check.
  bool canIn(Permission p, {String? domainId, Department? dept}) =>
      can(p) && reaches(domainId: domainId, dept: dept);

  /// Domains this person can assign work in, post to, etc.
  List<Domain> get domainsInReach => _domains.values
      .where((d) => reaches(domainId: d.id))
      .toList(growable: false);

  /// Should this person see something addressed to [audience]?
  bool sees({required Audience audience, String? domainId, Department? dept}) {
    switch (audience) {
      case Audience.society:
        return true;
      case Audience.department:
        return isSocietyWide || dept == department;
      case Audience.domain:
        return isSocietyWide ||
            domainId == me.domainId ||
            reaches(domainId: domainId);
    }
  }

  /// Can this person change [task]? Assigners in scope can; assignees can
  /// move their own task along.
  bool canEditTask(SocietyTask task) =>
      can(Permission.assignTasks) &&
      (task.domainId == null
          ? isSocietyWide
          : reaches(domainId: task.domainId));

  bool canMoveTask(SocietyTask task) =>
      canEditTask(task) || task.assigneeIds.contains(me.id);

  bool canManageEvent(SocietyEvent e) =>
      e.organizerIds.contains(me.id) ||
      (can(Permission.manageEvents) &&
          (e.domainId == null ? isSocietyWide : reaches(domainId: e.domainId)));

  /// Role changes and direct edits: only people with manageMembers.
  bool canManageMember(Member m) =>
      m.id != me.id && (can(Permission.manageMembers) || canSuspend(m));

  /// Can this person see and decide join requests for [domainId]? A domain
  /// lead covers their own domain; the core team covers every domain, so a
  /// request never waits on one person.
  bool canReview(String? domainId) =>
      can(Permission.approveMembers) &&
      (can(Permission.viewAllDomains) || reaches(domainId: domainId));

  /// Suspend (or restore) [m]. The core team can suspend anyone but
  /// themselves; a domain lead only plain members of their own domain.
  bool canSuspend(Member m) {
    if (m.id == me.id) return false;
    if (can(Permission.suspendAnyone)) return true;
    return can(Permission.suspendMembers) &&
        m.roleId == 'member' &&
        m.domainId != null &&
        m.domainId == me.domainId;
  }
}

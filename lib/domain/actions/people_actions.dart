import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/models.dart';
import '../../data/providers.dart';
import '../../data/repositories/repository.dart';
import '../default_roles.dart';
import 'base.dart';

final authActionsProvider = Provider((ref) => AuthActions(ref));
final peopleActionsProvider = Provider((ref) => PeopleActions(ref));
final termActionsProvider = Provider((ref) => TermActions(ref));

class AuthActions extends ActionsBase {
  AuthActions(super.ref);

  AuthRepository get _auth => ref.read(authRepositoryProvider);

  String? validateCampusEmail(String email) {
    final org = ref.read(organizationProvider);
    final domain = org?.emailDomain ?? 'kiit.ac.in';
    final e = email.trim().toLowerCase();
    if (e.isEmpty) return 'Enter your email.';
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(e)) {
      return 'That doesn’t look like an email address.';
    }
    if (!e.endsWith('@$domain')) return 'Use your @$domain email.';
    return null;
  }

  Future<void> signIn(String email, String password) =>
      _auth.signIn(email: email.trim().toLowerCase(), password: password);

  Future<void> signOut() => _auth.signOut();

  Future<void> requestPasswordReset(String email) =>
      _auth.requestPasswordReset(email: email);

  /// Member sign-up (doc §4): campus email, pick a domain, wait for a lead.
  Future<void> applyToJoin({
    required String name,
    required String email,
    required String password,
    required String domainId,
    required int year,
    required String branch,
    required String why,
    String experience = '',
    String portfolio = '',
  }) async {
    final uid = await _auth.signUp(email: email, password: password);
    final at = now;
    await ref
        .read(memberRepo)
        .save(
          Member(
            id: uid,
            name: name.trim(),
            email: email.trim().toLowerCase(),
            roleId: DefaultRoles.member,
            status: MemberStatus.pending,
            joinedAt: at,
            domainId: domainId,
            year: year,
            branch: branch.trim(),
          ),
        );
    await ref
        .read(applicationRepo)
        .save(
          Application(
            id: uid,
            memberId: uid,
            domainId: domainId,
            year: year,
            branch: branch.trim(),
            why: why.trim(),
            experience: experience.trim(),
            portfolio: portfolio.trim(),
            createdAt: at,
          ),
        );
    final domain = ref.read(domainMapProvider)[domainId]?.name ?? 'a domain';
    await notify(
      holdersOf(Permission.approveMembers, domainId: domainId),
      kind: NoticeKind.people,
      title: 'New join request',
      body: '${name.trim()} wants to join $domain.',
      route: '/people/requests/$uid',
    );
  }

  Future<void> changePassword(String newPassword) async {
    await _auth.changePassword(newPassword: newPassword);
    final uid = ref.read(authUserIdProvider);
    final me = uid == null ? null : ref.read(memberMapProvider)[uid];
    if (me != null && me.needsPasswordReset) {
      await ref.read(memberRepo).save(me.copyWith(needsPasswordReset: false));
    }
  }

  Future<void> updateProfile(Member updated) =>
      ref.read(memberRepo).save(updated);
}

class PeopleActions extends ActionsBase {
  PeopleActions(super.ref);

  Future<void> moveApplication(
    Application a,
    ApplicationStage stage, {
    DateTime? interviewAt,
  }) async {
    await ref
        .read(applicationRepo)
        .save(a.copyWith(stage: stage, interviewAt: interviewAt));
    if (stage == ApplicationStage.interview) {
      await notify(
        [a.memberId],
        kind: NoticeKind.people,
        title: 'You’re invited to an interview',
        body: interviewAt == null
            ? 'Your lead will share the time with you.'
            : 'Interview on ${interviewAt.day}/${interviewAt.month} at ${interviewAt.hour}:${interviewAt.minute.toString().padLeft(2, '0')}.',
        route: '/pending',
      );
    }
  }

  Future<void> addNote(Application a, String text) => ref
      .read(applicationRepo)
      .save(
        a.copyWith(
          notes: [
            ...a.notes,
            ReviewNote(authorId: myId, text: text.trim(), at: now),
          ],
        ),
      );

  Future<void> accept(Application a) async {
    final member = ref.read(memberMapProvider)[a.memberId];
    if (member == null) return;
    await ref
        .read(applicationRepo)
        .save(
          a.copyWith(
            stage: ApplicationStage.selected,
            decidedBy: myId,
            decidedAt: now,
          ),
        );
    await ref
        .read(memberRepo)
        .save(
          member.copyWith(status: MemberStatus.active, domainId: a.domainId),
        );
    final domain = ref.read(domainMapProvider)[a.domainId]?.name ?? '';
    await notify(
      [member.id],
      kind: NoticeKind.people,
      title: 'Welcome to the chapter',
      body: 'You’re in $domain. Say hi on the announcements board.',
      route: '/home',
    );
    await notify(
      holdersOf(Permission.assignTasks, domainId: a.domainId),
      kind: NoticeKind.people,
      title: 'New member in $domain',
      body: '${member.name} was accepted by ${access.me.name}.',
      route: '/people/${member.id}',
    );
    await audit(
      'member.accepted',
      '${access.me.name} accepted ${member.name} into $domain',
      targetId: member.id,
    );
  }

  Future<void> decline(Application a, {String note = ''}) async {
    final member = ref.read(memberMapProvider)[a.memberId];
    await ref
        .read(applicationRepo)
        .save(
          a.copyWith(
            stage: ApplicationStage.rejected,
            decidedBy: myId,
            decidedAt: now,
            notes: note.trim().isEmpty
                ? a.notes
                : [
                    ...a.notes,
                    ReviewNote(authorId: myId, text: note.trim(), at: now),
                  ],
          ),
        );
    if (member != null) {
      await ref
          .read(memberRepo)
          .save(member.copyWith(status: MemberStatus.rejected));
      await audit(
        'member.declined',
        '${access.me.name} declined ${member.name}',
        targetId: member.id,
      );
    }
  }

  static String temporaryPassword() {
    const chars = 'abcdefghjkmnpqrstuvwxyz23456789';
    final r = Random.secure();
    return 'gfg-${List.generate(6, (_) => chars[r.nextInt(chars.length)]).join()}';
  }

  /// President/VP adds a core member or lead directly (doc §4). Returns the
  /// temporary password to share with them.
  Future<String> addMember({
    required String name,
    required String email,
    required String roleId,
    String? domainId,
    Department? dept,
  }) async {
    final temp = temporaryPassword();
    final uid = await ref
        .read(authRepositoryProvider)
        .createAccount(email: email, temporaryPassword: temp);
    final role = ref.read(roleMapProvider)[roleId];
    await ref
        .read(memberRepo)
        .save(
          Member(
            id: uid,
            name: name.trim(),
            email: email.trim().toLowerCase(),
            roleId: roleId,
            status: MemberStatus.active,
            joinedAt: now,
            domainId: domainId,
            department: dept,
            needsPasswordReset: true,
          ),
        );
    await audit(
      'member.created',
      '${access.me.name} added ${name.trim()} as ${role?.name ?? roleId}',
      targetId: uid,
    );
    return temp;
  }

  Future<void> changeRole(
    Member m, {
    required String roleId,
    String? domainId,
    Department? dept,
  }) async {
    final roles = ref.read(roleMapProvider);
    final from = roles[m.roleId]?.name ?? m.roleId;
    final to = roles[roleId]?.name ?? roleId;
    await ref
        .read(memberRepo)
        .save(m.copyWith(roleId: roleId, domainId: domainId, department: dept));
    await notify(
      [m.id],
      kind: NoticeKind.people,
      title: 'Your role changed',
      body: 'You’re now $to.',
      route: '/profile',
    );
    await audit(
      'member.role_changed',
      '${access.me.name} changed ${m.name} from $from to $to',
      targetId: m.id,
    );
  }

  Future<void> setDisabled(Member m, bool disabled) async {
    await ref
        .read(memberRepo)
        .save(
          m.copyWith(
            status: disabled ? MemberStatus.disabled : MemberStatus.active,
            disabledAt: disabled ? now : null,
          ),
        );
    await audit(
      disabled ? 'member.disabled' : 'member.enabled',
      '${access.me.name} ${disabled ? 'disabled' : 're-enabled'} ${m.name}',
      targetId: m.id,
    );
  }

  Future<void> setRecruitment({required bool open, String note = ''}) async {
    final org = ref.read(organizationProvider);
    if (org == null) return;
    await ref
        .read(orgRepo)
        .save(
          org.copyWith(recruitmentOpen: open, recruitmentNote: note.trim()),
        );
    await audit(
      'recruitment.${open ? 'opened' : 'closed'}',
      '${access.me.name} ${open ? 'opened' : 'closed'} recruitment',
    );
  }
}

/// One office in the new cabinet: a role, optionally tied to a domain or department.
class Office {
  const Office({
    required this.roleId,
    this.domainId,
    this.dept,
    required this.holderId,
  });

  final String roleId;
  final String? domainId;
  final Department? dept;
  final String? holderId;

  String get key => '$roleId|${domainId ?? ''}|${dept?.name ?? ''}';
}

/// Term rollover (doc §7): reassign offices, keep everyone's history, and
/// disable — never delete — outgoing office bearers who are moving on.
class TermActions extends ActionsBase {
  TermActions(super.ref);

  Future<void> startNewTerm({
    required String newTerm,
    required List<Office> offices,
    required Set<String> alumniIds,
  }) async {
    final org = ref.read(organizationProvider)!;
    final roles = ref.read(roleMapProvider);
    final members = ref.read(memberMapProvider);
    final updated = <String, Member>{};

    Member current(String id) => updated[id] ?? members[id]!;

    // 1. Record the outgoing term for every current office bearer.
    for (final m in members.values.where(
      (m) => m.isActive && (roles[m.roleId]?.isOfficeBearer ?? false),
    )) {
      updated[m.id] = m.copyWith(
        history: [
          ...m.history,
          PastRole(
            term: org.currentTerm,
            roleId: m.roleId,
            domainId: m.domainId,
          ),
        ],
      );
    }

    // 2. Everyone who held an office drops to member unless reassigned below.
    for (final id in updated.keys.toList()) {
      updated[id] = current(
        id,
      ).copyWith(roleId: DefaultRoles.member, department: null);
    }

    // 3. Seat the new cabinet.
    for (final o in offices) {
      final id = o.holderId;
      if (id == null || members[id] == null) continue;
      updated[id] = current(id).copyWith(
        roleId: o.roleId,
        domainId: o.domainId ?? current(id).domainId,
        department: o.dept,
        status: MemberStatus.active,
      );
    }

    // 4. Outgoing people moving on become alumni (disabled, history kept).
    for (final id in alumniIds) {
      if (offices.any((o) => o.holderId == id)) continue;
      updated[id] = current(
        id,
      ).copyWith(status: MemberStatus.disabled, disabledAt: now);
    }

    await ref.read(memberRepo).saveAll(updated.values);
    await ref
        .read(orgRepo)
        .save(org.copyWith(currentTerm: newTerm, termStartedAt: now));
    await notify(
      ref.read(activeMembersProvider).map((m) => m.id),
      kind: NoticeKind.system,
      title: 'Welcome to the $newTerm term',
      body: 'The new cabinet is in place. Check your role on your profile.',
      route: '/profile',
      includeSelf: true,
    );
    await audit(
      'term.rollover',
      '${access.me.name} started the $newTerm term (${offices.length} offices assigned)',
    );
  }
}

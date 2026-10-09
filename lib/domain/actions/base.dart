import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../data/models/models.dart';
import '../../data/providers.dart';
import '../access.dart';

const _uuid = Uuid();

/// Shared plumbing for every action class: who is acting, ids, inbox
/// notifications and the audit log.
///
/// Backend: notifications and audit entries move to Cloud Functions
/// triggered by the writes, so a client can't skip or forge them.
abstract class ActionsBase {
  ActionsBase(this.ref);

  final Ref ref;

  Access get access {
    final a = ref.read(accessProvider);
    if (a == null) throw StateError('Sign in to do that.');
    return a;
  }

  String get myId => access.me.id;

  String newId() => _uuid.v4();

  DateTime get now => DateTime.now();

  Future<void> notify(
    Iterable<String> recipientIds, {
    required NoticeKind kind,
    required String title,
    required String body,
    String? route,
    bool includeSelf = false,
  }) async {
    final me = ref.read(authUserIdProvider);
    final ids = recipientIds.toSet()
      ..removeWhere((id) => !includeSelf && id == me);
    if (ids.isEmpty) return;
    final at = now;
    await ref.read(noticeRepo).saveAll([
      for (final id in ids)
        Notice(
          id: newId(),
          recipientId: id,
          kind: kind,
          title: title,
          body: body,
          route: route,
          createdAt: at,
        ),
    ]);
  }

  Future<void> audit(
    String action,
    String summary, {
    String? targetId,
    String? actorId,
  }) async {
    final org = ref.read(organizationProvider);
    await ref
        .read(auditRepo)
        .save(
          AuditEntry(
            id: newId(),
            actorId: actorId ?? ref.read(authUserIdProvider) ?? 'system',
            action: action,
            summary: summary,
            targetId: targetId,
            at: now,
            term: org?.currentTerm ?? '',
          ),
        );
  }

  String nameOf(String memberId) =>
      ref.read(memberMapProvider)[memberId]?.name ?? 'Someone';

  /// Active members who can see something addressed to this audience.
  List<String> audienceIds({
    required Audience audience,
    String? domainId,
    Department? dept,
  }) {
    final roles = ref.read(roleMapProvider);
    final domains = ref.read(domainMapProvider);
    return ref
        .read(activeMembersProvider)
        .where((m) {
          final r = roles[m.roleId];
          if (r == null) return false;
          return Access(
            me: m,
            role: r,
            domains: domains,
          ).sees(audience: audience, domainId: domainId, dept: dept);
        })
        .map((m) => m.id)
        .toList();
  }

  /// Active members holding [p] whose scope reaches [domainId].
  List<String> holdersOf(Permission p, {String? domainId}) {
    final roles = ref.read(roleMapProvider);
    final domains = ref.read(domainMapProvider);
    return ref
        .read(activeMembersProvider)
        .where((m) {
          final r = roles[m.roleId];
          if (r == null) return false;
          final a = Access(me: m, role: r, domains: domains);
          return domainId == null
              ? a.can(p) && a.isSocietyWide
              : a.canIn(p, domainId: domainId);
        })
        .map((m) => m.id)
        .toList();
  }
}

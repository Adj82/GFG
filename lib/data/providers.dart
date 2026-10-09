import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/access.dart';
import 'local/local_repository.dart';
import 'local/local_store.dart';
import 'models/models.dart';
import 'repositories/repository.dart';

// ───────────────────────────────────────────────────────────────────────────
// Backend switch.
//
// Everything below the "Repositories" line is the only place that knows the
// data lives on the device. To move to Firebase, replace `LocalRepository` /
// `LocalAuthRepository` with Firestore / Firebase Auth implementations of the
// same interfaces. See BACKEND.md.
// ───────────────────────────────────────────────────────────────────────────

/// Overridden in main() once the store is opened.
final localStoreProvider = Provider<LocalStore>(
  (ref) => throw UnimplementedError('Open LocalStore in main()'),
);

// Repositories ──────────────────────────────────────────────────────────────

Provider<Repository<T>> _repo<T extends Entity>(
  String collection,
  T Function(Json) fromJson,
) => Provider<Repository<T>>(
  (ref) =>
      LocalRepository<T>(ref.watch(localStoreProvider), collection, fromJson),
);

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => LocalAuthRepository(ref.watch(localStoreProvider)),
);

final orgRepo = _repo<Organization>(
  Collections.organization,
  Organization.fromJson,
);
final domainRepo = _repo<Domain>(Collections.domains, Domain.fromJson);
final roleRepo = _repo<Role>(Collections.roles, Role.fromJson);
final memberRepo = _repo<Member>(Collections.members, Member.fromJson);
final applicationRepo = _repo<Application>(
  Collections.applications,
  Application.fromJson,
);
final taskRepo = _repo<SocietyTask>(Collections.tasks, SocietyTask.fromJson);
final eventRepo = _repo<SocietyEvent>(
  Collections.events,
  SocietyEvent.fromJson,
);
final attendanceRepo = _repo<AttendanceRecord>(
  Collections.attendance,
  AttendanceRecord.fromJson,
);
final announcementRepo = _repo<Announcement>(
  Collections.announcements,
  Announcement.fromJson,
);
final expenseRepo = _repo<Expense>(Collections.expenses, Expense.fromJson);
final incomeRepo = _repo<Income>(Collections.income, Income.fromJson);
final meetingRepo = _repo<Meeting>(Collections.meetings, Meeting.fromJson);
final vaultRepo = _repo<VaultItem>(Collections.vault, VaultItem.fromJson);
final commentRepo = _repo<Comment>(Collections.comments, Comment.fromJson);
final noticeRepo = _repo<Notice>(Collections.notices, Notice.fromJson);
final auditRepo = _repo<AuditEntry>(Collections.audit, AuditEntry.fromJson);
final registrationRepo = _repo<EventRegistration>(
  Collections.registrations,
  EventRegistration.fromJson,
);

// Live collections ──────────────────────────────────────────────────────────

/// Turns a repository into a synchronous, always-available list for widgets.
Provider<List<T>> _live<T extends Entity>(Provider<Repository<T>> repo) {
  final stream = StreamProvider<List<T>>((ref) => ref.watch(repo).watchAll());
  return Provider<List<T>>((ref) {
    final async = ref.watch(stream);
    return async.value ?? ref.read(repo).cached ?? <T>[];
  });
}

final organizationsProvider = _live(orgRepo);
final domainsProvider = _live(domainRepo);
final rolesProvider = _live(roleRepo);
final membersProvider = _live(memberRepo);
final applicationsProvider = _live(applicationRepo);
final tasksProvider = _live(taskRepo);
final eventsProvider = _live(eventRepo);
final attendanceProvider = _live(attendanceRepo);
final announcementsProvider = _live(announcementRepo);
final expensesProvider = _live(expenseRepo);
final incomeProvider = _live(incomeRepo);
final meetingsProvider = _live(meetingRepo);
final vaultProvider = _live(vaultRepo);
final commentsProvider = _live(commentRepo);
final noticesProvider = _live(noticeRepo);
final auditProvider = _live(auditRepo);
final registrationsProvider = _live(registrationRepo);

// Lookups ───────────────────────────────────────────────────────────────────

final organizationProvider = Provider<Organization?>((ref) {
  final orgs = ref.watch(organizationsProvider);
  return orgs.isEmpty ? null : orgs.first;
});

final domainMapProvider = Provider<Map<String, Domain>>(
  (ref) => {for (final d in ref.watch(domainsProvider)) d.id: d},
);

final roleMapProvider = Provider<Map<String, Role>>(
  (ref) => {for (final r in ref.watch(rolesProvider)) r.id: r},
);

final memberMapProvider = Provider<Map<String, Member>>(
  (ref) => {for (final m in ref.watch(membersProvider)) m.id: m},
);

final eventMapProvider = Provider<Map<String, SocietyEvent>>(
  (ref) => {for (final e in ref.watch(eventsProvider)) e.id: e},
);

final activeMembersProvider = Provider<List<Member>>((ref) {
  final roles = ref.watch(roleMapProvider);
  final list = ref.watch(membersProvider).where((m) => m.isActive).toList()
    ..sort((a, b) {
      final r = (roles[a.roleId]?.rank ?? 99).compareTo(
        roles[b.roleId]?.rank ?? 99,
      );
      return r != 0 ? r : a.name.compareTo(b.name);
    });
  return list;
});

// Session ───────────────────────────────────────────────────────────────────

final _authUserStream = StreamProvider<String?>(
  (ref) => ref.watch(authRepositoryProvider).watchUserId(),
);

final authUserIdProvider = Provider<String?>((ref) {
  final async = ref.watch(_authUserStream);
  return async.hasValue
      ? async.value
      : ref.read(authRepositoryProvider).currentUserId;
});

/// The signed-in member's record (any status), or null when signed out.
final currentMemberProvider = Provider<Member?>((ref) {
  final uid = ref.watch(authUserIdProvider);
  if (uid == null) return null;
  return ref.watch(memberMapProvider)[uid];
});

/// Permissions for the signed-in, active member. Null if signed out or not active.
final accessProvider = Provider<Access?>((ref) {
  final me = ref.watch(currentMemberProvider);
  if (me == null || !me.isActive) return null;
  final role = ref.watch(roleMapProvider)[me.roleId];
  if (role == null) return null;
  return Access(me: me, role: role, domains: ref.watch(domainMapProvider));
});

/// Convenience for screens that only render inside the signed-in shell.
extension AccessRef on Ref {
  Access get access => read(accessProvider)!;
}

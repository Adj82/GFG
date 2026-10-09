import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/activity.dart';
import 'models/models.dart';
import 'providers.dart';

/// Read-side helpers shared across screens. Everything here is "what can the
/// signed-in person see". With Firestore these become scoped queries plus rules.

final visibleAnnouncementsProvider = Provider<List<Announcement>>((ref) {
  final a = ref.watch(accessProvider);
  if (a == null) return const [];
  final list =
      ref
          .watch(announcementsProvider)
          .where(
            (x) => a.sees(
              audience: x.audience,
              domainId: x.domainId,
              dept: x.department,
            ),
          )
          .toList()
        ..sort((x, y) {
          if (x.pinned != y.pinned) return x.pinned ? -1 : 1;
          return y.createdAt.compareTo(x.createdAt);
        });
  return list;
});

final visibleMeetingsProvider = Provider<List<Meeting>>((ref) {
  final a = ref.watch(accessProvider);
  if (a == null) return const [];
  return ref
      .watch(meetingsProvider)
      .where(
        (m) => a.sees(
          audience: m.audience,
          domainId: m.domainId,
          dept: m.department,
        ),
      )
      .toList()
    ..sort((x, y) => x.startsAt.compareTo(y.startsAt));
});

/// Events everyone can see (events are chapter-wide; domain events are
/// highlighted for their domain but open to all, since students attend across domains).
final upcomingEventsProvider = Provider<List<SocietyEvent>>((ref) {
  final now = DateTime.now();
  return ref
      .watch(eventsProvider)
      .where((e) => !e.cancelled && e.endsAt.isAfter(now))
      .toList()
    ..sort((a, b) => a.startsAt.compareTo(b.startsAt));
});

final pastEventsProvider = Provider<List<SocietyEvent>>((ref) {
  final now = DateTime.now();
  return ref
      .watch(eventsProvider)
      .where((e) => e.cancelled || e.endsAt.isBefore(now))
      .toList()
    ..sort((a, b) => b.startsAt.compareTo(a.startsAt));
});

final myTasksProvider = Provider<List<SocietyTask>>((ref) {
  final me = ref.watch(authUserIdProvider);
  return ref
      .watch(tasksProvider)
      .where((t) => me != null && t.assigneeIds.contains(me))
      .toList();
});

/// Tasks the signed-in person can see: their own plus everything in their reach.
final visibleTasksProvider = Provider<List<SocietyTask>>((ref) {
  final a = ref.watch(accessProvider);
  if (a == null) return const [];
  return ref.watch(tasksProvider).where((t) {
    if (t.assigneeIds.contains(a.me.id) || t.createdBy == a.me.id) return true;
    if (t.domainId == null) return true;
    return a.reaches(domainId: t.domainId) || t.domainId == a.me.domainId;
  }).toList();
});

/// Join requests this person can review.
final pendingRequestsProvider = Provider<List<Application>>((ref) {
  final a = ref.watch(accessProvider);
  if (a == null || !a.can(Permission.approveMembers)) return const [];
  final members = ref.watch(memberMapProvider);
  return ref
      .watch(applicationsProvider)
      .where(
        (x) =>
            x.stage.isOpen &&
            members[x.memberId]?.status == MemberStatus.pending &&
            a.reaches(domainId: x.domainId),
      )
      .toList()
    ..sort((x, y) => x.createdAt.compareTo(y.createdAt));
});

final myNoticesProvider = Provider<List<Notice>>((ref) {
  final me = ref.watch(authUserIdProvider);
  return ref.watch(noticesProvider).where((n) => n.recipientId == me).toList()
    ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
});

/// Contribution counts per day for the whole chapter or one member.
final activityProvider = Provider.family<Map<DateTime, int>, String?>((
  ref,
  memberId,
) {
  return Activity.byDay(
    tasks: ref.watch(tasksProvider),
    attendance: ref.watch(attendanceProvider),
    expenses: ref.watch(expensesProvider),
    announcements: ref.watch(announcementsProvider),
    memberId: memberId,
  );
});

/// Which events a member attended (for profiles and the term report).
final attendedEventsProvider = Provider.family<List<SocietyEvent>, String>((
  ref,
  memberId,
) {
  final events = ref.watch(eventMapProvider);
  return ref
      .watch(attendanceProvider)
      .where(
        (r) => r.target == AttendanceTarget.event && r.memberId == memberId,
      )
      .map((r) => events[r.targetId])
      .whereType<SocietyEvent>()
      .toList()
    ..sort((a, b) => b.startsAt.compareTo(a.startsAt));
});

final eventAttendanceProvider = Provider.family<List<AttendanceRecord>, String>(
  (ref, eventId) {
    return ref
        .watch(attendanceProvider)
        .where(
          (r) => r.target == AttendanceTarget.event && r.targetId == eventId,
        )
        .toList();
  },
);

/// Display name of whoever, tolerant of removed members.
String memberName(Map<String, Member> members, String? id) =>
    members[id]?.name ?? 'Former member';

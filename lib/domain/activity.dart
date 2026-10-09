import '../data/models/models.dart';

/// Contribution counting — powers the green activity grid on Home, profiles
/// and Analytics. One point per completed task, event or meeting attended,
/// expense filed, announcement posted.
abstract final class Activity {
  static DateTime _day(DateTime d) => DateTime(d.year, d.month, d.day);

  static Map<DateTime, int> byDay({
    required Iterable<SocietyTask> tasks,
    required Iterable<AttendanceRecord> attendance,
    required Iterable<Expense> expenses,
    required Iterable<Announcement> announcements,
    String? memberId,
  }) {
    final out = <DateTime, int>{};
    void add(DateTime d) =>
        out.update(_day(d), (v) => v + 1, ifAbsent: () => 1);

    for (final t in tasks) {
      if (t.completedAt == null) continue;
      if (memberId != null && !t.assigneeIds.contains(memberId)) continue;
      add(t.completedAt!);
    }
    for (final a in attendance) {
      if (memberId != null && a.memberId != memberId) continue;
      add(a.at);
    }
    for (final e in expenses) {
      if (memberId != null && e.submittedBy != memberId) continue;
      add(e.submittedAt);
    }
    for (final a in announcements) {
      if (memberId != null && a.authorId != memberId) continue;
      add(a.createdAt);
    }
    return out;
  }

  /// Current run of consecutive active days (allowing today to be empty).
  static int streak(Map<DateTime, int> days, {DateTime? now}) {
    var d = _day(now ?? DateTime.now());
    if ((days[d] ?? 0) == 0) d = d.subtract(const Duration(days: 1));
    var n = 0;
    while ((days[d] ?? 0) > 0) {
      n++;
      d = d.subtract(const Duration(days: 1));
    }
    return n;
  }

  static int total(Map<DateTime, int> days, {required DateTime since}) => days
      .entries
      .where((e) => !e.key.isBefore(_day(since)))
      .fold(0, (s, e) => s + e.value);
}

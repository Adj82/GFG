import 'package:intl/intl.dart';

/// Formatting helpers. Everything user-facing goes through here so the
/// app reads consistently (₹ in Indian grouping, short relative dates).
abstract final class Fmt {
  static final _inr = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 0,
  );
  static final _inrPaise = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 2,
  );

  /// ₹12,500
  static String money(num v) => (v % 1 == 0 ? _inr : _inrPaise).format(v);

  /// ₹1.2L, ₹45K
  static String moneyShort(num v) {
    final a = v.abs();
    if (a < 10000) return money(v);
    String f(double x) =>
        x % 1 == 0 ? x.toStringAsFixed(0) : x.toStringAsFixed(1);
    final sign = v < 0 ? '-' : '';
    if (a >= 10000000) return '$sign₹${f(a / 10000000)}Cr';
    if (a >= 100000) return '$sign₹${f(a / 100000)}L';
    return '$sign₹${f(a / 1000)}K';
  }

  static String date(DateTime d) => DateFormat('d MMM yyyy').format(d);
  static String dateShort(DateTime d) => DateFormat('d MMM').format(d);
  static String weekdayDate(DateTime d) => DateFormat('EEE, d MMM').format(d);
  static String time(DateTime d) => DateFormat('h:mm a').format(d);
  static String dateTime(DateTime d) => '${weekdayDate(d)}, ${time(d)}';
  static String monthYear(DateTime d) => DateFormat('MMMM yyyy').format(d);
  static String month(DateTime d) => DateFormat('MMM').format(d);

  /// "Today, 6:00 PM", "Tomorrow, 10:00 AM", "Fri, 17 Oct, 5:30 PM"
  static String when(DateTime d, {DateTime? now}) {
    final n = now ?? DateTime.now();
    final day = DateTime(d.year, d.month, d.day);
    final today = DateTime(n.year, n.month, n.day);
    final diff = day.difference(today).inDays;
    if (diff == 0) return 'Today, ${time(d)}';
    if (diff == 1) return 'Tomorrow, ${time(d)}';
    if (diff == -1) return 'Yesterday, ${time(d)}';
    return dateTime(d);
  }

  /// "just now", "5m ago", "3h ago", "2d ago", "12 Sep"
  static String ago(DateTime d, {DateTime? now}) {
    final n = now ?? DateTime.now();
    final s = n.difference(d);
    if (s.isNegative) return dueIn(d, now: n);
    if (s.inSeconds < 60) return 'just now';
    if (s.inMinutes < 60) return '${s.inMinutes}m ago';
    if (s.inHours < 24) return '${s.inHours}h ago';
    if (s.inDays < 7) return '${s.inDays}d ago';
    return d.year == n.year ? dateShort(d) : date(d);
  }

  /// Deadline phrasing relative to today: "Due today", "Due in 3 days", "2 days overdue".
  static String dueIn(DateTime d, {DateTime? now}) {
    final n = now ?? DateTime.now();
    final day = DateTime(d.year, d.month, d.day);
    final today = DateTime(n.year, n.month, n.day);
    final diff = day.difference(today).inDays;
    if (diff == 0) return 'Due today';
    if (diff == 1) return 'Due tomorrow';
    if (diff > 1 && diff < 7) return 'Due in $diff days';
    if (diff >= 7) return 'Due ${dateShort(d)}';
    if (diff == -1) return '1 day overdue';
    return '${-diff} days overdue';
  }

  static String countdown(DateTime d, {DateTime? now}) {
    final n = now ?? DateTime.now();
    final day = DateTime(d.year, d.month, d.day);
    final today = DateTime(n.year, n.month, n.day);
    final diff = day.difference(today).inDays;
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Tomorrow';
    if (diff > 1) return 'In $diff days';
    return dateShort(d);
  }

  static String percent(double v) => '${(v * 100).round()}%';

  static String fileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(0)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  static String plural(int n, String one, [String? many]) =>
      '$n ${n == 1 ? one : (many ?? '${one}s')}';

  static String initials(String name) {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }

  static String firstName(String name) =>
      name.trim().split(RegExp(r'\s+')).first;
}

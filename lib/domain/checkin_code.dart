import 'dart:convert';

import 'package:crypto/crypto.dart';

/// Rotating check-in codes for event attendance.
///
/// The organiser's screen shows a QR + 6-digit code that changes every
/// [window]. A screenshot forwarded to a group chat stops working within
/// a minute, which a static QR does not.
///
/// Backend: keep the event secret server-side and verify in a Cloud Function.
abstract final class CheckInCode {
  static const window = Duration(seconds: 30);
  static const scheme = 'societyos';

  static int _slot(DateTime at) =>
      at.millisecondsSinceEpoch ~/ window.inMilliseconds;

  static String _codeForSlot(String secret, String eventId, int slot) {
    final mac = Hmac(
      sha256,
      utf8.encode(secret),
    ).convert(utf8.encode('$eventId:$slot')).bytes;
    final n = ((mac[0] & 0x7f) << 24) | (mac[1] << 16) | (mac[2] << 8) | mac[3];
    return (n % 1000000).toString().padLeft(6, '0');
  }

  static String codeAt(String secret, String eventId, DateTime at) =>
      _codeForSlot(secret, eventId, _slot(at));

  /// Accepts the current code and the previous one, to absorb slow scans and
  /// small clock differences.
  static bool verify(String secret, String eventId, String code, DateTime now) {
    final c = code.trim();
    final s = _slot(now);
    return c == _codeForSlot(secret, eventId, s) ||
        c == _codeForSlot(secret, eventId, s - 1);
  }

  /// Time left before the code on screen changes.
  static Duration remaining(DateTime now) {
    final ms = window.inMilliseconds;
    return Duration(milliseconds: ms - (now.millisecondsSinceEpoch % ms));
  }

  static String payload(String eventId, String code) =>
      '$scheme://checkin?e=$eventId&c=$code';

  static ({String eventId, String code})? parse(String raw) {
    final uri = Uri.tryParse(raw.trim());
    if (uri == null || uri.scheme != scheme || uri.host != 'checkin') {
      return null;
    }
    final e = uri.queryParameters['e'];
    final c = uri.queryParameters['c'];
    if (e == null || c == null) return null;
    return (eventId: e, code: c);
  }
}

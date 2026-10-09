/// Small JSON helpers shared by every model.
///
/// Dates are stored as ISO-8601 strings. When the Firestore backend lands,
/// convert `Timestamp` <-> ISO string in the Firestore converter only; the
/// models stay unchanged.
library;

typedef Json = Map<String, dynamic>;

DateTime readDate(Object? v) => v is DateTime ? v : DateTime.parse(v as String);

DateTime? readDateOrNull(Object? v) => v == null ? null : readDate(v);

String? writeDate(DateTime? d) => d?.toIso8601String();

T readEnum<T extends Enum>(List<T> values, Object? name, T fallback) {
  if (name is! String) return fallback;
  for (final v in values) {
    if (v.name == name) return v;
  }
  return fallback;
}

T? readEnumOrNull<T extends Enum>(List<T> values, Object? name) {
  if (name is! String) return null;
  for (final v in values) {
    if (v.name == name) return v;
  }
  return null;
}

List<String> readStrings(Object? v) =>
    v is List ? v.map((e) => e.toString()).toList() : <String>[];

List<T> readList<T>(Object? v, T Function(Json) from) => v is List
    ? v.map((e) => from(Map<String, dynamic>.from(e as Map))).toList()
    : <T>[];

double readDouble(Object? v, [double fallback = 0]) =>
    v is num ? v.toDouble() : fallback;

int readInt(Object? v, [int fallback = 0]) => v is num ? v.toInt() : fallback;

/// Every stored record has an id and serialises to JSON.
abstract interface class Entity {
  String get id;
  Json toJson();
}

/// Sentinel used by copyWith methods to tell "set to null" apart from "leave as is".
const Object unset = _Unset();

class _Unset {
  const _Unset();
}

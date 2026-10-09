import 'dart:async';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/json.dart';
import '../repositories/repository.dart';

/// A tiny document store on top of SharedPreferences that behaves like
/// Firestore: named collections of JSON documents with live listeners.
///
/// It exists so the whole app works end to end before the backend is ready.
class LocalStore {
  LocalStore._(this._prefs);

  static const _prefix = 'societyos.v1.';
  static const _seededKey = '${_prefix}_seeded';
  static const _sessionKey = '${_prefix}_session';

  final SharedPreferences _prefs;
  final _cache = <String, Map<String, Json>>{};
  final _controllers = <String, StreamController<List<Json>>>{};

  static Future<LocalStore> open() async =>
      LocalStore._(await SharedPreferences.getInstance());

  bool get isSeeded => _prefs.getBool(_seededKey) ?? false;

  Future<void> markSeeded() => _prefs.setBool(_seededKey, true);

  String? get sessionUserId => _prefs.getString(_sessionKey);

  Future<void> setSessionUserId(String? id) => id == null
      ? _prefs.remove(_sessionKey)
      : _prefs.setString(_sessionKey, id);

  /// Device-only preferences (theme etc.). Never synced.
  String? setting(String key) => _prefs.getString('${_prefix}setting.$key');

  Future<void> setSetting(String key, String value) =>
      _prefs.setString('${_prefix}setting.$key', value);

  Map<String, Json> _collection(String name) {
    return _cache.putIfAbsent(name, () {
      final raw = _prefs.getString('$_prefix$name');
      if (raw == null) return <String, Json>{};
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      return decoded.map(
        (k, v) => MapEntry(k, Map<String, dynamic>.from(v as Map)),
      );
    });
  }

  List<Json> all(String collection) =>
      _collection(collection).values.toList(growable: false);

  Json? get(String collection, String id) => _collection(collection)[id];

  Future<void> put(String collection, Json doc) async {
    _collection(collection)[doc['id'] as String] = doc;
    await _commit(collection);
  }

  Future<void> putAll(String collection, Iterable<Json> docs) async {
    final c = _collection(collection);
    for (final d in docs) {
      c[d['id'] as String] = d;
    }
    await _commit(collection);
  }

  Future<void> remove(String collection, String id) async {
    _collection(collection).remove(id);
    await _commit(collection);
  }

  Stream<List<Json>> watch(String collection) async* {
    yield all(collection);
    yield* _controller(collection).stream;
  }

  /// Wipes everything (used by "Reset demo data").
  Future<void> clear() async {
    for (final name in Collections.all) {
      await _prefs.remove('$_prefix$name');
      _cache[name] = <String, Json>{};
      _controllers[name]?.add(const []);
    }
    await _prefs.remove(_seededKey);
  }

  StreamController<List<Json>> _controller(String collection) => _controllers
      .putIfAbsent(collection, () => StreamController<List<Json>>.broadcast());

  Future<void> _commit(String collection) async {
    final c = _collection(collection);
    _controllers[collection]?.add(c.values.toList(growable: false));
    await _prefs.setString('$_prefix$collection', jsonEncode(c));
  }
}

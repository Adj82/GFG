import 'dart:async';
import 'dart:convert';

import 'package:crypto/crypto.dart';

import '../models/json.dart';
import '../repositories/repository.dart';
import 'local_store.dart';

class LocalRepository<T extends Entity> implements Repository<T> {
  LocalRepository(this._store, this._collection, this._fromJson);

  final LocalStore _store;
  final String _collection;
  final T Function(Json) _fromJson;

  List<T> _decode(List<Json> docs) =>
      docs.map(_fromJson).toList(growable: false);

  @override
  List<T>? get cached => _decode(_store.all(_collection));

  @override
  Stream<List<T>> watchAll() => _store.watch(_collection).map(_decode);

  @override
  Future<List<T>> fetchAll() async => _decode(_store.all(_collection));

  @override
  Future<T?> fetch(String id) async {
    final doc = _store.get(_collection, id);
    return doc == null ? null : _fromJson(doc);
  }

  @override
  Future<void> save(T item) => _store.put(_collection, item.toJson());

  @override
  Future<void> saveAll(Iterable<T> items) =>
      _store.putAll(_collection, items.map((e) => e.toJson()));

  @override
  Future<void> delete(String id) => _store.remove(_collection, id);
}

/// Stand-in for Firebase Auth. Passwords are stored as salted SHA-256 hashes
/// on the device — fine for a demo build, replaced entirely by Firebase Auth.
class LocalAuthRepository implements AuthRepository {
  LocalAuthRepository(this._store) : _userId = _store.sessionUserId;

  final LocalStore _store;
  String? _userId;
  final _changes = StreamController<String?>.broadcast();

  static String hash(String email, String password) => sha256
      .convert(utf8.encode('societyos:${email.toLowerCase()}:$password'))
      .toString();

  Json? _credentialFor(String email) {
    final e = email.trim().toLowerCase();
    for (final c in _store.all(Collections.credentials)) {
      if (c['email'] == e) return c;
    }
    return null;
  }

  Future<void> _setUser(String? id) async {
    _userId = id;
    await _store.setSessionUserId(id);
    _changes.add(id);
  }

  @override
  String? get currentUserId => _userId;

  @override
  Stream<String?> watchUserId() async* {
    yield _userId;
    yield* _changes.stream;
  }

  @override
  Future<String> signIn({
    required String email,
    required String password,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 350));
    final cred = _credentialFor(email);
    if (cred == null) {
      throw const AuthFailure(
        'No account uses that email. Check it, or request to join.',
      );
    }
    if (cred['hash'] != hash(email, password)) {
      throw const AuthFailure('That password is incorrect.');
    }
    await _setUser(cred['id'] as String);
    return cred['id'] as String;
  }

  @override
  Future<String> signUp({
    required String email,
    required String password,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 350));
    if (_credentialFor(email) != null) {
      throw const AuthFailure(
        'An account with this email already exists. Sign in instead.',
      );
    }
    final id = 'u_${DateTime.now().microsecondsSinceEpoch.toRadixString(36)}';
    await _store.put(Collections.credentials, {
      'id': id,
      'email': email.trim().toLowerCase(),
      'hash': hash(email, password),
    });
    await _setUser(id);
    return id;
  }

  @override
  String? get currentEmail {
    final id = _userId;
    if (id == null) return null;
    return _store.get(Collections.credentials, id)?['email'] as String?;
  }

  /// Stands in for the Google account picker: the demo screen asks which
  /// address to "sign in" with, and this applies the same domain rule the real
  /// thing does.
  @override
  Future<GoogleIdentity> signInWithGoogle({
    required String allowedDomain,
    String? simulatedEmail,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 350));
    final email = (simulatedEmail ?? '').trim().toLowerCase();
    if (email.isEmpty) throw const AuthFailure('Sign-in was cancelled.');
    if (!email.endsWith('@$allowedDomain')) {
      throw AuthFailure('Use your @$allowedDomain Google account.');
    }
    var cred = _credentialFor(email);
    if (cred == null) {
      final id = 'u_${DateTime.now().microsecondsSinceEpoch.toRadixString(36)}';
      cred = {'id': id, 'email': email, 'hash': ''};
      await _store.put(Collections.credentials, cred);
    }
    await _setUser(cred['id'] as String);
    final local = email.split('@').first;
    return GoogleIdentity(uid: cred['id'] as String, email: email, name: local);
  }

  @override
  Future<void> changePassword({required String newPassword}) async {
    final id = _userId;
    if (id == null) {
      throw const AuthFailure('Sign in again to change your password.');
    }
    final cred = _store.get(Collections.credentials, id);
    if (cred == null) throw const AuthFailure('Account not found.');
    await _store.put(Collections.credentials, {
      ...cred,
      'hash': hash(cred['email'] as String, newPassword),
    });
  }

  @override
  Future<void> requestPasswordReset({required String email}) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    if (_credentialFor(email) == null) {
      throw const AuthFailure('No account uses that email.');
    }
  }

  @override
  Future<void> signOut() => _setUser(null);
}

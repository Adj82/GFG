import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/json.dart';
import '../repositories/repository.dart';

/// The society all data lives under: `orgs/{orgId}/{collection}`.
const kOrgId = 'gfg-kiit';

/// Collection name in Firestore for a [Collections] name. The organisation
/// record is `meta/org` in the rules.
String firestoreCollection(String name) =>
    name == Collections.organization ? 'meta' : name;

/// Firestore implementation of [Repository]. Documents are the models' own
/// JSON, so nothing else in the app changes.
class FirestoreRepository<T extends Entity> implements Repository<T> {
  FirestoreRepository(FirebaseFirestore db, String collection, this._fromJson)
    : _col = db
          .collection('orgs')
          .doc(kOrgId)
          .collection(firestoreCollection(collection));

  final CollectionReference<Map<String, dynamic>> _col;
  final T Function(Json) _fromJson;
  List<T>? _cached;

  T _decode(DocumentSnapshot<Map<String, dynamic>> d) =>
      _fromJson({...?d.data(), 'id': d.id});

  @override
  List<T>? get cached => _cached;

  @override
  Stream<List<T>> watchAll() => _col.snapshots().map((s) {
    final list = [for (final d in s.docs) _decode(d)];
    _cached = list;
    return list;
  });

  @override
  Future<List<T>> fetchAll() async {
    final s = await _col.get();
    return _cached = [for (final d in s.docs) _decode(d)];
  }

  @override
  Future<T?> fetch(String id) async {
    final d = await _col.doc(id).get();
    return d.exists ? _decode(d) : null;
  }

  @override
  Future<void> save(T item) => _col.doc(item.id).set(item.toJson());

  @override
  Future<void> saveAll(Iterable<T> items) async {
    final batch = _col.firestore.batch();
    for (final i in items) {
      batch.set(_col.doc(i.id), i.toJson());
    }
    await batch.commit();
  }

  @override
  Future<void> delete(String id) => _col.doc(id).delete();
}

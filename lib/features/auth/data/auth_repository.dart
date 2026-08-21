import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../domain/models/user_model.dart';
import '../domain/models/role.dart';

class AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<SocietyUser?> getUserData(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    if (!doc.exists) return null;
    return SocietyUser.fromJson(doc.data()!);
  }

  Future<SocietyRole?> getRoleData(String orgId, String roleName) async {
    final query = await _db
        .collection('roles')
        .where('orgId', isEqualTo: orgId)
        .where('name', isEqualTo: roleName)
        .limit(1)
        .get();
    
    if (query.docs.isEmpty) return null;
    return SocietyRole.fromJson(query.docs.first.data());
  }

  Future<void> login(String email, String password) async {
    await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<void> logout() async {
    await _auth.signOut();
  }
}

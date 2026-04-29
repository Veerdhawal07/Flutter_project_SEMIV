import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Helper to get collection name based on role
  String _getCollection(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return 'admins';
      case UserRole.officer:
        return 'officers';
      case UserRole.user:
        return 'users';
    }
  }

  Future<UserModel?> getUserData(String uid, UserRole role) async {
    try {
      DocumentSnapshot doc =
          await _db.collection(_getCollection(role)).doc(uid).get();
      if (doc.exists) {
        return UserModel.fromMap(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<UserCredential?> signUp({
    required String email,
    required String password,
    required UserModel userModel,
  }) async {
    try {
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await _db
          .collection(_getCollection(userModel.role))
          .doc(credential.user!.uid)
          .set(userModel.toMap());

      return credential;
    } catch (e) {
      rethrow;
    }
  }

  Future<UserCredential?> signIn(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}

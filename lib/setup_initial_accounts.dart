import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  print('🚀 Setting up initial admin and officer accounts...');

  try {
    // Create Admin Account
    await _createAdminAccount();

    // Create Officer Account
    await _createOfficerAccount();

    print('✅ Setup completed successfully!');
    print('📧 Admin: admin@village.com / admin123');
    print('📧 Officer: officer@village.com / officer123');
  } catch (e) {
    print('❌ Error during setup: $e');
  }
}

Future<void> _createAdminAccount() async {
  const email = 'admin@village.com';
  const password = 'admin123';

  try {
    // Create Firebase Auth user
    UserCredential credential =
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    String uid = credential.user!.uid;

    // Create admin document in Firestore
    await FirebaseFirestore.instance.collection('admins').doc(uid).set({
      'uid': uid,
      'fullName': 'System Admin',
      'email': email,
      'phone': '1234567890',
      'role': 'admin',
      'createdAt': FieldValue.serverTimestamp(),
    });

    print('✅ Admin account created successfully');
  } on FirebaseAuthException catch (e) {
    if (e.code == 'email-already-in-use') {
      print('⚠️  Admin email already exists, checking Firestore...');
      // Find the existing user and ensure Firestore document exists
      final users = await FirebaseAuth.instance.fetchSignInMethodsForEmail(email);
      if (users.isNotEmpty) {
        print('✅ Admin account already exists in Firebase Auth');
      }
    } else {
      rethrow;
    }
  }
}

Future<void> _createOfficerAccount() async {
  const email = 'officer@village.com';
  const password = 'officer123';

  try {
    // Create Firebase Auth user
    UserCredential credential =
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    String uid = credential.user!.uid;

    // Create officer document in Firestore
    await FirebaseFirestore.instance.collection('officers').doc(uid).set({
      'uid': uid,
      'fullName': 'Field Officer',
      'email': email,
      'phone': '0987654321',
      'role': 'officer',
      'department': 'General Administration',
      'area': 'Village Center',
      'officerId': 'OFF001',
      'createdAt': FieldValue.serverTimestamp(),
    });

    print('✅ Officer account created successfully');
  } on FirebaseAuthException catch (e) {
    if (e.code == 'email-already-in-use') {
      print('⚠️  Officer email already exists, checking Firestore...');
      final users = await FirebaseAuth.instance.fetchSignInMethodsForEmail(email);
      if (users.isNotEmpty) {
        print('✅ Officer account already exists in Firebase Auth');
      }
    } else {
      rethrow;
    }
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SetupInitialAccountsScreen extends StatefulWidget {
  const SetupInitialAccountsScreen({super.key});

  @override
  State<SetupInitialAccountsScreen> createState() =>
      _SetupInitialAccountsScreenState();
}

class _SetupInitialAccountsScreenState
    extends State<SetupInitialAccountsScreen> {
  bool _isLoading = false;
  List<String> _logs = [];

  void _log(String message) {
    setState(() {
      _logs.add(message);
    });
  }

  Future<void> _setupAccounts() async {
    setState(() {
      _isLoading = true;
      _logs.clear();
    });

    _log(' Setting up initial admin and officer accounts...\n');

    try {
      await _createAdminAccount();
      await _createOfficerAccount();
      _log('\n Setup completed successfully!');
      _log(' Admin: admin@village.com / admin123');
      _log(' Officer: officer@village.com / officer123');
    } catch (e) {
      _log('\n Error during setup: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _createAdminAccount() async {
    const email = 'admin@village.com';
    const password = 'admin123';

    try {
      _log('Creating admin account...');

      
      UserCredential credential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      String uid = credential.user!.uid;

      
      await FirebaseFirestore.instance.collection('admins').doc(uid).set({
        'uid': uid,
        'fullName': 'System Admin',
        'email': email,
        'phone': '1234567890',
        'role': 'admin',
        'createdAt': FieldValue.serverTimestamp(),
      });

      _log(' Admin account created successfully\n');
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        _log('  Admin email already exists in Firebase Auth');
        _log(' Checking if Firestore document exists...');
        
        
        await _ensureAdminDocumentExists(email);
      } else {
        _log(' Error creating admin: ${e.message}');
        rethrow;
      }
    }
  }

  Future<void> _ensureAdminDocumentExists(String email) async {
    try {
      
      UserCredential credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: 'admin123',
      );
      
      String uid = credential.user!.uid;
      _log(' Found admin UID: $uid');
      
      
      var doc = await FirebaseFirestore.instance.collection('admins').doc(uid).get();
      
      if (!doc.exists) {
        _log(' Creating Firestore document for existing admin...');
        await FirebaseFirestore.instance.collection('admins').doc(uid).set({
          'uid': uid,
          'fullName': 'System Admin',
          'email': email,
          'phone': '1234567890',
          'role': 'admin',
          'createdAt': FieldValue.serverTimestamp(),
        });
        _log(' Admin Firestore document created successfully');
      } else {
        _log(' Admin Firestore document already exists');
      }
      
      
      await FirebaseAuth.instance.signOut();
      _log('');
    } catch (e) {
      _log(' Error ensuring admin document: $e');
    }
  }

  Future<void> _createOfficerAccount() async {
    const email = 'officer@village.com';
    const password = 'officer123';

    try {
      _log('Creating officer account...');

      
      UserCredential credential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      String uid = credential.user!.uid;

      
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

      _log(' Officer account created successfully\n');
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        _log('  Officer email already exists in Firebase Auth');
        _log(' Checking if Firestore document exists...');
        
        
        await _ensureOfficerDocumentExists(email);
      } else {
        _log(' Error creating officer: ${e.message}');
        rethrow;
      }
    }
  }

  Future<void> _ensureOfficerDocumentExists(String email) async {
    try {
      
      UserCredential credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: 'officer123',
      );
      
      String uid = credential.user!.uid;
      _log(' Found officer UID: $uid');
      
      
      var doc = await FirebaseFirestore.instance.collection('officers').doc(uid).get();
      
      if (!doc.exists) {
        _log(' Creating Firestore document for existing officer...');
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
        _log(' Officer Firestore document created successfully');
      } else {
        _log(' Officer Firestore document already exists');
      }
      
      
      await FirebaseAuth.instance.signOut();
      _log('');
    } catch (e) {
      _log(' Error ensuring officer document: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Setup Initial Accounts'),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Initial Account Setup',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'This will create the following accounts:\n\n'
              ' Admin:\n'
              '   Email: admin@village.com\n'
              '   Password: admin123\n\n'
              ' Officer:\n'
              '   Email: officer@village.com\n'
              '   Password: officer123',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _setupAccounts,
              icon: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.person_add),
              label: Text(_isLoading ? 'Setting Up...' : 'Create Accounts'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.green,
              ),
            ),
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: _logs.isEmpty
                    ? const Center(
                        child: Text(
                          'Click the button to start setup...',
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    : SingleChildScrollView(
                        child: Text(
                          _logs.join('\n'),
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 14,
                          ),
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

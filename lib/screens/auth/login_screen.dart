import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../l10n/app_localizations.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import 'registration_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  final UserRole role;
  const LoginScreen({super.key, required this.role});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    
    if (widget.role == UserRole.admin) {
      _emailController.text = 'admin@village.com';
    }
  }

  Future<void> _login() async {
    if (_emailController.text.trim().isEmpty ||
        _passwordController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter email and password')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final authService = ref.read(authServiceProvider);

      
      final credential = await authService.signIn(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      if (credential?.user != null) {
        final user = credential!.user!;
        final email = user.email;

        
        if (widget.role == UserRole.admin && email != 'admin@village.com') {
          await authService.signOut();
          throw 'Unauthorized: Only the main Admin account can access this portal.';
        }

        
        if (widget.role == UserRole.user && email == 'admin@village.com') {
          await authService.signOut();
          throw 'Unauthorized: Reserved accounts cannot log in as a Villager.';
        }

        
        final userModel =
            await authService.getUserData(user.uid, widget.role);

        if (userModel == null) {
          await authService.signOut();
          String collectionName = widget.role == UserRole.admin
              ? 'admins'
              : (widget.role == UserRole.officer ? 'officers' : 'users');
          throw 'Profile Error: No record found in the "$collectionName" collection. Access denied for this portal.';
        }

        
        if (userModel.role != widget.role) {
          await authService.signOut();
          throw 'Role Mismatch: This account is registered as ${userModel.role.name.toUpperCase()} in the database.';
        }
      }

      if (mounted) {
        
        ref.read(userRoleProvider.notifier).state = widget.role;
        
        
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_role', widget.role.name);
        
        if (mounted) {
          
          Navigator.of(context).popUntil((route) => route.isFirst);
        }
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = e.toString();
        
        if (errorMessage.contains('user-not-found') ||
            errorMessage.contains('invalid-credential')) {
          errorMessage = 'Invalid email or password.';
        } else if (errorMessage.contains('wrong-password')) {
          errorMessage = 'Incorrect password.';
        } else if (errorMessage.contains('network-request-failed')) {
          errorMessage = 'Network error. Please check your connection.';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage.replaceFirst('Exception: ', '')),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
          title: Text('${l10n.login} - ${widget.role.name.toUpperCase()}')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Welcome Back',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text('Please sign in to continue'),
            const SizedBox(height: 32),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                hintText: 'Email',
                prefixIcon: Icon(Icons.email),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(
                hintText: 'Password',
                prefixIcon: Icon(Icons.lock),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 32),
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(onPressed: _login, child: const Text('LOGIN')),
            const SizedBox(height: 16),
            if (widget.role == UserRole.user)
              Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const RegistrationScreen(),
                      ),
                    );
                  },
                  child: const Text("Don't have an account? Register"),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_model.dart';
import '../services/auth_service.dart';

final authServiceProvider = Provider((ref) => AuthService());

final userRoleProvider = StateProvider<UserRole>((ref) => UserRole.user);

final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authServiceProvider).authStateChanges;
});

final userModelProvider = FutureProvider<UserModel?>((ref) async {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return null;
  
  // First, try to get role from the provider
  var role = ref.watch(userRoleProvider);
  
  // If role is still default (user), try to load from SharedPreferences
  if (role == UserRole.user) {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedRole = prefs.getString('user_role');
      if (savedRole != null) {
        role = UserRole.values.firstWhere(
          (e) => e.name == savedRole,
          orElse: () => UserRole.user,
        );
        // Update the provider with saved role
        ref.read(userRoleProvider.notifier).state = role;
      }
    } catch (e) {
      // If loading fails, continue with default role
    }
  }
  
  return ref.read(authServiceProvider).getUserData(user.uid, role);
});

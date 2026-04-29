import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import 'login_screen.dart';
import 'setup_initial_accounts_screen.dart';

class RoleSelectionScreen extends ConsumerWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppTheme.primaryColor, Colors.white],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.location_city, size: 80, color: Colors.white),
                const SizedBox(height: 16),
                const Text(
                  'Smart Village Manager',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Empowering Villages Digitally',
                  style: TextStyle(fontSize: 16, color: Colors.white70),
                ),
                const SizedBox(height: 48),
                const Text(
                  'Login As',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),
                _buildRoleButton(
                  context,
                  ref,
                  l10n.villager,
                  Icons.person,
                  UserRole.user,
                ),
                const SizedBox(height: 16),
                _buildRoleButton(
                  context,
                  ref,
                  l10n.admin,
                  Icons.admin_panel_settings,
                  UserRole.admin,
                ),
                const SizedBox(height: 16),
                _buildRoleButton(
                  context,
                  ref,
                  l10n.officer,
                  Icons.engineering,
                  UserRole.officer,
                ),
                const SizedBox(height: 32),
                TextButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SetupInitialAccountsScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.settings, color: Colors.white70),
                  label: const Text(
                    'Setup Initial Accounts',
                    style: TextStyle(color: Colors.white70),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoleButton(
    BuildContext context,
    WidgetRef ref,
    String title,
    IconData icon,
    UserRole role,
  ) {
    return ElevatedButton(
      onPressed: () {
        ref.read(userRoleProvider.notifier).state = role;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => LoginScreen(role: role),
          ),
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.primaryColor,
        elevation: 4,
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon),
          const SizedBox(width: 12),
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

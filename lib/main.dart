import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/app_theme.dart';
import 'l10n/app_localizations.dart';
import 'models/user_model.dart';
import 'providers/auth_provider.dart';
import 'providers/locale_provider.dart';
import 'screens/admin/admin_main_screen.dart';
import 'screens/auth/role_selection_screen.dart';
import 'screens/common/loading_screen.dart';
import 'screens/officer/officer_main_screen.dart';
import 'screens/user/user_main_screen.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const ProviderScope(child: SmartVillageApp()));
}

class SmartVillageApp extends ConsumerStatefulWidget {
  const SmartVillageApp({super.key});

  @override
  ConsumerState<SmartVillageApp> createState() => _SmartVillageAppState();
}

class _SmartVillageAppState extends ConsumerState<SmartVillageApp> {
  @override
  void initState() {
    super.initState();
    _initializeNotifications();
  }

  Future<void> _initializeNotifications() async {
    await ref.read(notificationServiceProvider).initialize();
    
    await ref.read(notificationServiceProvider).subscribeToTopic('notices');
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final locale = ref.watch(localeProvider);

    return MaterialApp(
      title: 'Smart Village Manager',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: authState.when(
        data: (user) {
          if (user == null) return const RoleSelectionScreen();

          final userModelAsync = ref.watch(userModelProvider);
          return userModelAsync.when(
            data: (userModel) {
              if (userModel == null) return const RoleSelectionScreen();

              switch (userModel.role) {
                case UserRole.admin:
                  return const AdminMainScreen();
                case UserRole.officer:
                  return const OfficerMainScreen();
                case UserRole.user:
                  return const UserMainScreen();
              }
            },
            loading: () => const LoadingScreen(),
            error: (e, s) => Scaffold(body: Center(child: Text('Error: $e'))),
          );
        },
        loading: () => const LoadingScreen(),
        error: (e, s) => Scaffold(body: Center(child: Text('Error: $e'))),
      ),
    );
  }
}

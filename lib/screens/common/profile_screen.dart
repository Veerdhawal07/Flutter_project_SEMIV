import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/locale_provider.dart';
import 'chat_list_screen.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userModel = ref.watch(userModelProvider).value;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => ref.read(authServiceProvider).signOut(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 50,
              backgroundColor: AppTheme.primaryColor,
              child: Icon(Icons.person, size: 50, color: Colors.white),
            ),
            const SizedBox(height: 16),
            Text(
              userModel?.fullName ?? 'User Name',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            Text(
              userModel?.email ?? 'email@example.com',
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                userModel?.role.name.toUpperCase() ?? 'USER',
                style: const TextStyle(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(height: 32),
            _buildProfileItem(
              Icons.phone,
              'Phone',
              userModel?.phone ?? 'Not provided',
            ),
            _buildProfileItem(
              Icons.location_on,
              'Address',
              userModel?.address ?? 'Not provided',
            ),
            _buildProfileItem(
              Icons.location_city,
              'Village',
              userModel?.villageName ?? 'Not provided',
            ),
            _buildProfileItem(
              Icons.numbers,
              'Ward Number',
              userModel?.wardNumber ?? 'Not provided',
            ),
            if (userModel?.occupation != null)
              _buildProfileItem(
                Icons.work,
                'Occupation',
                userModel!.occupation!,
              ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.language, color: AppTheme.primaryColor),
              title: const Text('Change Language'),
              trailing: DropdownButton<Locale>(
                value: ref.watch(localeProvider),
                underline: const SizedBox(),
                items: const [
                  DropdownMenuItem(
                    value: Locale('en'),
                    child: Text('English'),
                  ),
                  DropdownMenuItem(
                    value: Locale('hi'),
                    child: Text('हिन्दी'),
                  ),
                  DropdownMenuItem(
                    value: Locale('mr'),
                    child: Text('मराठी'),
                  ),
                ],
                onChanged: (Locale? newLocale) {
                  if (newLocale != null) {
                    ref.read(localeProvider.notifier).setLocale(newLocale);
                  }
                },
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.chat, color: AppTheme.primaryColor),
              title: const Text('Messages'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ChatListScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.edit),
              label: const Text('Edit Profile'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[200],
                foregroundColor: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileItem(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.primaryColor),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

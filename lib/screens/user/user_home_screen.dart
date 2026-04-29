import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../l10n/app_localizations.dart';
import '../../models/notice_model.dart';
import '../../providers/auth_provider.dart';
import '../common/chat_screen.dart';
import '../common/notice_board_screen.dart';

class UserHomeScreen extends ConsumerWidget {
  const UserHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userModel = ref.watch(userModelProvider).value;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NoticeBoardScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome, ${userModel?.fullName ?? "Villager"}',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text('Your village is growing today!'),
            const SizedBox(height: 24),

            // Stats Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('complaints')
                        .where('status', isEqualTo: 'completed')
                        .snapshots(),
                    builder: (context, snapshot) {
                      final count = snapshot.data?.docs.length ?? 0;
                      return _buildStatItem(
                          '$count', 'Village Solved', Colors.white);
                    },
                  ),
                  _buildStatItem('24°C', 'Weather', Colors.white),
                  _buildStatItem('Normal', 'Water Supply', Colors.white),
                ],
              ),
            ),
            const SizedBox(height: 24),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Support',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                TextButton.icon(
                  onPressed: () async {
                    final adminQuery = await FirebaseFirestore.instance
                        .collection('users')
                        .where('role', isEqualTo: 'admin')
                        .limit(1)
                        .get();

                    if (adminQuery.docs.isNotEmpty && context.mounted) {
                      final adminDoc = adminQuery.docs.first;
                      final adminData = adminDoc.data();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatScreen(
                            otherUserId: adminDoc.id,
                            otherUserName: adminData['fullName'] ?? 'Admin',
                          ),
                        ),
                      );
                    } else if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Admin support currently unavailable'),
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.chat),
                  label: Text(l10n.chatWithAdmin),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Village News',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const NoticeBoardScreen(),
                      ),
                    );
                  },
                  child: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('notices')
                  .orderBy('createdAt', descending: true)
                  .limit(2)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final notices = snapshot.data!.docs
                    .map(
                      (doc) => NoticeModel.fromMap(
                        doc.data() as Map<String, dynamic>,
                        doc.id,
                      ),
                    )
                    .toList();

                if (notices.isEmpty) {
                  return const Text('No recent news.');
                }

                return Column(
                  children: notices
                      .map(
                        (notice) => Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: _buildNewsCard(
                            notice.title,
                            notice.description,
                            '${notice.category} • ${notice.createdAt.day}/${notice.createdAt.month}',
                          ),
                        ),
                      )
                      .toList(),
                );
              },
            ),
            const SizedBox(height: 24),

            const Text(
              'Emergency Contacts',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildEmergencyIcon(
                  Icons.local_hospital,
                  'Hospital',
                  Colors.red,
                ),
                _buildEmergencyIcon(
                  Icons.local_fire_department,
                  'Fire',
                  Colors.orange,
                ),
                _buildEmergencyIcon(Icons.local_police, 'Police', Colors.blue),
                _buildEmergencyIcon(
                  Icons.electrical_services,
                  'Electricity',
                  Colors.amber,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String value, String label, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: color.withValues(alpha: 0.8)),
        ),
      ],
    );
  }

  Widget _buildNewsCard(String title, String desc, String time) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 4),
            Text(desc, style: const TextStyle(color: Colors.black87)),
            const SizedBox(height: 8),
            Text(
              time,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmergencyIcon(IconData icon, String label, Color color) {
    return Expanded(
      child: Column(
        children: [
          CircleAvatar(
            backgroundColor: color.withValues(alpha: 0.1),
            child: Icon(icon, color: color),
          ),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}

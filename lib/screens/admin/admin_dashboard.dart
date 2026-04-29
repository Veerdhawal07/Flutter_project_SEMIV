import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../models/complaint_model.dart';
import '../common/chat_list_screen.dart';
import '../common/notice_board_screen.dart';
import 'add_notice_screen.dart';
import 'complaint_details_admin_screen.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.chat),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ChatListScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.announcement),
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Overview',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AddNoticeScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Post Notice'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.secondaryColor,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('complaints')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const CircularProgressIndicator();
                final complaints = snapshot.data!.docs;
                final pending = complaints
                    .where((doc) => doc['status'] == 'pending')
                    .length;
                final assigned = complaints
                    .where((doc) => doc['status'] == 'assigned')
                    .length;
                final completed = complaints
                    .where((doc) => doc['status'] == 'completed')
                    .length;

                return Row(
                  children: [
                    _buildStatCard(
                      'Pending',
                      pending.toString(),
                      Colors.orange,
                    ),
                    _buildStatCard(
                      'Assigned',
                      assigned.toString(),
                      Colors.blue,
                    ),
                    _buildStatCard(
                      'Resolved',
                      completed.toString(),
                      Colors.green,
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 24),
            const Text(
              'Complaints by Category',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(height: 200, child: _buildCategoryChart()),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Recent Complaints',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                TextButton(onPressed: () {}, child: const Text('View All')),
              ],
            ),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('complaints')
                  .orderBy('createdAt', descending: true)
                  .limit(5)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData)
                  return const Center(child: CircularProgressIndicator());
                final docs = snapshot.data!.docs;
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final complaint = ComplaintModel.fromMap(
                      docs[index].data() as Map<String, dynamic>,
                      docs[index].id,
                    );
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: _getPriorityColor(
                          complaint.priority,
                        ).withOpacity(0.2),
                        child: Icon(
                          Icons.warning,
                          color: _getPriorityColor(complaint.priority),
                        ),
                      ),
                      title: Text(complaint.title),
                      subtitle: Text(
                        '${complaint.category} • ${complaint.area}',
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ComplaintDetailsAdminScreen(
                              complaint: complaint,
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String count, Color color) {
    return Expanded(
      child: Card(
        color: color.withOpacity(0.1),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Column(
            children: [
              Text(
                count,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Text(
                label,
                style: TextStyle(color: color, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getPriorityColor(ComplaintPriority priority) {
    switch (priority) {
      case ComplaintPriority.low:
        return Colors.green;
      case ComplaintPriority.medium:
        return Colors.orange;
      case ComplaintPriority.high:
        return Colors.red;
      case ComplaintPriority.emergency:
        return Colors.purple;
    }
  }

  Widget _buildCategoryChart() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('complaints').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox();
        Map<String, int> counts = {};
        for (var doc in snapshot.data!.docs) {
          String cat = doc['category'] ?? 'Other';
          counts[cat] = (counts[cat] ?? 0) + 1;
        }

        List<PieChartSectionData> sections = [];
        int i = 0;
        final colors = [
          Colors.blue,
          Colors.green,
          Colors.orange,
          Colors.red,
          Colors.purple,
          Colors.teal,
        ];
        counts.forEach((key, value) {
          sections.add(
            PieChartSectionData(
              color: colors[i % colors.length],
              value: value.toDouble(),
              title: '$value',
              radius: 50,
              titleStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          );
          i++;
        });

        return Row(
          children: [
            Expanded(child: PieChart(PieChartData(sections: sections))),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: counts.keys
                  .map(
                    (k) => Row(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          color: colors[
                              counts.keys.toList().indexOf(k) % colors.length],
                        ),
                        const SizedBox(width: 4),
                        Text(k, style: const TextStyle(fontSize: 10)),
                      ],
                    ),
                  )
                  .toList(),
            ),
          ],
        );
      },
    );
  }
}

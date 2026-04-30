import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../models/complaint_model.dart';
import '../common/chat_list_screen.dart';
import '../common/notice_board_screen.dart';
import 'add_notice_screen.dart';
import 'complaint_details_admin_screen.dart';
import 'manage_officers_screen.dart';

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
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          
          const Text(
            'Quick Actions',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _buildActionButton(
            context,
            icon: Icons.add,
            label: 'Post Notice',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddNoticeScreen(),
                ),
              );
            },
          ),
          const SizedBox(height: 8),
          _buildActionButton(
            context,
            icon: Icons.people,
            label: 'Manage Officers',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ManageOfficersScreen(),
                ),
              );
            },
          ),
          const SizedBox(height: 24),
          
          
          const Text(
            'Statistics',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('complaints')
                .snapshots(),
            builder: (context, snapshot) {
              
              if (snapshot.hasError) {
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text('Error loading stats: ${snapshot.error}'),
                  ),
                );
              }
              
              
              if (!snapshot.hasData) {
                return const Card(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                );
              }
              
              final complaints = snapshot.data!.docs;
              int pending = 0;
              int assigned = 0;
              int completed = 0;
              
              for (var doc in complaints) {
                try {
                  String status = doc['status'] ?? '';
                  if (status == 'pending' || status == 'seen') {
                    pending++;
                  } else if (status == 'assigned') {
                    assigned++;
                  } else if (status == 'completed') {
                    completed++;
                  }
                } catch (e) {
                  
                }
              }
              
              return Column(
                children: [
                  _buildStatCard('Total', complaints.length.toString(), Colors.blue),
                  const SizedBox(height: 8),
                  _buildStatCard('Pending', pending.toString(), Colors.orange),
                  const SizedBox(height: 8),
                  _buildStatCard('Assigned', assigned.toString(), Colors.purple),
                  const SizedBox(height: 8),
                  _buildStatCard('Completed', completed.toString(), Colors.green),
                ],
              );
            },
          ),
          const SizedBox(height: 24),
          
          
          const Text(
            'Recent Complaints',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('complaints')
                .orderBy('createdAt', descending: true)
                .limit(10)
                .snapshots(),
            builder: (context, snapshot) {
              
              if (snapshot.hasError) {
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text('Error: ${snapshot.error}'),
                  ),
                );
              }
              
              
              if (!snapshot.hasData) {
                return const Card(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                );
              }
              
              if (snapshot.data!.docs.isEmpty) {
                return const Card(
                  child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: Center(
                      child: Text(
                        'No complaints yet',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ),
                  ),
                );
              }
              
              final docs = snapshot.data!.docs;
              return Column(
                children: docs.map((doc) {
                  final complaint = ComplaintModel.fromMap(
                    doc.data() as Map<String, dynamic>,
                    doc.id,
                  );
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: const Icon(Icons.warning, color: Colors.orange),
                      title: Text(complaint.title),
                      subtitle: Text('${complaint.category} - ${complaint.status.name}'),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
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
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
  
  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(icon, size: 24),
              const SizedBox(width: 12),
              Text(
                label,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildStatCard(String label, String count, Color color) {
    return Card(
      color: color.withValues(alpha: 0.1),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              count,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

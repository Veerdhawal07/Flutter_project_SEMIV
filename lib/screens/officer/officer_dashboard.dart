import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/complaint_model.dart';
import '../../providers/auth_provider.dart';
import 'task_details_officer_screen.dart';

class OfficerDashboard extends ConsumerWidget {
  const OfficerDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).value;

    return Scaffold(
      appBar: AppBar(title: const Text('My Tasks')),
      body: user == null
          ? const Center(child: Text('Please login'))
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('complaints')
                  .where('assignedOfficerId', isEqualTo: user.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final tasks = snapshot.data!.docs
                    .map(
                      (doc) => ComplaintModel.fromMap(
                        doc.data() as Map<String, dynamic>,
                        doc.id,
                      ),
                    )
                    .toList();

                if (tasks.isEmpty) {
                  return const Center(child: Text('No tasks assigned yet.'));
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    final task = tasks[index];
                    return _buildTaskCard(context, task);
                  },
                );
              },
            ),
    );
  }

  Widget _buildTaskCard(BuildContext context, ComplaintModel task) {
    return Card(
      child: ListTile(
        title: Text(
          task.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text('${task.category} • ${task.area}'),
        trailing: _buildStatusBadge(task.status),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TaskDetailsOfficerScreen(task: task),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusBadge(ComplaintStatus status) {
    Color color = Colors.grey;
    if (status == ComplaintStatus.assigned) color = Colors.blue;
    if (status == ComplaintStatus.inProgress) color = Colors.orange;
    if (status == ComplaintStatus.completed) color = Colors.green;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status.name.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

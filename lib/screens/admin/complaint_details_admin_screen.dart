import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../models/complaint_model.dart';
import '../../services/notification_service.dart';

class ComplaintDetailsAdminScreen extends ConsumerStatefulWidget {
  final ComplaintModel complaint;
  const ComplaintDetailsAdminScreen({super.key, required this.complaint});

  @override
  ConsumerState<ComplaintDetailsAdminScreen> createState() =>
      _ComplaintDetailsAdminScreenState();
}

class _ComplaintDetailsAdminScreenState
    extends ConsumerState<ComplaintDetailsAdminScreen> {
  String? _selectedOfficerId;
  String? _selectedOfficerName;
  final _remarksController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _remarksController.text = widget.complaint.adminRemarks ?? '';
  }

  Future<void> _updateComplaint(ComplaintStatus status) async {
    setState(() => _isLoading = true);
    try {
      Map<String, dynamic> updateData = {
        'status': status.name,
        'adminRemarks': _remarksController.text.trim(),
      };

      if (status == ComplaintStatus.assigned) {
        updateData['assignedOfficerId'] = _selectedOfficerId;
        updateData['assignedOfficerName'] = _selectedOfficerName;
      }

      await FirebaseFirestore.instance
          .collection('complaints')
          .doc(widget.complaint.id)
          .update(updateData);

      // Send Notification to Villager
      await ref.read(notificationServiceProvider).sendNotificationToUser(
            widget.complaint.userId,
            'Complaint Update',
            'Your complaint "${widget.complaint.title}" is now ${status.name}.',
          );

      // Send Notification to Officer if assigned
      if (status == ComplaintStatus.assigned && _selectedOfficerId != null) {
        await ref.read(notificationServiceProvider).sendNotificationToUser(
              _selectedOfficerId!,
              'New Task Assigned',
              'You have been assigned a new task: ${widget.complaint.title}',
            );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Complaint updated successfully')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Complaint Details')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.complaint.imageUrl != null &&
                widget.complaint.imageUrl!.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  widget.complaint.imageUrl!,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 200,
                    width: double.infinity,
                    color: Colors.grey[300],
                    child: const Icon(Icons.image_not_supported, size: 50),
                  ),
                ),
              ),
            const SizedBox(height: 16),
            Text(
              widget.complaint.title,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(widget.complaint.description),
            const Divider(height: 32),
            _buildInfoRow(
              Icons.category,
              'Category',
              widget.complaint.category,
            ),
            _buildInfoRow(
              Icons.location_on,
              'Location',
              '${widget.complaint.area}, ${widget.complaint.landmark ?? ""}',
            ),
            _buildInfoRow(
              Icons.priority_high,
              'Priority',
              widget.complaint.priority.name.toUpperCase(),
            ),
            _buildInfoRow(
              Icons.person,
              'Posted By',
              widget.complaint.isAnonymous ? 'Anonymous' : 'Villager',
            ),
            const SizedBox(height: 24),
            const Text(
              'Admin Actions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _remarksController,
              decoration: const InputDecoration(
                labelText: 'Admin Remarks',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            if (widget.complaint.status == ComplaintStatus.pending ||
                widget.complaint.status == ComplaintStatus.seen)
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .where('role', isEqualTo: 'officer')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData)
                    return const CircularProgressIndicator();
                  final officers = snapshot.data!.docs;
                  return DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Assign Officer',
                    ),
                    items: officers.map((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      return DropdownMenuItem(
                        value: doc.id,
                        child: Text(
                          '${data['fullName']} (${data['department']})',
                        ),
                      );
                    }).toList(),
                    onChanged: (val) {
                      final doc = officers.firstWhere((d) => d.id == val);
                      setState(() {
                        _selectedOfficerId = val;
                        _selectedOfficerName =
                            (doc.data() as Map<String, dynamic>)['fullName'];
                      });
                    },
                  );
                },
              ),
            const SizedBox(height: 24),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () =>
                          _updateComplaint(ComplaintStatus.rejected),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      child: const Text('REJECT'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _selectedOfficerId == null
                          ? null
                          : () => _updateComplaint(ComplaintStatus.assigned),
                      child: const Text('ASSIGN'),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppTheme.primaryColor),
          const SizedBox(width: 8),
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(value),
        ],
      ),
    );
  }
}

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;

import '../../core/theme/app_theme.dart';
import '../../models/complaint_model.dart';
import '../../services/notification_service.dart';

class TaskDetailsOfficerScreen extends ConsumerStatefulWidget {
  final ComplaintModel task;
  const TaskDetailsOfficerScreen({super.key, required this.task});

  @override
  ConsumerState<TaskDetailsOfficerScreen> createState() =>
      _TaskDetailsOfficerScreenState();
}

class _TaskDetailsOfficerScreenState
    extends ConsumerState<TaskDetailsOfficerScreen> {
  final _notesController = TextEditingController();
  File? _resolutionImage;
  bool _isLoading = false;

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.camera,
    );
    if (pickedFile != null) {
      setState(() => _resolutionImage = File(pickedFile.path));
    }
  }

  Future<void> _updateStatus(ComplaintStatus status) async {
    setState(() => _isLoading = true);
    try {
      String? imageUrl;
      if (_resolutionImage != null) {
        try {
          final ref = FirebaseStorage.instance.ref().child('resolutions').child(
                '${widget.task.id}_res${path.extension(_resolutionImage!.path)}',
              );
          await ref.putFile(_resolutionImage!);
          imageUrl = await ref.getDownloadURL();
        } catch (e) {
          debugPrint('Storage error (skipping resolution image): $e');
        }
      }

      await FirebaseFirestore.instance
          .collection('complaints')
          .doc(widget.task.id)
          .update({
        'status': status.name,
        'officerNotes': _notesController.text.trim(),
        if (imageUrl != null) 'resolutionImageUrl': imageUrl,
      });

      // Notify Villager
      await ref.read(notificationServiceProvider).sendNotificationToUser(
            widget.task.userId,
            UserRole.user,
            'Work Update: ${widget.task.title}',
            'The officer has marked your complaint as ${status.name}.',
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Status updated to ${status.name}')),
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
      appBar: AppBar(title: const Text('Task Details')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.task.imageUrl != null &&
                widget.task.imageUrl!.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  widget.task.imageUrl!,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 200,
                    width: double.infinity,
                    color: Colors.grey[200],
                    child: const Icon(Icons.image_not_supported, size: 50),
                  ),
                ),
              ),
            const SizedBox(height: 16),
            _buildInfoCard(),
            const SizedBox(height: 24),
            const Text(
              'Update Progress',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notes / Material Used',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 150,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey),
                ),
                child: _resolutionImage == null
                    ? const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_a_photo, size: 40),
                          Text('Upload Completion Photo'),
                        ],
                      )
                    : Image.file(_resolutionImage!, fit: BoxFit.cover),
              ),
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
                          _updateStatus(ComplaintStatus.inProgress),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                      ),
                      child: const Text('START WORK'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _updateStatus(ComplaintStatus.completed),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                      child: const Text('COMPLETE'),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.task.title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(widget.task.description),
            const Divider(),
            _buildInfoRow(Icons.location_on, 'Area', widget.task.area),
            _buildInfoRow(
              Icons.priority_high,
              'Priority',
              widget.task.priority.name.toUpperCase(),
            ),
            if (widget.task.landmark != null)
              _buildInfoRow(Icons.near_me, 'Landmark', widget.task.landmark!),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppTheme.primaryColor),
          const SizedBox(width: 8),
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(value),
        ],
      ),
    );
  }
}

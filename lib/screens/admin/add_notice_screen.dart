import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/notice_model.dart';
import '../../services/notification_service.dart';

class AddNoticeScreen extends ConsumerStatefulWidget {
  const AddNoticeScreen({super.key});

  @override
  ConsumerState<AddNoticeScreen> createState() => _AddNoticeScreenState();
}

class _AddNoticeScreenState extends ConsumerState<AddNoticeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _selectedCategory = 'General';
  bool _isEmergency = false;
  bool _isLoading = false;

  final List<String> _categories = [
    'General',
    'Emergency',
    'Health',
    'Education',
    'Agriculture',
    'Meeting',
    'Event',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submitNotice() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final docRef = FirebaseFirestore.instance.collection('notices').doc();
      final notice = NoticeModel(
        id: docRef.id,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        category: _selectedCategory,
        createdAt: DateTime.now(),
        isEmergency: _isEmergency,
      );

      await docRef.set(notice.toMap());

      
      await ref
          .read(notificationServiceProvider)
          .sendNotificationToTopic(
            'notices',
            _isEmergency
                ? 'EMERGENCY: ${notice.title}'
                : 'New Notice: ${notice.title}',
            notice.description,
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Notice published successfully!')),
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
      appBar: AppBar(title: const Text('Post New Notice')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'Title',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.title),
                      ),
                      validator: (value) => value == null || value.isEmpty
                          ? 'Please enter title'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.description),
                      ),
                      maxLines: 5,
                      validator: (value) => value == null || value.isEmpty
                          ? 'Please enter description'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedCategory,
                      decoration: const InputDecoration(
                        labelText: 'Category',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.category),
                      ),
                      items: _categories.map((String category) {
                        return DropdownMenuItem(
                          value: category,
                          child: Text(category),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedCategory = value!;
                          if (_selectedCategory == 'Emergency') {
                            _isEmergency = true;
                          }
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    SwitchListTile(
                      title: const Text('Mark as Emergency'),
                      subtitle: const Text('This will highlight the notice'),
                      value: _isEmergency,
                      onChanged: (value) {
                        setState(() => _isEmergency = value);
                      },
                      secondary: Icon(
                        Icons.warning_amber_rounded,
                        color: _isEmergency ? Colors.red : null,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _submitNotice,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Publish Notice'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

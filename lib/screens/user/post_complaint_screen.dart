import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;

import '../../models/complaint_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/notification_service.dart';

class PostComplaintScreen extends ConsumerStatefulWidget {
  const PostComplaintScreen({super.key});

  @override
  ConsumerState<PostComplaintScreen> createState() =>
      _PostComplaintScreenState();
}

class _PostComplaintScreenState extends ConsumerState<PostComplaintScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _areaController = TextEditingController();
  final _landmarkController = TextEditingController();

  String _category = 'Road';
  ComplaintPriority _priority = ComplaintPriority.medium;
  File? _image;
  bool _isAnonymous = false;
  bool _isLoading = false;

  final List<String> _categories = [
    'Road',
    'Water',
    'Electricity',
    'Garbage',
    'Street Light',
    'Drainage',
    'Health',
    'Other',
  ];

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.camera,
    );
    if (pickedFile != null) {
      setState(() => _image = File(pickedFile.path));
    }
  }

  Future<void> _submitComplaint() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final user = ref.read(authStateProvider).value;
      if (user == null) return;

      String? imageUrl;
      if (_image != null) {
        try {
          final ref = FirebaseStorage.instance.ref().child('complaints').child(
                '${DateTime.now().millisecondsSinceEpoch}${path.extension(_image!.path)}',
              );
          await ref.putFile(_image!);
          imageUrl = await ref.getDownloadURL();
        } catch (e) {
          debugPrint('Storage error (skipping image): $e');
          
        }
      }

      final complaintId =
          FirebaseFirestore.instance.collection('complaints').doc().id;
      final complaint = ComplaintModel(
        id: complaintId,
        userId: user.uid,
        title: _titleController.text.trim(),
        description: _descController.text.trim(),
        category: _category,
        area: _areaController.text.trim(),
        landmark: _landmarkController.text.trim(),
        priority: _priority,
        imageUrl: imageUrl,
        isAnonymous: _isAnonymous,
        createdAt: DateTime.now(),
        status: ComplaintStatus.pending,
      );

      await FirebaseFirestore.instance
          .collection('complaints')
          .doc(complaintId)
          .set(complaint.toMap());

      
      ref.read(notificationServiceProvider).sendNotificationToTopic(
            'admin_notices',
            'New Complaint: $_category',
            _titleController.text.trim(),
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Complaint submitted successfully!')),
        );
        _formKey.currentState!.reset();
        setState(() {
          _image = null;
          _isAnonymous = false;
        });
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
      appBar: AppBar(title: const Text('Post Complaint')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Complaint Title',
                  prefixIcon: Icon(Icons.title),
                ),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  prefixIcon: Icon(Icons.description),
                ),
                maxLines: 3,
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _category,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  prefixIcon: Icon(Icons.category),
                ),
                items: _categories
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (v) => setState(() => _category = v!),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _areaController,
                decoration: const InputDecoration(
                  labelText: 'Area / Street Name',
                  prefixIcon: Icon(Icons.map),
                ),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _landmarkController,
                decoration: const InputDecoration(
                  labelText: 'Landmark',
                  prefixIcon: Icon(Icons.location_on),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Priority',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Row(
                children: ComplaintPriority.values
                    .map(
                      (p) => Expanded(
                        child: RadioListTile<ComplaintPriority>(
                          title: Text(
                            p.name[0].toUpperCase() + p.name.substring(1),
                            style: const TextStyle(fontSize: 10),
                          ),
                          value: p,
                          groupValue: _priority,
                          onChanged: (ComplaintPriority? v) => setState(() => _priority = v!),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    )
                    .toList(),
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
                  child: _image == null
                      ? const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.camera_alt, size: 40),
                            Text('Upload Photo'),
                          ],
                        )
                      : Image.file(_image!, fit: BoxFit.cover),
                ),
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Post Anonymously'),
                value: _isAnonymous,
                onChanged: (v) => setState(() => _isAnonymous = v),
              ),
              const SizedBox(height: 24),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _submitComplaint,
                      child: const Text('SUBMIT COMPLAINT'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}

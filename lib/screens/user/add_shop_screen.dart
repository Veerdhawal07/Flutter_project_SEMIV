import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../models/shop_model.dart';
import '../../providers/auth_provider.dart';

class AddShopScreen extends ConsumerStatefulWidget {
  const AddShopScreen({super.key});

  @override
  ConsumerState<AddShopScreen> createState() => _AddShopScreenState();
}

class _AddShopScreenState extends ConsumerState<AddShopScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ownerController = TextEditingController();
  final _areaController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _whatsappController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _openTimeController = TextEditingController(text: '09:00 AM');
  final _closeTimeController = TextEditingController(text: '09:00 PM');

  String _category = 'Grocery';
  bool _hasHomeDelivery = false;
  File? _logoImage;
  File? _bannerImage;
  bool _isLoading = false;

  final List<String> _categories = [
    'Grocery',
    'Vegetable',
    'Dairy',
    'Clothes',
    'Hardware',
    'Medical',
    'Electronics',
    'Salon',
    'Other',
  ];

  Future<void> _pickImage(bool isLogo) async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      setState(() {
        if (isLogo) {
          _logoImage = File(pickedFile.path);
        } else {
          _bannerImage = File(pickedFile.path);
        }
      });
    }
  }

  Future<void> _submitShop() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final user = ref.read(authStateProvider).value;
      if (user == null) return;

      String? logoUrl;
      if (_logoImage != null) {
        try {
          final ref = FirebaseStorage.instance.ref().child(
                'shops/logos/${DateTime.now().millisecondsSinceEpoch}',
              );
          await ref.putFile(_logoImage!);
          logoUrl = await ref.getDownloadURL();
        } catch (e) {
          debugPrint('Storage error (skipping logo): $e');
        }
      }

      String? bannerUrl;
      if (_bannerImage != null) {
        try {
          final ref = FirebaseStorage.instance.ref().child(
                'shops/banners/${DateTime.now().millisecondsSinceEpoch}',
              );
          await ref.putFile(_bannerImage!);
          bannerUrl = await ref.getDownloadURL();
        } catch (e) {
          debugPrint('Storage error (skipping banner): $e');
        }
      }

      final shopId = FirebaseFirestore.instance.collection('shops').doc().id;
      final shop = ShopModel(
        id: shopId,
        ownerId: user.uid,
        name: _nameController.text.trim(),
        ownerName: _ownerController.text.trim(),
        category: _category,
        area: _areaController.text.trim(),
        address: _addressController.text.trim(),
        phone: _phoneController.text.trim(),
        whatsapp: _whatsappController.text.trim(),
        logoUrl: logoUrl,
        bannerUrl: bannerUrl,
        openingTime: _openTimeController.text,
        closingTime: _closeTimeController.text,
        hasHomeDelivery: _hasHomeDelivery,
        description: _descriptionController.text.trim(),
      );

      await FirebaseFirestore.instance
          .collection('shops')
          .doc(shopId)
          .set(shop.toMap());

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Shop registered successfully!')),
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
      appBar: AppBar(title: const Text('Register Shop')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildTextField(_nameController, 'Shop Name', Icons.store),
              _buildTextField(_ownerController, 'Owner Name', Icons.person),
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
              _buildTextField(_areaController, 'Area', Icons.location_on),
              _buildTextField(_addressController, 'Full Address', Icons.map),
              _buildTextField(
                _phoneController,
                'Phone Number',
                Icons.phone,
                keyboardType: TextInputType.phone,
              ),
              _buildTextField(
                _whatsappController,
                'WhatsApp Number',
                Icons.chat,
                keyboardType: TextInputType.phone,
              ),
              _buildTextField(
                _descriptionController,
                'Description',
                Icons.description,
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      _openTimeController,
                      'Opening Time',
                      Icons.access_time,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTextField(
                      _closeTimeController,
                      'Closing Time',
                      Icons.access_time,
                    ),
                  ),
                ],
              ),
              SwitchListTile(
                title: const Text('Home Delivery Available?'),
                value: _hasHomeDelivery,
                onChanged: (v) => setState(() => _hasHomeDelivery = v),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildImagePicker(
                      'Shop Logo',
                      _logoImage,
                      () => _pickImage(true),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildImagePicker(
                      'Shop Banner',
                      _bannerImage,
                      () => _pickImage(false),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _submitShop,
                      child: const Text('REGISTER SHOP'),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon)),
        maxLines: maxLines,
        keyboardType: keyboardType,
        validator: (v) => v == null || v.isEmpty ? 'Required' : null,
      ),
    );
  }

  Widget _buildImagePicker(String label, File? image, VoidCallback onTap) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: onTap,
          child: Container(
            height: 100,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey),
            ),
            child: image == null
                ? const Icon(Icons.add_a_photo, size: 30)
                : ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(image, fit: BoxFit.cover),
                  ),
          ),
        ),
      ],
    );
  }
}

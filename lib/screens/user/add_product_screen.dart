import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;

import '../../models/shop_model.dart';

class AddProductScreen extends StatefulWidget {
  final String shopId;
  final ProductModel? product;
  const AddProductScreen({super.key, required this.shopId, this.product});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _discountController;
  late TextEditingController _quantityController;
  late TextEditingController _unitController;

  String _category = 'Grocery';
  File? _image;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product?.name);
    _priceController = TextEditingController(
      text: widget.product?.price.toString(),
    );
    _discountController = TextEditingController(
      text: widget.product?.discount.toString() ?? '0',
    );
    _quantityController = TextEditingController(
      text: widget.product?.quantity.toString(),
    );
    _unitController = TextEditingController(text: widget.product?.unit ?? 'kg');
    if (widget.product != null) {
      _category = widget.product!.category;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _discountController.dispose();
    _quantityController.dispose();
    _unitController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      setState(() => _image = File(pickedFile.path));
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      String? imageUrl = widget.product?.imageUrl;
      if (_image != null) {
        try {
          final ref = FirebaseStorage.instance.ref().child('products').child(
                '${DateTime.now().millisecondsSinceEpoch}${path.extension(_image!.path)}',
              );
          await ref.putFile(_image!);
          imageUrl = await ref.getDownloadURL();
        } catch (e) {
          debugPrint('Storage error (skipping product image): $e');
        }
      }

      final productId = widget.product?.id ??
          FirebaseFirestore.instance
              .collection('shops')
              .doc(widget.shopId)
              .collection('products')
              .doc()
              .id;

      final product = ProductModel(
        id: productId,
        shopId: widget.shopId,
        name: _nameController.text.trim(),
        category: _category,
        price: double.parse(_priceController.text),
        discount: double.parse(_discountController.text),
        quantity: double.parse(_quantityController.text),
        unit: _unitController.text.trim(),
        imageUrl: imageUrl,
      );

      await FirebaseFirestore.instance
          .collection('shops')
          .doc(widget.shopId)
          .collection('products')
          .doc(productId)
          .set(product.toMap());

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isEditing = widget.product != null;

    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? 'Edit Product' : 'Add Product')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Product Name'),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.number,
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _quantityController,
                      decoration: const InputDecoration(labelText: 'Quantity'),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _unitController,
                      decoration: const InputDecoration(
                        labelText: 'Unit (kg, ltr, pcs)',
                      ),
                    ),
                  ),
                ],
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
                  ),
                  child: _image != null
                      ? Image.file(_image!, fit: BoxFit.cover)
                      : (widget.product?.imageUrl != null
                          ? Image.network(
                              widget.product!.imageUrl!,
                              fit: BoxFit.cover,
                            )
                          : const Icon(Icons.add_a_photo, size: 40)),
                ),
              ),
              const SizedBox(height: 32),
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _submit,
                      child: Text(isEditing ? 'UPDATE PRODUCT' : 'ADD PRODUCT'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';

class RegistrationScreen extends ConsumerStatefulWidget {
  const RegistrationScreen({super.key});

  @override
  ConsumerState<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends ConsumerState<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _addressController = TextEditingController();
  final _villageController = TextEditingController();
  final _wardController = TextEditingController();
  final _aadhaarController = TextEditingController();
  final _occupationController = TextEditingController();
  final _houseController = TextEditingController();

  String _gender = 'Male';
  bool _isLoading = false;

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final userModel = UserModel(
        uid: '', // Will be set by Firebase
        fullName: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        role: UserRole.user,
        address: _addressController.text.trim(),
        villageName: _villageController.text.trim(),
        wardNumber: _wardController.text.trim(),
        aadhaarId: _aadhaarController.text.trim(),
        gender: _gender,
        occupation: _occupationController.text.trim(),
        houseNumber: _houseController.text.trim(),
      );

      await ref.read(authServiceProvider).signUp(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
            userModel: userModel,
          );

      if (mounted) {
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.register)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildTextField(_nameController, 'Full Name', Icons.person),
              const SizedBox(height: 16),
              _buildTextField(
                _emailController,
                'Email',
                Icons.email,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                _phoneController,
                'Mobile Number',
                Icons.phone,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                _passwordController,
                'Password',
                Icons.lock,
                obscureText: true,
              ),
              const SizedBox(height: 16),
              _buildTextField(_addressController, 'Address', Icons.home),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      _villageController,
                      'Village',
                      Icons.location_city,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTextField(
                      _wardController,
                      'Ward No',
                      Icons.numbers,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildTextField(
                _aadhaarController,
                'Aadhaar / Village ID (Optional)',
                Icons.badge,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _gender,
                decoration: const InputDecoration(
                  labelText: 'Gender',
                  prefixIcon: Icon(Icons.people),
                ),
                items: ['Male', 'Female', 'Other']
                    .map(
                      (label) =>
                          DropdownMenuItem(value: label, child: Text(label)),
                    )
                    .toList(),
                onChanged: (value) => setState(() => _gender = value!),
              ),
              const SizedBox(height: 16),
              _buildTextField(_occupationController, 'Occupation', Icons.work),
              const SizedBox(height: 16),
              _buildTextField(
                _houseController,
                'House Number',
                Icons.door_front_door,
              ),
              const SizedBox(height: 32),
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _register,
                      child: Text(l10n.register.toUpperCase()),
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
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon)),
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: (value) =>
          value == null || value.isEmpty ? 'Field required' : null,
    );
  }
}

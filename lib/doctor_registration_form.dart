import 'dart:convert';
import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

const String _BaseUrl = 'https://heathos-api.onrender.com';
const kTeal = Color(0xFF0D7B6B);
const kTealLight = Color(0xFFE6F5F2);
const kTextDark = Color(0xFF1A2E2C);
const kTextGrey = Color(0xFF7A9490);
const kBorder = Color(0xFFE0E0E0);

class DoctorRegistrationForm extends StatefulWidget {
  const DoctorRegistrationForm({super.key});

  @override
  State<DoctorRegistrationForm> createState() => _DoctorRegistrationFormState();
}

class _DoctorRegistrationFormState extends State<DoctorRegistrationForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _specialtyController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _specialtyController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _registerDoctor() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final token = html.window.localStorage['token'] ?? '';
      if (token.isEmpty) {
        _showError('No token found. Please log in again.');
        return;
      }

      final response = await http.post(
        Uri.parse('$_BaseUrl/api/doctors/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          "fullName": _nameController.text.trim(),
          "email": _emailController.text.trim(),
          "specialty": _specialtyController.text.trim().isEmpty
              ? "General Practitioner"
              : _specialtyController.text.trim(),
          "password": _passwordController.text.trim(),
          "phone": _phoneController.text.trim(),
          "role": "Doctor",
          "active": true,
        }),
      );

      debugPrint('Register doctor status: ${response.statusCode}');
      debugPrint('Register doctor body: ${response.body}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        if (!mounted) return;
        Navigator.pop(context, true); // Return true to refresh list
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Doctor registered successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        final data = jsonDecode(response.body);
        _showError(data['message'] ?? 'Failed to register doctor');
      }
    } catch (e) {
      _showError('Network error: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Register New Doctor'),
        backgroundColor: kTeal,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Doctor Information',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: kTextDark,
                ),
              ),
              const SizedBox(height: 24),

              _buildTextField(
                controller: _nameController,
                label: 'Full Name *',
                icon: Icons.person_outline,
                validator: (v) =>
                    v == null || v.isEmpty ? 'Name is required' : null,
              ),
              const SizedBox(height: 16),

              _buildTextField(
                controller: _emailController,
                label: 'Email *',
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Email is required';
                  if (!v.contains('@')) return 'Enter a valid email';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              _buildTextField(
                controller: _phoneController,
                label: 'Phone Number',
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),

              _buildTextField(
                controller: _specialtyController,
                label: 'Specialty (e.g. Cardiology)',
                icon: Icons.medical_services_outlined,
              ),
              const SizedBox(height: 16),

              _buildTextField(
                controller: _passwordController,
                label: 'Temporary Password *',
                icon: Icons.lock_outline,
                obscureText: true,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Password is required';
                  if (v.length < 6)
                    return 'Password must be at least 6 characters';
                  return null;
                },
              ),
              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _registerDoctor,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kTeal,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Register Doctor',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    bool obscureText = false,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: kTeal, size: 20),
        filled: true,
        fillColor: kTealLight,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: kBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: kTeal, width: 1.5),
        ),
      ),
    );
  }
}

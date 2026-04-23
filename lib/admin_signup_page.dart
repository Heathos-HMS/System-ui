import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'constants/api_constants.dart';
import 'admin_login_page.dart';
import 'admin_dashboard.dart';
import 'doctor_dashboard.dart';
import 'patient_dashboard.dart';
import 'lab_technicians_page.dart';
import 'billing_staff_dashboard.dart';

// ── Base URL ─────────────────────────heathos─────────────────────────────────────────
const String _BaseUrl = 'https://heathos-api.onrender.com';

// ── Colour tokens ─────────────────────────────────────────────────────────────
const _cTeal = Color.fromARGB(255, 1, 211, 193);
const _cTealDark = Color(0xFF0D7B6B);
const _cBg = Color(0xFFF5FAFA);
const _cBorder = Color(0xFFCCE8E5);
const _cText = Color(0xFF0D2B27);
const _cSubtext = Color(0xFF607C79);

// ── Role options ──────────────────────────────────────────────────────────────
const List<_RoleOption> _signupRoles = [
  _RoleOption(
    label: 'Admin',
    apiValue: 'ADMIN',
    icon: Icons.admin_panel_settings_rounded,
  ),
  _RoleOption(
    label: 'Doctor',
    apiValue: 'DOCTOR',
    icon: Icons.medical_services_rounded,
  ),
  _RoleOption(
    label: 'Receptionist',
    apiValue: 'RECEPTIONIST',
    icon: Icons.desktop_mac_rounded,
  ),
  _RoleOption(
    label: 'Lab Technician',
    apiValue: 'LAB_TECHNICIAN',
    icon: Icons.science_rounded,
  ),
  _RoleOption(
    label: 'Billing Staff',
    apiValue: 'BILLING_OFFICER',
    icon: Icons.receipt_long_rounded,
  ),
];

class _RoleOption {
  final String label;
  final String apiValue;
  final IconData icon;
  const _RoleOption({
    required this.label,
    required this.apiValue,
    required this.icon,
  });
}

// ─────────────────────────────────────────────────────────────────────────────

class AdminSignUpPage extends StatefulWidget {
  const AdminSignUpPage({super.key});

  @override
  State<AdminSignUpPage> createState() => _AdminSignUpPageState();
}

class _AdminSignUpPageState extends State<AdminSignUpPage> {
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  _RoleOption? _selectedRole;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // ── API — REGISTER ───────────────────────────────────────────────────────
  Future<void> _handleSignUp() async {
    setState(() => _errorMessage = null);

    if (_selectedRole == null) {
      setState(() => _errorMessage = 'Please select a user type.');
      return;
    }
    if (_fullNameController.text.trim().isEmpty) {
      setState(() => _errorMessage = 'Please enter your full name.');
      return;
    }
    if (_emailController.text.trim().isEmpty) {
      setState(() => _errorMessage = 'Please enter your email.');
      return;
    }
    if (_phoneController.text.trim().isEmpty) {
      setState(() => _errorMessage = 'Please enter your phone number.');
      return;
    }
    if (_passwordController.text.length < 8) {
      setState(() => _errorMessage = 'Password must be at least 8 characters.');
      return;
    }
    if (_passwordController.text != _confirmPasswordController.text) {
      setState(() => _errorMessage = 'Passwords do not match.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await http
          .post(
            Uri.parse('$_BaseUrl/api/auth/register'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'fullName': _fullNameController.text.trim(),
              'email': _emailController.text.trim(),
              'password': _passwordController.text,
              'role': _selectedRole!.apiValue,
              'phone': _phoneController.text.trim(),
            }),
          )
          .timeout(const Duration(seconds: 20));

      final body = jsonDecode(response.body);

      if (response.statusCode == 200 && body['success'] == true) {
        if (!mounted) return;

        // CHANGED: Show success and go to login instead of dashboard
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Account created successfully. Please log in.'),
            backgroundColor: _cTeal,
          ),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const AdminLoginPage()),
        );
      } else {
        setState(() {
          _errorMessage =
              body['message'] ?? 'Sign up failed. Email may already exist.';
        });
      }
    } catch (e) {
      final msg = e.toString();
      if (msg.contains('XMLHttpRequest') || msg.contains('SocketException')) {
        _errorMessage = 'Cannot reach server. Check network or CORS.';
      } else if (msg.contains('TimeoutException')) {
        _errorMessage = 'Request timed out. Try again.';
      } else {
        _errorMessage = msg.replaceFirst('Exception: ', '');
      }
      setState(() {});
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ── Navigation ───────────────────────────────────────────────────────────
  void _goToLogin() => Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (_) => const AdminLoginPage()),
  );

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWide = size.width >= 800;

    return Scaffold(
      backgroundColor: _cBg,
      body: Row(
        children: [
          Expanded(
            flex: isWide ? 5 : 10,
            child: Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: isWide ? 60 : 28,
                  vertical: 48,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 460),
                  child: _buildForm(),
                ),
              ),
            ),
          ),
          if (isWide)
            Expanded(
              flex: 5,
              child: Image.asset(
                'assets/images/signpg_img.png',
                fit: BoxFit.cover,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Image.asset('assets/images/Logo.png', height: 34),
            const SizedBox(width: 10),
            const Text(
              'Heathos',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: _cTealDark,
              ),
            ),
          ],
        ),
        const SizedBox(height: 40),

        const Text(
          'Welcome',
          style: TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.w900,
            color: _cTeal,
            height: 1.1,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Seamless hospital management for smarter,\nsafer and better healthcare.',
          style: TextStyle(
            fontSize: 13,
            color: Color.fromARGB(255, 7, 13, 12),
            height: 1.6,
          ),
        ),
        const SizedBox(height: 32),

        const Text(
          'Sign Up',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: _cText,
          ),
        ),
        const SizedBox(height: 20),

        _label('User Type'),
        const SizedBox(height: 6),
        DropdownButtonFormField<_RoleOption>(
          value: _selectedRole,
          decoration: _inputDeco('Select user type'),
          style: const TextStyle(fontSize: 14, color: _cText),
          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: _cSubtext),
          items: _signupRoles
              .map(
                (r) => DropdownMenuItem(
                  value: r,
                  child: Row(
                    children: [
                      Icon(r.icon, size: 16, color: _cSubtext),
                      const SizedBox(width: 8),
                      Text(
                        r.label,
                        style: const TextStyle(fontSize: 14, color: _cText),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
          onChanged: (v) => setState(() => _selectedRole = v),
        ),
        const SizedBox(height: 18),

        _label('Full Name'),
        const SizedBox(height: 6),
        TextField(
          controller: _fullNameController,
          style: const TextStyle(fontSize: 14, color: _cText),
          decoration: _inputDeco('Enter your full name'),
        ),
        const SizedBox(height: 18),

        _label('Email'),
        const SizedBox(height: 6),
        TextField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          style: const TextStyle(fontSize: 14, color: _cText),
          decoration: _inputDeco('Enter your email'),
        ),
        const SizedBox(height: 18),

        _label('Phone Number'),
        const SizedBox(height: 6),
        TextField(
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          style: const TextStyle(fontSize: 14, color: _cText),
          decoration: _inputDeco('Enter your phone number'),
        ),
        const SizedBox(height: 18),

        _label('Password'),
        const SizedBox(height: 6),
        TextField(
          controller: _passwordController,
          obscureText: _obscurePassword,
          style: const TextStyle(fontSize: 14, color: _cText),
          decoration: _inputDeco('Create a password').copyWith(
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility_off : Icons.visibility,
                color: _cSubtext,
                size: 20,
              ),
              onPressed: () =>
                  setState(() => _obscurePassword = !_obscurePassword),
            ),
          ),
        ),
        const SizedBox(height: 18),

        _label('Confirm Password'),
        const SizedBox(height: 6),
        TextField(
          controller: _confirmPasswordController,
          obscureText: _obscureConfirm,
          style: const TextStyle(fontSize: 14, color: _cText),
          decoration: _inputDeco('Re-enter your password').copyWith(
            suffixIcon: IconButton(
              icon: Icon(
                _obscureConfirm ? Icons.visibility_off : Icons.visibility,
                color: _cSubtext,
                size: 20,
              ),
              onPressed: () =>
                  setState(() => _obscureConfirm = !_obscureConfirm),
            ),
          ),
        ),
        const SizedBox(height: 24),

        if (_errorMessage != null) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.07),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.red.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.error_outline_rounded,
                  color: Colors.red,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],

        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _cTeal,
              disabledBackgroundColor: _cTeal.withOpacity(0.55),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            onPressed: _isLoading ? null : _handleSignUp,
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                    ),
                  )
                : const Text(
                    'Sign Up',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: Colors.black,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 20),

        Center(
          child: GestureDetector(
            onTap: _goToLogin,
            child: RichText(
              text: const TextSpan(
                style: TextStyle(fontSize: 13, color: _cSubtext),
                children: [
                  TextSpan(text: 'Already have an account? '),
                  TextSpan(
                    text: 'Login',
                    style: TextStyle(
                      color: _cTeal,
                      fontWeight: FontWeight.w700,
                      decoration: TextDecoration.underline,
                      decorationColor: _cTeal,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _label(String text) => Text(
    text,
    style: const TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w600,
      color: _cText,
    ),
  );

  InputDecoration _inputDeco(String hint) => InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(color: _cSubtext, fontSize: 13),
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: _cBorder, width: 1.4),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: _cTeal, width: 2),
    ),
  );
}

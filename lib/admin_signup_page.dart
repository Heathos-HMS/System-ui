import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'admin_dashboard.dart';
import 'doctor_dashboard.dart';
import 'staff_dashboard.dart';
import 'admin_login_page.dart';

// ── Base URL ─────────────────────────────────────────────────────────────────
// Flutter Web runs in the browser — localhost refers to your own machine.
// Make sure your Spring Boot backend has CORS enabled for http://localhost
const String _baseUrl = 'https://heathos-api.onrender.com';

//'http://localhost:8080/api';

// ── Colour tokens ─────────────────────────────────────────────────────────────
const _cTeal = Color.fromARGB(255, 1, 211, 193);
const _cTealDark = Color(0xFF0D7B6B);
const _cBg = Color(0xFFF5FAFA);
const _cBorder = Color(0xFFCCE8E5);
const _cText = Color(0xFF0D2B27);
const _cSubtext = Color(0xFF607C79);

class AdminSignUpPage extends StatefulWidget {
  const AdminSignUpPage({super.key});

  @override
  State<AdminSignUpPage> createState() => _AdminSignUpPageState();
}

class _AdminSignUpPageState extends State<AdminSignUpPage> {
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // ── State ─────────────────────────────────────────────────────────────────
  String? _selectedRole;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // ── Map display label → API role value
  String _toApiRole(String label) {
    switch (label) {
      case 'Doctor':
        return 'DOCTOR';
      case 'Staff':
        return 'STAFF';
      case 'Admin':
      default:
        return 'ADMIN';
    }
  }

  // ── API call
  Future<void> _handleSignUp() async {
    // Client-side validation
    if (_selectedRole == null) {
      setState(() => _errorMessage = 'Please select a user type.');
      return;
    }
    if (_fullNameController.text.trim().isEmpty) {
      setState(() => _errorMessage = 'Please enter your full name.');
      return;
    }
    if (_emailController.text.trim().isEmpty) {
      setState(() => _errorMessage = 'Please enter your institutional email.');
      return;
    }
    if (_passwordController.text.isEmpty) {
      setState(() => _errorMessage = 'Please create a password.');
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

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final uri = Uri.parse('$_baseUrl/api/auth/register');
      debugPrint('[SignUp] POST → $uri');

      final response = await http
          .post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'fullName': _fullNameController.text.trim(),
              'email': _emailController.text.trim(),
              'password': _passwordController.text,
              'role': _toApiRole(_selectedRole!),
            }),
          )
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () => throw Exception(
              'Request timed out. Make sure the backend is running on port 8080.',
            ),
          );

      debugPrint('[SignUp] Status: ${response.statusCode}');
      debugPrint('[SignUp] Body: ${response.body}');

      final body = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && body['success'] == true) {
        if (!mounted) return;
        _navigateToDashboard(_selectedRole!);
      } else {
        setState(
          () => _errorMessage =
              body['message'] as String? ?? 'Sign up failed. Please try again.',
        );
      }
    } catch (e) {
      debugPrint('[SignUp] Error: $e');
      final msg = e.toString();
      if (msg.contains('XMLHttpRequest') ||
          msg.contains('Failed host lookup')) {
        setState(
          () => _errorMessage =
              'Could not reach the server. CORS may not be enabled.',
        );
      } else if (msg.contains('timed out')) {
        setState(
          () => _errorMessage =
              'Request timed out. Make sure the backend is running.',
        );
      } else {
        setState(() => _errorMessage = msg.replaceFirst('Exception: ', ''));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ── Role-based navigation ─────────────────────────────────────────────────
  void _navigateToDashboard(String role) {
    Widget destination;
    switch (role) {
      case 'Doctor':
        destination = const DoctorDashboard();
        break;
      case 'Staff':
        destination = const StaffDashboard();
        break;
      default:
        destination = const AdminDashboard();
    }
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => destination),
    );
  }

  void _goToLogin() => Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (_) => const AdminLoginPage()),
  );

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWide = size.width >= 800;

    return Scaffold(
      backgroundColor: _cBg,
      body: Row(
        children: [
          // ── LEFT: form panel ───────────────────────────────────────────
          Expanded(
            flex: isWide ? 5 : 10,
            child: Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: isWide ? 56 : 28,
                  vertical: 40,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 480),
                  child: _buildForm(),
                ),
              ),
            ),
          ),

          // ── RIGHT: image panel ─────────────────────────────────────────
          if (isWide)
            Expanded(
              flex: 5,
              child: SizedBox(
                height: size.height,
                child: Image.asset(
                  'assets/images/signpg_img.png',
                  fit: BoxFit.cover,
                ),
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
        // ── Logo row ──────────────────────────────────────────────────────
        Row(
          children: [
            Image.asset('assets/images/Logo.png', height: 36),
            const SizedBox(width: 10),
            const Text(
              'Heathos',
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.w800,
                color: _cTealDark,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
        const SizedBox(height: 36),

        // ── Heading ───────────────────────────────────────────────────────
        const Text(
          'Sign Up',
          style: TextStyle(
            fontSize: 35,
            fontWeight: FontWeight.w900,
            color: _cTeal,
            height: 1.1,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Create your Heathos HMS account below.',
          style: TextStyle(fontSize: 13, color: _cSubtext, height: 1.5),
        ),
        const SizedBox(height: 28),

        // ── User type dropdown ─────────────────────────────────────────────
        _label('User Type'),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          value: _selectedRole,
          decoration: _inputDeco('Select User Type'),
          style: const TextStyle(fontSize: 14, color: _cText),
          dropdownColor: Colors.white,
          borderRadius: BorderRadius.circular(10),
          items: [
            'Admin',
            'Doctor',
            'Staff',
          ].map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
          onChanged: (v) => setState(() {
            _selectedRole = v;
            _errorMessage = null;
          }),
        ),
        const SizedBox(height: 16),

        // ── Full Name ──────────────────────────────────────────────────────
        _label('Full Name'),
        const SizedBox(height: 6),
        TextField(
          controller: _fullNameController,
          style: const TextStyle(fontSize: 14, color: _cText),
          decoration: _inputDeco('Please enter your full name'),
        ),
        const SizedBox(height: 16),

        // ── Institutional Email ────────────────────────────────────────────
        _label('Institutional Email'),
        const SizedBox(height: 6),
        TextField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          style: const TextStyle(fontSize: 14, color: _cText),
          decoration: _inputDeco('Enter your institutional email'),
        ),
        const SizedBox(height: 16),

        // ── Create Password ────────────────────────────────────────────────
        _label('Create Password'),
        const SizedBox(height: 6),
        TextField(
          controller: _passwordController,
          obscureText: _obscurePassword,
          style: const TextStyle(fontSize: 14, color: _cText),
          decoration: _inputDeco('Minimum 8 characters').copyWith(
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
        const SizedBox(height: 16),

        // ── Confirm Password ───────────────────────────────────────────────
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
        const SizedBox(height: 22),

        // ── Error message ──────────────────────────────────────────────────
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

        // ── Sign Up button ─────────────────────────────────────────────────
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

        // ── Already have account ───────────────────────────────────────────
        Center(
          child: GestureDetector(
            onTap: _goToLogin,
            child: RichText(
              text: const TextSpan(
                style: TextStyle(fontSize: 13, color: _cSubtext),
                children: [
                  TextSpan(text: 'Already have an account? '),
                  TextSpan(
                    text: 'Sign In',
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

  // ── Helpers ───────────────────────────────────────────────────────────────
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

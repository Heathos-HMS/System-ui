import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'admin_dashboard.dart';
import 'doctor_dashboard.dart';
import 'staff_dashboard.dart';
import 'admin_signup_page.dart';

const String _baseUrl = 'https://heathos-api.onrender.com';

// ── Colour tokens (login page palette) ───────────────────────────────────────
const _cTeal = Color.fromARGB(255, 1, 211, 193);
const _cTealDark = Color(0xFF0D7B6B);
const _cBg = Color(0xFFF5FAFA);
const _cBorder = Color(0xFFCCE8E5);
const _cText = Color(0xFF0D2B27);
const _cSubtext = Color(0xFF607C79);

class AdminLoginPage extends StatefulWidget {
  const AdminLoginPage({super.key});

  @override
  State<AdminLoginPage> createState() => _AdminLoginPageState();
}

class _AdminLoginPageState extends State<AdminLoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  String? _selectedRole;
  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ── API call ──────────────────────────────────────────────────────────────
  Future<void> _handleLogin() async {
    if (_selectedRole == null) {
      setState(() => _errorMessage = 'Please select your role.');
      return;
    }
    if (_emailController.text.trim().isEmpty ||
        _passwordController.text.isEmpty) {
      setState(() => _errorMessage = 'Enter email and password.');
      return;
    }
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final uri = Uri.parse('$_baseUrl/api/auth/login');
      final response = await http
          .post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'email': _emailController.text.trim(),
              'password': _passwordController.text,
            }),
          )
          .timeout(const Duration(seconds: 20));
      final body = jsonDecode(response.body);
      if (response.statusCode == 200 && body['success'] == true) {
        _navigateToDashboard(body['data']['role'] as String);
      } else {
        setState(() => _errorMessage = body['message'] ?? 'Login failed');
      }
    } catch (e) {
      setState(() => _errorMessage = 'Server not reachable or CORS issue.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ── Role-based navigation ─────────────────────────────────────────────────
  void _navigateToDashboard(String serverRole) {
    Widget destination;
    switch (serverRole.toUpperCase()) {
      case 'DOCTOR':
        destination = const AdminDashboard();
        break;
      case 'STAFF':
        destination = const AdminDashboard();
        break;
      default:
        destination = const AdminDashboard();
    }
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => destination),
    );
  }

  void _goToSignUp() => Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (_) => const AdminSignUpPage()),
  );

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWide = size.width >= 800;

    return Scaffold(
      backgroundColor: _cBg,
      // ── No AppBar — cleaner full-screen look ──────────────────────────────
      body: Row(
        children: [
          // ── LEFT: form panel ─────────────────────────────────────────────
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

          // ── RIGHT: image panel ───────────────────────────────────────────
          if (isWide)
            Expanded(
              flex: 5,
              child: SizedBox(
                height: size.height,
                child: Image.asset(
                  'assets/images/login_image.png',
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
        // ── Logo row ───────────────────────────────────────────────────────
        Row(
          children: [
            Image.asset('assets/images/Logo.png', height: 36),
            const SizedBox(width: 10),
            const Text(
              'Heathos',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: _cTealDark,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
        const SizedBox(height: 40),

        // ── Heading ────────────────────────────────────────────────────────
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

        // ── Section label ──────────────────────────────────────────────────
        const Text(
          'Login',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: _cText,
          ),
        ),
        const SizedBox(height: 20),

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
        const SizedBox(height: 18),

        // ── Email ──────────────────────────────────────────────────────────
        _label('Institutional Email'),
        const SizedBox(height: 6),
        TextField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          style: const TextStyle(fontSize: 14, color: _cText),
          decoration: _inputDeco('Enter your institutional email'),
        ),
        const SizedBox(height: 18),

        // ── Password ───────────────────────────────────────────────────────
        _label('Password'),
        const SizedBox(height: 6),
        TextField(
          controller: _passwordController,
          obscureText: _obscurePassword,
          style: const TextStyle(fontSize: 14, color: _cText),
          decoration: _inputDeco('Enter your password').copyWith(
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
        const SizedBox(height: 24),

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

        // ── Login button ───────────────────────────────────────────────────
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
            onPressed: _isLoading ? null : _handleLogin,
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
                    'Login',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: Colors.black,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 20),

        // ── Sign Up link ───────────────────────────────────────────────────
        Center(
          child: GestureDetector(
            onTap: _goToSignUp,
            child: RichText(
              text: const TextSpan(
                style: TextStyle(fontSize: 13, color: _cSubtext),
                children: [
                  TextSpan(text: "Don't have an account? "),
                  TextSpan(
                    text: 'Sign Up',
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

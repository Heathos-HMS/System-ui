import 'dart:convert';
import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'constants/api_constants.dart';
import 'admin_signup_page.dart';
import 'admin_dashboard.dart';
import 'doctor_dashboard.dart';
//import 'receptionist_page.dart';
import 'lab_technicians_page.dart';
import 'billing_staff_dashboard.dart';
import 'patient_dashboard.dart';

// ── Base URL ──────────────────────────────────────────────────────────────────
const String _loginBaseUrl = kApiBaseUrlWithApi;

// ── Colour tokens ─────────────────────────────────────────────────────────────
const _cTeal = Color.fromARGB(255, 1, 211, 193);
const _cTealDark = Color(0xFF0D7B6B);
const _cBg = Color(0xFFF5FAFA);
const _cBorder = Color(0xFFCCE8E5);
const _cText = Color(0xFF0D2B27);
const _cSubtext = Color(0xFF607C79);

// ── Role options shown in the dropdown ────────────────────────────────────────
const List<_RoleOption> _loginRoles = [
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
    apiValue: 'BILLING_STAFF',
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

class AdminLoginPage extends StatefulWidget {
  const AdminLoginPage({super.key});

  @override
  State<AdminLoginPage> createState() => _AdminLoginPageState();
}

class _AdminLoginPageState extends State<AdminLoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  _RoleOption? _selectedRole;
  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ── API — POST /api/auth/login ────────────────────────────────────────────
  Future<void> _handleLogin() async {
    setState(() => _errorMessage = null);

    if (_selectedRole == null) {
      setState(() => _errorMessage = 'Please select your user type.');
      return;
    }
    if (_emailController.text.trim().isEmpty) {
      setState(() => _errorMessage = 'Please enter your email.');
      return;
    }
    if (_passwordController.text.isEmpty) {
      setState(() => _errorMessage = 'Please enter your password.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await http
          .post(
            Uri.parse('$_loginBaseUrl/auth/login'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'email': _emailController.text.trim(),
              'password': _passwordController.text,
            }),
          )
          .timeout(const Duration(seconds: 20));

      final body = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && body['success'] == true) {
        final data = body['data'];

        final String token = data['token'];
        final String serverRole = (data['role'] as String).toUpperCase();
        final String userId = data['userId'];

        // ✅ STORE TOKEN (WEB)
        html.window.localStorage['token'] = token;
        html.window.localStorage['role'] = serverRole;
        html.window.localStorage['userId'] = userId;

        if (!mounted) return;
        _navigateToDashboard(serverRole);
      } else {
        setState(
          () => _errorMessage = body['message'] as String? ?? 'Login failed.',
        );
      }
    } catch (e) {
      final msg = e.toString();
      if (msg.contains('XMLHttpRequest') || msg.contains('SocketException')) {
        setState(
          () => _errorMessage = 'Cannot reach server. Check network or CORS.',
        );
      } else if (msg.contains('TimeoutException')) {
        setState(() => _errorMessage = 'Request timed out. Try again.');
      } else {
        setState(() => _errorMessage = msg.replaceFirst('Exception: ', ''));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ── Role-based navigation ────────────────────────────────────────────────
  void _navigateToDashboard(String serverRole) {
    Widget destination;
    switch (serverRole) {
      case 'DOCTOR':
        destination = const AdminDashboard(); // replace later
        break;
      case 'RECEPTIONIST':
        destination = const PatientListPage();
        break;
      case 'LAB_TECHNICIAN':
        destination = const LabTechniciansPage();
        break;
      case 'BILLING_STAFF':
      case 'BILLING_OFFICER':
        destination = const BillingStaffDashboard();
        break;
      case 'ADMIN':
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

        // ── Section label ──────────────────────────────────────────────────
        const Text(
          'Login',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color.fromARGB(255, 26, 45, 42),
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
          items: _loginRoles
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

        _label('Email'),
        const SizedBox(height: 6),
        TextField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          style: const TextStyle(fontSize: 14, color: _cText),
          decoration: _inputDeco('Enter your email'),
        ),
        const SizedBox(height: 18),

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

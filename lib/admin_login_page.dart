import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'admin_dashboard.dart';
import 'doctor_dashboard.dart'; // uncomment when ready
import 'staff_dashboard.dart';  // uncomment when ready
import 'admin_signup_page.dart';

// Base URL — Flutter Web uses localhost directly 
// Ensure your Spring Boot backend has CORS enabled for http://localhost
const String _baseUrl = 'https://heathos-api.onrender.com/api/auth/login';
//'http://localhost:8080/api';

class AdminLoginPage extends StatefulWidget {
  const AdminLoginPage({super.key});

  @override
  State<AdminLoginPage> createState() => _AdminLoginPageState();
}

class _AdminLoginPageState extends State<AdminLoginPage> {
  // ── Controllers ──────────────────────────────────────────────────────────
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // ── State ─────────────────────────────────────────────────────────────────
  String? _selectedRole; // "Admin" | "Doctor" | "Staff"
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
    // Client-side validation
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

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final uri = Uri.parse('$_baseUrl/auth/login');
      debugPrint('[Login] POST → $uri');

      final response = await http
          .post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'email': _emailController.text.trim(),
              'password': _passwordController.text,
            }),
          )
          .timeout(
            const Duration(seconds: 15),
            onTimeout: () => throw Exception(
              'Request timed out. Make sure the backend is running on port 8080.',
            ),
          );

      debugPrint('[Login] Status: ${response.statusCode}');
      debugPrint('[Login] Body: ${response.body}');

      final body = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && body['success'] == true) {
        final data = body['data'] as Map<String, dynamic>;
        final String roleFromServer = data['role'] as String? ?? '';
        final String token = data['token'] as String? ?? '';
        final String userId = data['userId'] as String? ?? '';

        debugPrint('[Login] Role from server: $roleFromServer');
        debugPrint('[Login] Token: $token');
        debugPrint('[Login] UserId: $userId');

        // Optional: store token for later authenticated requests
        // e.g. SharedPreferences, Provider, Riverpod, etc.

        if (!mounted) return;

        // Navigate based on role returned by the server
        // (server is source of truth, not just the dropdown)
        _navigateToDashboard(roleFromServer);
      } else {
        // Covers 400 wrong password, 404 no account, 403 deactivated
        setState(
          () => _errorMessage =
              body['message'] as String? ?? 'Login failed. Please try again.',
        );
      }
    } catch (e) {
      debugPrint('[Login] Error: $e');
      final msg = e.toString();

      // Flutter Web: CORS or server unreachable both surface as XMLHttpRequest error
      if (msg.contains('XMLHttpRequest') ||
          msg.contains('Failed host lookup')) {
        setState(
          () => _errorMessage =
              'Could not reach the server. Make sure the backend is running '
              'and CORS is enabled for http://localhost.',
        );
      } else if (msg.contains('timed out')) {
        setState(
          () => _errorMessage =
              'Request timed out. Make sure the backend is running on port 8080.',
        );
      } else {
        setState(() => _errorMessage = msg.replaceFirst('Exception: ', ''));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ── Role-based navigation — server role is source of truth ───────────────
  void _navigateToDashboard(String serverRole) {
    Widget destination;
    switch (serverRole.toUpperCase()) {
      case 'DOCTOR':
        // destination = const DoctorDashboard(); // uncomment when ready
        destination = const AdminDashboard(); // placeholder
        break;
      case 'STAFF':
        // destination = const StaffDashboard();  // uncomment when ready
        destination = const AdminDashboard(); // placeholder
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

  // ── Navigate to Sign Up ───────────────────────────────────────────────────
  void _goToSignUp() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const AdminSignUpPage()),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // On narrow screens (< 700px) hide the right image and go single column
    final bool isWide = screenWidth >= 700;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.maybePop(context),
          icon: const Icon(Icons.arrow_back_outlined, color: Colors.black),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: Image.asset('assets/images/Logo.png'),
            ),
            const Text(
              "Heathos",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),

      body: SingleChildScrollView(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── LEFT: Login Form ──────────────────────────────────────────
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // WELCOME TEXT — original style
                    const Text(
                      'Welcome',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 60,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 1, 211, 193),
                      ),
                    ),

                    // DISPLAY TEXT — original style
                    const Text(
                      'Seamless hospital management for smarter, safer and better\n healthcare',
                      style: TextStyle(fontFamily: 'Poppins'),
                    ),

                    const SizedBox(height: 25),

                    // LOGIN TEXT — original style
                    const Text(
                      'Login',
                      style: TextStyle(fontSize: 24, fontFamily: 'Poppins'),
                    ),

                    const SizedBox(height: 20),

                    // USER TYPE DROPDOWN — unchanged from original
                    DropdownButtonFormField<String>(
                      value: _selectedRole,
                      decoration: InputDecoration(
                        labelText: 'Select User Type',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                      items: ['Admin', 'Doctor', 'Staff']
                          .map(
                            (String value) => DropdownMenuItem(
                              value: value,
                              child: Text(value),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedRole = value;
                          _errorMessage = null;
                        });
                      },
                    ),
                    const SizedBox(height: 20),

                    // EMAIL FIELD — original style
                    TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: 'Enter your institution Email',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // PASSWORD FIELD — original style + working toggle
                    TextField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                        labelText: 'Password',
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () => setState(
                            () => _obscurePassword = !_obscurePassword,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // ERROR MESSAGE — only shows when there is an error
                    if (_errorMessage != null) ...[
                      Text(
                        _errorMessage!,
                        style: const TextStyle(
                          color: Colors.red,
                          fontSize: 13,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],

                    // LOGIN BUTTON — original style
                    Align(
                      alignment: Alignment.center,
                      child: SizedBox(
                        height: 45,
                        width: 200,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color.fromARGB(
                              255,
                              1,
                              211,
                              193,
                            ),
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
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.black,
                                    ),
                                  ),
                                )
                              : const Text(
                                  'Login',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // DON'T HAVE AN ACCOUNT — Sign Up link
                    Center(
                      child: GestureDetector(
                        onTap: _goToSignUp,
                        child: RichText(
                          text: const TextSpan(
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.black54,
                              fontFamily: 'Poppins',
                            ),
                            children: [
                              TextSpan(text: "Don't have an account? "),
                              TextSpan(
                                text: 'Sign Up',
                                style: TextStyle(
                                  color: Color.fromARGB(255, 1, 211, 193),
                                  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration.underline,
                                  decorationColor: Color.fromARGB(
                                    255,
                                    1,
                                    211,
                                    193,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── RIGHT: Image — hidden on narrow screens ───────────────────
            if (isWide)
              Expanded(
                flex: 1,
                child: SizedBox(
                  height:
                      screenHeight -
                      kToolbarHeight -
                      MediaQuery.of(context).padding.top,
                  child: Image.asset(
                    'assets/images/login_image.png',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}








// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;

// class AdminLoginPage extends StatefulWidget {
//   const AdminLoginPage({super.key});

//   @override
//   State<AdminLoginPage> createState() => _AdminLoginPageState();
// }

// class _AdminLoginPageState extends State<AdminLoginPage> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         leading: IconButton(
//           onPressed: () {},
//           icon: Icon(Icons.arrow_back_outlined, color: Colors.black),
//         ),
//         title: Row(
//           mainAxisAlignment: MainAxisAlignment.start,
//           children: [
//             Align(
//               alignment: Alignment.topLeft,
//               child: Image.asset('assets/images/Logo.png'),
//             ),

//             Text(
//               "Heathos",
//               style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//             ),
//           ],
//         ),
//       ),

//       body: SingleChildScrollView(
//         child: Row(
//           children: [
//             // LOGIN FORM
//             Expanded(
//               flex: 1,
//               child: Padding(
//                 padding: const EdgeInsets.all(20.0),
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     //WELCOME TEXT
//                     Text(
//                       'Welcome',
//                       style: TextStyle(
//                         fontFamily: 'Poppins',
//                         fontSize: 60,
//                         fontWeight: FontWeight.bold,
//                         color: const Color.fromARGB(255, 1, 211, 193),
//                       ),
//                     ),
//                     //SizedBox(height: 2),

//                     //DISPLAY TEXT
//                     Text(
//                       'Seamless hospital management for smarter, safer and better\n healthcare',
//                       style: TextStyle(fontFamily: 'Poppins'),
//                     ),

//                     SizedBox(height: 25),

//                     //LOGIN TEXT
//                     Text(
//                       'Login',
//                       style: TextStyle(fontSize: 24, fontFamily: 'Poppins'),
//                     ),

//                     SizedBox(height: 20),

//                     //USERS SELECTION FIELD
//                     DropdownButtonFormField<String>(
//                       decoration: InputDecoration(
//                         labelText: 'Select User Type',
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(5),
//                         ),
//                       ),
//                       items: ['Admin', 'Doctor', 'Staff'].map((String value) {
//                         return DropdownMenuItem(
//                           value: value,
//                           child: Text(value),
//                         );
//                       }).toList(),
//                       onChanged: (value) {},
//                     ),
//                     SizedBox(height: 20),

//                     //email FIELD
//                     TextField(
//                       decoration: InputDecoration(
//                         labelText: 'Enter your institution Email',
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(5),
//                         ),
//                         //   labelText: 'Password',
//                         //   suffixIcon: Icon(Icons.visibility_off),
//                         // )
//                       ),
//                     ),
//                     SizedBox(height: 20),

//                     //PASSWORD FIELD
//                     TextField(
//                       obscureText: true,
//                       decoration: InputDecoration(
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(5),
//                         ),
//                         labelText: 'Password',
//                         suffixIcon: Icon(Icons.visibility_off),
//                       ),
//                     ),
//                     SizedBox(height: 20),

//                     //LOGIN BUTTON
//                     Align(
//                       alignment: Alignment.center,
//                       child: SizedBox(
//                         height: 45,
//                         width: 200,
//                         child: ElevatedButton(
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: const Color.fromARGB(
//                               255,
//                               1,
//                               211,
//                               193,
//                             ),
//                           ),
//                           onPressed: () {},
//                           child: Text(
//                             'Login',
//                             style: TextStyle(
//                               fontFamily: 'Poppins',
//                               fontWeight: FontWeight.bold,
//                               color: Colors.black,
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),

                  
//                   ],
//                 ),
//               ),
//             ),
//             // Right side: Image

//             //PAGE IMAGE ON THE RIGHT SIDE
//             Expanded(
//               flex: 1,
//               child: Opacity(
//                 opacity: 1.0,
//                 child: Image.asset(
//                   'assets/images/login_image.png',
//                   fit: BoxFit.cover,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       )
//     );
//   }
// }
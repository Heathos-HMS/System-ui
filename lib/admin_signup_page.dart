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
const String _baseUrl = 'https://heathos-api.onrender.com/api/auth/register';

//'http://localhost:8080/api';

class AdminSignUpPage extends StatefulWidget {
  const AdminSignUpPage({super.key});

  @override
  State<AdminSignUpPage> createState() => _AdminSignUpPageState();
}

class _AdminSignUpPageState extends State<AdminSignUpPage> {
  // ── Controllers ──────────────────────────────────────────────────────────
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
      final uri = Uri.parse('$_baseUrl/auth/register');
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
            const Duration(seconds: 15),
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
        // Covers 400, duplicate email, and all other backend error messages
        setState(
          () => _errorMessage =
              body['message'] as String? ?? 'Sign up failed. Please try again.',
        );
      }
    } catch (e) {
      debugPrint('[SignUp] Error: $e');

      final msg = e.toString();

      // Flutter Web: CORS or server unreachable both surface as XMLHttpRequest error
      if (msg.contains('XMLHttpRequest') ||
          msg.contains('Failed host lookup')) {
        setState(
          () => _errorMessage =
              'Could not reach the server. This is likely a CORS issue — '
              'ask your backend developer to allow requests from '
              'http://localhost in the Spring Boot CORS config.',
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

  // ── Role-based navigation ─────────────────────────────────────────────────
  void _navigateToDashboard(String role) {
    Widget destination;
    switch (role) {
      case 'Doctor':
        // destination = const DoctorDashboard(); // uncomment when ready
        destination = const AdminDashboard();
        break;
      case 'Staff':
        // destination = const StaffDashboard(); // uncomment when ready
        destination = const AdminDashboard();
        break;
      case 'Admin':
      default:
        destination = const AdminDashboard();
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => destination),
    );
  }

  // ── Navigate to Login ─────────────────────────────────────────────────────
  void _goToLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const AdminLoginPage()),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
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
            // ── LEFT: Sign Up Form ────────────────────────────────────────
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // HEADING
                    const Text(
                      'Sign Up',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 60,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 1, 211, 193),
                      ),
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

                    // FULL NAME
                    const Text(
                      'Full Name',
                      style: TextStyle(fontSize: 24, fontFamily: 'Poppins'),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _fullNameController,
                      decoration: InputDecoration(
                        labelText: 'Please Enter Your Full Name',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // INSTITUTIONAL EMAIL
                    const Text(
                      'Institutional Email',
                      style: TextStyle(fontSize: 24, fontFamily: 'Poppins'),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: 'Enter Your Institutional Email',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // CREATE PASSWORD
                    const Text(
                      'Create Password',
                      style: TextStyle(fontSize: 24, fontFamily: 'Poppins'),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        labelText: 'Create Password',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
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

                    // CONFIRM PASSWORD
                    const Text(
                      'Confirm Password',
                      style: TextStyle(fontSize: 24, fontFamily: 'Poppins'),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _confirmPasswordController,
                      obscureText: _obscureConfirm,
                      decoration: InputDecoration(
                        labelText: 'Confirm Password',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureConfirm
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () => setState(
                            () => _obscureConfirm = !_obscureConfirm,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // ERROR MESSAGE
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

                    // SIGN UP BUTTON
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
                          onPressed: _isLoading ? null : _handleSignUp,
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
                                  'Sign Up',
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

                    // ALREADY HAVE AN ACCOUNT
                    Center(
                      child: GestureDetector(
                        onTap: _goToLogin,
                        child: RichText(
                          text: const TextSpan(
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.black54,
                              fontFamily: 'Poppins',
                            ),
                            children: [
                              TextSpan(text: 'Already have an account? '),
                              TextSpan(
                                text: 'Sign In',
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

            // ── RIGHT: Medical Image ──────────────────────────────────────
            Expanded(
              flex: 1,
              child: SizedBox(
                height:
                    MediaQuery.of(context).size.height -
                    kToolbarHeight -
                    MediaQuery.of(context).padding.top,
                child: Image.asset(
                  'assets/images/signpg_img.png',
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

// class AdminSignUpPage extends StatefulWidget {
//   const AdminSignUpPage({super.key});

//   @override
//   State<AdminSignUpPage> createState() => _AdminSignUpPageState();
// }

// class _AdminSignUpPageState extends State<AdminSignUpPage> {
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
//             // SIGN UP FORM
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
//                       'Sign Up',
//                       style: TextStyle(
//                         fontFamily: 'Poppins',
//                         fontSize: 60,
//                         fontWeight: FontWeight.bold,
//                         color: const Color.fromARGB(255, 1, 211, 193),
//                       ),
//                     ),

//                     //SizedBox(height: 2),

//                     //DISPLAY TEXT
//                     // Text(
//                     //   'Seamless hospital management for smarter, safer and better\n healthcare',
//                     //   style: TextStyle(fontFamily: 'Poppins'),
//                     // ),
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

//                     Text(
//                       'Full Name',
//                       style: TextStyle(fontSize: 24, fontFamily: 'Poppins'),
//                     ),
//                     SizedBox(height: 20),

//                     //email FIELD
//                     TextField(
//                       decoration: InputDecoration(
//                         labelText: 'Please Enter Your Full Name',
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(5),
//                         ),
//                         //   labelText: 'Password',
//                         //   suffixIcon: Icon(Icons.visibility_off),
//                         // )
//                       ),
//                     ),
//                     SizedBox(height: 20),

//                     Text(
//                       'Institutional Email',
//                       style: TextStyle(fontSize: 24, fontFamily: 'Poppins'),
//                     ),
//                     SizedBox(height: 20),

//                     //email FIELD
//                     TextField(
//                       decoration: InputDecoration(
//                         labelText: 'Enter Your Institutional Email',
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(5),
//                         ),
//                         //   labelText: 'Password',
//                         //   suffixIcon: Icon(Icons.visibility_off),
//                         // )
//                       ),
//                     ),
//                     SizedBox(height: 20),

//                     //CREATE PASSWORD FIELD
//                     Text(
//                       'Create Password',
//                       style: TextStyle(fontSize: 24, fontFamily: 'Poppins'),
//                     ),
                    
//                     TextField(
//                       obscureText: true,
//                       decoration: InputDecoration(
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(5),
//                         ),
//                         labelText: 'Create Password',
//                         suffixIcon: Icon(Icons.visibility_off),
//                       ),
//                     ),
//                     SizedBox(height: 20),

//                      //CONFIRM PASSWORD FIELD
//                     Text(
//                       'Confirm Password',
//                       style: TextStyle(fontSize: 24, fontFamily: 'Poppins'),
//                     ),

//                     TextField(
//                       obscureText: true,
//                       decoration: InputDecoration(
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(5),
//                         ),
//                         labelText: 'Confirm Password',
//                         suffixIcon: Icon(Icons.visibility_off),
//                       ),
//                     ),
//                     SizedBox(height: 20),

//                     //SIGN UP BUTTON
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
//                             'Sign Up',
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
//                   'assets/images/signpg_img.png',
//                   fit: BoxFit.cover,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }



// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'admin_dashboard.dart';
// import 'doctor_dashboard.dart';   
// import 'staff_dashboard.dart';  


// // CONSTANTS 
// const _kTeal = Color(0xFF0D7B6B);
// const _kTealLight = Color(0xFF1FC8B2);
// const _kTealDark = Color(0xFF095F54);
// const _kTealSurface = Color(0xFFE8F5F3);
// const _kWhite = Color(0xFFFFFFFF);
// const _kBackground = Color(0xFFF4F9F8);
// const _kTextDark = Color(0xFF0D2B27);
// const _kTextMid = Color(0xFF4A7A72);
// const _kTextLight = Color(0xFF8AACA7);
// const _kError = Color(0xFFD94040);

// const _kBaseUrl = 'http://localhost:8080/api';

// // ROLE MODEL
// class _Role {
//   final String label;       // Display label e.g. "Admin"
//   final String apiValue;    // API value e.g. "ADMIN"
//   final IconData icon;
//   final String description;

//   const _Role({
//     required this.label,
//     required this.apiValue,
//     required this.icon,
//     required this.description,
//   });
// }

// const _roles = [
//   _Role(
//     label: 'Admin',
//     apiValue: 'ADMIN',
//     icon: Icons.admin_panel_settings_rounded,
//     description: '',
//   ),
//   _Role(
//     label: 'Doctor',
//     apiValue: 'DOCTOR',
//     icon: Icons.medical_services_rounded,
//     description: '',
//   ),
//   _Role(
//     label: 'Staff',
//     apiValue: 'STAFF',
//     icon: Icons.badge_rounded,
//     description: '',
//   ),
// ];

// //SIGN UP PAGE 
// class AdminSignUpPage extends StatefulWidget {
//   const AdminSignUpPage({super.key});

//   @override
//   State<AdminSignUpPage> createState() => _AdminSignUpPageState();
// }

// class _AdminSignUpPageState extends State<AdminSignUpPage>
//     with SingleTickerProviderStateMixin {
//   // Controllers
//   final _fullNameController = TextEditingController();
//   final _emailController = TextEditingController();
//   final _passwordController = TextEditingController();
//   final _confirmPasswordController = TextEditingController();
//   final _formKey = GlobalKey<FormState>();

//   // State
//   _Role? _selectedRole;
//   bool _obscurePassword = true;
//   bool _obscureConfirm = true;
//   bool _isLoading = false;
//   String? _errorMessage;
//   String? _successMessage;

//   late AnimationController _animController;
//   late Animation<double> _fadeAnim;
//   late Animation<Offset> _slideAnim;

//   @override
//   void initState() {
//     super.initState();
//     _animController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 700),
//     );
//     _fadeAnim = CurvedAnimation(
//         parent: _animController, curve: Curves.easeOut);
//     _slideAnim = Tween<Offset>(
//       begin: const Offset(0, 0.06),
//       end: Offset.zero,
//     ).animate(CurvedAnimation(
//         parent: _animController, curve: Curves.easeOutCubic));
//     _animController.forward();
//   }

//   @override
//   void dispose() {
//     _animController.dispose();
//     _fullNameController.dispose();
//     _emailController.dispose();
//     _passwordController.dispose();
//     _confirmPasswordController.dispose();
//     super.dispose();
//   }

//   // ── API call ────────────────────────────────────────────────────────────

//   Future<void> _handleSignUp() async {
//     if (!_formKey.currentState!.validate()) return;
//     if (_selectedRole == null) {
//       setState(() => _errorMessage = 'Please select a user type to continue.');
//       return;
//     }

//     setState(() {
//       _isLoading = true;
//       _errorMessage = null;
//       _successMessage = null;
//     });

//     try {
//       final response = await http.post(
//         Uri.parse('$_kBaseUrl/auth/register'),
//         headers: {'Content-Type': 'application/json'},
//         body: jsonEncode({
//           'fullName': _fullNameController.text.trim(),
//           'email': _emailController.text.trim(),
//           'password': _passwordController.text,
//           'role': _selectedRole!.apiValue,
//         }),
//       );

//       final body = jsonDecode(response.body) as Map<String, dynamic>;

//       if (response.statusCode == 200 && body['success'] == true) {
//         setState(() => _successMessage =
//             'Account created! Redirecting to your dashboard…');

//         await Future.delayed(const Duration(milliseconds: 1200));

//         if (!mounted) return;
//         _navigateToDashboard(_selectedRole!.apiValue);
//       } else {
//         // 400 / duplicate email / validation error
//         setState(() =>
//             _errorMessage = body['message'] as String? ??
//                 'Something went wrong. Please try again.');
//       }
//     } catch (e) {
//       setState(() =>
//           _errorMessage = 'Unable to connect to the server. Check your network.');
//     } finally {
//       if (mounted) setState(() => _isLoading = false);
//     }
//   }

//   // ── Role-based navigation ───────────────────────────────────────────────

//   void _navigateToDashboard(String role) {
//     Widget destination;
//     switch (role) {
//       case 'DOCTOR':
//         // destination = const DoctorDashboard();
//         destination = const AdminDashboard(); // placeholder until ready
//         break;
//       case 'STAFF':
//         // destination = const StaffDashboard();
//         destination = const AdminDashboard(); // placeholder until ready
//         break;
//       case 'ADMIN':
//       default:
//         destination = const AdminDashboard();
//     }

//     Navigator.pushReplacement(
//       context,
//       PageRouteBuilder(
//         pageBuilder: (_, animation, __) => destination,
//         transitionsBuilder: (_, animation, __, child) => FadeTransition(
//           opacity: animation,
//           child: child,
//         ),
//         transitionDuration: const Duration(milliseconds: 400),
//       ),
//     );
//   }

//   // ─── BUILD ───────────────────────────────────────────────────────────────

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: _kBackground,
//       body: Row(
//         children: [
//           // ── Left panel: decorative ──
//           const _LeftPanel(),

//           // ── Right panel: form ──
//           Expanded(
//             flex: 5,
//             child: FadeTransition(
//               opacity: _fadeAnim,
//               child: SlideTransition(
//                 position: _slideAnim,
//                 child: Center(
//                   child: SingleChildScrollView(
//                     padding: const EdgeInsets.symmetric(
//                         horizontal: 56, vertical: 40),
//                     child: ConstrainedBox(
//                       constraints: const BoxConstraints(maxWidth: 520),
//                       child: _buildForm(),
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildForm() {
//     return Form(
//       key: _formKey,
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Back button
//           InkWell(
//             onTap: () => Navigator.maybePop(context),
//             borderRadius: BorderRadius.circular(8),
//             child: Padding(
//               padding: const EdgeInsets.all(4),
//               child: Row(
//                 mainAxisSize: MainAxisSize.min,
//                 children: const [
//                   Icon(Icons.arrow_back_ios_new_rounded,
//                       size: 14, color: _kTextMid),
//                   SizedBox(width: 6),
//                   Text('Back',
//                       style: TextStyle(
//                           fontSize: 13,
//                           color: _kTextMid,
//                           fontWeight: FontWeight.w500)),
//                 ],
//               ),
//             ),
//           ),
//           const SizedBox(height: 28),

//           // Heading
//           const Text(
//             'Create Account',
//             style: TextStyle(
//               fontSize: 36,
//               fontWeight: FontWeight.w900,
//               color: _kTeal,
//               height: 1.1,
//               letterSpacing: -0.5,
//             ),
//           ),
//           const SizedBox(height: 6),
//           const Text(
//             'Join Heathos HMS — fill in your details below.',
//             style: TextStyle(
//                 fontSize: 14, color: _kTextMid, fontWeight: FontWeight.w400),
//           ),
//           const SizedBox(height: 32),

//           // ── Role selector ──
//           const _FieldLabel(text: 'User Type'),
//           const SizedBox(height: 10),
//           _RoleSelector(
//             selectedRole: _selectedRole,
//             onSelected: (r) =>
//                 setState(() {
//                   _selectedRole = r;
//                   _errorMessage = null;
//                 }),
//           ),
//           const SizedBox(height: 24),

//           // ── Full Name ──
//           const _FieldLabel(text: 'Full Name'),
//           const SizedBox(height: 8),
//           _InputField(
//             controller: _fullNameController,
//             hint: 'e.g. Dr. Kwame Asante',
//             prefixIcon: Icons.person_outline_rounded,
//             validator: (v) {
//               if (v == null || v.trim().isEmpty) return 'Full name is required';
//               if (v.trim().length < 3) return 'Name must be at least 3 characters';
//               return null;
//             },
//           ),
//           const SizedBox(height: 20),

//           // ── Email ──
//           const _FieldLabel(text: 'Institutional Email'),
//           const SizedBox(height: 8),
//           _InputField(
//             controller: _emailController,
//             hint: 'e.g. kwame@hospital.com',
//             prefixIcon: Icons.email_outlined,
//             keyboardType: TextInputType.emailAddress,
//             validator: (v) {
//               if (v == null || v.trim().isEmpty) return 'Email is required';
//               final emailReg = RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,}$');
//               if (!emailReg.hasMatch(v.trim())) return 'Enter a valid email';
//               return null;
//             },
//           ),
//           const SizedBox(height: 20),

//           // ── Password ──
//           const _FieldLabel(text: 'Create Password'),
//           const SizedBox(height: 8),
//           _InputField(
//             controller: _passwordController,
//             hint: 'Minimum 8 characters',
//             prefixIcon: Icons.lock_outline_rounded,
//             obscureText: _obscurePassword,
//             suffixIcon: _obscurePassword
//                 ? Icons.visibility_off_outlined
//                 : Icons.visibility_outlined,
//             onSuffixTap: () =>
//                 setState(() => _obscurePassword = !_obscurePassword),
//             validator: (v) {
//               if (v == null || v.isEmpty) return 'Password is required';
//               if (v.length < 8) return 'Password must be at least 8 characters';
//               return null;
//             },
//           ),
//           const SizedBox(height: 20),

//           // ── Confirm Password ──
//           const _FieldLabel(text: 'Confirm Password'),
//           const SizedBox(height: 8),
//           _InputField(
//             controller: _confirmPasswordController,
//             hint: 'Re-enter your password',
//             prefixIcon: Icons.lock_outline_rounded,
//             obscureText: _obscureConfirm,
//             suffixIcon: _obscureConfirm
//                 ? Icons.visibility_off_outlined
//                 : Icons.visibility_outlined,
//             onSuffixTap: () =>
//                 setState(() => _obscureConfirm = !_obscureConfirm),
//             validator: (v) {
//               if (v == null || v.isEmpty) return 'Please confirm your password';
//               if (v != _passwordController.text) return 'Passwords do not match';
//               return null;
//             },
//           ),
//           const SizedBox(height: 28),

//           // ── Error / Success messages ──
//           if (_errorMessage != null) ...[
//             _MessageBanner(
//                 message: _errorMessage!, isError: true),
//             const SizedBox(height: 16),
//           ],
//           if (_successMessage != null) ...[
//             _MessageBanner(
//                 message: _successMessage!, isError: false),
//             const SizedBox(height: 16),
//           ],

//           // ── Sign Up button ──
//           SizedBox(
//             width: double.infinity,
//             height: 52,
//             child: ElevatedButton(
//               onPressed: _isLoading ? null : _handleSignUp,
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: _kTeal,
//                 disabledBackgroundColor: _kTeal.withOpacity(0.6),
//                 elevation: 0,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//               ),
//               child: _isLoading
//                   ? const SizedBox(
//                       width: 22,
//                       height: 22,
//                       child: CircularProgressIndicator(
//                         strokeWidth: 2.5,
//                         valueColor:
//                             AlwaysStoppedAnimation<Color>(_kWhite),
//                       ),
//                     )
//                   : const Text(
//                       'Create Account',
//                       style: TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.w700,
//                         color: _kWhite,
//                         letterSpacing: 0.3,
//                       ),
//                     ),
//             ),
//           ),
//           const SizedBox(height: 20),

//           // ── Already have account ──
//           Center(
//             child: GestureDetector(
//               onTap: () => Navigator.pushReplacementNamed(context, '/login'),
//               child: RichText(
//                 text: const TextSpan(
//                   style: TextStyle(
//                       fontSize: 13,
//                       color: _kTextMid,
//                       fontWeight: FontWeight.w400),
//                   children: [
//                     TextSpan(text: 'Already have an account? '),
//                     TextSpan(
//                       text: 'Sign In',
//                       style: TextStyle(
//                         color: _kTeal,
//                         fontWeight: FontWeight.w700,
//                         decoration: TextDecoration.underline,
//                         decorationColor: _kTeal,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// // ─── LEFT DECORATIVE PANEL ──────────────────────────────────────────────────

// class _LeftPanel extends StatelessWidget {
//   const _LeftPanel();

//   @override
//   Widget build(BuildContext context) {
//     return Expanded(
//       flex: 4,
//       child: Container(
//         height: double.infinity,
//         decoration: const BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//             colors: [_kTealDark, _kTeal, _kTealLight],
//             stops: [0.0, 0.55, 1.0],
//           ),
//         ),
//         child: Stack(
//           children: [
//             // Decorative circles
//             Positioned(
//               top: -60,
//               left: -60,
//               child: _DecorCircle(size: 220,
//                   color: _kWhite.withOpacity(0.05)),
//             ),
//             Positioned(
//               bottom: -80,
//               right: -80,
//               child: _DecorCircle(size: 300,
//                   color: _kWhite.withOpacity(0.06)),
//             ),
//             Positioned(
//               top: 180,
//               right: -40,
//               child: _DecorCircle(size: 140,
//                   color: _kWhite.withOpacity(0.07)),
//             ),

//             // Content
//             Padding(
//               padding: const EdgeInsets.symmetric(
//                   horizontal: 40, vertical: 60),
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // Logo
//                   Row(
//                     children: [
//                       Container(
//                         width: 42,
//                         height: 42,
//                         decoration: BoxDecoration(
//                           color: _kWhite,
//                           borderRadius: BorderRadius.circular(10),
//                         ),
//                         child: const Center(
//                           child: Text(
//                             'H',
//                             style: TextStyle(
//                               color: _kTeal,
//                               fontWeight: FontWeight.w900,
//                               fontSize: 24,
//                             ),
//                           ),
//                         ),
//                       ),
//                       const SizedBox(width: 12),
//                       const Text(
//                         'Heathos',
//                         style: TextStyle(
//                           color: _kWhite,
//                           fontSize: 26,
//                           fontWeight: FontWeight.w800,
//                           letterSpacing: 0.3,
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 60),

//                   const Text(
//                     'Smarter\nHospital\nManagement.',
//                     style: TextStyle(
//                       color: _kWhite,
//                       fontSize: 38,
//                       fontWeight: FontWeight.w900,
//                       height: 1.15,
//                       letterSpacing: -0.5,
//                     ),
//                   ),
//                   const SizedBox(height: 20),
//                   Text(
//                     'Seamless workflows for every\nrole — from admin to clinical.',
//                     style: TextStyle(
//                       color: _kWhite.withOpacity(0.80),
//                       fontSize: 15,
//                       height: 1.6,
//                       fontWeight: FontWeight.w400,
//                     ),
//                   ),
//                   const SizedBox(height: 56),

//                   // Feature pills
//                   ...[
//                     'Role-based access control',
//                     'Real-time patient records',
//                     'Integrated billing & pharmacy',
//                   ].map(
//                     (f) => Padding(
//                       padding: const EdgeInsets.only(bottom: 12),
//                       child: Row(
//                         children: [
//                           Container(
//                             width: 22,
//                             height: 22,
//                             decoration: BoxDecoration(
//                               color: _kWhite.withOpacity(0.20),
//                               shape: BoxShape.circle,
//                             ),
//                             child: const Icon(Icons.check_rounded,
//                                 color: _kWhite, size: 13),
//                           ),
//                           const SizedBox(width: 12),
//                           Text(
//                             f,
//                             style: TextStyle(
//                               color: _kWhite.withOpacity(0.90),
//                               fontSize: 13,
//                               fontWeight: FontWeight.w500,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class _DecorCircle extends StatelessWidget {
//   final double size;
//   final Color color;
//   const _DecorCircle({required this.size, required this.color});

//   @override
//   Widget build(BuildContext context) => Container(
//         width: size,
//         height: size,
//         decoration: BoxDecoration(color: color, shape: BoxShape.circle),
//       );
// }

// // ─── ROLE SELECTOR ───────────────────────────────────────────────────────────

// class _RoleSelector extends StatelessWidget {
//   final _Role? selectedRole;
//   final ValueChanged<_Role> onSelected;

//   const _RoleSelector(
//       {required this.selectedRole, required this.onSelected});

//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       children: _roles.map((role) {
//         final isSelected = selectedRole?.apiValue == role.apiValue;
//         return Expanded(
//           child: Padding(
//             padding: EdgeInsets.only(
//                 right: role == _roles.last ? 0 : 12),
//             child: GestureDetector(
//               onTap: () => onSelected(role),
//               child: AnimatedContainer(
//                 duration: const Duration(milliseconds: 180),
//                 padding: const EdgeInsets.symmetric(
//                     vertical: 14, horizontal: 10),
//                 decoration: BoxDecoration(
//                   color: isSelected ? _kTeal : _kWhite,
//                   borderRadius: BorderRadius.circular(12),
//                   border: Border.all(
//                     color: isSelected ? _kTeal : const Color(0xFFD0E4E1),
//                     width: isSelected ? 2 : 1.5,
//                   ),
//                   boxShadow: isSelected
//                       ? [
//                           BoxShadow(
//                             color: _kTeal.withOpacity(0.25),
//                             blurRadius: 10,
//                             offset: const Offset(0, 4),
//                           )
//                         ]
//                       : [],
//                 ),
//                 child: Column(
//                   children: [
//                     Icon(
//                       role.icon,
//                       color: isSelected ? _kWhite : _kTextMid,
//                       size: 26,
//                     ),
//                     const SizedBox(height: 8),
//                     Text(
//                       role.label,
//                       style: TextStyle(
//                         fontSize: 13,
//                         fontWeight: FontWeight.w700,
//                         color: isSelected ? _kWhite : _kTextDark,
//                       ),
//                     ),
//                     const SizedBox(height: 2),
//                     Text(
//                       role.description,
//                       textAlign: TextAlign.center,
//                       style: TextStyle(
//                         fontSize: 10,
//                         color: isSelected
//                             ? _kWhite.withOpacity(0.80)
//                             : _kTextLight,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         );
//       }).toList(),
//     );
//   }
// }

// // ─── REUSABLE WIDGETS ────────────────────────────────────────────────────────

// class _FieldLabel extends StatelessWidget {
//   final String text;
//   const _FieldLabel({required this.text});

//   @override
//   Widget build(BuildContext context) {
//     return Text(
//       text,
//       style: const TextStyle(
//         fontSize: 13,
//         fontWeight: FontWeight.w700,
//         color: _kTextDark,
//         letterSpacing: 0.1,
//       ),
//     );
//   }
// }

// class _InputField extends StatelessWidget {
//   final TextEditingController controller;
//   final String hint;
//   final IconData prefixIcon;
//   final bool obscureText;
//   final IconData? suffixIcon;
//   final VoidCallback? onSuffixTap;
//   final TextInputType? keyboardType;
//   final String? Function(String?)? validator;

//   const _InputField({
//     required this.controller,
//     required this.hint,
//     required this.prefixIcon,
//     this.obscureText = false,
//     this.suffixIcon,
//     this.onSuffixTap,
//     this.keyboardType,
//     this.validator,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return TextFormField(
//       controller: controller,
//       obscureText: obscureText,
//       keyboardType: keyboardType,
//       validator: validator,
//       style: const TextStyle(
//           fontSize: 14, color: _kTextDark, fontWeight: FontWeight.w500),
//       decoration: InputDecoration(
//         hintText: hint,
//         hintStyle:
//             const TextStyle(color: _kTextLight, fontSize: 13),
//         prefixIcon:
//             Icon(prefixIcon, size: 18, color: _kTextMid),
//         suffixIcon: suffixIcon != null
//             ? GestureDetector(
//                 onTap: onSuffixTap,
//                 child: Icon(suffixIcon, size: 18, color: _kTextMid),
//               )
//             : null,
//         filled: true,
//         fillColor: _kWhite,
//         contentPadding:
//             const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
//         enabledBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(10),
//           borderSide:
//               const BorderSide(color: Color(0xFFD0E4E1), width: 1.5),
//         ),
//         focusedBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(10),
//           borderSide: const BorderSide(color: _kTeal, width: 2),
//         ),
//         errorBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(10),
//           borderSide: const BorderSide(color: _kError, width: 1.5),
//         ),
//         focusedErrorBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(10),
//           borderSide: const BorderSide(color: _kError, width: 2),
//         ),
//         errorStyle:
//             const TextStyle(color: _kError, fontSize: 11),
//       ),
//     );
//   }
// }

// class _MessageBanner extends StatelessWidget {
//   final String message;
//   final bool isError;
//   const _MessageBanner(
//       {required this.message, required this.isError});

//   @override
//   Widget build(BuildContext context) {
//     final color = isError ? _kError : _kTeal;
//     return Container(
//       padding:
//           const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//       decoration: BoxDecoration(
//         color: color.withOpacity(0.08),
//         borderRadius: BorderRadius.circular(10),
//         border: Border.all(color: color.withOpacity(0.30), width: 1),
//       ),
//       child: Row(
//         children: [
//           Icon(
//             isError
//                 ? Icons.error_outline_rounded
//                 : Icons.check_circle_outline_rounded,
//             color: color,
//             size: 18,
//           ),
//           const SizedBox(width: 10),
//           Expanded(
//             child: Text(
//               message,
//               style: TextStyle(
//                 fontSize: 13,
//                 color: color,
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }




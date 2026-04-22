import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';

import 'constants/api_constants.dart';
// Import your actual page files
import 'admin_login_page.dart';
import 'patient_dashboard.dart' hide TopBar;
import 'appointment_page.dart';

// ─── CONSTANTS ───────────────────────────────────────────────────────────────
const kTeal = Color(0xFF0D7B6B);
const kTealLight = Color(0xFF1A9E8A);
const kTealDark = Color(0xFF095F54);
const kTealAccent = Color(0xFF4FC3B0);
const kBackground = Color(0xFFF0F4F4);
const kWhite = Color(0xFFFFFFFF);
const kTextDark = Color(0xFF1A2E2C);
const kTextGrey = Color(0xFF7A9490);
const kCardBg = Color(0xFFF5F8F8);
const kBorder = Color(0xFF000000);
const kBlack = Color(0xFF000000);

const String _baseUrl = 'https://heathos-api.onrender.com';

// ─── MAIN PAGE ───────────────────────────────────────────────────────────────
class PatientRegistrationPage extends StatefulWidget {
  const PatientRegistrationPage({super.key});

  @override
  State<PatientRegistrationPage> createState() =>
      _PatientRegistrationPageState();
}

class _PatientRegistrationPageState extends State<PatientRegistrationPage> {
  Uint8List? _profileImageBytes;
  Uint8List? _topBarProfileImageBytes;
  String? _profileImageError;

  bool _isLoading = false;

  // Controllers
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _dobController = TextEditingController();
  final _genderController = TextEditingController();
  final _addressController = TextEditingController();
  final _emergencyContactController = TextEditingController();
  final _insuranceProviderController = TextEditingController();
  final _insuranceNumberController = TextEditingController();
  String? _selectedBloodGroup;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _dobController.dispose();
    _genderController.dispose();
    _addressController.dispose();
    _emergencyContactController.dispose();
    _insuranceProviderController.dispose();
    _insuranceNumberController.dispose();
    super.dispose();
  }

  void _logout() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const AdminLoginPage()),
      (route) => false,
    );
  }

  void _goBack() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const PatientListPage()),
    );
  }

  void _proceedWithAppointment() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AppointmentPage()),
    );
  }

  Future<void> _uploadProfilePhoto() async {
    final result = await FilePicker.pickFiles(
      type: FileType.image,
      withData: true,
    );

    if (result != null && result.files.first.bytes != null) {
      setState(() {
        _profileImageBytes = result.files.first.bytes;
        _profileImageError = null;
      });
    }
  }

  void _deleteProfilePhoto() {
    setState(() {
      _profileImageBytes = null;
    });
  }

  // ✅ FULL API INTEGRATION
  Future<void> _savePatient() async {
    if (_fullNameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _phoneController.text.isEmpty) {
      _showError('Full name, email and phone are required.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await http
          .post(
            Uri.parse('$_baseUrl/api/patients'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              "fullName": _fullNameController.text.trim(),
              "email": _emailController.text.trim(),
              "phone": _phoneController.text.trim(),
              "bloodGroup": _selectedBloodGroup ?? '',
              "dob": _dobController.text.trim(),
              "gender": _genderController.text.trim(),
              "address": _addressController.text.trim(),
              "emergencyContact": _emergencyContactController.text.trim(),
              "insuranceProvider": _insuranceProviderController.text.trim(),
              "insuranceNumber": _insuranceNumberController.text.trim(),
            }),
          )
          .timeout(const Duration(seconds: 20));

      final body = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        _showSuccess('Patient saved successfully');
        _goBack();
      } else {
        _showError(body['message'] ?? 'Failed to save patient');
      }
    } catch (e) {
      _showError(e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));
  }

  void _showSuccess(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Patient saved successfully'),
        backgroundColor: kTeal,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      body: Column(
        children: [
          TopBar(
            profileImageBytes: _topBarProfileImageBytes,
            onProfileImageChanged: (img) =>
                setState(() => _topBarProfileImageBytes = img),
            onLogout: _logout,
            onGoToProfile: () {},
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: _goBack,
                        icon: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: kTeal,
                          size: 20,
                        ),
                        tooltip: 'Back to Patient Dashboard',
                        style: IconButton.styleFrom(
                          backgroundColor: kWhite,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: BorderSide(color: kTeal.withOpacity(0.25)),
                          ),
                          padding: const EdgeInsets.all(10),
                        ),
                      ),
                      const SizedBox(width: 14),
                      const Text(
                        'Add Patient Form',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: kTeal,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // PROFILE IMAGE
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: kTeal.withOpacity(0.2),
                        backgroundImage: _profileImageBytes != null
                            ? MemoryImage(_profileImageBytes!)
                            : null,
                        child: _profileImageBytes == null
                            ? const Icon(Icons.person, color: kTeal)
                            : null,
                      ),
                      const SizedBox(width: 20),
                      ElevatedButton(
                        onPressed: _uploadProfilePhoto,
                        child: const Text("Upload Image"),
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  // FORM
                  Wrap(
                    spacing: 20,
                    runSpacing: 20,
                    children: [
                      _field("Full Name", _fullNameController),
                      _field("Email", _emailController),
                      _field("Phone", _phoneController),
                      _bloodGroupDropdown(),
                      _field("Date of Birth (YYYY-MM-DD)", _dobController),
                      _field("Gender", _genderController),
                      _field("Address", _addressController),
                      _field("Emergency Contact", _emergencyContactController),
                      _field(
                        "Insurance Provider (optional)",
                        _insuranceProviderController,
                      ),
                      _field(
                        "Insurance Number (optional)",
                        _insuranceNumberController,
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: _isLoading ? null : _savePatient,
                        child: _isLoading
                            ? const CircularProgressIndicator()
                            : const Text("Save", selectionColor: Colors.teal),
                      ),
                      const SizedBox(width: 20),
                      TextButton(
                        onPressed: _proceedWithAppointment,
                        child: const Text(
                          "Schedule Appointment",
                          selectionColor: Colors.teal,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          //const Footer()
        ],
      ),
    );
  }

  Widget _field(String label, TextEditingController c) {
    return SizedBox(
      width: 250,
      child: TextField(
        controller: c,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _bloodGroupDropdown() {
    const groups = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];
    return SizedBox(
      width: 250,
      child: DropdownButtonFormField<String>(
        value: _selectedBloodGroup,
        decoration: const InputDecoration(
          labelText: 'Blood Group',
          border: OutlineInputBorder(),
        ),
        items: groups
            .map((g) => DropdownMenuItem(value: g, child: Text(g)))
            .toList(),
        onChanged: (val) => setState(() => _selectedBloodGroup = val),
      ),
    );
  }
}

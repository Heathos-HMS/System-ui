// import 'dart:async';
// import 'dart:html' as html;
// import 'dart:convert';
// import 'dart:typed_data';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:intl/intl.dart';
// import 'package:file_picker/file_picker.dart';

// import 'constants/api_constants.dart';
// // Import your actual page files
// import 'admin_login_page.dart';
// import 'patient_dashboard.dart' hide TopBar;
// import 'appointment_page.dart';

// // ─── CONSTANTS ───────────────────────────────────────────────────────────────
// const kTeal = Color(0xFF0D7B6B);
// const kTealLight = Color(0xFF1A9E8A);
// const kTealDark = Color(0xFF095F54);
// const kTealAccent = Color(0xFF4FC3B0);
// const kBackground = Color(0xFFF0F4F4);
// const kWhite = Color(0xFFFFFFFF);
// const kTextDark = Color(0xFF1A2E2C);
// const kTextGrey = Color(0xFF7A9490);
// const kCardBg = Color(0xFFF5F8F8);
// const kSuccess = Color(0xFF4CAF50);
// const kWarning = Color(0xFFFF9800);
// const kError = Color(0xFFF44336);
// const kBorder = Color(0xFFE0E0E0);
// const kBlack = Color(0xFF000000);

// const String _BaseUrl = 'https://heathos-api.onrender.com';

// // ─── MAIN PAGE ───────────────────────────────────────────────────────────────
// class PatientRegistrationPage extends StatefulWidget {
//   const PatientRegistrationPage({super.key});

//   @override
//   State<PatientRegistrationPage> createState() =>
//       _PatientRegistrationPageState();
// }

// class _PatientRegistrationPageState extends State<PatientRegistrationPage> {
//   Uint8List? _profileImageBytes;
//   Uint8List? _topBarProfileImageBytes;
//   String? _profileImageError;

//   bool _isLoading = false;

//   // Controllers
//   final _fullNameController = TextEditingController();
//   final _emailController = TextEditingController();
//   final _phoneController = TextEditingController();
//   final _dobController = TextEditingController();
//   final _addressController = TextEditingController();
//   final _emergencyContactController = TextEditingController();
//   final _insuranceProviderController = TextEditingController();
//   final _insuranceNumberController = TextEditingController();

//   // CHANGE 1: Gender dropdown + DOB date
//   String? _selectedGender;
//   String? _selectedBloodGroup;
//   DateTime? _selectedDob;

//   @override
//   void dispose() {
//     _fullNameController.dispose();
//     _emailController.dispose();
//     _phoneController.dispose();
//     _dobController.dispose();
//     _addressController.dispose();
//     _emergencyContactController.dispose();
//     _insuranceProviderController.dispose();
//     _insuranceNumberController.dispose();
//     super.dispose();
//   }

//   void _logout() {
//     Navigator.pushAndRemoveUntil(
//       context,
//       MaterialPageRoute(builder: (_) => const AdminLoginPage()),
//       (route) => false,
//     );
//   }

//   void _goBack() {
//     Navigator.pushReplacement(
//       context,
//       MaterialPageRoute(builder: (_) => const PatientListPage()),
//     );
//   }

//   void _proceedWithAppointment() {
//     Navigator.push(
//       context,
//       MaterialPageRoute(builder: (_) => AppointmentPage()),
//     );
//   }

//   Future<void> _uploadProfilePhoto() async {
//     final result = await FilePicker.pickFiles(
//       type: FileType.image,
//       withData: true,
//     );

//     if (result != null && result.files.first.bytes != null) {
//       setState(() {
//         _profileImageBytes = result.files.first.bytes;
//         _profileImageError = null;
//       });
//     }
//   }

//   void _deleteProfilePhoto() {
//     setState(() {
//       _profileImageBytes = null;
//     });
//   }

//   // CHANGE 2: DOB calendar picker
//   Future<void> _pickDateOfBirth() async {
//     final DateTime? picked = await showDatePicker(
//       context: context,
//       initialDate: _selectedDob ?? DateTime(2000),
//       firstDate: DateTime(1900),
//       lastDate: DateTime.now(),
//       builder: (context, child) {
//         return Theme(
//           data: Theme.of(context).copyWith(
//             colorScheme: const ColorScheme.light(
//               primary: kTeal,
//               onPrimary: kWhite,
//               onSurface: kTextDark,
//             ),
//           ),
//           child: child!,
//         );
//       },
//     );
//     if (picked != null) {
//       setState(() {
//         _selectedDob = picked;
//         _dobController.text = DateFormat('yyyy-MM-dd').format(picked);
//       });
//     }
//   }

//   // ✅ FULL API INTEGRATION - Save to backend + return true to refresh list
//   Future<void> _savePatient() async {
//     if (_fullNameController.text.isEmpty ||
//         _emailController.text.isEmpty ||
//         _phoneController.text.isEmpty) {
//       _showError('Full name, email and phone are required.');
//       return;
//     }

//     setState(() => _isLoading = true);

//     try {
//       // ✅ Get token first
//       final token = html.window.localStorage['token'] ?? '';
//       if (token.isEmpty) {
//         _showError('No token found. Please log in again.');
//         return;
//       }

//       final response = await http
//           .post(
//             Uri.parse('$_BaseUrl/api/patients'),
//             headers: {
//               'Content-Type': 'application/json',
//               'Authorization': 'Bearer $token', // ✅ Added
//             },
//             body: jsonEncode({
//               "fullName": _fullNameController.text.trim(),
//               "email": _emailController.text.trim(),
//               "phone": _phoneController.text.trim(),
//               "bloodGroup": _selectedBloodGroup ?? '',
//               "dob": _dobController.text.trim(),
//               "gender": _selectedGender ?? '',
//               "address": _addressController.text.trim(),
//               "emergencyContact": _emergencyContactController.text.trim(),
//               "insuranceProvider": _insuranceProviderController.text.trim(),
//               "insuranceNumber": _insuranceNumberController.text.trim(),
//             }),
//           )
//           .timeout(const Duration(seconds: 20));

//       // ✅ Guard against empty response
//       if (!mounted) return;
//       if (response.body.isEmpty) {
//         _showError('Server returned empty response. Check backend logs.');
//         return;
//       }

//       final body = jsonDecode(response.body);

//       if (response.statusCode == 200 || response.statusCode == 201) {
//         _showSuccess('Patient saved successfully');
//         Navigator.pop(context, true);
//       } else {
//         _showError(body['message'] ?? 'Failed to save patient');
//       }

//     } catch (e) {
//       if (e is TimeoutException) {
//         _showError('Request timed out. Please try again.');
//       } else if (e is FormatException) {
//         _showError('Invalid response from server.');
//       } else {
//         _showError(e.toString());
//       }
//     } finally {
//       if (mounted) setState(() => _isLoading = false); // ✅ mounted guard
//     }
//   }

//   void _showError(String msg) {
//     ScaffoldMessenger.of(
//       context,
//     ).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));
//   }

//   void _showSuccess(String msg) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(
//         content: Text('Patient saved successfully'),
//         backgroundColor: kTeal,
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: kBackground,
//       body: Column(
//         children: [
//           TopBar(
//             profileImageBytes: _topBarProfileImageBytes,
//             onProfileImageChanged: (img) =>
//                 setState(() => _topBarProfileImageBytes = img),
//             onLogout: _logout,
//             onGoToProfile: () {},
//           ),
//           Expanded(
//             child: SingleChildScrollView(
//               padding: const EdgeInsets.all(28),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Row(
//                     children: [
//                       IconButton(
//                         onPressed: _goBack,
//                         icon: const Icon(
//                           Icons.arrow_back_ios_new_rounded,
//                           color: kTeal,
//                           size: 20,
//                         ),
//                         tooltip: 'Back to Patient Dashboard',
//                         style: IconButton.styleFrom(
//                           backgroundColor: kWhite,
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(10),
//                             side: BorderSide(color: kTeal.withOpacity(0.25)),
//                           ),
//                           padding: const EdgeInsets.all(10),
//                         ),
//                       ),
//                       const SizedBox(width: 14),
//                       const Text(
//                         'Add Patient Form',
//                         style: TextStyle(
//                           fontSize: 28,
//                           fontWeight: FontWeight.bold,
//                           color: kTeal,
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 20),

//                   // PROFILE IMAGE
//                   Row(
//                     children: [
//                       CircleAvatar(
//                         radius: 40,
//                         backgroundColor: kTeal.withOpacity(0.2),
//                         backgroundImage: _profileImageBytes != null
//                             ? MemoryImage(_profileImageBytes!)
//                             : null,
//                         child: _profileImageBytes == null
//                             ? const Icon(Icons.person, color: kTeal)
//                             : null,
//                       ),
//                       const SizedBox(width: 20),
//                       // CHANGE 3: Teal button
//                       ElevatedButton(
//                         onPressed: _uploadProfilePhoto,
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: kTeal,
//                           foregroundColor: kWhite,
//                           padding: const EdgeInsets.symmetric(
//                             horizontal: 20,
//                             vertical: 12,
//                           ),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(8),
//                           ),
//                         ),
//                         child: const Text("Upload Image"),
//                       ),
//                     ],
//                   ),

//                   const SizedBox(height: 30),

//                   // FORM
//                   Wrap(
//                     spacing: 20,
//                     runSpacing: 20,
//                     children: [
//                       _field("Full Name", _fullNameController),
//                       _field("Email", _emailController),
//                       _field("Phone", _phoneController),
//                       _bloodGroupDropdown(),
//                       _dobField(), // CHANGED: Calendar picker
//                       _genderDropdown(), // CHANGED: Dropdown
//                       _field("Address", _addressController),
//                       _field("Emergency Contact", _emergencyContactController),
//                       _field(
//                         "Insurance Provider (optional)",
//                         _insuranceProviderController,
//                       ),
//                       _field(
//                         "Insurance Number (optional)",
//                         _insuranceNumberController,
//                       ),
//                     ],
//                   ),

//                   const SizedBox(height: 30),

//                   Row(
//                     children: [
//                       // CHANGE 4: Teal Save button
//                       ElevatedButton(
//                         onPressed: _isLoading ? null : _savePatient,
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: kTeal,
//                           foregroundColor: kWhite,
//                           padding: const EdgeInsets.symmetric(
//                             horizontal: 32,
//                             vertical: 14,
//                           ),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(8),
//                           ),
//                         ),
//                         child: _isLoading
//                             ? const SizedBox(
//                                 width: 20,
//                                 height: 20,
//                                 child: CircularProgressIndicator(
//                                   strokeWidth: 2,
//                                   color: kWhite,
//                                 ),
//                               )
//                             : const Text(
//                                 "Save",
//                                 style: TextStyle(fontWeight: FontWeight.w600),
//                               ),
//                       ),
//                       const SizedBox(width: 20),
//                       // CHANGE 5: Teal Schedule button
//                       TextButton(
//                         onPressed: _proceedWithAppointment,
//                         style: TextButton.styleFrom(
//                           foregroundColor: kTeal,
//                           padding: const EdgeInsets.symmetric(
//                             horizontal: 20,
//                             vertical: 14,
//                           ),
//                         ),
//                         child: const Text(
//                           "Schedule Appointment",
//                           style: TextStyle(fontWeight: FontWeight.w600),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ),
//           //const Footer()
//         ],
//       ),
//     );
//   }

//   Widget _field(String label, TextEditingController c) {
//     return SizedBox(
//       width: 250,
//       child: TextField(
//         controller: c,
//         decoration: InputDecoration(
//           labelText: label,
//           border: OutlineInputBorder(),
//         ),
//       ),
//     );
//   }

//   // CHANGE 6: DOB with calendar picker
//   Widget _dobField() {
//     return SizedBox(
//       width: 250,
//       child: TextFormField(
//         controller: _dobController,
//         readOnly: true,
//         onTap: _pickDateOfBirth,
//         decoration: InputDecoration(
//           labelText: 'Date of Birth',
//           hintText: 'YYYY-MM-DD',
//           border: const OutlineInputBorder(),
//           suffixIcon: const Icon(Icons.calendar_today, color: kTeal),
//         ),
//       ),
//     );
//   }

//   // CHANGE 7: Gender dropdown
//   Widget _genderDropdown() {
//     return SizedBox(
//       width: 250,
//       child: DropdownButtonFormField<String>(
//         value: _selectedGender,
//         decoration: const InputDecoration(
//           labelText: 'Gender',
//           border: OutlineInputBorder(),
//         ),
//         items: const [
//           DropdownMenuItem(value: 'Male', child: Text('Male')),
//           DropdownMenuItem(value: 'Female', child: Text('Female')),
//         ],
//         onChanged: (val) => setState(() => _selectedGender = val),
//       ),
//     );
//   }

//   Widget _bloodGroupDropdown() {
//     const groups = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];
//     return SizedBox(
//       width: 250,
//       child: DropdownButtonFormField<String>(
//         value: _selectedBloodGroup,
//         decoration: const InputDecoration(
//           labelText: 'Blood Group',
//           border: OutlineInputBorder(),
//         ),
//         items: groups
//             .map((g) => DropdownMenuItem(value: g, child: Text(g)))
//             .toList(),
//         onChanged: (val) => setState(() => _selectedBloodGroup = val),
//       ),
//     );
//   }
// }

// // TopBar and Footer - reuse from previous code
// class TopBar extends StatefulWidget {
//   final Uint8List? profileImageBytes;
//   final ValueChanged<Uint8List> onProfileImageChanged;
//   final VoidCallback onLogout;
//   final VoidCallback onGoToProfile;

//   const TopBar({
//     super.key,
//     required this.profileImageBytes,
//     required this.onProfileImageChanged,
//     required this.onLogout,
//     required this.onGoToProfile,
//   });

//   @override
//   State<TopBar> createState() => _TopBarState();
// }

// class _TopBarState extends State<TopBar> {
//   final _searchController = TextEditingController();
//   final LayerLink _layerLink = LayerLink();
//   OverlayEntry? _overlayEntry;
//   Timer? _hideTimer;
//   bool _isHoveringBadge = false;
//   bool _isHoveringMenu = false;
//   List<SearchResult> _searchResults = [];
//   bool _isSearching = false;
//   Timer? _debounce;

//   @override
//   void dispose() {
//     _searchController.dispose();
//     _hideTimer?.cancel();
//     _debounce?.cancel();
//     _removeOverlay();
//     super.dispose();
//   }

//   void _onSearchChanged(String query) {
//     _debounce?.cancel();
//     if (query.trim().isEmpty) {
//       setState(() {
//         _searchResults = [];
//         _isSearching = false;
//       });
//       return;
//     }
//     _debounce = Timer(
//       const Duration(milliseconds: 400),
//       () => _runSearch(query.trim()),
//     );
//   }

//   // DO NOT TOUCH - User specified block
//   Future<void> _runSearch(String query) async {
//     setState(() => _isSearching = true);

//     final endpoints = {
//       'Doctor': '$_BaseUrl/doctors/search?q=$query',
//       'Patient': '$_BaseUrl/patients/search?q=$query',
//       'Nurse': '$_BaseUrl/nurses/search?q=$query',
//       'Staff': '$_BaseUrl/staff/search?q=$query',
//     };

//     final results = <SearchResult>[];
//     final errors = <String>[]; // Track failed endpoints

//     await Future.wait(
//       endpoints.entries.map((entry) async {
//         try {
//           final response = await http
//               .get(Uri.parse(entry.value))
//               .timeout(const Duration(seconds: 30));

//           if (response.statusCode == 200) {
//             final body = jsonDecode(response.body);
//             final List<dynamic> items = body is List
//                 ? body
//                 : (body['data'] as List? ?? []);
//             for (final item in items) {
//               results.add(
//                 SearchResult(
//                   name:
//                       item['fullName'] as String? ??
//                       item['name'] as String? ??
//                       'Unknown',
//                   category: entry.key,
//                   subtitle:
//                       item['email'] as String? ?? item['id'] as String? ?? '',
//                 ),
//               );
//             }
//           } else {
//             // Non-200 response
//             errors.add('${entry.key}: HTTP ${response.statusCode}');
//             debugPrint(
//               'Search failed for ${entry.key}: ${response.statusCode} ${response.body}',
//             );
//           }
//         } on TimeoutException {
//           errors.add('${entry.key}: Request timed out');
//           debugPrint('Search timeout for ${entry.key}');
//         } on FormatException catch (e) {
//           errors.add('${entry.key}: Invalid JSON');
//           debugPrint('Search JSON error for ${entry.key}: $e');
//         } catch (e) {
//           errors.add('${entry.key}: $e');
//           debugPrint('Search error for ${entry.key}: $e');
//         }
//       }),
//     );

//     if (mounted) {
//       setState(() {
//         _searchResults = results;
//         _isSearching = false;
//       });

//       // Show error snackbar if any endpoint failed
//       if (errors.isNotEmpty && context.mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Search errors: ${errors.join(', ')}'),
//             backgroundColor: Colors.orange.shade700,
//             duration: const Duration(seconds: 4),
//           ),
//         );
//       }
//     }
//   }

//   void _showAdminMenu() {
//     _hideTimer?.cancel();
//     if (_overlayEntry != null) return;
//     _overlayEntry = OverlayEntry(
//       builder: (_) => Positioned(
//         width: 150,
//         child: CompositedTransformFollower(
//           link: _layerLink,
//           showWhenUnlinked: false,
//           offset: const Offset(-40, 38),
//           child: MouseRegion(
//             onEnter: (_) {
//               _isHoveringMenu = true;
//               _hideTimer?.cancel();
//             },
//             onExit: (_) {
//               _isHoveringMenu = false;
//               _scheduleHide();
//             },
//             child: Material(
//               elevation: 8,
//               borderRadius: BorderRadius.circular(10),
//               child: Container(
//                 decoration: BoxDecoration(
//                   color: kWhite,
//                   borderRadius: BorderRadius.circular(10),
//                   border: Border.all(color: Colors.grey.shade200),
//                 ),
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     TextButton.icon(
//                       onPressed: () {
//                         _removeOverlay();
//                         widget.onGoToProfile();
//                       },
//                       icon: const Icon(
//                         Icons.person_outline,
//                         size: 16,
//                         color: kTeal,
//                       ),
//                       label: const Text(
//                         'Profile',
//                         style: TextStyle(color: kTextDark, fontSize: 13),
//                       ),
//                       style: TextButton.styleFrom(
//                         alignment: Alignment.centerLeft,
//                         padding: const EdgeInsets.symmetric(
//                           horizontal: 14,
//                           vertical: 10,
//                         ),
//                       ),
//                     ),
//                     Divider(height: 1, color: Colors.grey.shade200),
//                     TextButton.icon(
//                       onPressed: () {
//                         _removeOverlay();
//                         widget.onLogout();
//                       },
//                       icon: const Icon(
//                         Icons.logout,
//                         size: 16,
//                         color: Colors.red,
//                       ),
//                       label: const Text(
//                         'Logout',
//                         style: TextStyle(color: Colors.red, fontSize: 13),
//                       ),
//                       style: TextButton.styleFrom(
//                         alignment: Alignment.centerLeft,
//                         padding: const EdgeInsets.symmetric(
//                           horizontal: 14,
//                           vertical: 10,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//     Overlay.of(context).insert(_overlayEntry!);
//   }

//   void _scheduleHide() {
//     _hideTimer?.cancel();
//     _hideTimer = Timer(const Duration(milliseconds: 200), () {
//       if (!_isHoveringBadge && !_isHoveringMenu) _removeOverlay();
//     });
//   }

//   void _removeOverlay() {
//     _overlayEntry?.remove();
//     _overlayEntry = null;
//   }

//   Future<void> _pickProfileImage() async {
//     try {
//       final result = await FilePicker.pickFiles(
//         type: FileType.image,
//         withData: true,
//       );
//       if (result != null && result.files.first.bytes != null) {
//         widget.onProfileImageChanged(result.files.first.bytes!);
//       }
//     } catch (e) {
//       debugPrint('File pick error: $e');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       color: kWhite,
//       padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
//       child: Row(
//         children: [
//           Row(
//             children: [
//               SizedBox(
//                 width: 38,
//                 height: 38,
//                 child: Image.asset(
//                   'assets/images/Group.png',
//                   fit: BoxFit.contain,
//                   errorBuilder: (_, __, ___) =>
//                       const Icon(Icons.local_hospital, color: kTeal, size: 32),
//                 ),
//               ),
//               const SizedBox(width: 10),
//               const Text(
//                 'Heathos',
//                 style: TextStyle(
//                   color: kTeal,
//                   fontSize: 22,
//                   fontWeight: FontWeight.w700,
//                 ),
//               ),
//               const SizedBox(width: 16),
//               // Align(
//               //   alignment: Alignment.center,
//               //   child: Text(
//               //     'Appointment Booking',
//               //     style: TextStyle(
//               //       color: const Color.fromARGB(255, 17, 22, 21),
//               //       fontSize: 20,
//               //       fontWeight: FontWeight.w500,
//               //     ),
//               //   ),
//               // ),
//             ],
//           ),
//           const Spacer(),
//           SizedBox(
//             width: 260,
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Container(
//                   height: 40,
//                   decoration: BoxDecoration(
//                     border: Border.all(color: kTeal, width: 1.5),
//                     borderRadius: BorderRadius.circular(20),
//                   ),
//                   child: Row(
//                     children: [
//                       const SizedBox(width: 14),
//                       const Icon(
//                         Icons.search_rounded,
//                         color: kTextGrey,
//                         size: 18,
//                       ),
//                       const SizedBox(width: 8),
//                       Expanded(
//                         child: TextField(
//                           controller: _searchController,
//                           onChanged: _onSearchChanged,
//                           decoration: const InputDecoration(
//                             hintText: 'Search',
//                             hintStyle: TextStyle(
//                               color: kTextGrey,
//                               fontSize: 14,
//                             ),
//                             border: InputBorder.none,
//                             isDense: true,
//                             contentPadding: EdgeInsets.zero,
//                           ),
//                         ),
//                       ),
//                       _isSearching
//                           ? const SizedBox(
//                               width: 14,
//                               height: 14,
//                               child: CircularProgressIndicator(
//                                 strokeWidth: 1.5,
//                                 color: kTeal,
//                               ),
//                             )
//                           : const Icon(
//                               Icons.mic_rounded,
//                               color: kTextGrey,
//                               size: 18,
//                             ),
//                       const SizedBox(width: 14),
//                     ],
//                   ),
//                 ),
//                 if (_searchResults.isNotEmpty)
//                   Container(
//                     constraints: const BoxConstraints(maxHeight: 260),
//                     margin: const EdgeInsets.only(top: 4),
//                     decoration: BoxDecoration(
//                       color: kWhite,
//                       borderRadius: BorderRadius.circular(10),
//                       border: Border.all(color: Colors.grey.shade200),
//                       boxShadow: [
//                         BoxShadow(
//                           color: Colors.black.withOpacity(0.08),
//                           blurRadius: 12,
//                           offset: const Offset(0, 4),
//                         ),
//                       ],
//                     ),
//                     child: ListView.separated(
//                       shrinkWrap: true,
//                       padding: const EdgeInsets.symmetric(vertical: 6),
//                       itemCount: _searchResults.length,
//                       separatorBuilder: (_, __) =>
//                           Divider(height: 1, color: Colors.grey.shade100),
//                       itemBuilder: (_, i) {
//                         final r = _searchResults[i];
//                         return ListTile(
//                           dense: true,
//                           leading: CircleAvatar(
//                             radius: 14,
//                             backgroundColor: kTeal.withOpacity(0.12),
//                             child: Text(
//                               r.category[0],
//                               style: const TextStyle(
//                                 fontSize: 11,
//                                 color: kTeal,
//                                 fontWeight: FontWeight.w700,
//                               ),
//                             ),
//                           ),
//                           title: Text(
//                             r.name,
//                             style: const TextStyle(
//                               fontSize: 13,
//                               color: kTextDark,
//                               fontWeight: FontWeight.w600,
//                             ),
//                           ),
//                           subtitle: Text(
//                             '${r.category} · ${r.subtitle}',
//                             style: const TextStyle(
//                               fontSize: 11,
//                               color: kTextGrey,
//                             ),
//                           ),
//                           onTap: () {
//                             _searchController.clear();
//                             setState(() => _searchResults = []);
//                           },
//                         );
//                       },
//                     ),
//                   ),
//               ],
//             ),
//           ),
//           const SizedBox(width: 20),
//           Stack(
//             clipBehavior: Clip.none,
//             children: [
//               Container(
//                 width: 40,
//                 height: 40,
//                 decoration: BoxDecoration(
//                   shape: BoxShape.circle,
//                   border: Border.all(color: kTeal, width: 1.5),
//                 ),
//                 child: const Icon(
//                   Icons.notifications_rounded,
//                   color: kTeal,
//                   size: 20,
//                 ),
//               ),
//               Positioned(
//                 top: -4,
//                 right: -2,
//                 child: Container(
//                   width: 14,
//                   height: 14,
//                   decoration: const BoxDecoration(
//                     color: Colors.red,
//                     shape: BoxShape.circle,
//                   ),
//                   child: const Center(
//                     child: Text(
//                       '3',
//                       style: TextStyle(
//                         color: kWhite,
//                         fontSize: 8,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(width: 16),
//           CompositedTransformTarget(
//             link: _layerLink,
//             child: MouseRegion(
//               cursor: SystemMouseCursors.click,
//               onEnter: (_) {
//                 _isHoveringBadge = true;
//                 _hideTimer?.cancel();
//                 _showAdminMenu();
//               },
//               onExit: (_) {
//                 _isHoveringBadge = false;
//                 _scheduleHide();
//               },
//               child: GestureDetector(
//                 onTap: () {
//                   if (_overlayEntry == null) {
//                     _showAdminMenu();
//                   } else {
//                     _removeOverlay();
//                   }
//                 },
//                 child: Container(
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 12,
//                     vertical: 6,
//                   ),
//                   decoration: BoxDecoration(
//                     color: kCardBg,
//                     borderRadius: BorderRadius.circular(20),
//                     border: Border.all(color: kBorder),
//                   ),
//                   child: Row(
//                     children: [
//                       GestureDetector(
//                         onTap: _pickProfileImage,
//                         child: Container(
//                           width: 32,
//                           height: 32,
//                           decoration: BoxDecoration(
//                             color: kTealAccent,
//                             shape: BoxShape.circle,
//                           ),
//                           child: widget.profileImageBytes != null
//                               ? ClipOval(
//                                   child: Image.memory(
//                                     widget.profileImageBytes!,
//                                     fit: BoxFit.cover,
//                                   ),
//                                 )
//                               : const Icon(
//                                   Icons.person,
//                                   color: kWhite,
//                                   size: 18,
//                                 ),
//                         ),
//                       ),
//                       const SizedBox(width: 8),
//                       const Text(
//                         'VERA DUGAH',
//                         style: TextStyle(
//                           fontSize: 13,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                       const SizedBox(width: 4),
//                       const Icon(Icons.keyboard_arrow_down, size: 18),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class Footer extends StatelessWidget {
//   const Footer({super.key});
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.symmetric(vertical: 12),
//       color: kBackground,
//       child: const Center(
//         child: Text(
//           'Copyright © A2026.Designed by Group 5',
//           style: TextStyle(
//             color: kTeal,
//             fontSize: 13,
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//       ),
//     );
//   }
// }









import 'dart:async';
import 'dart:html' as html;
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
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
const kSuccess = Color(0xFF4CAF50);
const kWarning = Color(0xFFFF9800);
const kError = Color(0xFFF44336);
const kBorder = Color(0xFFE0E0E0);
const kBlack = Color(0xFF000000);

const String _BaseUrl = 'https://heathos-api.onrender.com';

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
  final _addressController = TextEditingController();
  final _emergencyContactController = TextEditingController();
  final _insuranceProviderController = TextEditingController();
  final _insuranceNumberController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  final _occupationController = TextEditingController();

  // CHANGE 1: Gender dropdown + DOB date
  String? _selectedGender;
  String? _selectedBloodGroup;
  DateTime? _selectedDob;
  int? _calculatedAge; // auto-calculated from DOB

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _dobController.dispose();
    _addressController.dispose();
    _emergencyContactController.dispose();
    _insuranceProviderController.dispose();
    _insuranceNumberController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _occupationController.dispose();
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

  // CHANGE 2: DOB calendar picker
  Future<void> _pickDateOfBirth() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDob ?? DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: kTeal,
              onPrimary: kWhite,
              onSurface: kTextDark,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      // Auto-calculate age from selected DOB
      final today = DateTime.now();
      int age = today.year - picked.year;
      if (today.month < picked.month ||
          (today.month == picked.month && today.day < picked.day)) {
        age--;
      }
      setState(() {
        _selectedDob = picked;
        _dobController.text = DateFormat('yyyy-MM-dd').format(picked);
        _calculatedAge = age;
      });
    }
  }

  // ✅ FULL API INTEGRATION - Save to backend + return true to refresh list
  Future<void> _savePatient() async {
    if (_fullNameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _phoneController.text.isEmpty) {
      _showError('Full name, email and phone are required.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      // ✅ Get token first
      final token = html.window.localStorage['token'] ?? '';
      if (token.isEmpty) {
        _showError('No token found. Please log in again.');
        return;
      }

      final response = await http
          .post(
            Uri.parse('$_BaseUrl/api/patients'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token', // ✅ Added
            },
            body: jsonEncode({
              "fullName": _fullNameController.text.trim(),
              "email": _emailController.text.trim(),
              "phone": _phoneController.text.trim(),
              "bloodGroup": _selectedBloodGroup ?? '',
              "dob": _dobController.text.trim(),
              "gender": _selectedGender ?? '',
              "address": _addressController.text.trim(),
              "emergencyContact": _emergencyContactController.text.trim(),
              "insuranceProvider": _insuranceProviderController.text.trim(),
              "insuranceNumber": _insuranceNumberController.text.trim(),
              "height": _heightController.text.trim().isNotEmpty
                  ? double.tryParse(_heightController.text.trim())
                  : null,
              "weight": _weightController.text.trim().isNotEmpty
                  ? double.tryParse(_weightController.text.trim())
                  : null,
              "occupation": _occupationController.text.trim(),
              if (_calculatedAge != null) "age": _calculatedAge,
            }),
          )
          .timeout(const Duration(seconds: 20));

      // ✅ Guard against empty response
      if (!mounted) return;
      if (response.body.isEmpty) {
        _showError('Server returned empty response. Check backend logs.');
        return;
      }

      final body = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        _showSuccess('Patient saved successfully');
        Navigator.pop(context, true);
      } else {
        _showError(body['message'] ?? 'Failed to save patient');
      }
    } catch (e) {
      if (e is TimeoutException) {
        _showError('Request timed out. Please try again.');
      } else if (e is FormatException) {
        _showError('Invalid response from server.');
      } else {
        _showError(e.toString());
      }
    } finally {
      if (mounted) setState(() => _isLoading = false); // ✅ mounted guard
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
                      // CHANGE 3: Teal button
                      ElevatedButton(
                        onPressed: _uploadProfilePhoto,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kTeal,
                          foregroundColor: kWhite,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
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
                      _dobField(), // CHANGED: Calendar picker
                      _genderDropdown(), // CHANGED: Dropdown
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
                      _field("Occupation (optional)", _occupationController),
                      _heightField(),
                      _weightField(),
                      _ageDisplay(),
                    ],
                  ),

                  const SizedBox(height: 30),

                  Row(
                    children: [
                      // CHANGE 4: Teal Save button
                      ElevatedButton(
                        onPressed: _isLoading ? null : _savePatient,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kTeal,
                          foregroundColor: kWhite,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: kWhite,
                                ),
                              )
                            : const Text(
                                "Save",
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                      ),
                      const SizedBox(width: 20),
                      // CHANGE 5: Teal Schedule button
                      TextButton(
                        onPressed: _proceedWithAppointment,
                        style: TextButton.styleFrom(
                          foregroundColor: kTeal,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 14,
                          ),
                        ),
                        child: const Text(
                          "Schedule Appointment",
                          style: TextStyle(fontWeight: FontWeight.w600),
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

  // CHANGE 6: DOB with calendar picker
  Widget _dobField() {
    return SizedBox(
      width: 250,
      child: TextFormField(
        controller: _dobController,
        readOnly: true,
        onTap: _pickDateOfBirth,
        decoration: InputDecoration(
          labelText: 'Date of Birth',
          hintText: 'YYYY-MM-DD',
          border: const OutlineInputBorder(),
          suffixIcon: const Icon(Icons.calendar_today, color: kTeal),
        ),
      ),
    );
  }

  // CHANGE 7: Gender dropdown
  Widget _genderDropdown() {
    return SizedBox(
      width: 250,
      child: DropdownButtonFormField<String>(
        value: _selectedGender,
        decoration: const InputDecoration(
          labelText: 'Gender',
          border: OutlineInputBorder(),
        ),
        items: const [
          DropdownMenuItem(value: 'Male', child: Text('Male')),
          DropdownMenuItem(value: 'Female', child: Text('Female')),
        ],
        onChanged: (val) => setState(() => _selectedGender = val),
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

  // Height field — positive double, in centimetres
  Widget _heightField() {
    return SizedBox(
      width: 250,
      child: TextField(
        controller: _heightController,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: const InputDecoration(
          labelText: 'Height (cm)',
          hintText: 'e.g. 175',
          border: OutlineInputBorder(),
          suffixText: 'cm',
        ),
      ),
    );
  }

  // Weight field — positive double, in kilograms
  Widget _weightField() {
    return SizedBox(
      width: 250,
      child: TextField(
        controller: _weightController,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: const InputDecoration(
          labelText: 'Weight (kg)',
          hintText: 'e.g. 70',
          border: OutlineInputBorder(),
          suffixText: 'kg',
        ),
      ),
    );
  }

  // Age display — read-only, auto-calculated from DOB
  Widget _ageDisplay() {
    return SizedBox(
      width: 250,
      child: TextFormField(
        readOnly: true,
        decoration: InputDecoration(
          labelText: 'Age (auto-calculated)',
          hintText: _calculatedAge != null
              ? '${_calculatedAge!} years'
              : 'Select Date of Birth first',
          border: const OutlineInputBorder(),
          filled: true,
          fillColor: const Color(0xFFF0F4F4),
          suffixIcon: const Icon(Icons.cake_outlined, color: kTeal),
        ),
        controller: TextEditingController(
          text: _calculatedAge != null ? '$_calculatedAge years' : '',
        ),
      ),
    );
  }
}

// TopBar and Footer - reuse from previous code
class TopBar extends StatefulWidget {
  final Uint8List? profileImageBytes;
  final ValueChanged<Uint8List> onProfileImageChanged;
  final VoidCallback onLogout;
  final VoidCallback onGoToProfile;

  const TopBar({
    super.key,
    required this.profileImageBytes,
    required this.onProfileImageChanged,
    required this.onLogout,
    required this.onGoToProfile,
  });

  @override
  State<TopBar> createState() => _TopBarState();
}

class _TopBarState extends State<TopBar> {
  final _searchController = TextEditingController();
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  Timer? _hideTimer;
  bool _isHoveringBadge = false;
  bool _isHoveringMenu = false;
  List<SearchResult> _searchResults = [];
  bool _isSearching = false;
  Timer? _debounce;

  @override
  void dispose() {
    _searchController.dispose();
    _hideTimer?.cancel();
    _debounce?.cancel();
    _removeOverlay();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _debounce?.cancel();
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }
    _debounce = Timer(
      const Duration(milliseconds: 400),
      () => _runSearch(query.trim()),
    );
  }

  // DO NOT TOUCH - User specified block
  Future<void> _runSearch(String query) async {
    setState(() => _isSearching = true);

    final endpoints = {
      'Doctor': '$_BaseUrl/doctors/search?q=$query',
      'Patient': '$_BaseUrl/patients/search?q=$query',
      'Nurse': '$_BaseUrl/nurses/search?q=$query',
      'Staff': '$_BaseUrl/staff/search?q=$query',
    };

    final results = <SearchResult>[];
    final errors = <String>[]; // Track failed endpoints

    await Future.wait(
      endpoints.entries.map((entry) async {
        try {
          final response = await http
              .get(Uri.parse(entry.value))
              .timeout(const Duration(seconds: 30));

          if (response.statusCode == 200) {
            final body = jsonDecode(response.body);
            final List<dynamic> items = body is List
                ? body
                : (body['data'] as List? ?? []);
            for (final item in items) {
              results.add(
                SearchResult(
                  name:
                      item['fullName'] as String? ??
                      item['name'] as String? ??
                      'Unknown',
                  category: entry.key,
                  subtitle:
                      item['email'] as String? ?? item['id'] as String? ?? '',
                ),
              );
            }
          } else {
            // Non-200 response
            errors.add('${entry.key}: HTTP ${response.statusCode}');
            debugPrint(
              'Search failed for ${entry.key}: ${response.statusCode} ${response.body}',
            );
          }
        } on TimeoutException {
          errors.add('${entry.key}: Request timed out');
          debugPrint('Search timeout for ${entry.key}');
        } on FormatException catch (e) {
          errors.add('${entry.key}: Invalid JSON');
          debugPrint('Search JSON error for ${entry.key}: $e');
        } catch (e) {
          errors.add('${entry.key}: $e');
          debugPrint('Search error for ${entry.key}: $e');
        }
      }),
    );

    if (mounted) {
      setState(() {
        _searchResults = results;
        _isSearching = false;
      });

      // Show error snackbar if any endpoint failed
      if (errors.isNotEmpty && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Search errors: ${errors.join(', ')}'),
            backgroundColor: Colors.orange.shade700,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  void _showAdminMenu() {
    _hideTimer?.cancel();
    if (_overlayEntry != null) return;
    _overlayEntry = OverlayEntry(
      builder: (_) => Positioned(
        width: 150,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: const Offset(-40, 38),
          child: MouseRegion(
            onEnter: (_) {
              _isHoveringMenu = true;
              _hideTimer?.cancel();
            },
            onExit: (_) {
              _isHoveringMenu = false;
              _scheduleHide();
            },
            child: Material(
              elevation: 8,
              borderRadius: BorderRadius.circular(10),
              child: Container(
                decoration: BoxDecoration(
                  color: kWhite,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextButton.icon(
                      onPressed: () {
                        _removeOverlay();
                        widget.onGoToProfile();
                      },
                      icon: const Icon(
                        Icons.person_outline,
                        size: 16,
                        color: kTeal,
                      ),
                      label: const Text(
                        'Profile',
                        style: TextStyle(color: kTextDark, fontSize: 13),
                      ),
                      style: TextButton.styleFrom(
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                      ),
                    ),
                    Divider(height: 1, color: Colors.grey.shade200),
                    TextButton.icon(
                      onPressed: () {
                        _removeOverlay();
                        widget.onLogout();
                      },
                      icon: const Icon(
                        Icons.logout,
                        size: 16,
                        color: Colors.red,
                      ),
                      label: const Text(
                        'Logout',
                        style: TextStyle(color: Colors.red, fontSize: 13),
                      ),
                      style: TextButton.styleFrom(
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
    Overlay.of(context).insert(_overlayEntry!);
  }

  void _scheduleHide() {
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(milliseconds: 200), () {
      if (!_isHoveringBadge && !_isHoveringMenu) _removeOverlay();
    });
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  Future<void> _pickProfileImage() async {
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.image,
        withData: true,
      );
      if (result != null && result.files.first.bytes != null) {
        widget.onProfileImageChanged(result.files.first.bytes!);
      }
    } catch (e) {
      debugPrint('File pick error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: kWhite,
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
      child: Row(
        children: [
          Row(
            children: [
              SizedBox(
                width: 38,
                height: 38,
                child: Image.asset(
                  'assets/images/Group.png',
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) =>
                      const Icon(Icons.local_hospital, color: kTeal, size: 32),
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'Heathos',
                style: TextStyle(
                  color: kTeal,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 16),
              // Align(
              //   alignment: Alignment.center,
              //   child: Text(
              //     'Appointment Booking',
              //     style: TextStyle(
              //       color: const Color.fromARGB(255, 17, 22, 21),
              //       fontSize: 20,
              //       fontWeight: FontWeight.w500,
              //     ),
              //   ),
              // ),
            ],
          ),
          const Spacer(),
          SizedBox(
            width: 260,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: 40,
                  decoration: BoxDecoration(
                    border: Border.all(color: kTeal, width: 1.5),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      const SizedBox(width: 14),
                      const Icon(
                        Icons.search_rounded,
                        color: kTextGrey,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          onChanged: _onSearchChanged,
                          decoration: const InputDecoration(
                            hintText: 'Search',
                            hintStyle: TextStyle(
                              color: kTextGrey,
                              fontSize: 14,
                            ),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ),
                      _isSearching
                          ? const SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(
                                strokeWidth: 1.5,
                                color: kTeal,
                              ),
                            )
                          : const Icon(
                              Icons.mic_rounded,
                              color: kTextGrey,
                              size: 18,
                            ),
                      const SizedBox(width: 14),
                    ],
                  ),
                ),
                if (_searchResults.isNotEmpty)
                  Container(
                    constraints: const BoxConstraints(maxHeight: 260),
                    margin: const EdgeInsets.only(top: 4),
                    decoration: BoxDecoration(
                      color: kWhite,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey.shade200),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ListView.separated(
                      shrinkWrap: true,
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      itemCount: _searchResults.length,
                      separatorBuilder: (_, __) =>
                          Divider(height: 1, color: Colors.grey.shade100),
                      itemBuilder: (_, i) {
                        final r = _searchResults[i];
                        return ListTile(
                          dense: true,
                          leading: CircleAvatar(
                            radius: 14,
                            backgroundColor: kTeal.withOpacity(0.12),
                            child: Text(
                              r.category[0],
                              style: const TextStyle(
                                fontSize: 11,
                                color: kTeal,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          title: Text(
                            r.name,
                            style: const TextStyle(
                              fontSize: 13,
                              color: kTextDark,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle: Text(
                            '${r.category} · ${r.subtitle}',
                            style: const TextStyle(
                              fontSize: 11,
                              color: kTextGrey,
                            ),
                          ),
                          onTap: () {
                            _searchController.clear();
                            setState(() => _searchResults = []);
                          },
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: kTeal, width: 1.5),
                ),
                child: const Icon(
                  Icons.notifications_rounded,
                  color: kTeal,
                  size: 20,
                ),
              ),
              Positioned(
                top: -4,
                right: -2,
                child: Container(
                  width: 14,
                  height: 14,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Text(
                      '3',
                      style: TextStyle(
                        color: kWhite,
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          CompositedTransformTarget(
            link: _layerLink,
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              onEnter: (_) {
                _isHoveringBadge = true;
                _hideTimer?.cancel();
                _showAdminMenu();
              },
              onExit: (_) {
                _isHoveringBadge = false;
                _scheduleHide();
              },
              child: GestureDetector(
                onTap: () {
                  if (_overlayEntry == null) {
                    _showAdminMenu();
                  } else {
                    _removeOverlay();
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: kCardBg,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: kBorder),
                  ),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: _pickProfileImage,
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: kTealAccent,
                            shape: BoxShape.circle,
                          ),
                          child: widget.profileImageBytes != null
                              ? ClipOval(
                                  child: Image.memory(
                                    widget.profileImageBytes!,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : const Icon(
                                  Icons.person,
                                  color: kWhite,
                                  size: 18,
                                ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'VERA DUGAH',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.keyboard_arrow_down, size: 18),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class Footer extends StatelessWidget {
  const Footer({super.key});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      color: kBackground,
      child: const Center(
        child: Text(
          'Copyright © A2026.Designed by Group 5',
          style: TextStyle(
            color: kTeal,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

// import 'dart:convert';
// import 'dart:html' as html;
// import 'dart:typed_data';
// import 'package:file_picker/file_picker.dart';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;

// import 'constants/api_constants.dart';
// import 'admin_login_page.dart';
// import 'patient_reg.dart';
// // Import all pages the sidebar needs
// import 'admin_dashboard.dart';
// import 'appointment_page.dart';
// import 'staff_page.dart';
// import 'inventory_page.dart';
// import 'billing_page.dart';

// const String _BaseUrl = 'https://heathos-api.onrender.com';

// // ADDED: Constants needed for sidebar - copied from admin_dashboard.dart
// const _kTeal = Color(0xFF0D7B6B);
// const _kTealLight = Color(0xFF1A9E8A);
// const _kTealDark = Color(0xFF095F54);
// const _kTealAccent = Color(0xFF4FC3B0);
// const _kWhite = Color(0xFFFFFFFF);
// const _kTextDark = Color(0xFF1A2E2C);
// const _kTextGrey = Color(0xFF7A9490);

// // ADDED: Nav index constants for sidebar
// const int _kNavOverview = 0;
// const int _kNavPatient = 1;
// const int _kNavAppointment = 2;
// const int _kNavStaff = 3;
// const int _kNavInventory = 4;
// const int _kNavBillings = 5;

// class PatientListPage extends StatefulWidget {
//   final bool isAdminView;
//   const PatientListPage({super.key, this.isAdminView = false});

//   @override
//   State<PatientListPage> createState() => _PatientListPageState();
// }

// class _PatientListPageState extends State<PatientListPage> {
//   List patients = [];
//   bool isLoading = true;
//   String _searchQuery = '';
//   Uint8List? _topBarProfileImageBytes;
//   String _userRole = 'RECEPTIONIST';

//   // Hide Add button for admin
//   bool get _canAddPatient =>
//       _userRole.toUpperCase() == 'RECEPTIONIST' &&!widget.isAdminView;

//   List get _filteredPatients {
//     if (_searchQuery.trim().isEmpty) return patients;
//     final q = _searchQuery.toLowerCase();
//     return patients.where((p) {
//       return (p['fullName']?? '').toLowerCase().contains(q) ||
//           (p['phone']?? '').toLowerCase().contains(q) ||
//           (p['email']?? '').toLowerCase().contains(q) ||
//           (p['id']?? '').toString().contains(q);
//     }).toList();
//   }

//   @override
//   void initState() {
//     super.initState();
//     _loadUserRole();
//     fetchPatients();
//   }

//   void _loadUserRole() {
//     _userRole = html.window.localStorage['role']?? 'RECEPTIONIST';
//   }

//   void _logout() {
//     html.window.localStorage.clear(); // Clear token on logout
//     Navigator.pushAndRemoveUntil(
//       context,
//       MaterialPageRoute(builder: (_) => const AdminLoginPage()),
//       (route) => false,
//     );
//   }

//   // ───────── FETCH - BULLETPROOF VERSION ─────────
//   Future<void> fetchPatients() async {
//     if (!mounted) return;
//     setState(() => isLoading = true);

//     try {
//       final token = html.window.localStorage['token']?? '';

//       if (token.isEmpty) {
//         showError('No token found. Please log in again.');
//         _logout();
//         return;
//       }

//       final response = await http.get(
//         Uri.parse('$_BaseUrl/api/patients'),
//         headers: {
//           'Content-Type': 'application/json',
//           'Authorization': 'Bearer $token',
//         },
//       );

//       // DEBUG: Print what we actually got
//       debugPrint('Status: ${response.statusCode}');
//       debugPrint('Body: ${response.body}');

//       // FIX 1: Check status BEFORE decoding
//       if (response.statusCode == 401) {
//         showError('Session expired. Please log in again.');
//         _logout();
//         return;
//       }

//       if (response.statusCode == 403) {
//         showError('You do not have permission to view patients.');
//         return;
//       }

//       // FIX 2: Only decode if body exists and looks like JSON
//       if (response.body.isEmpty) {
//         showError('Server returned empty response. Status: ${response.statusCode}');
//         return;
//       }

//       if (!response.body.trim().startsWith('{') &&!response.body.trim().startsWith('[')) {
//         showError('Server returned HTML/text instead of JSON. Backend may be down.');
//         return;
//       }

//       final data = jsonDecode(response.body);

//       if (response.statusCode == 200 && data['success'] == true) {
//         if (!mounted) return;
//         setState(() {
//           patients = data['data'] is List? data['data'] : [];
//         });
//       } else {
//         showError(data['message']?? 'Failed to fetch patients');
//       }
//     } catch (e) {
//       if (e is FormatException) {
//         showError('Invalid response from server. Check backend logs.');
//       } else {
//         showError('Network error: $e');
//       }
//     } finally {
//       if (!mounted) return;
//       setState(() => isLoading = false);
//     }
//   }

//   // ───────── DELETE - BULLETPROOF VERSION ─────────
//   Future<void> deletePatient(String id) async {
//     try {
//       final token = html.window.localStorage['token']?? '';

//       final response = await http.delete(
//         Uri.parse('$_BaseUrl/api/patients/$id'),
//         headers: {
//           'Content-Type': 'application/json',
//           'Authorization': 'Bearer $token',
//         },
//       );

//       if (response.statusCode == 401) {
//         showError('Session expired. Please log in again.');
//         _logout();
//         return;
//       }

//       if (response.body.isEmpty) {
//         showError('Delete failed: empty server response');
//         return;
//       }

//       final data = jsonDecode(response.body);

//       if (response.statusCode == 200) {
//         if (!mounted) return;
//         ScaffoldMessenger.of(
//           context,
//         ).showSnackBar(const SnackBar(content: Text('Patient deleted')));
//         fetchPatients();
//       } else {
//         showError(data['message']?? 'Delete failed');
//       }
//     } catch (e) {
//       if (e is FormatException) {
//         showError('Server returned invalid data');
//       } else {
//         showError('Error: $e');
//       }
//     }
//   }

//   // ───────── UPDATE - BULLETPROOF VERSION ─────────
//   Future<void> updatePatient(String id, Map body) async {
//     try {
//       final token = html.window.localStorage['token']?? '';

//       final response = await http.put(
//         Uri.parse('$_BaseUrl/api/patients/$id'),
//         headers: {
//           'Content-Type': 'application/json',
//           'Authorization': 'Bearer $token',
//         },
//         body: jsonEncode(body),
//       );

//       if (response.statusCode == 200) {
//         if (!mounted) return;
//         Navigator.pop(context);
//         fetchPatients();
//       } else {
//         String errorMsg = 'Update failed';
//         if (response.body.isNotEmpty) {
//           try {
//             final data = jsonDecode(response.body);
//             errorMsg = data['message']?? errorMsg;
//           } catch (_) {}
//         }
//         if (response.statusCode == 401) {
//           showError('Session expired. Please log in again.');
//           _logout();
//         } else {
//           showError(errorMsg);
//         }
//       }
//     } catch (e) {
//       showError('Error: $e');
//     }
//   }

//   // ───────── EDIT DIALOG ─────────
//   void showEditDialog(Map p) {
//     final firstName = TextEditingController(text: p['firstName']);
//     final surname = TextEditingController(text: p['surname']);
//     final phone = TextEditingController(text: p['phone']);
//     final address = TextEditingController(text: p['address']);

//     showDialog(
//       context: context,
//       builder: (_) => AlertDialog(
//         title: const Text('Edit Patient'),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             TextField(
//               controller: firstName,
//               decoration: const InputDecoration(labelText: 'First Name'),
//             ),
//             TextField(
//               controller: surname,
//               decoration: const InputDecoration(labelText: 'Surname'),
//             ),
//             TextField(
//               controller: phone,
//               decoration: const InputDecoration(labelText: 'Phone'),
//             ),
//             TextField(
//               controller: address,
//               decoration: const InputDecoration(labelText: 'Address'),
//             ),
//           ],
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('Cancel'),
//           ),
//           ElevatedButton(
//             style: ElevatedButton.styleFrom(
//               backgroundColor: const Color(0xFF0E8A73),
//             ),
//             onPressed: () {
//               updatePatient(p['id'].toString(), {
//                 "firstName": firstName.text,
//                 "surname": surname.text,
//                 "phone": phone.text,
//                 "address": address.text,
//               });
//             },
//             child: const Text('Save'),
//           ),
//         ],
//       ),
//     );
//   }

//   void confirmDelete(String id) {
//     showDialog(
//       context: context,
//       builder: (_) => AlertDialog(
//         title: const Text('Delete Patient?'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('Cancel'),
//           ),
//           ElevatedButton(
//             style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
//             onPressed: () {
//               Navigator.pop(context);
//               deletePatient(id);
//             },
//             child: const Text('Delete'),
//           ),
//         ],
//       ),
//     );
//   }

//   void showError(String msg) {
//     if (!mounted) return;
//     ScaffoldMessenger.of(
//       context,
//     ).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));
//   }

//   // Navigate to registration and refresh on return
//   Future<void> _navigateToAddPatient() async {
//     await Navigator.push(
//       context,
//       MaterialPageRoute(builder: (_) => const PatientRegistrationPage()),
//     );
//     fetchPatients(); // Refresh list after returning
//   }

//   // ───────── UI ─────────
//   @override
//   Widget build(BuildContext context) {
//     const teal = Color(0xFF0E8A73);
//     const lightTeal = Color(0xFFE6F5F2);

//     Widget mainContent = Scaffold(
//       backgroundColor: Colors.white,
//       body: Column(
//         children: [
//           _PatientTopBar(
//             profileImageBytes: _topBarProfileImageBytes,
//             onProfileImageChanged: (img) =>
//                 setState(() => _topBarProfileImageBytes = img),
//             onLogout: _logout,
//           ),
//           Expanded(
//             child: Padding(
//               padding: const EdgeInsets.all(24.0),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // Header Row
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           const Text(
//                             'List of Patients',
//                             style: TextStyle(
//                               fontSize: 32,
//                               fontWeight: FontWeight.w700,
//                               color: teal,
//                             ),
//                           ),
//                           const SizedBox(height: 8),
//                           Text(
//                             'View and manage patient records, appointments, and history in one\nplace.',
//                             style: TextStyle(
//                               fontSize: 14,
//                               color: Colors.grey.shade600,
//                               height: 1.4,
//                             ),
//                           ),
//                         ],
//                       ),
//                       Row(
//                         children: [
//                           SizedBox(
//                             width: 260,
//                             height: 44,
//                             child: TextField(
//                               onChanged: (v) =>
//                                   setState(() => _searchQuery = v),
//                               style: const TextStyle(
//                                 fontSize: 14,
//                                 color: Color(0xFF0D2B27),
//                               ),
//                               decoration: InputDecoration(
//                                 hintText: 'Search patients…',
//                                 hintStyle: const TextStyle(
//                                   color: Color(0xFF607C79),
//                                   fontSize: 13,
//                                 ),
//                                 prefixIcon: const Icon(
//                                   Icons.search_rounded,
//                                   color: Color(0xFF607C79),
//                                   size: 20,
//                                 ),
//                                 filled: true,
//                                 fillColor: Colors.white,
//                                 contentPadding: const EdgeInsets.symmetric(
//                                   horizontal: 16,
//                                   vertical: 0,
//                                 ),
//                                 enabledBorder: OutlineInputBorder(
//                                   borderRadius: BorderRadius.circular(24),
//                                   borderSide: const BorderSide(
//                                     color: Color(0xFFCCE8E5),
//                                     width: 1.4,
//                                   ),
//                                 ),
//                                 focusedBorder: OutlineInputBorder(
//                                   borderRadius: BorderRadius.circular(24),
//                                   borderSide: const BorderSide(
//                                     color: teal,
//                                     width: 2,
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ),
//                           if (_canAddPatient)...[
//                             const SizedBox(width: 12),
//                             ElevatedButton.icon(
//                               onPressed: _navigateToAddPatient,
//                               icon: const Icon(Icons.add, size: 18),
//                               label: const Text('Add Patient'),
//                               style: ElevatedButton.styleFrom(
//                                 backgroundColor: teal,
//                                 foregroundColor: Colors.white,
//                                 padding: const EdgeInsets.symmetric(
//                                   horizontal: 24,
//                                   vertical: 16,
//                                 ),
//                                 shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(24),
//                                 ),
//                                 elevation: 0,
//                               ),
//                             ),
//                           ],
//                         ],
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 24),

//                   // Table
//                   Expanded(
//                     child: isLoading
//                        ? const Center(
//                             child: CircularProgressIndicator(color: teal),
//                           )
//                         : Container(
//                             decoration: BoxDecoration(
//                               borderRadius: BorderRadius.circular(8),
//                               border: Border.all(color: Colors.grey.shade200),
//                             ),
//                             child: Column(
//                               children: [
//                                 // Table Header
//                                 Container(
//                                   padding: const EdgeInsets.symmetric(
//                                     horizontal: 16,
//                                     vertical: 16,
//                                   ),
//                                   decoration: const BoxDecoration(
//                                     color: lightTeal,
//                                     borderRadius: BorderRadius.only(
//                                       topLeft: Radius.circular(8),
//                                       topRight: Radius.circular(8),
//                                     ),
//                                   ),
//                                   child: const Row(
//                                     children: [
//                                       Expanded(
//                                         flex: 1,
//                                         child: Text(
//                                           'Patient ID',
//                                           style: TextStyle(
//                                             fontWeight: FontWeight.w600,
//                                             color: teal,
//                                           ),
//                                         ),
//                                       ),
//                                       Expanded(
//                                         flex: 3,
//                                         child: Text(
//                                           'Name',
//                                           style: TextStyle(
//                                             fontWeight: FontWeight.w600,
//                                             color: teal,
//                                           ),
//                                         ),
//                                       ),
//                                       Expanded(
//                                         flex: 2,
//                                         child: Text(
//                                           'Gender',
//                                           style: TextStyle(
//                                             fontWeight: FontWeight.w600,
//                                             color: teal,
//                                           ),
//                                         ),
//                                       ),
//                                       Expanded(
//                                         flex: 2,
//                                         child: Text(
//                                           'Phone Number',
//                                           style: TextStyle(
//                                             fontWeight: FontWeight.w600,
//                                             color: teal,
//                                           ),
//                                         ),
//                                       ),
//                                       Expanded(
//                                         flex: 2,
//                                         child: Text(
//                                           'Address',
//                                           style: TextStyle(
//                                             fontWeight: FontWeight.w600,
//                                             color: teal,
//                                           ),
//                                         ),
//                                       ),
//                                       Expanded(
//                                         flex: 1,
//                                         child: Text(
//                                           'Action',
//                                           style: TextStyle(
//                                             fontWeight: FontWeight.w600,
//                                             color: teal,
//                                           ),
//                                           textAlign: TextAlign.center,
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                                 // Table Body
//                                 Expanded(
//                                   child: patients.isEmpty
//                                      ? const Center(
//                                           child: Padding(
//                                             padding: EdgeInsets.all(32.0),
//                                             child: Text(
//                                               'Awaiting Patient',
//                                               style: TextStyle(
//                                                 fontSize: 16,
//                                                 color: Colors.grey,
//                                               ),
//                                             ),
//                                           ),
//                                         )
//                                       : _filteredPatients.isEmpty
//                                      ? const Center(
//                                           child: Padding(
//                                             padding: EdgeInsets.all(32.0),
//                                             child: Text(
//                                               'No patients match your search.',
//                                               style: TextStyle(
//                                                 fontSize: 16,
//                                                 color: Colors.grey,
//                                               ),
//                                             ),
//                                           ),
//                                         )
//                                       : ListView.separated(
//                                           itemCount: _filteredPatients.length,
//                                           separatorBuilder: (_, __) => Divider(
//                                             height: 1,
//                                             color: Colors.grey.shade200,
//                                           ),
//                                           itemBuilder: (context, i) {
//                                             final p = _filteredPatients[i];
//                                             return Container(
//                                               padding:
//                                                   const EdgeInsets.symmetric(
//                                                     horizontal: 16,
//                                                     vertical: 12,
//                                                   ),
//                                               child: Row(
//                                                 children: [
//                                                   Expanded(
//                                                     flex: 1,
//                                                     child: Text(
//                                                       '${p['id']?? i + 1}',
//                                                     ),
//                                                   ),
//                                                   Expanded(
//                                                     flex: 3,
//                                                     child: Row(
//                                                       children: [
//                                                         CircleAvatar(
//                                                           radius: 16,
//                                                           backgroundColor:
//                                                               lightTeal,
//                                                           child: const Icon(
//                                                             Icons.person,
//                                                             size: 18,
//                                                             color: teal,
//                                                           ),
//                                                         ),
//                                                         const SizedBox(
//                                                           width: 12,
//                                                         ),
//                                                         Text(
//                                                           p['fullName']??
//                                                               'N/A',
//                                                         ),
//                                                       ],
//                                                     ),
//                                                   ),
//                                                   Expanded(
//                                                     flex: 2,
//                                                     child: Text(
//                                                       p['gender']?? 'N/A',
//                                                     ),
//                                                   ),
//                                                   Expanded(
//                                                     flex: 2,
//                                                     child: Text(
//                                                       p['phone']?? '',
//                                                     ),
//                                                   ),
//                                                   Expanded(
//                                                     flex: 2,
//                                                     child: Text(
//                                                       p['address']?? 'N/A',
//                                                     ),
//                                                   ),
//                                                   Expanded(
//                                                     flex: 1,
//                                                     child: Row(
//                                                       mainAxisAlignment:
//                                                           MainAxisAlignment
//                                                              .center,
//                                                       children: [
//                                                         IconButton(
//                                                           icon: const Icon(
//                                                             Icons.edit,
//                                                             color: teal,
//                                                             size: 20,
//                                                           ),
//                                                           onPressed: () =>
//                                                               showEditDialog(p),
//                                                           padding:
//                                                               EdgeInsets.zero,
//                                                           constraints:
//                                                               const BoxConstraints(),
//                                                         ),
//                                                         const SizedBox(
//                                                           width: 8,
//                                                         ),
//                                                         IconButton(
//                                                           icon: const Icon(
//                                                             Icons
//                                                                .delete_outline,
//                                                             color: Colors.red,
//                                                             size: 20,
//                                                           ),
//                                                           onPressed: () =>
//                                                               confirmDelete(
//                                                                 p['id']
//                                                                    .toString(),
//                                                               ),
//                                                           padding:
//                                                               EdgeInsets.zero,
//                                                           constraints:
//                                                               const BoxConstraints(),
//                                                         ),
//                                                       ],
//                                                     ),
//                                                   ),
//                                                 ],
//                                               ),
//                                             );
//                                           },
//                                         ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );

//     if (widget.isAdminView) {
//       return Scaffold(
//         backgroundColor: Colors.white,
//         body: Row(
//           children: [
//             const _AdminSidebar(),
//             Expanded(child: mainContent),
//           ],
//         ),
//       );
//     }
//     return mainContent;
//   }
// }

// // ───────── SIDEBAR + TOPBAR CODE UNCHANGED ─────────
// // ADDED: Standalone sidebar with all functionality
// class _AdminSidebar extends StatefulWidget {
//   const _AdminSidebar();

//   @override
//   State<_AdminSidebar> createState() => _AdminSidebarState();
// }

// class _AdminSidebarState extends State<_AdminSidebar> {
//   int _selectedIndex = _kNavPatient;

//   final List<_NavItemData> _navItems = const [
//     _NavItemData(
//       icon: Icons.dashboard_rounded,
//       label: 'Overview',
//       index: _kNavOverview,
//     ),
//     _NavItemData(
//       icon: Icons.personal_injury_rounded,
//       label: 'Patient',
//       index: _kNavPatient,
//     ),
//     _NavItemData(
//       icon: Icons.event_note_rounded,
//       label: 'Appointment',
//       index: _kNavAppointment,
//     ),
//     _NavItemData(icon: Icons.groups_rounded, label: 'Staff', index: _kNavStaff),
//     _NavItemData(
//       icon: Icons.inventory_2_rounded,
//       label: 'Inventory',
//       index: _kNavInventory,
//     ),
//     _NavItemData(
//       icon: Icons.receipt_long_rounded,
//       label: 'Billings',
//       index: _kNavBillings,
//     ),
//   ];

//   void _onNavItemSelected(int index) {
//     setState(() => _selectedIndex = index);

//     switch (index) {
//       case _kNavOverview:
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(builder: (_) => const AdminDashboard()),
//         );
//         break;
//       case _kNavPatient:
//         break;
//       case _kNavAppointment:
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(builder: (_) => AppointmentPage()),
//         );
//         break;
//       case _kNavStaff:
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(builder: (_) => const StaffPage()),
//         );
//         break;
//       case _kNavInventory:
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(builder: (_) => InventoryPage()),
//         );
//         break;
//       // case _kNavBillings:
//       //   Navigator.pushReplacement(
//       //     context,
//       //     MaterialPageRoute(builder: (_) => const BillingPage()),
//       //   );
//       //   break;
//     }
//   }

//   void _logout() {
//     html.window.localStorage.clear();
//     Navigator.pushAndRemoveUntil(
//       context,
//       MaterialPageRoute(builder: (_) => const AdminLoginPage()),
//       (route) => false,
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: 240,
//       height: double.infinity,
//       color: _kTeal,
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Padding(
//             padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
//             child: Row(
//               children: [
//                 Container(
//                   width: 38,
//                   height: 38,
//                   child: Image.asset(
//                     'assets/images/Group.png',
//                     fit: BoxFit.contain,
//                   ),
//                 ),
//                 const SizedBox(width: 10),
//                 const Text(
//                   'Heathos',
//                   style: TextStyle(
//                     color: _kWhite,
//                     fontSize: 22,
//                     fontWeight: FontWeight.w700,
//                     letterSpacing: 0.5,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           Expanded(
//             child: ListView.builder(
//               padding: EdgeInsets.zero,
//               itemCount: _navItems.length,
//               itemBuilder: (_, i) => _SidebarItemWidget(
//                 icon: _navItems[i].icon,
//                 label: _navItems[i].label,
//                 isSelected: _selectedIndex == _navItems[i].index,
//                 onTap: () => _onNavItemSelected(_navItems[i].index),
//               ),
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
//             child: InkWell(
//               onTap: _logout,
//               borderRadius: BorderRadius.circular(10),
//               child: Padding(
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 12,
//                   vertical: 10,
//                 ),
//                 child: Row(
//                   children: const [
//                     Text(
//                       'Logout',
//                       style: TextStyle(
//                         color: _kWhite,
//                         fontSize: 15,
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                     SizedBox(width: 8),
//                     Icon(Icons.arrow_forward_rounded, color: _kWhite, size: 18),
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

// class _NavItemData {
//   final IconData icon;
//   final String label;
//   final int index;
//   const _NavItemData({
//     required this.icon,
//     required this.label,
//     required this.index,
//   });
// }

// class _SidebarItemWidget extends StatefulWidget {
//   final IconData icon;
//   final String label;
//   final bool isSelected;
//   final VoidCallback onTap;

//   const _SidebarItemWidget({
//     required this.icon,
//     required this.label,
//     required this.isSelected,
//     required this.onTap,
//   });

//   @override
//   State<_SidebarItemWidget> createState() => _SidebarItemWidgetState();
// }

// class _SidebarItemWidgetState extends State<_SidebarItemWidget> {
//   bool _hovering = false;

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
//       child: MouseRegion(
//         onEnter: (_) => setState(() => _hovering = true),
//         onExit: (_) => setState(() => _hovering = false),
//         child: InkWell(
//           onTap: widget.onTap,
//           borderRadius: BorderRadius.circular(10),
//           child: AnimatedContainer(
//             duration: const Duration(milliseconds: 180),
//             padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
//             decoration: BoxDecoration(
//               color: widget.isSelected
//                  ? _kWhite.withOpacity(0.20)
//                   : _hovering
//                  ? _kWhite.withOpacity(0.10)
//                   : Colors.transparent,
//               borderRadius: BorderRadius.circular(10),
//               border: widget.isSelected
//                  ? Border.all(color: _kWhite.withOpacity(0.3), width: 1)
//                   : null,
//             ),
//             child: Row(
//               children: [
//                 Icon(widget.icon, color: _kWhite, size: 20),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: Text(
//                     widget.label,
//                     style: TextStyle(
//                       color: _kWhite,
//                       fontSize: 14,
//                       fontWeight: widget.isSelected
//                          ? FontWeight.w700
//                           : FontWeight.w500,
//                     ),
//                     overflow: TextOverflow.ellipsis,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// // ─────────────────────────────────────────────────────────────────────────────
// // Patient Dashboard TopBar
// // ─────────────────────────────────────────────────────────────────────────────

// class _PatientTopBar extends StatefulWidget {
//   final Uint8List? profileImageBytes;
//   final ValueChanged<Uint8List?> onProfileImageChanged;
//   final VoidCallback onLogout;

//   const _PatientTopBar({
//     required this.profileImageBytes,
//     required this.onProfileImageChanged,
//     required this.onLogout,
//   });

//   @override
//   State<_PatientTopBar> createState() => _PatientTopBarState();
// }

// class _PatientTopBarState extends State<_PatientTopBar> {
//   static const _teal = Color(0xFF0E8A73);
//   static const _tealLight = Color(0xFFE6F5F2);

//   String _userName = 'User';
//   String _userRole = 'Admin';
//   bool _showMenu = false;

//   @override
//   void initState() {
//     super.initState();
//     _loadUserInfo();
//   }

//   void _loadUserInfo() {
//     final role = html.window.localStorage['role']?? 'ADMIN';
//     final name =
//         html.window.localStorage['userName']??
//         html.window.localStorage['fullName']??
//         html.window.localStorage['email']??
//         'User';
//     setState(() {
//       _userRole = _formatRole(role);
//       _userName = name;
//     });
//   }

//   String _formatRole(String role) {
//     switch (role.toUpperCase()) {
//       case 'ADMIN':
//         return 'Admin';
//       case 'RECEPTIONIST':
//         return 'Receptionist';
//       default:
//         return role[0].toUpperCase() + role.substring(1).toLowerCase();
//     }
//   }

//   Future<void> _pickProfileImage() async {
//     try {
//       final result = await FilePicker.pickFiles(
//         type: FileType.image,
//         withData: true,
//       );
//       if (result!= null && result.files.first.bytes!= null) {
//         widget.onProfileImageChanged(result.files.first.bytes!);
//       }
//     } catch (e) {
//       debugPrint('File pick error: $e');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         border: Border(
//           bottom: BorderSide(color: Colors.grey.shade200, width: 1),
//         ),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.04),
//             blurRadius: 6,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           // ── Logo + title ──
//           Row(
//             children: [
//               Container(
//                 width: 36,
//                 height: 36,
//                 decoration: BoxDecoration(
//                   color: _tealLight,
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: const Icon(
//                   Icons.local_hospital_rounded,
//                   color: _teal,
//                   size: 20,
//                 ),
//               ),
//               const SizedBox(width: 10),
//               const Text(
//                 'Heathos HMS',
//                 style: TextStyle(
//                   fontSize: 17,
//                   fontWeight: FontWeight.w800,
//                   color: _teal,
//                 ),
//               ),
//             ],
//           ),

//           // ── Profile area ──
//           Row(
//             children: [
//               // Avatar + dropdown
//               GestureDetector(
//                 onTap: () => setState(() => _showMenu =!_showMenu),
//                 child: Stack(
//                   children: [
//                     CircleAvatar(
//                       radius: 18,
//                       backgroundColor: _tealLight,
//                       backgroundImage: widget.profileImageBytes!= null
//                          ? MemoryImage(widget.profileImageBytes!)
//                           : null,
//                       child: widget.profileImageBytes == null
//                          ? const Icon(Icons.person, color: _teal, size: 20)
//                           : null,
//                     ),
//                     Positioned(
//                       right: 0,
//                       bottom: 0,
//                       child: Container(
//                         width: 14,
//                         height: 14,
//                         decoration: BoxDecoration(
//                           color: Colors.white,
//                           shape: BoxShape.circle,
//                           border: Border.all(color: _teal, width: 1.2),
//                         ),
//                         child: const Icon(
//                           Icons.keyboard_arrow_down_rounded,
//                           size: 10,
//                           color: _teal,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),

//               const SizedBox(width: 10),

//               // Name
//               Text(
//                 _userName,
//                 style: const TextStyle(
//                   fontSize: 14,
//                   fontWeight: FontWeight.w600,
//                   color: Color(0xFF0D2B27),
//                 ),
//               ),
//               const SizedBox(width: 8),

//               // Role badge
//               Container(
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 10,
//                   vertical: 4,
//                 ),
//                 decoration: BoxDecoration(
//                   color: _tealLight,
//                   borderRadius: BorderRadius.circular(20),
//                 ),
//                 child: Text(
//                   _userRole,
//                   style: const TextStyle(
//                     fontSize: 12,
//                     fontWeight: FontWeight.w600,
//                     color: _teal,
//                   ),
//                 ),
//               ),

//               // Dropdown menu
//               if (_showMenu)
//                 Material(
//                   elevation: 8,
//                   borderRadius: BorderRadius.circular(10),
//                   child: Container(
//                     width: 180,
//                     padding: const EdgeInsets.symmetric(vertical: 6),
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                     child: Column(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         ListTile(
//                           dense: true,
//                           leading: const Icon(
//                             Icons.camera_alt_outlined,
//                             color: _teal,
//                             size: 18,
//                           ),
//                           title: const Text(
//                             'Upload Photo',
//                             style: TextStyle(fontSize: 13),
//                           ),
//                           onTap: () {
//                             setState(() => _showMenu = false);
//                             _pickProfileImage();
//                           },
//                         ),
//                         const Divider(height: 1),
//                         ListTile(
//                           dense: true,
//                           leading: const Icon(
//                             Icons.logout_rounded,
//                             color: Colors.red,
//                             size: 18,
//                           ),
//                           title: const Text(
//                             'Logout',
//                             style: TextStyle(fontSize: 13, color: Colors.red),
//                           ),
//                           onTap: () {
//                             setState(() => _showMenu = false);
//                             widget.onLogout();
//                           },
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'dart:convert';
import 'dart:html' as html;
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'constants/api_constants.dart';
import 'admin_login_page.dart';
import 'patient_reg.dart';
// Import all pages the sidebar needs
import 'admin_dashboard.dart';
import 'appointment_page.dart';
import 'staff_page.dart';
import 'inventory_page.dart';
import 'billing_page.dart';

const String _BaseUrl = 'https://heathos-api.onrender.com';

// ADDED: Constants needed for sidebar - copied from admin_dashboard.dart
const _kTeal = Color(0xFF0D7B6B);
const _kTealLight = Color(0xFF1A9E8A);
const _kTealDark = Color(0xFF095F54);
const _kTealAccent = Color(0xFF4FC3B0);
const _kWhite = Color(0xFFFFFFFF);
const _kTextDark = Color(0xFF1A2E2C);
const _kTextGrey = Color(0xFF7A9490);

// ADDED: Nav index constants for sidebar
const int _kNavOverview = 0;
const int _kNavPatient = 1;
const int _kNavAppointment = 2;
const int _kNavStaff = 3;
const int _kNavInventory = 4;
const int _kNavBillings = 5;

class PatientListPage extends StatefulWidget {
  final bool isAdminView;
  const PatientListPage({super.key, this.isAdminView = false});

  @override
  State<PatientListPage> createState() => _PatientListPageState();
}

class _PatientListPageState extends State<PatientListPage> {
  List patients = [];
  bool isLoading = true;
  String _searchQuery = '';
  Uint8List? _topBarProfileImageBytes;
  String _userRole = 'RECEPTIONIST';

  // Hide Add button for admin
  bool get _canAddPatient =>
      _userRole.toUpperCase() == 'RECEPTIONIST' && !widget.isAdminView;

  List get _filteredPatients {
    if (_searchQuery.trim().isEmpty) return patients;
    final q = _searchQuery.toLowerCase();
    return patients.where((p) {
      return (p['fullName'] ?? '').toLowerCase().contains(q) ||
          (p['phone'] ?? '').toLowerCase().contains(q) ||
          (p['email'] ?? '').toLowerCase().contains(q) ||
          (p['id'] ?? '').toString().contains(q);
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    _loadUserRole();
    fetchPatients();
  }

  void _loadUserRole() {
    _userRole = html.window.localStorage['role'] ?? 'RECEPTIONIST';
  }

  void _logout() {
    html.window.localStorage.clear(); // Clear token on logout
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const AdminLoginPage()),
      (route) => false,
    );
  }

  // ───────── FETCH - BULLETPROOF VERSION ─────────
  Future<void> fetchPatients() async {
    if (!mounted) return;
    setState(() => isLoading = true);

    try {
      final token = html.window.localStorage['token'] ?? '';

      if (token.isEmpty) {
        showError('No token found. Please log in again.');
        _logout();
        return;
      }

      final response = await http.get(
        Uri.parse('$_BaseUrl/api/patients'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      // DEBUG: Print what we actually got
      debugPrint('Status: ${response.statusCode}');
      debugPrint('Body: ${response.body}');

      // FIX 1: Check status BEFORE decoding
      if (response.statusCode == 401) {
        showError('Session expired. Please log in again.');
        _logout();
        return;
      }

      if (response.statusCode == 403) {
        showError('You do not have permission to view patients.');
        return;
      }

      // FIX 2: Only decode if body exists and looks like JSON
      if (response.body.isEmpty) {
        showError(
          'Server returned empty response. Status: ${response.statusCode}',
        );
        return;
      }

      if (!response.body.trim().startsWith('{') &&
          !response.body.trim().startsWith('[')) {
        showError(
          'Server returned HTML/text instead of JSON. Backend may be down.',
        );
        return;
      }

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        if (!mounted) return;
        setState(() {
          patients = data['data'] is List ? data['data'] : [];
        });
      } else {
        showError(data['message'] ?? 'Failed to fetch patients');
      }
    } catch (e) {
      if (e is FormatException) {
        showError('Invalid response from server. Check backend logs.');
      } else {
        showError('Network error: $e');
      }
    } finally {
      if (!mounted) return;
      setState(() => isLoading = false);
    }
  }

  // ───────── DELETE - BULLETPROOF VERSION ─────────
  Future<void> deletePatient(String id) async {
    try {
      final token = html.window.localStorage['token'] ?? '';

      final response = await http.delete(
        Uri.parse('$_BaseUrl/api/patients/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 401) {
        showError('Session expired. Please log in again.');
        _logout();
        return;
      }

      if (response.body.isEmpty) {
        showError('Delete failed: empty server response');
        return;
      }

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Patient deleted')));
        fetchPatients();
      } else {
        showError(data['message'] ?? 'Delete failed');
      }
    } catch (e) {
      if (e is FormatException) {
        showError('Server returned invalid data');
      } else {
        showError('Error: $e');
      }
    }
  }

  // ───────── UPDATE - BULLETPROOF VERSION ─────────
  Future<void> updatePatient(String id, Map body) async {
    try {
      final token = html.window.localStorage['token'] ?? '';

      final response = await http.put(
        Uri.parse('$_BaseUrl/api/patients/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        if (!mounted) return;
        Navigator.pop(context);
        fetchPatients();
      } else {
        String errorMsg = 'Update failed';
        if (response.body.isNotEmpty) {
          try {
            final data = jsonDecode(response.body);
            errorMsg = data['message'] ?? errorMsg;
          } catch (_) {}
        }
        if (response.statusCode == 401) {
          showError('Session expired. Please log in again.');
          _logout();
        } else {
          showError(errorMsg);
        }
      }
    } catch (e) {
      showError('Error: $e');
    }
  }

  // ───────── EDIT DIALOG ─────────
  void showEditDialog(Map p) {
    final firstName = TextEditingController(text: p['firstName']);
    final surname = TextEditingController(text: p['surname']);
    final phone = TextEditingController(text: p['phone']);
    final address = TextEditingController(text: p['address']);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Edit Patient'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: firstName,
              decoration: const InputDecoration(labelText: 'First Name'),
            ),
            TextField(
              controller: surname,
              decoration: const InputDecoration(labelText: 'Surname'),
            ),
            TextField(
              controller: phone,
              decoration: const InputDecoration(labelText: 'Phone'),
            ),
            TextField(
              controller: address,
              decoration: const InputDecoration(labelText: 'Address'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0E8A73),
            ),
            onPressed: () {
              updatePatient(p['id'].toString(), {
                "firstName": firstName.text,
                "surname": surname.text,
                "phone": phone.text,
                "address": address.text,
              });
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void confirmDelete(String id) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Patient?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(context);
              deletePatient(id);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));
  }

  // Navigate to registration and refresh on return
  Future<void> _navigateToAddPatient() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const PatientRegistrationPage()),
    );
    fetchPatients(); // Refresh list after returning
  }

  // ───────── UI ─────────
  @override
  Widget build(BuildContext context) {
    const teal = Color(0xFF0E8A73);
    const lightTeal = Color(0xFFE6F5F2);

    Widget mainContent = Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          _PatientTopBar(
            profileImageBytes: _topBarProfileImageBytes,
            onProfileImageChanged: (img) =>
                setState(() => _topBarProfileImageBytes = img),
            onLogout: _logout,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'List of Patients',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w700,
                              color: teal,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'View and manage patient records, appointments, and history in one\nplace.',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          SizedBox(
                            width: 260,
                            height: 44,
                            child: TextField(
                              onChanged: (v) =>
                                  setState(() => _searchQuery = v),
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFF0D2B27),
                              ),
                              decoration: InputDecoration(
                                hintText: 'Search patients…',
                                hintStyle: const TextStyle(
                                  color: Color(0xFF607C79),
                                  fontSize: 13,
                                ),
                                prefixIcon: const Icon(
                                  Icons.search_rounded,
                                  color: Color(0xFF607C79),
                                  size: 20,
                                ),
                                filled: true,
                                fillColor: Colors.white,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 0,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(24),
                                  borderSide: const BorderSide(
                                    color: Color(0xFFCCE8E5),
                                    width: 1.4,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(24),
                                  borderSide: const BorderSide(
                                    color: teal,
                                    width: 2,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          if (_canAddPatient) ...[
                            const SizedBox(width: 12),
                            ElevatedButton.icon(
                              onPressed: _navigateToAddPatient,
                              icon: const Icon(Icons.add, size: 18),
                              label: const Text('Add Patient'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: teal,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                elevation: 0,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Table
                  Expanded(
                    child: isLoading
                        ? const Center(
                            child: CircularProgressIndicator(color: teal),
                          )
                        : Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: Column(
                              children: [
                                // Table Header
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 16,
                                  ),
                                  decoration: const BoxDecoration(
                                    color: lightTeal,
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(8),
                                      topRight: Radius.circular(8),
                                    ),
                                  ),
                                  child: const Row(
                                    children: [
                                      Expanded(
                                        flex: 1,
                                        child: Text(
                                          'Patient ID',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            color: teal,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 3,
                                        child: Text(
                                          'Name',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            color: teal,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: Text(
                                          'Gender',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            color: teal,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: Text(
                                          'Phone Number',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            color: teal,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: Text(
                                          'Address',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            color: teal,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 1,
                                        child: Text(
                                          'Action',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            color: teal,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Table Body
                                Expanded(
                                  child: patients.isEmpty
                                      ? const Center(
                                          child: Padding(
                                            padding: EdgeInsets.all(32.0),
                                            child: Text(
                                              'Awaiting Patient',
                                              style: TextStyle(
                                                fontSize: 16,
                                                color: Colors.grey,
                                              ),
                                            ),
                                          ),
                                        )
                                      : _filteredPatients.isEmpty
                                      ? const Center(
                                          child: Padding(
                                            padding: EdgeInsets.all(32.0),
                                            child: Text(
                                              'No patients match your search.',
                                              style: TextStyle(
                                                fontSize: 16,
                                                color: Colors.grey,
                                              ),
                                            ),
                                          ),
                                        )
                                      : ListView.separated(
                                          itemCount: _filteredPatients.length,
                                          separatorBuilder: (_, __) => Divider(
                                            height: 1,
                                            color: Colors.grey.shade200,
                                          ),
                                          itemBuilder: (context, i) {
                                            final p = _filteredPatients[i];
                                            return Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 16,
                                                    vertical: 12,
                                                  ),
                                              child: Row(
                                                children: [
                                                  Expanded(
                                                    flex: 1,
                                                    child: Text(
                                                      '${p['id'] ?? i + 1}',
                                                    ),
                                                  ),
                                                  Expanded(
                                                    flex: 3,
                                                    child: Row(
                                                      children: [
                                                        CircleAvatar(
                                                          radius: 16,
                                                          backgroundColor:
                                                              lightTeal,
                                                          child: const Icon(
                                                            Icons.person,
                                                            size: 18,
                                                            color: teal,
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                          width: 12,
                                                        ),
                                                        Text(
                                                          p['fullName'] ??
                                                              'N/A',
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  Expanded(
                                                    flex: 2,
                                                    child: Text(
                                                      p['gender'] ?? 'N/A',
                                                    ),
                                                  ),
                                                  Expanded(
                                                    flex: 2,
                                                    child: Text(
                                                      p['phone'] ?? '',
                                                    ),
                                                  ),
                                                  Expanded(
                                                    flex: 2,
                                                    child: Text(
                                                      p['address'] ?? 'N/A',
                                                    ),
                                                  ),
                                                  Expanded(
                                                    flex: 1,
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        IconButton(
                                                          icon: const Icon(
                                                            Icons.edit,
                                                            color: teal,
                                                            size: 20,
                                                          ),
                                                          onPressed: () =>
                                                              showEditDialog(p),
                                                          padding:
                                                              EdgeInsets.zero,
                                                          constraints:
                                                              const BoxConstraints(),
                                                        ),
                                                        const SizedBox(
                                                          width: 8,
                                                        ),
                                                        IconButton(
                                                          icon: const Icon(
                                                            Icons
                                                                .delete_outline,
                                                            color: Colors.red,
                                                            size: 20,
                                                          ),
                                                          onPressed: () =>
                                                              confirmDelete(
                                                                p['id']
                                                                    .toString(),
                                                              ),
                                                          padding:
                                                              EdgeInsets.zero,
                                                          constraints:
                                                              const BoxConstraints(),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            );
                                          },
                                        ),
                                ),
                              ],
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );

    if (widget.isAdminView) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Row(
          children: [
            const _AdminSidebar(),
            Expanded(child: mainContent),
          ],
        ),
      );
    }
    return mainContent;
  }
}

// ───────── SIDEBAR + TOPBAR CODE UNCHANGED ─────────
// ADDED: Standalone sidebar with all functionality
class _AdminSidebar extends StatefulWidget {
  const _AdminSidebar();

  @override
  State<_AdminSidebar> createState() => _AdminSidebarState();
}

class _AdminSidebarState extends State<_AdminSidebar> {
  int _selectedIndex = _kNavPatient;

  final List<_NavItemData> _navItems = const [
    _NavItemData(
      icon: Icons.dashboard_rounded,
      label: 'Overview',
      index: _kNavOverview,
    ),
    _NavItemData(
      icon: Icons.personal_injury_rounded,
      label: 'Patient',
      index: _kNavPatient,
    ),
    _NavItemData(
      icon: Icons.event_note_rounded,
      label: 'Appointment',
      index: _kNavAppointment,
    ),
    _NavItemData(icon: Icons.groups_rounded, label: 'Staff', index: _kNavStaff),
    _NavItemData(
      icon: Icons.inventory_2_rounded,
      label: 'Inventory',
      index: _kNavInventory,
    ),
    _NavItemData(
      icon: Icons.receipt_long_rounded,
      label: 'Billings',
      index: _kNavBillings,
    ),
  ];

  void _onNavItemSelected(int index) {
    setState(() => _selectedIndex = index);

    switch (index) {
      case _kNavOverview:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const AdminDashboard()),
        );
        break;
      case _kNavPatient:
        break;
      case _kNavAppointment:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => AppointmentPage()),
        );
        break;
      case _kNavStaff:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const StaffPage()),
        );
        break;
      case _kNavInventory:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => InventoryPage()),
        );
        break;
      // case _kNavBillings:
      // Navigator.pushReplacement(
      // context,
      // MaterialPageRoute(builder: (_) => const BillingPage()),
      // );
      // break;
    }
  }

  void _logout() {
    html.window.localStorage.clear();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const AdminLoginPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 240,
      height: double.infinity,
      color: _kTeal,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  child: Image.asset(
                    'assets/images/Group.png',
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(width: 10),
                const Text(
                  'Heathos',
                  style: TextStyle(
                    color: _kWhite,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: _navItems.length,
              itemBuilder: (_, i) => _SidebarItemWidget(
                icon: _navItems[i].icon,
                label: _navItems[i].label,
                isSelected: _selectedIndex == _navItems[i].index,
                onTap: () => _onNavItemSelected(_navItems[i].index),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
            child: InkWell(
              onTap: _logout,
              borderRadius: BorderRadius.circular(10),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                child: Row(
                  children: const [
                    Text(
                      'Logout',
                      style: TextStyle(
                        color: _kWhite,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_forward_rounded, color: _kWhite, size: 18),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItemData {
  final IconData icon;
  final String label;
  final int index;
  const _NavItemData({
    required this.icon,
    required this.label,
    required this.index,
  });
}

class _SidebarItemWidget extends StatefulWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _SidebarItemWidget({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_SidebarItemWidget> createState() => _SidebarItemWidgetState();
}

class _SidebarItemWidgetState extends State<_SidebarItemWidget> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovering = true),
        onExit: (_) => setState(() => _hovering = false),
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(10),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
            decoration: BoxDecoration(
              color: widget.isSelected
                  ? _kWhite.withOpacity(0.20)
                  : _hovering
                  ? _kWhite.withOpacity(0.10)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
              border: widget.isSelected
                  ? Border.all(color: _kWhite.withOpacity(0.3), width: 1)
                  : null,
            ),
            child: Row(
              children: [
                Icon(widget.icon, color: _kWhite, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.label,
                    style: TextStyle(
                      color: _kWhite,
                      fontSize: 14,
                      fontWeight: widget.isSelected
                          ? FontWeight.w700
                          : FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Patient Dashboard TopBar
// ─────────────────────────────────────────────────────────────────────────────

class _PatientTopBar extends StatefulWidget {
  final Uint8List? profileImageBytes;
  final ValueChanged<Uint8List?> onProfileImageChanged;
  final VoidCallback onLogout;

  const _PatientTopBar({
    required this.profileImageBytes,
    required this.onProfileImageChanged,
    required this.onLogout,
  });

  @override
  State<_PatientTopBar> createState() => _PatientTopBarState();
}

class _PatientTopBarState extends State<_PatientTopBar> {
  static const _teal = Color(0xFF0E8A73);
  static const _tealLight = Color(0xFFE6F5F2);

  String _userName = 'User';
  String _userRole = 'Admin';
  bool _showMenu = false;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  void _loadUserInfo() {
    final role = html.window.localStorage['role'] ?? 'ADMIN';
    final name =
        html.window.localStorage['userName'] ??
        html.window.localStorage['fullName'] ??
        html.window.localStorage['email'] ??
        'User';
    setState(() {
      _userRole = _formatRole(role);
      _userName = name;
    });
  }

  String _formatRole(String role) {
    switch (role.toUpperCase()) {
      case 'ADMIN':
        return 'Admin';
      case 'RECEPTIONIST':
        return 'Receptionist';
      default:
        return role[0].toUpperCase() + role.substring(1).toLowerCase();
    }
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
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200, width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // ── Logo + title ──
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: _tealLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.local_hospital_rounded,
                  color: _teal,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'Heathos HMS',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: _teal,
                ),
              ),
            ],
          ),

          // ── Profile area ──
          Row(
            children: [
              // Avatar + dropdown
              GestureDetector(
                onTap: () => setState(() => _showMenu = !_showMenu),
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: _tealLight,
                      backgroundImage: widget.profileImageBytes != null
                          ? MemoryImage(widget.profileImageBytes!)
                          : null,
                      child: widget.profileImageBytes == null
                          ? const Icon(Icons.person, color: _teal, size: 20)
                          : null,
                    ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(color: _teal, width: 1.2),
                        ),
                        child: const Icon(
                          Icons.keyboard_arrow_down_rounded,
                          size: 10,
                          color: _teal,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 10),

              // CHANGED: Role text - now shows role in small text
              Text(
                _userRole,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF607C79),
                ),
              ),
              const SizedBox(width: 8),

              // CHANGED: Name badge - Now shows userName instead of role
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: _tealLight,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _userName,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _teal,
                  ),
                ),
              ),

              // Dropdown menu
              if (_showMenu)
                Material(
                  elevation: 8,
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    width: 180,
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ListTile(
                          dense: true,
                          leading: const Icon(
                            Icons.camera_alt_outlined,
                            color: _teal,
                            size: 18,
                          ),
                          title: const Text(
                            'Upload Photo',
                            style: TextStyle(fontSize: 13),
                          ),
                          onTap: () {
                            setState(() => _showMenu = false);
                            _pickProfileImage();
                          },
                        ),
                        const Divider(height: 1),
                        ListTile(
                          dense: true,
                          leading: const Icon(
                            Icons.logout_rounded,
                            color: Colors.red,
                            size: 18,
                          ),
                          title: const Text(
                            'Logout',
                            style: TextStyle(fontSize: 13, color: Colors.red),
                          ),
                          onTap: () {
                            setState(() => _showMenu = false);
                            widget.onLogout();
                          },
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

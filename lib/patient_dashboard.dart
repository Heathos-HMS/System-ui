// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;

// import 'patient_reg.dart';

// const String baseUrl = 'https://heathos-api.onrender.com';

// class PatientListPage extends StatefulWidget {
//   const PatientListPage({super.key});

//   @override
//   State<PatientListPage> createState() => _PatientListPageState();
// }

// class _PatientListPageState extends State<PatientListPage> {
//   List patients = [];
//   bool isLoading = true;

//   @override
//   void initState() {
//     super.initState();
//     fetchPatients();
//   }

//   // ───────── FETCH ─────────
//   Future<void> fetchPatients() async {
//     setState(() => isLoading = true);

//     try {
//       final response = await http.get(
//         Uri.parse('$baseUrl/api/patients'),
//       );

//       final data = jsonDecode(response.body);

//       if (response.statusCode == 200) {
//         setState(() {
//           patients = data['data'] ?? [];
//         });
//       } else {
//         showError(data['message'] ?? 'Failed to fetch patients');
//       }
//     } catch (e) {
//       showError('Error: $e');
//     }

//     setState(() => isLoading = false);
//   }

//   // ───────── DELETE ─────────
//   Future<void> deletePatient(String id) async {
//     try {
//       final response = await http.delete(
//         Uri.parse('$baseUrl/api/patients/$id'),
//       );

//       final data = jsonDecode(response.body);

//       if (response.statusCode == 200) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Patient deleted')),
//         );
//         fetchPatients();
//       } else {
//         showError(data['message'] ?? 'Delete failed');
//       }
//     } catch (e) {
//       showError('Error: $e');
//     }
//   }

//   // ───────── UPDATE ─────────
//   Future<void> updatePatient(String id, Map body) async {
//     try {
//       final response = await http.put(
//         Uri.parse('$baseUrl/api/patients/$id'),
//         headers: {'Content-Type': 'application/json'},
//         body: jsonEncode(body),
//       );

//       if (response.statusCode == 200) {
//         Navigator.pop(context);
//         fetchPatients();
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
//             TextField(controller: firstName),
//             TextField(controller: surname),
//             TextField(controller: phone),
//             TextField(controller: address),
//           ],
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('Cancel'),
//           ),
//           ElevatedButton(
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
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text(msg), backgroundColor: Colors.red),
//     );
//   }

//   // ───────── UI ─────────
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Patients'),
//         backgroundColor: Colors.teal,
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.refresh),
//             onPressed: fetchPatients,
//           )
//         ],
//       ),
//       body: isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : patients.isEmpty
//               ? const Center(child: Text('No patients found'))
//               : ListView.builder(
//                   itemCount: patients.length,
//                   itemBuilder: (context, i) {
//                     final p = patients[i];

//                     return Card(
//                       child: ListTile(
//                         title: Text('${p['firstName']} ${p['surname']}'),
//                         subtitle: Text(p['phone'] ?? ''),
//                         trailing: Row(
//                           mainAxisSize: MainAxisSize.min,
//                           children: [
//                             IconButton(
//                               icon: const Icon(Icons.edit),
//                               onPressed: () => showEditDialog(p),
//                             ),
//                             IconButton(
//                               icon: const Icon(Icons.delete, color: Colors.red),
//                               onPressed: () =>
//                                   confirmDelete(p['id'].toString()),
//                             ),
//                           ],
//                         ),
//                       ),
//                     );
//                   },
//                 ),
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

const String baseUrl = 'https://heathos-api.onrender.com';

class PatientListPage extends StatefulWidget {
  const PatientListPage({super.key});

  @override
  State<PatientListPage> createState() => _PatientListPageState();
}

class _PatientListPageState extends State<PatientListPage> {
  List patients = [];
  bool isLoading = true;
  String _searchQuery = '';
  Uint8List? _topBarProfileImageBytes;

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
    fetchPatients();
  }

  void _logout() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const AdminLoginPage()),
      (route) => false,
    );
  }

  // ───────── FETCH ─────────
  Future<void> fetchPatients() async {
    if (!mounted) return;
    setState(() => isLoading = true);

    try {
      final response = await http.get(Uri.parse('$baseUrl/api/patients'));

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        if (!mounted) return;
        setState(() {
          patients = data['data'] ?? [];
        });
      } else {
        showError(data['message'] ?? 'Failed to fetch patients');
      }
    } catch (e) {
      showError('Error: $e');
    }

    if (!mounted) return;
    setState(() => isLoading = false);
  }

  // ───────── DELETE ─────────
  Future<void> deletePatient(String id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/api/patients/$id'),
      );

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
      showError('Error: $e');
    }
  }

  // ───────── UPDATE ─────────
  Future<void> updatePatient(String id, Map body) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/api/patients/$id'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        if (!mounted) return;
        Navigator.pop(context);
        fetchPatients();
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

    return Scaffold(
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
      debugPrint('File pick error: \$e');
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

              // Name
              Text(
                _userName,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF0D2B27),
                ),
              ),
              const SizedBox(width: 8),

              // Role badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: _tealLight,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _userRole,
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

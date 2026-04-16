import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

import 'edit_patient_records.dart';
import 'delete_patient.dart';
import 'package:http/http.dart' as http;
import 'patient_dashboard.dart';

// COLORS (same as dashboard)
const kTeal = Color(0xFF0D7B6B);
const kTealLight = Color(0xFF1A9E8A);
const kTealDark = Color(0xFF095F54);
const kTealAccent = Color(0xFF4FC3B0);
const kBackground = Color(0xFFF0F4F4);
const kWhite = Color(0xFFFFFFFF);
const kTextDark = Color(0xFF1A2E2C);
const kTextGrey = Color(0xFF7A9490);

// ───────────────── PATIENT LIST PAGE ─────────────────
class PatientListPage extends StatefulWidget {
  const PatientListPage({super.key});

  @override
  State<PatientListPage> createState() => _PatientListPageState();
}

class _PatientListPageState extends State<PatientListPage> {
  int _selectedIndex = 1; // patient tab active
  Uint8List? _profileImageBytes;

  final List<_NavItem> _navItems = const [
    _NavItem(icon: Icons.dashboard_rounded, label: 'Overview'),
    _NavItem(icon: Icons.personal_injury_rounded, label: 'Patient'),
    _NavItem(icon: Icons.medical_services_rounded, label: 'Doctor'),
    _NavItem(icon: Icons.health_and_safety_rounded, label: 'Nurse'),
  ];

  void _onProfileImageChanged(Uint8List bytes) {
    setState(() => _profileImageBytes = bytes);
  }

  void _logout() {}
  void _goToProfile() {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      body: Row(
        children: [
          _Sidebar(
            navItems: _navItems,
            selectedIndex: _selectedIndex,
            onItemSelected: (i) => setState(() => _selectedIndex = i),
            onLogout: _logout,
          ),
          Expanded(
            child: Column(
              children: [
                _TopBar(
                  profileImageBytes: _profileImageBytes,
                  onProfileImageChanged: _onProfileImageChanged,
                  onLogout: _logout,
                  onGoToProfile: _goToProfile,
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Container(
                      decoration: BoxDecoration(
                        color: kWhite,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: ListView(
                        padding: const EdgeInsets.all(16),
                        children: [
                          _buildRow(context, 'John Doe', 'Male'),
                          _buildRow(context, 'Jane Smith', 'Female'),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRow(BuildContext context, String name, String gender) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: ListTile(
        title: Text(name),
        subtitle: Text(gender),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => EditPatientRecords()),
                );
              },
            ),
            //           IconButton(
            // icon: Icon(Icons.delete, color: Colors.red),
            // onPressed: () async {
            //   final confirm = await showDialog<bool>(context: context, builder: (_) => AlertDialog(
            //     title: Text('Delete User'),
            //     content: Text('Are you sure?'),
            //     actions: [
            //       TextButton(onPressed: ()=>Navigator.pop(context, false), child: Text('Cancel')),
            //       TextButton(onPressed: ()=>Navigator.pop(context, true), child: Text('Delete')),
            //     ],
            //   ));
            //     if (confirm == true) {
            //       await http.delete(Uri.parse('$_baseUrl/users/${user.id}'));
            //       setState(() => users.remove(user));
            //     }
            //   },
            // )
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => DeletePatient()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ───────────────── SHARED SIDEBAR ─────────────────
class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem({required this.icon, required this.label});
}

class _Sidebar extends StatelessWidget {
  final List<_NavItem> navItems;
  final int selectedIndex;
  final ValueChanged<int> onItemSelected;
  final VoidCallback onLogout;

  const _Sidebar({
    required this.navItems,
    required this.selectedIndex,
    required this.onItemSelected,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 240,
      color: kTeal,
      child: Column(
        children: [
          const SizedBox(height: 30),
          const Text('Heathos', style: TextStyle(color: kWhite, fontSize: 22)),
          Expanded(
            child: ListView.builder(
              itemCount: navItems.length,
              itemBuilder: (context, index) => ListTile(
                leading: Icon(navItems[index].icon, color: kWhite),
                title: Text(
                  navItems[index].label,
                  style: const TextStyle(color: kWhite),
                ),
                selected: selectedIndex == index,
                onTap: () => onItemSelected(index),
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.logout, color: kWhite),
            title: const Text('Logout', style: TextStyle(color: kWhite)),
            onTap: onLogout,
          ),
        ],
      ),
    );
  }
}

// ───────────────── SHARED TOP BAR ─────────────────
class _TopBar extends StatefulWidget {
  final Uint8List? profileImageBytes;
  final ValueChanged<Uint8List> onProfileImageChanged;
  final VoidCallback onLogout;
  final VoidCallback onGoToProfile;

  const _TopBar({
    required this.profileImageBytes,
    required this.onProfileImageChanged,
    required this.onLogout,
    required this.onGoToProfile,
  });

  @override
  State<_TopBar> createState() => _TopBarState();
}

class _TopBarState extends State<_TopBar> {
  Future<void> _pickProfileImage() async {
    final result = await FilePicker.pickFiles(
      type: FileType.image,
      withData: true,
    );
    if (result != null && result.files.first.bytes != null) {
      widget.onProfileImageChanged(result.files.first.bytes!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: kWhite,
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
      child: Row(
        children: [
          const Text(
            'Welcome Back, ADMIN',
            style: TextStyle(fontSize: 16, color: kTextDark),
          ),
          const Spacer(),
          GestureDetector(
            onTap: _pickProfileImage,
            child: CircleAvatar(
              backgroundColor: kTealAccent,
              backgroundImage: widget.profileImageBytes != null
                  ? MemoryImage(widget.profileImageBytes!)
                  : null,
              child: widget.profileImageBytes == null
                  ? const Icon(Icons.person, color: kWhite)
                  : null,
            ),
          ),
          const SizedBox(width: 10),
          const Text('Admin_Name'),
        ],
      ),
    );
  }
}

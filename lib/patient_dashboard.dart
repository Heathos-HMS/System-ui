// import 'package:flutter/material.dart';

// class PatientDashboard extends StatefulWidget {
//   @override
//   _PatientDashboardState createState() => _PatientDashboardState();
// }

// class _PatientDashboardState extends State<PatientDashboard> {
//   List<Patient> patients = [
//     Patient(1, 'Nana Owusu Ofori', 'Male', '024 567 4567', '02/04/2026'),
//     Patient(2, 'Adwoa Agyeman', 'Female', '055 234 5678', '04/04/2026'),
//     Patient(3, 'Kwaku Boateng', 'Male', '020 345 6789', '06/04/2026'),
//     Patient(4, 'Efua Boateng', 'Female', '027 456 7890', '08/04/2026'),
//     Patient(5, 'Kojo Agyeman', 'Male', '026 567 8901', '10/04/2026'),
//     Patient(6, 'Abena Owusu', 'Female', '054 678 9012', '12/04/2026'),
//     Patient(7, 'Kwasi Adu', 'Male', '059 789 0123', '14/04/2026'),
//     Patient(8, 'Yaa Appiah', 'Female', '059 432 1567', '16/04/2026'),
//     Patient(9, 'Kwame Mensah', 'Male', '054 210 9876', '18/04/2026'),
//     Patient(10, 'Ama Serwaa', 'Female', '026 789 6593', '20/04/2026'),
//     Patient(11, 'Yaw Appiah', 'Male', '027 345 2198', '22/04/2026'),
//     Patient(12, 'Afia Mensah', 'Female', '020 678 4321', '24/04/2026'),
//     Patient(14, 'Kofi Asante', 'Male', '055 912 3456', '28/04/2026'),
//     Patient(15, 'Audrey Cobbinah', 'Female', '024 801 2345', '30/04/2026'),
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Row(
//         children: [
//           // Sidebar
//           Container(
//             width: 250,
//             color: Color(0xFF2E7D32),
//             child: Column(
//               children: [
//                 SizedBox(height: 40),
//                 Text(
//                   'Heathos',
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontSize: 24,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 SizedBox(height: 40),
//                 _sidebarItem('Overview', Icons.dashboard, true),
//                 _sidebarItem('Patient', Icons.person),
//                 _sidebarItem('Doctor', Icons.medical_services),
//                 Spacer(),
//                 _sidebarItem('Logout', Icons.logout),
//                 SizedBox(height: 20),
//               ],
//             ),
//           ),
//           // Main content
//           Expanded(
//             child: Padding(
//               padding: const EdgeInsets.all(20.0),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     'List of Patients',
//                     style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
//                   ),
//                   SizedBox(height: 10),
//                   Text(
//                     'View and manage patient records, appointments, and history in one place.',
//                   ),
//                   SizedBox(height: 20),
//                   Row(
//                     children: [
//                       Expanded(
//                         child: TextField(
//                           decoration: InputDecoration(
//                             hintText: 'Search',
//                             prefixIcon: Icon(Icons.search),
//                             border: OutlineInputBorder(),
//                           ),
//                         ),
//                       ),
//                       SizedBox(width: 10),
//                       ElevatedButton.icon(
//                         onPressed: () {},
//                         icon: Icon(Icons.sort),
//                         label: Text('Sort'),
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: Color(0xFF2E7D32),
//                         ),
//                       ),
//                       SizedBox(width: 10),
//                       ElevatedButton.icon(
//                         onPressed: () {},
//                         icon: Icon(Icons.add),
//                         label: Text('Add Patient'),
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: Color(0xFF2E7D32),
//                         ),
//                       ),
//                     ],
//                   ),
//                   SizedBox(height: 20),
//                   Expanded(
//                     child: SingleChildScrollView(
//                       scrollDirection: Axis.vertical,
//                       child: DataTable(
//                         columns: [
//                           DataColumn(label: Text('Patient ID')),
//                           DataColumn(label: Text('Name')),
//                           DataColumn(label: Text('Gender')),
//                           DataColumn(label: Text('Phone Number')),
//                           DataColumn(label: Text('Join Date')),
//                           DataColumn(label: Text('Action')),
//                         ],
//                         rows: patients
//                             .map(
//                               (patient) => DataRow(
//                                 cells: [
//                                   DataCell(Text(patient.id.toString())),
//                                   DataCell(Text(patient.name)),
//                                   DataCell(Text(patient.gender)),
//                                   DataCell(Text(patient.phone)),
//                                   DataCell(Text(patient.joinDate)),
//                                   DataCell(
//                                     Row(
//                                       children: [
//                                         Icon(Icons.edit, color: Colors.teal),
//                                         SizedBox(width: 10),
//                                         Icon(Icons.delete, color: Colors.red),
//                                       ],
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             )
//                             .toList(),
//                       ),
//                     ),
//                   ),
//                   SizedBox(height: 20),
//                   Row(
//                     children: [
//                       Text('Previous'),
//                       SizedBox(width: 10),
//                       _paginationButton('1'),
//                       _paginationButton('2', selected: true),
//                       _paginationButton('3'),
//                       SizedBox(width: 10),
//                       Text('Next'),
//                     ],
//                   ),
//                   SizedBox(height: 20),
//                   Center(
//                     child: Text(
//                       'Copyright © A2026. Designed by Group 5',
//                       style: TextStyle(color: Colors.grey),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _sidebarItem(String title, IconData icon, [bool selected = false]) {
//     return ListTile(
//       leading: Icon(icon, color: Colors.white),
//       title: Text(
//         title,
//         style: TextStyle(color: selected ? Colors.white : Colors.white70),
//       ),
//       tileColor: selected ? Colors.green[700] : null,
//     );
//   }

//   Widget _paginationButton(String text, {bool selected = false}) {
//     return Container(
//       margin: EdgeInsets.symmetric(horizontal: 5),
//       padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
//       decoration: BoxDecoration(
//         color: selected ? Color(0xFF2E7D32) : Colors.grey[200],
//         borderRadius: BorderRadius.circular(5),
//       ),
//       child: Text(
//         text,
//         style: TextStyle(color: selected ? Colors.white : Colors.black),
//       ),
//     );
//   }
// }

// class Patient {
//   final int id;
//   final String name;
//   final String gender;
//   final String phone;
//   final String joinDate;

//   Patient(this.id, this.name, this.gender, this.phone, this.joinDate);
// }


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
                )
              ],
            ),
          )
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
                title: Text(navItems[index].label, style: const TextStyle(color: kWhite)),
                selected: selectedIndex == index,
                onTap: () => onItemSelected(index),
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.logout, color: kWhite),
            title: const Text('Logout', style: TextStyle(color: kWhite)),
            onTap: onLogout,
          )
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
    final result = await FilePicker.pickFiles(type: FileType.image, withData: true);
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
          const Text('Welcome Back, ADMIN', style: TextStyle(fontSize: 16, color: kTextDark)),
          const Spacer(),
          GestureDetector(
            onTap: _pickProfileImage,
            child: CircleAvatar(
              backgroundColor: kTealAccent,
              backgroundImage: widget.profileImageBytes != null ? MemoryImage(widget.profileImageBytes!) : null,
              child: widget.profileImageBytes == null ? const Icon(Icons.person, color: kWhite) : null,
            ),
          ),
          const SizedBox(width: 10),
          const Text('Admin_Name')
        ],
      ),
    );
  }
}

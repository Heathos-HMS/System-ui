import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class AdminDashboard1 extends StatefulWidget {
  const AdminDashboard1({super.key});

  @override
  State<AdminDashboard1> createState() => _AdminDashboard1State();
}

class _AdminDashboard1State extends State<AdminDashboard1> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    OverviewScreen(),
    ProfileScreen(),
    AppointmentScreen(),
    PatientScreen(),
    DoctorScreen(),
    NurseScreen(),
    LabTechnicianScreen(),
    PharmacyScreen(),
    AdministrativeStaffScreen(),
    BillingsScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
          appBar: AppBar(
        title: Text('Heathos Admin'),
        actions: [TextButton(onPressed: () {}, child: Text('Admin'))],
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            _drawerItem(Icons.dashboard, 'Overview', 0),
            _drawerItem(Icons.person, 'Profile', 1),
            _drawerItem(Icons.calendar_today, 'Appointment', 2),
            _drawerItem(Icons.people, 'Patient', 3),
            _drawerItem(Icons.medical_services, 'Doctor', 4),
            _drawerItem(Icons.local_hospital_outlined, 'Nurse', 5),
            _drawerItem(Icons.science, 'Lab Technician', 6),
            _drawerItem(Icons.medication, 'Pharmacy', 7),
            _drawerItem(Icons.admin_panel_settings, 'Administrative Staff', 8),
            _drawerItem(Icons.payment, 'Billings', 9),
          ],
        ),
      ),
      body: Row(
        children: [
          Expanded(flex: 1, child: Container()),
          Expanded(flex: 5, child: _screens[_selectedIndex]),
        ],
      ),
    );
  }

  ListTile _drawerItem(IconData icon, String title, int index) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: () => _onItemTapped(index),
    );
  }
}

class OverviewScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 20),
        Text('Welcome Admin', style: TextStyle(fontSize: 24)),
        Text('Date: ${DateTime.now().toString().split(' ')[0]}'),
        SizedBox(height: 20),
        Wrap(
          children: [
            _statsCard(
              Icons.medical_services,
              '20 Available Doctors',
              Colors.teal,
            ),
            _statsCard(Icons.people, '200+ Patients', Colors.teal),
            _statsCard(Icons.person, '50 Visitors', Colors.teal),
            _statsCard(Icons.group, '200+ Medical Staff', Colors.teal),
          ],
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: LineChart(
              LineChartData(
                lineBarsData: [
                  LineChartBarData(
                    spots: [
                      FlSpot(0, 1),
                      FlSpot(1, 3),
                      FlSpot(2, 2),
                      FlSpot(3, 4),
                    ],
                    color: Colors.teal,
                  ),
                ],
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(),
                  bottomTitles: AxisTitles(),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _statsCard(IconData icon, String text, Color color) {
    return Card(
      color: color,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Icon(icon, size: 40, color: Colors.white),
            Text(text, style: TextStyle(color: Colors.white)),
          ],
        ),
      ),
    );
  }
}



// Dummy screens for other menu items
class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Center(child: Text('Profile Screen'));
}

class AppointmentScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      Center(child: Text('Appointment Screen'));
}

class PatientScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Center(child: Text('Patient Screen'));
}

class DoctorScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Center(child: Text('Doctor Screen'));
}

class NurseScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Center(child: Text('Nurse Screen'));
}

class LabTechnicianScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      Center(child: Text('Lab Technician Screen'));
}

class PharmacyScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Center(child: Text('Pharmacy Screen'));
}

class AdministrativeStaffScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      Center(child: Text('Administrative Staff Screen'));
}

class BillingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Center(child: Text('Billings Screen'));
}

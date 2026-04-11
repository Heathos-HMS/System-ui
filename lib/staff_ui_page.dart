import 'package:flutter/material.dart';
import 'patient_registration_page.dart';

class StaffUIPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('HEATHOS HMS')),
      body: GridView.count(
        crossAxisCount: 2,
        padding: EdgeInsets.all(20),
        children: [
          _buildCard(context, 'NEW PATIENT', Icons.add, () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => PatientRegistrationPage()));
          }),
          _buildCard(context, 'PATIENT FOLDER/RECORDS', Icons.folder, () {
            // Navigate to records page
          }),
          _buildCard(context, 'SCHEDULE APPOINTMENT', Icons.calendar_today, () {
            // Navigate to appointment page
          }),
          _buildCard(context, 'AVAILABLE DOCTOR', Icons.person, () {
            // Navigate to doctor page
          }),
        ],
      ),
    );
  }

  Widget _buildCard(BuildContext context, String title, IconData icon, VoidCallback onTap) {
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 40),
              Text(title),
            ],
          ),
        ),
      ),
    );
  }
}
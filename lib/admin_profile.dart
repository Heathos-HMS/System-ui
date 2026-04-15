import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class AdminProfilePage extends StatefulWidget {
  @override
  _AdminProfilePageState createState() => _AdminProfilePageState();
}

class _AdminProfilePageState extends State<AdminProfilePage> {
  File? _profileImage;
  final ImagePicker _picker = ImagePicker();
  String _searchQuery = '';

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _profileImage = File(image.path);
      });
    }
  }

  void _logout() {
    // Add logout logic here
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => SignInPage(),
      ), // Implement SignInPage
    );
  }

  void _search(String query) {
    setState(() {
      _searchQuery = query;
    });
    // Add search logic here
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Heathos'),
        actions: [
          Container(
            width: 300,
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search...',
                border: OutlineInputBorder(),
              ),
              onChanged: _search,
            ),
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'profile') {
                // Stay on the same page
              } else if (value == 'logout') {
                _logout();
              }
            },
            itemBuilder: (BuildContext context) {
              return ['profile', 'logout'].map((String choice) {
                return PopupMenuItem<String>(
                  value: choice,
                  child: Text(choice),
                );
              }).toList();
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              color: Colors.green,
              child: Text('ADMIN', style: TextStyle(color: Colors.white)),
            ),
          ),
          GestureDetector(
            onTap: _pickImage,
            child: CircleAvatar(
              backgroundImage: _profileImage != null
                  ? FileImage(_profileImage!)
                  : null,
              child: _profileImage == null ? Icon(Icons.person) : null,
            ),
          ),
          Text('Admin_Name'),
        ],
      ),
      body: Row(
        children: [
          // Sidebar
          Container(
            width: 250,
            color: Colors.teal,
            child: Column(
              children: [
                _sidebarItem(Icons.dashboard, 'Overview'),
                _sidebarItem(Icons.person, 'Patient'),
                _sidebarItem(Icons.medical_services, 'Doctor'),
                _sidebarItem(Icons.health_and_safety_rounded, 'Nurse'),
                Spacer(),
                _sidebarItem(Icons.logout, 'Logout', onTap: _logout),
              ],
            ),
          ),
          // Main content
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Personal Details', style: TextStyle(fontSize: 24)),
                  SizedBox(height: 20),
                  _profileForm(),
                  SizedBox(height: 20),
                  Text(
                    'Copyright © A2020. Designed by Group 5',
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sidebarItem(IconData icon, String title, {VoidCallback? onTap}) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(title, style: TextStyle(color: Colors.white)),
      onTap: onTap,
    );
  }

  Widget _profileForm() {
    return Column(
      children: [
        // Profile picture upload
        Row(
          children: [
            CircleAvatar(radius: 50),
            ElevatedButton.icon(
              onPressed: _pickImage,
              icon: Icon(Icons.upload),
              label: Text('Upload Profile Photo'),
            ),
          ],
        ),
        SizedBox(height: 20),
        // Form fields
        _textField('Staff ID', 'Enter user ID'),
        _textField('Staff Type', 'Administrator'),
        _textField('Staff First Name', 'Firstname'),
        _textField('Staff Middle Name', 'Middle Name'),
        _textField('Staff Last Name', 'Last Name'),
        _textField('Institutional Email', 'administrator@heathos.org'),
        _textField('Phone Number', '+233 ...'),
        SizedBox(height: 20),
        // Password section
        Text('Password', style: TextStyle(fontSize: 18)),
        _passwordField('Current Password'),
        _passwordField('New Password'),
        _passwordField('Confirm Password'),
        SizedBox(height: 20),
        ElevatedButton(onPressed: () {}, child: Text('Save')),
      ],
    );
  }

  Widget _textField(String label, String hint) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _passwordField(String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        obscureText: true,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
      ),
    );
  }
}

class SignInPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Text('Sign In Page')));
  }
}

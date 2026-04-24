import 'dart:convert';
import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

const String _BaseUrl = 'https://heathos-api.onrender.com';
const kTeal = Color(0xFF0D7B6B);
const kTealLight = Color(0xFFE6F5F2);
const kTextDark = Color(0xFF1A2E2C);
const kTextGrey = Color(0xFF7A9490);
const kWhite = Color(0xFFFFFFFF);

class ViewDoctorDetails extends StatefulWidget {
  final String doctorId; // ADDED: This fixes your error
  const ViewDoctorDetails({super.key, required this.doctorId});

  @override
  State<ViewDoctorDetails> createState() => _ViewDoctorDetailsState();
}

class _ViewDoctorDetailsState extends State<ViewDoctorDetails> {
  Map<String, dynamic>? doctor;
  bool isLoading = true;
  String? errorMsg;

  @override
  void initState() {
    super.initState();
    fetchDoctorDetails();
  }

  Future<void> fetchDoctorDetails() async {
    if (!mounted) return;
    setState(() {
      isLoading = true;
      errorMsg = null;
    });

    try {
      final token = html.window.localStorage['token'] ?? '';
      if (token.isEmpty) {
        setState(() {
          errorMsg = 'No token found. Please log in again.';
          isLoading = false;
        });
        return;
      }

      final response = await http.get(
        Uri.parse('$_BaseUrl/api/doctors/${widget.doctorId}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      debugPrint('Doctor details status: ${response.statusCode}');
      debugPrint('Doctor details body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (!mounted) return;
        setState(() {
          // Handle both {data: {...}} and direct {...} responses
          doctor = data['data'] ?? data;
          isLoading = false;
        });
      } else {
        final data = jsonDecode(response.body);
        setState(() {
          errorMsg = data['message'] ?? 'Failed to load doctor details';
          isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        errorMsg = 'Network error: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kWhite,
      appBar: AppBar(
        title: const Text('Doctor Details'),
        backgroundColor: kTeal,
        foregroundColor: kWhite,
        elevation: 0,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: kTeal))
          : errorMsg != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    errorMsg!,
                    style: const TextStyle(fontSize: 16, color: kTextGrey),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: fetchDoctorDetails,
                    style: ElevatedButton.styleFrom(backgroundColor: kTeal),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            )
          : doctor == null
          ? const Center(child: Text('Doctor not found'))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile Header
                  Center(
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 60,
                          backgroundColor: kTealLight,
                          backgroundImage:
                              doctor!['avatarUrl'] != null &&
                                  doctor!['avatarUrl'].toString().startsWith(
                                    'http',
                                  )
                              ? NetworkImage(doctor!['avatarUrl'])
                              : null,
                          child: doctor!['avatarUrl'] == null
                              ? const Icon(Icons.person, size: 60, color: kTeal)
                              : null,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          doctor!['fullName'] ?? 'Unknown',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: kTextDark,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: kTealLight,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            doctor!['specialty'] ?? 'General Practitioner',
                            style: const TextStyle(
                              fontSize: 14,
                              color: kTeal,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Details Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: kTealLight,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        _DetailRow(
                          icon: Icons.email_outlined,
                          label: 'Email',
                          value: doctor!['email'] ?? 'N/A',
                        ),
                        const Divider(height: 24),
                        _DetailRow(
                          icon: Icons.badge_outlined,
                          label: 'Doctor ID',
                          value: doctor!['userId'] ?? doctor!['id'] ?? 'N/A',
                        ),
                        const Divider(height: 24),
                        _DetailRow(
                          icon: Icons.work_outline,
                          label: 'Role',
                          value: doctor!['role'] ?? 'Doctor',
                        ),
                        const Divider(height: 24),
                        _DetailRow(
                          icon: Icons.calendar_today_outlined,
                          label: 'Joined',
                          value: _formatDate(doctor!['createdAt']),
                        ),
                        const Divider(height: 24),
                        _DetailRow(
                          icon: Icons.circle,
                          label: 'Status',
                          value: doctor!['active'] == true
                              ? 'Active'
                              : 'Inactive',
                          valueColor: doctor!['active'] == true
                              ? Colors.green
                              : Colors.red,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return 'N/A';
    try {
      final dt = DateTime.parse(dateStr);
      return '${dt.day}/${dt.month}/${dt.year}';
    } catch (_) {
      return dateStr;
    }
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: kTeal),
        const SizedBox(width: 12),
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: kTextGrey,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14,
              color: valueColor ?? kTextDark,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

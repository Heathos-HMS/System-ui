// import 'package:flutter/material.dart';
// import 'view_doctor_details.dart';

// // ─── COLORS (match your dashboard) ─────────────────────────────
// const kTeal = Color(0xFF0D7B6B);
// const kBackground = Color(0xFFF0F4F4);
// const kWhite = Color(0xFFFFFFFF);
// const kTextDark = Color(0xFF1A2E2C);
// const kTextGrey = Color(0xFF7A9490);

// // ─── MODEL ─────────────────────────────────────────────────────
// class Doctor {
//   final String name;
//   final String specialty;
//   final String image;

//   Doctor({required this.name, required this.specialty, required this.image});
// }

// // ─── MAIN PAGE ─────────────────────────────────────────────────
// class DoctorListPage extends StatelessWidget {
//   const DoctorListPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final doctors = [
//       Doctor(
//         name: "Dr. Daniel Osei",
//         specialty: "General Practitioner",
//         image: "assets/images/drjackline.png",
//       ),
//       Doctor(
//         name: "Dr. Jackline Sam",
//         specialty: "General Surgeon",
//         image: "assets/images/drsam.png",
//       ),
//       Doctor(
//         name: "Dr. Grace Dankwa",
//         specialty: "Gynecologist",
//         image: "assets/images/#004.png",
//       ),
//       Doctor(
//         name: "Dr. Joseph Kwofie",
//         specialty: "Pediatrician",
//         image: "assets/images/#003.png",
//       ),
//       Doctor(
//         name: "Dr. Patricia Quaye",
//         specialty: "Ophthalmologist",
//         image: "assets/images/#006.png",
//       ),
//       Doctor(
//         name: "Dr. Lord Glassmen",
//         specialty: "Radiologist",
//         image: "assets/images/#009.png",
//       ),
//     ];

//     return Container(
//       color: kBackground,
//       padding: const EdgeInsets.all(28),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // ── Header ──
//           Row(
//             children: [
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: const [
//                   Text(
//                     "List of Doctors",
//                     style: TextStyle(
//                       fontSize: 22,
//                       fontWeight: FontWeight.bold,
//                       color: kTextDark,
//                     ),
//                   ),
//                   SizedBox(height: 4),
//                   Text(
//                     "View and manage doctors and their availability",
//                     style: TextStyle(fontSize: 13, color: kTextGrey),
//                   ),
//                 ],
//               ),
//               const Spacer(),
//               ElevatedButton.icon(
//                 onPressed: () {},
//                 icon: const Icon(Icons.add, size: 18),
//                 label: const Text("Add Doctor"),
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: kTeal,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(20),
//                   ),
//                 ),
//               ),
//             ],
//           ),

//           const SizedBox(height: 24),

//           // ── Grid ──
//           Expanded(
//             child: GridView.builder(
//               itemCount: doctors.length,
//               gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                 crossAxisCount: 3,
//                 mainAxisSpacing: 20,
//                 crossAxisSpacing: 20,
//                 childAspectRatio: 0.85,
//               ),
//               itemBuilder: (context, index) {
//                 final doc = doctors[index];
//                 return _DoctorCard(doctor: doc);
//               },
//             ),
//           ),

//           const SizedBox(height: 10),

//           // ── Pagination (UI only) ──
//           Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: const [
//               Text("Previous", style: TextStyle(color: kTextGrey)),
//               SizedBox(width: 10),
//               _PageNumber(number: "1", active: true),
//               _PageNumber(number: "2"),
//               _PageNumber(number: "3"),
//               SizedBox(width: 10),
//               Text("Next", style: TextStyle(color: kTextGrey)),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }

// // ─── DOCTOR CARD ───────────────────────────────────────────────
// class _DoctorCard extends StatelessWidget {
//   final Doctor doctor;

//   const _DoctorCard({required this.doctor});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: BoxDecoration(
//         color: kTeal,
//         borderRadius: BorderRadius.circular(20),
//       ),
//       padding: const EdgeInsets.all(14),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Image
//           ClipRRect(
//             borderRadius: BorderRadius.circular(16),
//             child: Image.asset(
//               doctor.image,
//               height: 120,
//               width: double.infinity,
//               fit: BoxFit.cover,
//             ),
//           ),

//           const SizedBox(height: 12),

//           Text(
//             doctor.name,
//             style: const TextStyle(
//               color: kWhite,
//               fontSize: 15,
//               fontWeight: FontWeight.bold,
//             ),
//           ),

//           const SizedBox(height: 4),

//           Text(
//             doctor.specialty,
//             style: const TextStyle(color: Colors.white70, fontSize: 12),
//           ),

//           const Spacer(),

//           // ── View Details Button ──
//           TextButton(
//             onPressed: () {
//               // TODO: Navigate to Doctor Details Page
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(builder: (_) => const ViewDoctorDetails()),
//               );
//             },
//             style: TextButton.styleFrom(
//               backgroundColor: kWhite,
//               padding: const EdgeInsets.symmetric(horizontal: 12),
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(20),
//               ),
//             ),
//             child: const Text(
//               "View Details",
//               style: TextStyle(
//                 color: kTeal,
//                 fontSize: 12,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// // ─── PAGINATION ────────────────────────────────────────────────
// class _PageNumber extends StatelessWidget {
//   final String number;
//   final bool active;

//   const _PageNumber({required this.number, this.active = false});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       margin: const EdgeInsets.symmetric(horizontal: 4),
//       padding: const EdgeInsets.all(8),
//       decoration: BoxDecoration(
//         color: active ? kTeal : Colors.transparent,
//         borderRadius: BorderRadius.circular(8),
//       ),
//       child: Text(
//         number,
//         style: TextStyle(
//           color: active ? kWhite : kTextGrey,
//           fontWeight: FontWeight.w600,
//         ),
//       ),
//     );
//   }
// }







import 'dart:convert';
import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'view_doctor_details.dart';
import 'doctor_registration_form.dart'; // ADDED

// ─── COLORS (match your dashboard) ─────────────────────────────
const kTeal = Color(0xFF0D7B6B);
const kBackground = Color(0xFFF0F4F4);
const kWhite = Color(0xFFFFFFFF);
const kTextDark = Color(0xFF1A2E2C);
const kTextGrey = Color(0xFF7A9490);

const String _BaseUrl = 'https://heathos-api.onrender.com';

// ─── MODEL ─────────────────────────────────────────────────────
class Doctor {
  final String id;
  final String name;
  final String specialty;
  final String email;
  final String image;
  final bool active;

  Doctor({
    required this.id,
    required this.name,
    required this.specialty,
    required this.email,
    required this.image,
    required this.active,
  });

  factory Doctor.fromJson(Map<String, dynamic> json) => Doctor(
    id: json['userId'] ?? json['id'] ?? '',
    name: json['fullName'] ?? 'Unknown',
    specialty: json['specialty'] ?? 'General Practitioner',
    email: json['email'] ?? '',
    image:
        json['avatarUrl'] ?? json['image'] ?? 'assets/images/default_doc.png',
    active: json['active'] ?? true,
  );
}

// ─── MAIN PAGE ─────────────────────────────────────────────────
class DoctorListPage extends StatefulWidget {
  const DoctorListPage({super.key});

  @override
  State<DoctorListPage> createState() => _DoctorListPageState();
}

class _DoctorListPageState extends State<DoctorListPage> {
  List<Doctor> doctors = [];
  bool isLoading = true;
  String _userRole = 'RECEPTIONIST';

  bool get _canAddDoctor => _userRole.toUpperCase() == 'ADMIN';

  @override
  void initState() {
    super.initState();
    _loadUserRole();
    fetchDoctors();
  }

  void _loadUserRole() {
    _userRole = html.window.localStorage['role'] ?? 'RECEPTIONIST';
  }

  // ───────── FETCH DOCTORS FROM BACKEND ─────────
  Future<void> fetchDoctors() async {
    if (!mounted) return;
    setState(() => isLoading = true);

    try {
      final token = html.window.localStorage['token'] ?? '';
      if (token.isEmpty) {
        showError('No token found. Please log in again.');
        return;
      }

      final response = await http.get(
        Uri.parse('$_BaseUrl/api/doctors/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      debugPrint('Doctor fetch status: ${response.statusCode}');
      debugPrint('Doctor fetch body: ${response.body}');

      if (response.statusCode == 401) {
        showError('Session expired. Please log in again.');
        return;
      }

      if (response.statusCode == 403) {
        showError('You do not have permission to view doctors.');
        return;
      }

      if (response.body.isEmpty) {
        showError('Server returned empty response.');
        return;
      }

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final List rawList = data is List ? data : (data['data'] ?? []);
        if (!mounted) return;
        setState(() {
          doctors = rawList.map((e) => Doctor.fromJson(e)).toList();
        });
      } else {
        showError(data['message'] ?? 'Failed to fetch doctors');
      }
    } catch (e) {
      showError('Network error: $e');
    } finally {
      if (!mounted) return;
      setState(() => isLoading = false);
    }
  }

  // ───────── OPEN ADD DOCTOR FORM ─────────
  Future<void> _openAddDoctorForm() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const DoctorRegistrationForm()),
    );

    // Refresh list if doctor was added
    if (result == true) {
      fetchDoctors();
    }
  }

  void showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: kBackground,
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    "List of Doctors",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: kTextDark,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "View and manage doctors and their availability",
                    style: TextStyle(fontSize: 13, color: kTextGrey),
                  ),
                ],
              ),
              const Spacer(),
              if (_canAddDoctor)
                ElevatedButton.icon(
                  onPressed: _openAddDoctorForm,
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text("Add Doctor"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kTeal,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 24),

          // ── Grid ──
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator(color: kTeal))
                : doctors.isEmpty
                ? const Center(
                    child: Text(
                      'No doctors found. Add one to get started.',
                      style: TextStyle(fontSize: 16, color: kTextGrey),
                    ),
                  )
                : GridView.builder(
                    itemCount: doctors.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          mainAxisSpacing: 20,
                          crossAxisSpacing: 20,
                          childAspectRatio: 0.85,
                        ),
                    itemBuilder: (context, index) {
                      final doc = doctors[index];
                      return _DoctorCard(doctor: doc);
                    },
                  ),
          ),

          const SizedBox(height: 10),

          // ── Pagination (UI only) ──
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Text("Previous", style: TextStyle(color: kTextGrey)),
              SizedBox(width: 10),
              _PageNumber(number: "1", active: true),
              _PageNumber(number: "2"),
              _PageNumber(number: "3"),
              SizedBox(width: 10),
              Text("Next", style: TextStyle(color: kTextGrey)),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── DOCTOR CARD ───────────────────────────────────────────────
class _DoctorCard extends StatelessWidget {
  final Doctor doctor;

  const _DoctorCard({required this.doctor});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: kTeal,
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: doctor.image.startsWith('http')
                ? Image.network(
                    doctor.image,
                    height: 120,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Image.asset(
                      'assets/images/default_doc.png',
                      height: 120,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  )
                : Image.asset(
                    doctor.image,
                    height: 120,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      height: 120,
                      width: double.infinity,
                      color: Colors.white24,
                      child: const Icon(Icons.person, size: 50, color: kWhite),
                    ),
                  ),
          ),

          const SizedBox(height: 12),

          Text(
            doctor.name,
            style: const TextStyle(
              color: kWhite,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: 4),

          Text(
            doctor.specialty,
            style: const TextStyle(color: Colors.white70, fontSize: 12),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),

          const Spacer(),

          // ── View Details Button ──
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ViewDoctorDetails(doctorId: doctor.id),
                ), // ✅ FIXED
              );
            },
            style: TextButton.styleFrom(
              backgroundColor: kWhite,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: const Text(
              "View Details",
              style: TextStyle(
                color: kTeal,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── PAGINATION ────────────────────────────────────────────────
class _PageNumber extends StatelessWidget {
  final String number;
  final bool active;

  const _PageNumber({required this.number, this.active = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: active ? kTeal : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        number,
        style: TextStyle(
          color: active ? kWhite : kTextGrey,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

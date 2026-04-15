// import 'package:flutter/material.dart';

// class DoctorListPage extends StatefulWidget {
//   @override
//   _DoctorListPageState createState() => _DoctorListPageState();
// }

// class _DoctorListPageState extends State<DoctorListPage> {
//   List<Map<String, dynamic>> doctors = [
//     {"name": "Dr. Daniel Osei", "specialty": "Dentist", "image": "doctor1.jpg"},
//     {"name": "Dr. Jackline Sam", "specialty": "Dentist", "image": "doctor2.jpg"},
//     {"name": "Dr. Grace Dankwa", "specialty": "Dentist", "image": "doctor3.jpg"},
//     {"name": "Dr. Joseph Kwofie", "specialty": "Dentist", "image": "doctor4.jpg"},
//     {"name": "Dr. Patricia Quaye", "specialty": "Orthodontist", "image": "doctor5.jpg"},
//     {"name": "Dr. Lord Glassmen", "specialty": "Dentist", "image": "doctor6.jpg"},
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Row(
//         children: [
//           // Sidebar
//           Container(
//             width: 80,
//             color: Color(0xFF009688),
//             child: Column(
//               children: [
//                 SizedBox(height: 50),
//                 Icon(Icons.dashboard, color: Colors.white),
//                 SizedBox(height: 5),
//                 Text("Overview", style: TextStyle(color: Colors.white, fontSize: 10)),
//                 SizedBox(height: 30),
//                 Icon(Icons.person, color: Colors.white),
//                 SizedBox(height: 5),
//                 Text("Patient", style: TextStyle(color: Colors.white, fontSize: 10)),
//                 SizedBox(height: 30),
//                 Icon(Icons.local_hospital, color: Colors.white, size: 30),
//                 SizedBox(height: 5),
//                 Text("Doctor", style: TextStyle(color: Colors.white, fontSize: 10)),
//                 Spacer(),
//                 Icon(Icons.logout, color: Colors.white),
//                 SizedBox(height: 5),
//                 Text("Logout", style: TextStyle(color: Colors.white, fontSize: 10)),
//                 SizedBox(height: 50),
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
//                     "List of Doctors",
//                     style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//                   ),
//                   SizedBox(height: 10),
//                   Text("View and manage doctors and their availability."),
//                   SizedBox(height: 20),
//                   // Search bar
//                   TextField(
//                     decoration: InputDecoration(
//                       hintText: "Search...",
//                       prefixIcon: Icon(Icons.search),
//                       suffixIcon: Icon(Icons.notifications),
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                     ),
//                   ),
//                   SizedBox(height: 20),
//                   // Doctor grid
//                   Expanded(
//                     child: GridView.builder(
//                       gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//                         crossAxisCount: 3,
//                         crossAxisSpacing: 20,
//                         mainAxisSpacing: 20,
//                       ),
//                       itemCount: doctors.length,
//                       itemBuilder: (context, index) {
//                         return Card(
//                           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//                           elevation: 4,
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               // Placeholder for doctor image
//                               Container(
//                                 height: 100,
//                                 color: Colors.grey[300],
//                                 child: Icon(Icons.person, size: 50),
//                               ),
//                               Padding(
//                                 padding: const EdgeInsets.all(8.0),
//                                 child: Text(
//                                   doctors[index]["name"],
//                                   style: TextStyle(fontWeight: FontWeight.bold),
//                                 ),
//                               ),
//                               Padding(
//                                 padding: const EdgeInsets.symmetric(horizontal: 8.0),
//                                 child: Text(doctors[index]["specialty"]),
//                               ),
//                               Spacer(),
//                               Align(
//                                 alignment: Alignment.center,
//                                 child: ElevatedButton(
//                                   style: ElevatedButton.styleFrom(
//                                     backgroundColor: Color(0xFF009688),
//                                   ),
//                                   onPressed: () {},
//                                   child: Text("View Details"),
//                                 ),
//                               ),
//                               SizedBox(height: 10),
//                             ],
//                           ),
//                         );
//                       },
//                     ),
//                   ),
//                   // Pagination
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       TextButton(onPressed: () {}, child: Text("Previous")),
//                       Text("1"),
//                       TextButton(onPressed: () {}, child: Text("Next")),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';

// ─── COLORS (match your dashboard) ─────────────────────────────
const kTeal = Color(0xFF0D7B6B);
const kBackground = Color(0xFFF0F4F4);
const kWhite = Color(0xFFFFFFFF);
const kTextDark = Color(0xFF1A2E2C);
const kTextGrey = Color(0xFF7A9490);

// ─── MODEL ─────────────────────────────────────────────────────
class Doctor {
  final String name;
  final String specialty;
  final String image;

  Doctor({required this.name, required this.specialty, required this.image});
}

// ─── MAIN PAGE ─────────────────────────────────────────────────
class DoctorListPage extends StatelessWidget {
  const DoctorListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final doctors = [
      Doctor(
        name: "Dr. Daniel Osei",
        specialty: "General Practitioner",
        image: "assets/images/doc1.jpg",
      ),
      Doctor(
        name: "Dr. Jackline Sam",
        specialty: "General Surgeon",
        image: "assets/images/doc2.jpg",
      ),
      Doctor(
        name: "Dr. Grace Dankwa",
        specialty: "Gynecologist",
        image: "assets/images/doc3.jpg",
      ),
      Doctor(
        name: "Dr. Joseph Kwofie",
        specialty: "Pediatrician",
        image: "assets/images/doc4.jpg",
      ),
      Doctor(
        name: "Dr. Patricia Quaye",
        specialty: "Ophthalmologist",
        image: "assets/images/doc5.jpg",
      ),
      Doctor(
        name: "Dr. Lord Glassmen",
        specialty: "Radiologist",
        image: "assets/images/doc6.jpg",
      ),
    ];

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
              ElevatedButton.icon(
                onPressed: () {},
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
            child: GridView.builder(
              itemCount: doctors.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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
            child: Image.asset(
              doctor.image,
              height: 120,
              width: double.infinity,
              fit: BoxFit.cover,
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
          ),

          const SizedBox(height: 4),

          Text(
            doctor.specialty,
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),

          const Spacer(),

          // ── View Details Button ──
          TextButton(
            onPressed: () {
              // TODO: Navigate to Doctor Details Page
              // Navigator.push(context,
              //   MaterialPageRoute(builder: (_) => DoctorDetailsPage()));
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

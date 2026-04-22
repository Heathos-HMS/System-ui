// import 'dart:async';
// import 'dart:convert';
// import 'dart:typed_data';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:intl/intl.dart';

// import 'admin_login_page.dart';
// import 'admin_dashboard.dart';

// // ─── CONSTANTS ───────────────────────────────────────────────────────────────
// const kTeal = Color(0xFF0D7B6B);
// const kTealLight = Color(0xFF1A9E8A);
// const kTealDark = Color(0xFF095F54);
// const kTealAccent = Color(0xFF4FC3B0);
// const kBackground = Color(0xFFF0F4F4);
// const kWhite = Color(0xFFFFFFFF);
// const kTextDark = Color(0xFF1A2E2C);
// const kTextGrey = Color(0xFF7A9490);
// const kCardBg = Color(0xFFFFFFFF);
// const kSuccess = Color(0xFF4CAF50);
// const kWarning = Color(0xFFFF9800);
// const kError = Color(0xFFF44336);
// const kBorder = Color(0xFFE0E0E0);

// const String _baseUrl = 'https://heathos-app-latest.onrender.com';

// // ─── MODELS ─────────────────────────────────────────────────────────────────
// enum AppointmentType { IN_PERSON, VIRTUAL }
// enum AppointmentStatus { SCHEDULED, CHECKED_IN, COMPLETED, CANCELLED }

// class Doctor {
//   final String id;
//   final String name;
//   final String department;
//   final String? avatarUrl;

//   const Doctor({
//     required this.id,
//     required this.name,
//     required this.department,
//     this.avatarUrl,
//   });

//   factory Doctor.fromJson(Map<String, dynamic> json) => Doctor(
//     id: json['id']?? '',
//     name: json['fullName']?? json['name']?? 'Unknown',
//     department: json['department']?? 'General',
//     avatarUrl: json['avatarUrl'],
//   );
// }

// class Patient {
//   final String id;
//   final String name;
//   final String phone;
//   final String? avatarUrl;

//   const Patient({
//     required this.id,
//     required this.name,
//     required this.phone,
//     this.avatarUrl,
//   });

//   factory Patient.fromJson(Map<String, dynamic> json) => Patient(
//     id: json['id']?? '',
//     name: json['fullName']?? json['name']?? 'Unknown',
//     phone: json['phoneNumber']?? json['phone']?? '',
//     avatarUrl: json['avatarUrl'],
//   );
// }

// class AppointmentSlot {
//   final String datetime; // "2025-01-20T08:00:00"
//   final bool isBooked;

//   const AppointmentSlot({
//     required this.datetime,
//     required this.isBooked,
//   });

//   factory AppointmentSlot.fromJson(Map<String, dynamic> json) => AppointmentSlot(
//     datetime: json['slotDatetime']?? json['datetime']?? '',
//     isBooked: json['isBooked']?? false,
//   );

//   String get timeDisplay {
//     try {
//       final dt = DateTime.parse(datetime);
//       return DateFormat('h:mma').format(dt).toLowerCase();
//     } catch (_) {
//       return datetime;
//     }
//   }
// }

// class Appointment {
//   final String id;
//   final String patientId;
//   final String patientName;
//   final String? patientAvatar;
//   final String doctorId;
//   final String slotDatetime;
//   final AppointmentStatus status;
//   final AppointmentType type;

//   const Appointment({
//     required this.id,
//     required this.patientId,
//     required this.patientName,
//     this.patientAvatar,
//     required this.doctorId,
//     required this.slotDatetime,
//     required this.status,
//     required this.type,
//   });

//   factory Appointment.fromJson(Map<String, dynamic> json) => Appointment(
//     id: json['id']?? '',
//     patientId: json['patientId']?? '',
//     patientName: json['patientName']?? json['patient']?['name']?? 'Unknown',
//     patientAvatar: json['patientAvatar']?? json['patient']?['avatarUrl'],
//     doctorId: json['doctorId']?? '',
//     slotDatetime: json['slotDatetime']?? '',
//     status: _parseStatus(json['status']),
//     type: json['type'] == 'VIRTUAL'? AppointmentType.VIRTUAL : AppointmentType.IN_PERSON,
//   );

//   static AppointmentStatus _parseStatus(String? status) {
//     switch (status?.toUpperCase()) {
//       case 'CHECKED_IN': return AppointmentStatus.CHECKED_IN;
//       case 'COMPLETED': return AppointmentStatus.COMPLETED;
//       case 'CANCELLED': return AppointmentStatus.CANCELLED;
//       default: return AppointmentStatus.SCHEDULED;
//     }
//   }

//   String get timeDisplay {
//     try {
//       final dt = DateTime.parse(slotDatetime);
//       return DateFormat('h:mma').format(dt).toLowerCase();
//     } catch (_) {
//       return slotDatetime;
//     }
//   }
// }

// // ─── APPOINTMENT PAGE ───────────────────────────────────────────────────────
// class AppointmentPage extends StatefulWidget {
//   const AppointmentPage({super.key});

//   @override
//   State<AppointmentPage> createState() => _AppointmentPageState();
// }

// class _AppointmentPageState extends State<AppointmentPage> {
//   Uint8List? _topBarProfileImageBytes;
//   DateTime _selectedDate = DateTime.now();
//   String _selectedDepartment = 'All Departments';
//   Doctor? _selectedDoctor;
//   Patient? _selectedPatient;
//   AppointmentSlot? _selectedSlot;

//   List<Doctor> _doctors = [];
//   List<Patient> _patients = [];
//   List<AppointmentSlot> _availableSlots = [];
//   List<Appointment> _appointments = [];
//   List<Appointment> _liveQueue = [];

//   bool _isLoadingSlots = false;
//   bool _isLoadingQueue = false;
//   bool _isBooking = false;
//   String? _errorMessage;
//   Timer? _queuePollTimer;

//   final _searchController = TextEditingController();
//   final _patientNameController = TextEditingController();
//   final _phoneController = TextEditingController();
//   final _reasonController = TextEditingController();

//   final List<String> _departments = [
//     'All Departments',
//     'General Medicine',
//     'Pediatrics',
//     'Cardiology',
//     'Orthopedics',
//     'Dermatology',
//     'Neurology',
//   ];

//   @override
//   void initState() {
//     super.initState();
//     _initData();
//     _startQueuePolling();
//   }

//   @override
//   void dispose() {
//     _searchController.dispose();
//     _patientNameController.dispose();
//     _phoneController.dispose();
//     _reasonController.dispose();
//     _queuePollTimer?.cancel();
//     super.dispose();
//   }

//   Future<void> _initData() async {
//     await Future.wait([
//       _fetchDoctors(),
//       _fetchPatients(),
//     ]);
//     if (_doctors.isNotEmpty) {
//       _selectedDoctor = _doctors.first;
//       await _loadSlotsAndQueue();
//     }
//   }

//   void _startQueuePolling() {
//     _queuePollTimer = Timer.periodic(const Duration(seconds: 15), (_) {
//       if (_selectedDoctor!= null) _fetchLiveQueue();
//     });
//   }

//   Future<void> _loadSlotsAndQueue() async {
//     await Future.wait([
//       _fetchAvailableSlots(),
//       _fetchLiveQueue(),
//     ]);
//   }

//   Future<void> _fetchDoctors() async {
//     try {
//       final res = await http.get(Uri.parse('$_baseUrl/doctors'));
//       if (res.statusCode == 200) {
//         final body = jsonDecode(res.body);
//         final List data = body['data']?? body;
//         setState(() => _doctors = data.map((e) => Doctor.fromJson(e)).toList());
//       }
//     } catch (e) {
//       _showError('Failed to load doctors: $e');
//     }
//   }

//   Future<void> _fetchPatients() async {
//     try {
//       final res = await http.get(Uri.parse('$_baseUrl/patients'));
//       if (res.statusCode == 200) {
//         final body = jsonDecode(res.body);
//         final List data = body['data']?? body;
//         setState(() => _patients = data.map((e) => Patient.fromJson(e)).toList());
//       }
//     } catch (e) {
//       _showError('Failed to load patients: $e');
//     }
//   }

//   Future<void> _fetchAvailableSlots() async {
//     if (_selectedDoctor == null) return;
//     setState(() => _isLoadingSlots = true);
//     try {
//       final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
//       final res = await http.get(
//         Uri.parse('$_baseUrl/api/appointments/slots?doctor_id=${_selectedDoctor!.id}&date=$dateStr'),
//       );
//       if (res.statusCode == 200) {
//         final body = jsonDecode(res.body);
//         final List data = body['data']?? [];
//         setState(() {
//           _availableSlots = data.map((e) => AppointmentSlot.fromJson(e)).toList();
//           _isLoadingSlots = false;
//         });
//       } else {
//         setState(() => _isLoadingSlots = false);
//       }
//     } catch (e) {
//       setState(() => _isLoadingSlots = false);
//       _showError('Failed to load slots: $e');
//     }
//   }

//   Future<void> _fetchLiveQueue() async {
//     if (_selectedDoctor == null) return;
//     setState(() => _isLoadingQueue = true);
//     try {
//       final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
//       final res = await http.get(
//         Uri.parse('$_baseUrl/api/appointments/queue?doctor_id=${_selectedDoctor!.id}&date=$dateStr'),
//       );
//       if (res.statusCode == 200) {
//         final body = jsonDecode(res.body);
//         final List data = body['data']?? [];
//         setState(() {
//           _liveQueue = data.map((e) => Appointment.fromJson(e)).toList();
//           _isLoadingQueue = false;
//         });
//       } else {
//         setState(() => _isLoadingQueue = false);
//       }
//     } catch (e) {
//       setState(() => _isLoadingQueue = false);
//     }
//   }

//   Future<void> _bookAppointment() async {
//     if (_selectedPatient == null || _selectedDoctor == null || _selectedSlot == null) {
//       _showError('Please select patient, doctor, and time slot');
//       return;
//     }

//     setState(() => _isBooking = true);
//     try {
//       final res = await http.post(
//         Uri.parse('$_baseUrl/api/appointments'),
//         headers: {'Content-Type': 'application/json'},
//         body: jsonEncode({
//           'patientId': _selectedPatient!.id,
//           'doctorId': _selectedDoctor!.id,
//           'slotDatetime': _selectedSlot!.datetime,
//           'type': 'IN_PERSON',
//         }),
//       );

//       if (res.statusCode == 200) {
//         _showSuccess('Appointment booked successfully');
//         _clearBookingForm();
//         await _loadSlotsAndQueue();
//       } else if (res.statusCode == 409) {
//         _showError('Slot already booked by another appointment');
//         await _fetchAvailableSlots();
//       } else {
//         final body = jsonDecode(res.body);
//         _showError(body['message']?? 'Failed to book appointment');
//       }
//     } catch (e) {
//       _showError('Booking failed: $e');
//     } finally {
//       setState(() => _isBooking = false);
//     }
//   }

//   Future<void> _checkInPatient(String appointmentId) async {
//     try {
//       final res = await http.patch(
//         Uri.parse('$_baseUrl/api/appointments/$appointmentId/checkin'),
//       );
//       if (res.statusCode == 200) {
//         _showSuccess('Patient checked in');
//         await _fetchLiveQueue();
//       } else {
//         final body = jsonDecode(res.body);
//         _showError(body['message']?? 'Check-in failed');
//       }
//     } catch (e) {
//       _showError('Check-in failed: $e');
//     }
//   }

//   Future<void> _cancelAppointment(String appointmentId) async {
//     try {
//       final res = await http.patch(
//         Uri.parse('$_baseUrl/api/appointments/$appointmentId/cancel'),
//       );
//       if (res.statusCode == 200) {
//         _showSuccess('Appointment cancelled');
//         await _loadSlotsAndQueue();
//       } else {
//         final body = jsonDecode(res.body);
//         _showError(body['message']?? 'Cancel failed');
//       }
//     } catch (e) {
//       _showError('Cancel failed: $e');
//     }
//   }

//   void _clearBookingForm() {
//     setState(() {
//       _selectedSlot = null;
//       _selectedPatient = null;
//       _patientNameController.clear();
//       _phoneController.clear();
//       _reasonController.clear();
//     });
//   }

//   void _showError(String msg) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text(msg), backgroundColor: kError),
//     );
//   }

//   void _showSuccess(String msg) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text(msg), backgroundColor: kSuccess),
//     );
//   }

//   void _goBack() {
//     Navigator.pushReplacement(
//       context,
//       MaterialPageRoute(builder: (_) => const AdminDashboard()),
//     );
//   }

//   void _logout() {
//     Navigator.pushAndRemoveUntil(
//       context,
//       MaterialPageRoute(builder: (_) => const AdminLoginPage()),
//       (route) => false,
//     );
//   }

//   List<Patient> get _filteredPatients {
//     final query = _searchController.text.toLowerCase();
//     if (query.isEmpty) return _patients;
//     return _patients.where((p) =>
//       p.name.toLowerCase().contains(query) ||
//       p.phone.contains(query)
//     ).toList();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: kBackground,
//       body: Column(
//         children: [
//           TopBar(
//             profileImageBytes: _topBarProfileImageBytes,
//             onProfileImageChanged: (bytes) => setState(() => _topBarProfileImageBytes = bytes),
//             onLogout: _logout,
//             onGoToProfile: () {},
//           ),
//           Expanded(
//             child: SingleChildScrollView(
//               padding: const EdgeInsets.fromLTRB(28, 20, 28, 28),
//               child: _AppointmentContent(
//                 selectedDate: _selectedDate,
//                 onDateChanged: (date) {
//                   setState(() => _selectedDate = date);
//                   _loadSlotsAndQueue();
//                 },
//                 selectedDepartment: _selectedDepartment,
//                 onDepartmentChanged: (dept) => setState(() => _selectedDepartment = dept),
//                 departments: _departments,
//                 selectedDoctor: _selectedDoctor,
//                 onDoctorChanged: (doc) {
//                   setState(() => _selectedDoctor = doc);
//                   _loadSlotsAndQueue();
//                 },
//                 doctors: _doctors,
//                 searchController: _searchController,
//                 filteredPatients: _filteredPatients,
//                 availableSlots: _availableSlots,
//                 liveQueue: _liveQueue,
//                 isLoadingSlots: _isLoadingSlots,
//                 selectedSlot: _selectedSlot,
//                 onSlotSelected: (slot) => setState(() => _selectedSlot = slot),
//                 selectedPatient: _selectedPatient,
//                 onPatientSelected: (p) {
//                   setState(() {
//                     _selectedPatient = p;
//                     _patientNameController.text = p.name;
//                     _phoneController.text = p.phone;
//                   });
//                 },
//                 patientNameController: _patientNameController,
//                 phoneController: _phoneController,
//                 reasonController: _reasonController,
//                 onBookAppointment: _bookAppointment,
//                 onCancelBooking: _clearBookingForm,
//                 onCheckIn: _checkInPatient,
//                 onCancelAppointment: _cancelAppointment,
//                 isBooking: _isBooking,
//                 onBack: _goBack,
//               ),
//             ),
//           ),
//           const Footer(),
//         ],
//       ),
//     );
//   }
// }

// // ─── APPOINTMENT CONTENT ────────────────────────────────────────────────────
// class _AppointmentContent extends StatelessWidget {
//   final DateTime selectedDate;
//   final ValueChanged<DateTime> onDateChanged;
//   final String selectedDepartment;
//   final ValueChanged<String> onDepartmentChanged;
//   final List<String> departments;
//   final Doctor? selectedDoctor;
//   final ValueChanged<Doctor?> onDoctorChanged;
//   final List<Doctor> doctors;
//   final TextEditingController searchController;
//   final List<Patient> filteredPatients;
//   final List<AppointmentSlot> availableSlots;
//   final List<Appointment> liveQueue;
//   final bool isLoadingSlots;
//   final AppointmentSlot? selectedSlot;
//   final ValueChanged<AppointmentSlot> onSlotSelected;
//   final Patient? selectedPatient;
//   final ValueChanged<Patient> onPatientSelected;
//   final TextEditingController patientNameController;
//   final TextEditingController phoneController;
//   final TextEditingController reasonController;
//   final VoidCallback onBookAppointment;
//   final VoidCallback onCancelBooking;
//   final Function(String) onCheckIn;
//   final Function(String) onCancelAppointment;
//   final bool isBooking;
//   final VoidCallback onBack;

//   const _AppointmentContent({
//     required this.selectedDate,
//     required this.onDateChanged,
//     required this.selectedDepartment,
//     required this.onDepartmentChanged,
//     required this.departments,
//     required this.selectedDoctor,
//     required this.onDoctorChanged,
//     required this.doctors,
//     required this.searchController,
//     required this.filteredPatients,
//     required this.availableSlots,
//     required this.liveQueue,
//     required this.isLoadingSlots,
//     required this.selectedSlot,
//     required this.onSlotSelected,
//     required this.selectedPatient,
//     required this.onPatientSelected,
//     required this.patientNameController,
//     required this.phoneController,
//     required this.reasonController,
//     required this.onBookAppointment,
//     required this.onCancelBooking,
//     required this.onCheckIn,
//     required this.onCancelAppointment,
//     required this.isBooking,
//     required this.onBack,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         // Header with back button
//         Row(
//           children: [
//             InkWell(
//               onTap: onBack,
//               borderRadius: BorderRadius.circular(8),
//               child: const Padding(
//                 padding: EdgeInsets.all(8.0),
//                 child: Icon(Icons.arrow_back, color: kTextDark, size: 24),
//               ),
//             ),
//             const SizedBox(width: 8),
//             const Text(
//               'Appointment Booking',
//               style: TextStyle(
//                 fontSize: 28,
//                 fontWeight: FontWeight.w800,
//                 color: kTextDark,
//               ),
//             ),
//           ],
//         ),
//         const SizedBox(height: 20),
//         // Main layout: Left panel + Center + Right drawer
//         Row(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Left: Date picker + Department filter
//             SizedBox(
//               width: 280,
//               child: _DateDepartmentPanel(
//                 selectedDate: selectedDate,
//                 onDateChanged: onDateChanged,
//                 selectedDepartment: selectedDepartment,
//                 onDepartmentChanged: onDepartmentChanged,
//                 departments: departments,
//               ),
//             ),
//             const SizedBox(width: 20),
//             // Center: Slots + Live Queue
//             Expanded(
//               child: _CenterPanel(
//                 searchController: searchController,
//                 filteredPatients: filteredPatients,
//                 onPatientSelected: onPatientSelected,
//                 availableSlots: availableSlots,
//                 liveQueue: liveQueue,
//                 isLoadingSlots: isLoadingSlots,
//                 onCheckIn: onCheckIn,
//                 onCancelAppointment: onCancelAppointment,
//                 onSlotTap: onSlotSelected,
//               ),
//             ),
//             const SizedBox(width: 20),
//             // Right: Booking drawer
//             SizedBox(
//               width: 320,
//               child: _BookingDrawer(
//                 selectedSlot: selectedSlot,
//                 selectedDoctor: selectedDoctor,
//                 doctors: doctors,
//                 onDoctorChanged: onDoctorChanged,
//                 patientNameController: patientNameController,
//                 phoneController: phoneController,
//                 reasonController: reasonController,
//                 onBookAppointment: onBookAppointment,
//                 onCancel: onCancelBooking,
//                 isBooking: isBooking,
//               ),
//             ),
//           ],
//         ),
//       ],
//     );
//   }
// }

// class _DateDepartmentPanel extends StatelessWidget {
//   final DateTime selectedDate;
//   final ValueChanged<DateTime> onDateChanged;
//   final String selectedDepartment;
//   final ValueChanged<String> onDepartmentChanged;
//   final List<String> departments;

//   const _DateDepartmentPanel({
//     required this.selectedDate,
//     required this.onDateChanged,
//     required this.selectedDepartment,
//     required this.onDepartmentChanged,
//     required this.departments,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: kCardBg,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: kBorder),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Text(
//             'Select a date',
//             style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: kTextDark),
//           ),
//           const SizedBox(height: 8),
//           Row(
//             children: [
//               Icon(Icons.access_time, size: 16, color: kTextGrey),
//               const SizedBox(width: 6),
//               const Text('15 min appointments', style: TextStyle(fontSize: 12, color: kTextGrey)),
//             ],
//           ),
//           const SizedBox(height: 12),
//           // Department dropdown
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//             decoration: BoxDecoration(
//               border: Border.all(color: kTeal),
//               borderRadius: BorderRadius.circular(8),
//             ),
//             child: DropdownButtonHideUnderline(
//               child: DropdownButton<String>(
//                 value: selectedDepartment,
//                 isDense: true,
//                 isExpanded: true,
//                 icon: const Icon(Icons.keyboard_arrow_down, size: 18, color: kTeal),
//                 items: departments.map((d) => DropdownMenuItem(
//                   value: d,
//                   child: Row(
//                     children: [
//                       Icon(Icons.medical_services_outlined, size: 16, color: kTeal),
//                       const SizedBox(width: 6),
//                       Text(d, style: const TextStyle(fontSize: 13)),
//                     ],
//                   ),
//                 )).toList(),
//                 onChanged: (v) => onDepartmentChanged(v!),
//               ),
//             ),
//           ),
//           const SizedBox(height: 16),
//           // Calendar
//           _MiniCalendar(
//             selectedDate: selectedDate,
//             onDateSelected: onDateChanged,
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _MiniCalendar extends StatelessWidget {
//   final DateTime selectedDate;
//   final ValueChanged<DateTime> onDateSelected;

//   const _MiniCalendar({required this.selectedDate, required this.onDateSelected});

//   @override
//   Widget build(BuildContext context) {
//     final now = DateTime.now();
//     final firstDay = DateTime(selectedDate.year, selectedDate.month, 1);
//     final daysInMonth = DateTime(selectedDate.year, selectedDate.month + 1, 0).day;
//     final startWeekday = firstDay.weekday % 7;

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Text(
//               DateFormat('E, MMMM d').format(selectedDate),
//               style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
//             ),
//             Row(
//               children: [
//                 InkWell(
//                   onTap: () => onDateSelected(DateTime(selectedDate.year, selectedDate.month - 1, 1)),
//                   child: const Icon(Icons.chevron_left, size: 20),
//                 ),
//                 const SizedBox(width: 8),
//                 InkWell(
//                   onTap: () => onDateSelected(DateTime(selectedDate.year, selectedDate.month + 1, 1)),
//                   child: const Icon(Icons.chevron_right, size: 20),
//                 ),
//               ],
//             ),
//           ],
//         ),
//         const SizedBox(height: 12),
//         // Weekday headers
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceAround,
//           children: ['S', 'M', 'T', 'W', 'T', 'F', 'S'].map((d) =>
//             SizedBox(
//               width: 28,
//               child: Text(d, textAlign: TextAlign.center, style: const TextStyle(fontSize: 11, color: kTextGrey)),
//             )
//           ).toList(),
//         ),
//         const SizedBox(height: 8),
//         // Days grid
//        ...List.generate(6, (week) {
//           return Padding(
//             padding: const EdgeInsets.symmetric(vertical: 2),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceAround,
//               children: List.generate(7, (day) {
//                 final dayNum = week * 7 + day - startWeekday + 1;
//                 if (dayNum < 1 || dayNum > daysInMonth) {
//                   return const SizedBox(width: 28, height: 28);
//                 }
//                 final date = DateTime(selectedDate.year, selectedDate.month, dayNum);
//                 final isSelected = date.day == selectedDate.day &&
//                                   date.month == selectedDate.month &&
//                                   date.year == selectedDate.year;
//                 final isToday = date.day == now.day &&
//                                date.month == now.month &&
//                                date.year == now.year;

//                 return InkWell(
//                   onTap: () => onDateSelected(date),
//                   borderRadius: BorderRadius.circular(14),
//                   child: Container(
//                     width: 28,
//                     height: 28,
//                     decoration: BoxDecoration(
//                       color: isSelected? kTeal : isToday? kTeal.withOpacity(0.1) : null,
//                       shape: BoxShape.circle,
//                     ),
//                     child: Center(
//                       child: Text(
//                         '$dayNum',
//                         style: TextStyle(
//                           fontSize: 12,
//                           color: isSelected? kWhite : kTextDark,
//                           fontWeight: isSelected || isToday? FontWeight.w700 : FontWeight.w500,
//                         ),
//                       ),
//                     ),
//                   ),
//                 );
//               }),
//             ),
//           );
//         }),
//       ],
//     );
//   }
// }

// class _CenterPanel extends StatelessWidget {
//   final TextEditingController searchController;
//   final List<Patient> filteredPatients;
//   final ValueChanged<Patient> onPatientSelected;
//   final List<AppointmentSlot> availableSlots;
//   final List<Appointment> liveQueue;
//   final bool isLoadingSlots;
//   final Function(String) onCheckIn;
//   final Function(String) onCancelAppointment;
//   final ValueChanged<AppointmentSlot> onSlotTap;

//   const _CenterPanel({
//     required this.searchController,
//     required this.filteredPatients,
//     required this.onPatientSelected,
//     required this.availableSlots,
//     required this.liveQueue,
//     required this.isLoadingSlots,
//     required this.onCheckIn,
//     required this.onCancelAppointment,
//     required this.onSlotTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         // Search bar
//         Container(
//           height: 44,
//           decoration: BoxDecoration(
//             border: Border.all(color: kBorder),
//             borderRadius: BorderRadius.circular(22),
//           ),
//           child: Row(
//             children: [
//               const SizedBox(width: 14),
//               const Icon(Icons.search, color: kTextGrey, size: 20),
//               const SizedBox(width: 8),
//               Expanded(
//                 child: TextField(
//                   controller: searchController,
//                   decoration: const InputDecoration(
//                     hintText: 'Search Patients...',
//                     border: InputBorder.none,
//                     isDense: true,
//                   ),
//                   onChanged: (_) {},
//                 ),
//               ),
//               const Icon(Icons.keyboard_arrow_down, color: kTextGrey, size: 20),
//               const SizedBox(width: 14),
//             ],
//           ),
//         ),
//         const SizedBox(height: 16),
//         // Appointment Slots
//         _SlotsSection(
//           title: 'Appointment Slots',
//           slots: availableSlots,
//           isLoading: isLoadingSlots,
//           onSlotTap: onSlotTap,
//         ),
//         const SizedBox(height: 16),
//         // Live Queue
//         _QueueSection(
//           appointments: liveQueue,
//           onCheckIn: onCheckIn,
//           onCancel: onCancelAppointment,
//         ),
//       ],
//     );
//   }
// }

// class _SlotsSection extends StatelessWidget {
//   final String title;
//   final List<AppointmentSlot> slots;
//   final bool isLoading;
//   final ValueChanged<AppointmentSlot> onSlotTap;

//   const _SlotsSection({
//     required this.title,
//     required this.slots,
//     required this.isLoading,
//     required this.onSlotTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: BoxDecoration(
//         color: kCardBg,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: kBorder),
//       ),
//       child: Column(
//         children: [
//           Padding(
//             padding: const EdgeInsets.all(16),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
//                 TextButton(
//                   onPressed: () {},
//                   child: Row(
//                     children: const [
//                       Text('View all', style: TextStyle(color: kTeal, fontSize: 13)),
//                       Icon(Icons.chevron_right, size: 18, color: kTeal),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           if (isLoading)
//             const Padding(
//               padding: EdgeInsets.all(32),
//               child: CircularProgressIndicator(color: kTeal),
//             )
//           else if (slots.isEmpty)
//             const Padding(
//               padding: EdgeInsets.all(32),
//               child: Text('No available slots', style: TextStyle(color: kTextGrey)),
//             )
//           else
//             ListView.separated(
//               shrinkWrap: true,
//               physics: const NeverScrollableScrollPhysics(),
//               itemCount: slots.length > 5? 5 : slots.length,
//               separatorBuilder: (_, __) => Divider(height: 1, color: kBorder),
//               itemBuilder: (_, i) {
//                 final slot = slots[i];
//                 return InkWell(
//                   onTap: () => onSlotTap(slot),
//                   child: Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//                     child: Row(
//                       children: [
//                         Expanded(
//                           flex: 3,
//                           child: Text('Available', style: const TextStyle(fontSize: 13)),
//                         ),
//                         Expanded(
//                           flex: 2,
//                           child: Text(slot.timeDisplay, style: const TextStyle(fontSize: 13)),
//                         ),
//                         Expanded(
//                           flex: 2,
//                           child: Container(
//                             padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
//                             decoration: BoxDecoration(
//                               color: kSuccess.withOpacity(0.15),
//                               borderRadius: BorderRadius.circular(12),
//                             ),
//                             child: Text(
//                               'Open',
//                               textAlign: TextAlign.center,
//                               style: TextStyle(fontSize: 12, color: kSuccess, fontWeight: FontWeight.w600),
//                             ),
//                           ),
//                         ),
//                         Expanded(
//                           flex: 2,
//                           child: TextButton(
//                             onPressed: () => onSlotTap(slot),
//                             child: const Text('Select', style: TextStyle(color: kTeal, fontSize: 12)),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 );
//               },
//             ),
//         ],
//       ),
//     );
//   }
// }

// class _QueueSection extends StatelessWidget {
//   final List<Appointment> appointments;
//   final Function(String) onCheckIn;
//   final Function(String) onCancel;

//   const _QueueSection({
//     required this.appointments,
//     required this.onCheckIn,
//     required this.onCancel,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: BoxDecoration(
//         color: kCardBg,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: kBorder),
//       ),
//       child: Column(
//         children: [
//           Padding(
//             padding: const EdgeInsets.all(16),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 const Text('Live Queue', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
//                 Text(
//                   '${appointments.length} patients',
//                   style: const TextStyle(fontSize: 13, color: kTextGrey),
//                 ),
//               ],
//             ),
//           ),
//           if (appointments.isEmpty)
//                         const Padding(
//               padding: EdgeInsets.all(32),
//               child: Text('No patients in queue', style: TextStyle(color: kTextGrey)),
//             )
//           else
//             ListView.separated(
//               shrinkWrap: true,
//               physics: const NeverScrollableScrollPhysics(),
//               itemCount: appointments.length,
//               separatorBuilder: (_, __) => Divider(height: 1, color: kBorder),
//               itemBuilder: (_, i) {
//                 final apt = appointments[i];
//                 return Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//                   child: Row(
//                     children: [
//                       // Patient avatar + name
//                       Expanded(
//                         flex: 3,
//                         child: Row(
//                           children: [
//                             Container(
//                               width: 32,
//                               height: 32,
//                               decoration: BoxDecoration(
//                                 color: kTealAccent.withOpacity(0.3),
//                                 borderRadius: BorderRadius.circular(4),
//                               ),
//                               child: apt.patientAvatar!= null
//                                  ? ClipRRect(
//                                       borderRadius: BorderRadius.circular(4),
//                                       child: Image.network(
//                                         apt.patientAvatar!,
//                                         fit: BoxFit.cover,
//                                         errorBuilder: (_, __, ___) => const Icon(
//                                           Icons.person,
//                                           size: 18,
//                                           color: kTeal,
//                                         ),
//                                       ),
//                                     )
//                                   : const Icon(Icons.person, size: 18, color: kTeal),
//                             ),
//                             const SizedBox(width: 10),
//                             Expanded(
//                               child: Text(
//                                 apt.patientName,
//                                 style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
//                                 overflow: TextOverflow.ellipsis,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                       // Time
//                       Expanded(
//                         flex: 2,
//                         child: Text(
//                           apt.timeDisplay,
//                           style: const TextStyle(fontSize: 13),
//                         ),
//                       ),
//                       // Status badge
//                       Expanded(
//                         flex: 2,
//                         child: _StatusBadge(status: apt.status),
//                       ),
//                       // Actions
//                       Expanded(
//                         flex: 3,
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.end,
//                           children: [
//                             if (apt.status == AppointmentStatus.SCHEDULED)
//                               _ActionButton(
//                                 label: 'Check In',
//                                 color: kSuccess,
//                                 onTap: () => onCheckIn(apt.id),
//                               )
//                             else if (apt.status == AppointmentStatus.CHECKED_IN)
//                               Container(
//                                 padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
//                                 decoration: BoxDecoration(
//                                   color: kWarning.withOpacity(0.15),
//                                   borderRadius: BorderRadius.circular(12),
//                                 ),
//                                 child: Text(
//                                   'In Queue',
//                                   style: TextStyle(
//                                     fontSize: 11,
//                                     color: kWarning,
//                                     fontWeight: FontWeight.w600,
//                                   ),
//                                 ),
//                               ),
//                             const SizedBox(width: 8),
//                             if (apt.status!= AppointmentStatus.COMPLETED)
//                               _ActionButton(
//                                 label: 'Cancel',
//                                 color: kError,
//                                 onTap: () => onCancel(apt.id),
//                               ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                 );
//               },
//             ),
//           const SizedBox(height: 8),
//           if (appointments.length > 3)
//             TextButton(
//               onPressed: () {},
//               child: const Text(
//                 'See all in queue >',
//                 style: TextStyle(color: kTeal, fontSize: 13),
//               ),
//             ),
//         ],
//       ),
//     );
//   }
// }

// class _StatusBadge extends StatelessWidget {
//   final AppointmentStatus status;
//   const _StatusBadge({required this.status});

//   @override
//   Widget build(BuildContext context) {
//     Color bgColor;
//     Color textColor;
//     String label;

//     switch (status) {
//       case AppointmentStatus.SCHEDULED:
//         bgColor = kTeal.withOpacity(0.15);
//         textColor = kTeal;
//         label = 'Confirmed';
//         break;
//       case AppointmentStatus.CHECKED_IN:
//         bgColor = kWarning.withOpacity(0.15);
//         textColor = kWarning;
//         label = 'Checked In';
//         break;
//       case AppointmentStatus.COMPLETED:
//         bgColor = kSuccess.withOpacity(0.15);
//         textColor = kSuccess;
//         label = 'Completed';
//         break;
//       case AppointmentStatus.CANCELLED:
//         bgColor = kError.withOpacity(0.15);
//         textColor = kError;
//         label = 'Cancelled';
//         break;
//     }

//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
//       decoration: BoxDecoration(
//         color: bgColor,
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Text(
//         label,
//         textAlign: TextAlign.center,
//         style: TextStyle(fontSize: 12, color: textColor, fontWeight: FontWeight.w600),
//       ),
//     );
//   }
// }

// class _ActionButton extends StatelessWidget {
//   final String label;
//   final Color color;
//   final VoidCallback onTap;

//   const _ActionButton({
//     required this.label,
//     required this.color,
//     required this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return InkWell(
//       onTap: onTap,
//       borderRadius: BorderRadius.circular(12),
//       child: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
//         decoration: BoxDecoration(
//           border: Border.all(color: color),
//           borderRadius: BorderRadius.circular(12),
//         ),
//         child: Text(
//           label,
//           style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600),
//         ),
//       ),
//     );
//   }
// }

// // ─── BOOKING DRAWER ─────────────────────────────────────────────────────────
// class _BookingDrawer extends StatelessWidget {
//   final AppointmentSlot? selectedSlot;
//   final Doctor? selectedDoctor;
//   final List<Doctor> doctors;
//   final ValueChanged<Doctor?> onDoctorChanged;
//   final TextEditingController patientNameController;
//   final TextEditingController phoneController;
//   final TextEditingController reasonController;
//   final VoidCallback onBookAppointment;
//   final VoidCallback onCancel;
//   final bool isBooking;

//   const _BookingDrawer({
//     required this.selectedSlot,
//     required this.selectedDoctor,
//     required this.doctors,
//     required this.onDoctorChanged,
//     required this.patientNameController,
//     required this.phoneController,
//     required this.reasonController,
//     required this.onBookAppointment,
//     required this.onCancel,
//     required this.isBooking,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         color: kCardBg,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: kBorder),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.04),
//             blurRadius: 8,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           // Header
//           Row(
//             children: [
//               Container(
//                 padding: const EdgeInsets.all(6),
//                 decoration: BoxDecoration(
//                   color: kWarning.withOpacity(0.15),
//                   shape: BoxShape.circle,
//                 ),
//                 child: const Icon(Icons.person_outline, color: kWarning, size: 18),
//               ),
//               const SizedBox(width: 8),
//               const Text(
//                 'Selected Slot for Booking',
//                 style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
//               ),
//             ],
//           ),
//           const SizedBox(height: 16),
//           const Text(
//             'Book Appointment for Patient',
//             style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: kTextDark),
//           ),
//           const SizedBox(height: 16),
//           // Selected time display
//           if (selectedSlot!= null)
//             Container(
//               padding: const EdgeInsets.all(12),
//               decoration: BoxDecoration(
//                 color: kTeal.withOpacity(0.08),
//                 borderRadius: BorderRadius.circular(8),
//                 border: Border.all(color: kTeal.withOpacity(0.3)),
//               ),
//               child: Row(
//                 children: [
//                   const Icon(Icons.access_time, size: 16, color: kTeal),
//                   const SizedBox(width: 8),
//                   Text(
//                     selectedSlot!.timeDisplay,
//                     style: const TextStyle(
//                       fontSize: 14,
//                       fontWeight: FontWeight.w700,
//                       color: kTeal,
//                     ),
//                   ),
//                 ],
//               ),
//             )
//           else
//             Container(
//               padding: const EdgeInsets.all(12),
//               decoration: BoxDecoration(
//                 color: kTextGrey.withOpacity(0.08),
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               child: const Text(
//                 'Select a time slot from the list',
//                 style: TextStyle(fontSize: 12, color: kTextGrey),
//               ),
//             ),
//           const SizedBox(height: 16),
//           // Doctor dropdown
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
//             decoration: BoxDecoration(
//               border: Border.all(color: kBorder),
//               borderRadius: BorderRadius.circular(8),
//               color: kWhite,
//             ),
//             child: DropdownButtonHideUnderline(
//               child: DropdownButton<Doctor>(
//                 value: selectedDoctor,
//                 isExpanded: true,
//                 hint: const Text('Select Doctor', style: TextStyle(fontSize: 13)),
//                 icon: const Icon(Icons.keyboard_arrow_down, size: 18),
//                 items: doctors.map((d) => DropdownMenuItem(
//                   value: d,
//                   child: Text('${d.name} - ${d.department}', style: const TextStyle(fontSize: 13)),
//                 )).toList(),
//                 onChanged: onDoctorChanged,
//               ),
//             ),
//           ),
//           const SizedBox(height: 12),
//           // Patient Name
//           _BookingField(
//             controller: patientNameController,
//             hint: 'Patient Name',
//             enabled: true,
//           ),
//           const SizedBox(height: 12),
//           // Phone
//           _BookingField(
//             controller: phoneController,
//             hint: 'Enter phone number',
//             enabled: true,
//           ),
//           const SizedBox(height: 12),
//           // Reason
//           _BookingField(
//             controller: reasonController,
//             hint: 'Reason for Visit',
//             enabled: true,
//             maxLines: 3,
//           ),
//           const SizedBox(height: 20),
//           // Action buttons
//           Row(
//             children: [
//               Expanded(
//                 child: OutlinedButton(
//                   onPressed: onCancel,
//                   style: OutlinedButton.styleFrom(
//                     side: const BorderSide(color: kBorder),
//                     padding: const EdgeInsets.symmetric(vertical: 12),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                   ),
//                   child: const Text(
//                     'Cancel',
//                     style: TextStyle(color: kTextDark, fontSize: 14),
//                   ),
//                 ),
//               ),
//               const SizedBox(width: 12),
//               Expanded(
//                 child: ElevatedButton(
//                   onPressed: isBooking? null : onBookAppointment,
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: kTeal,
//                     padding: const EdgeInsets.symmetric(vertical: 12),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                   ),
//                   child: isBooking
//                      ? const SizedBox(
//                           width: 16,
//                           height: 16,
//                           child: CircularProgressIndicator(
//                             strokeWidth: 2,
//                             color: kWhite,
//                           ),
//                         )
//                       : const Text(
//                           'Book Appointment',
//                           style: TextStyle(color: kWhite, fontSize: 14, fontWeight: FontWeight.w600),
//                         ),
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _BookingField extends StatelessWidget {
//   final TextEditingController controller;
//   final String hint;
//   final bool enabled;
//   final int maxLines;

//   const _BookingField({
//     required this.controller,
//     required this.hint,
//     this.enabled = true,
//     this.maxLines = 1,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return TextField(
//       controller: controller,
//       enabled: enabled,
//       maxLines: maxLines,
//       style: const TextStyle(fontSize: 13),
//       decoration: InputDecoration(
//         hintText: hint,
//         hintStyle: const TextStyle(color: kTextGrey, fontSize: 13),
//         filled: true,
//         fillColor: kWhite,
//         contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(8),
//           borderSide: const BorderSide(color: kBorder),
//         ),
//         enabledBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(8),
//           borderSide: const BorderSide(color: kBorder),
//         ),
//         focusedBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(8),
//           borderSide: const BorderSide(color: kTeal, width: 1.5),
//         ),
//       ),
//     );
//   }
// }

// // TopBar and Footer - reuse from previous code
// class TopBar extends StatefulWidget {
//   final Uint8List? profileImageBytes;
//   final ValueChanged<Uint8List> onProfileImageChanged;
//   final VoidCallback onLogout;
//   final VoidCallback onGoToProfile;

//   const TopBar({
//     super.key,
//     required this.profileImageBytes,
//     required this.onProfileImageChanged,
//     required this.onLogout,
//     required this.onGoToProfile,
//   });

//   @override
//   State<TopBar> createState() => _TopBarState();
// }

// class _TopBarState extends State<TopBar> {
//   final _searchController = TextEditingController();
//   final LayerLink _layerLink = LayerLink();
//   OverlayEntry? _overlayEntry;
//   Timer? _hideTimer;
//   bool _isHoveringBadge = false;
//   bool _isHoveringMenu = false;

//   @override
//   void dispose() {
//     _searchController.dispose();
//     _hideTimer?.cancel();
//     _removeOverlay();
//     super.dispose();
//   }

//   void _showAdminMenu() {
//     _hideTimer?.cancel();
//     if (_overlayEntry!= null) return;
//     _overlayEntry = OverlayEntry(
//       builder: (_) => Positioned(
//         width: 150,
//         child: CompositedTransformFollower(
//           link: _layerLink,
//           showWhenUnlinked: false,
//           offset: const Offset(-40, 38),
//           child: MouseRegion(
//             onEnter: (_) {
//               _isHoveringMenu = true;
//               _hideTimer?.cancel();
//             },
//             onExit: (_) {
//               _isHoveringMenu = false;
//               _scheduleHide();
//             },
//             child: Material(
//               elevation: 8,
//               borderRadius: BorderRadius.circular(10),
//               child: Container(
//                 decoration: BoxDecoration(
//                   color: kWhite,
//                   borderRadius: BorderRadius.circular(10),
//                   border: Border.all(color: Colors.grey.shade200),
//                 ),
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     TextButton.icon(
//                       onPressed: () {
//                         _removeOverlay();
//                         widget.onGoToProfile();
//                       },
//                       icon: const Icon(Icons.person_outline, size: 16, color: kTeal),
//                       label: const Text('Profile', style: TextStyle(color: kTextDark, fontSize: 13)),
//                       style: TextButton.styleFrom(
//                         alignment: Alignment.centerLeft,
//                         padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
//                       ),
//                     ),
//                     Divider(height: 1, color: Colors.grey.shade200),
//                     TextButton.icon(
//                       onPressed: () {
//                         _removeOverlay();
//                         widget.onLogout();
//                       },
//                       icon: const Icon(Icons.logout, size: 16, color: Colors.red),
//                       label: const Text('Logout', style: TextStyle(color: Colors.red, fontSize: 13)),
//                       style: TextButton.styleFrom(
//                         alignment: Alignment.centerLeft,
//                         padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//     Overlay.of(context).insert(_overlayEntry!);
//   }

//   void _scheduleHide() {
//     _hideTimer?.cancel();
//     _hideTimer = Timer(const Duration(milliseconds: 200), () {
//       if (!_isHoveringBadge &&!_isHoveringMenu) _removeOverlay();
//     });
//   }

//   void _removeOverlay() {
//     _overlayEntry?.remove();
//     _overlayEntry = null;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       color: kWhite,
//       padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
//       child: Row(
//         children: [
//           Row(
//             children: [
//               SizedBox(
//                 width: 38,
//                 height: 38,
//                 child: Image.asset(
//                   'assets/images/Group.png',
//                   fit: BoxFit.contain,
//                   errorBuilder: (_, __, ___) => const Icon(Icons.local_hospital, color: kTeal, size: 32),
//                 ),
//               ),
//               const SizedBox(width: 10),
//               const Text(
//                 'Heathos',
//                 style: TextStyle(
//                   color: kTeal,
//                   fontSize: 22,
//                   fontWeight: FontWeight.w700,
//                 ),
//               ),
//               const SizedBox(width: 16),
//               Align(alignment: Alignment.center,
//               child: Text(
//                 'Appointment Booking',
//                 style: TextStyle(
//                   color: const Color.fromARGB(255, 17, 22, 21), fontSize: 20, fontWeight: FontWeight.w500),
//               ),
//               ),

//             ],
//           ),
//           const Spacer(),
//           Stack(
//             clipBehavior: Clip.none,
//             children: [
//               Container(
//                 width: 40,
//                 height: 40,
//                 decoration: BoxDecoration(
//                   shape: BoxShape.circle,
//                   border: Border.all(color: kTeal, width: 1.5),
//                 ),
//                 child: const Icon(Icons.notifications_rounded, color: kTeal, size: 20),
//               ),
//               Positioned(
//                 top: -4,
//                 right: -2,
//                 child: Container(
//                   width: 14,
//                   height: 14,
//                   decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
//                   child: const Center(
//                     child: Text('3', style: TextStyle(color: kWhite, fontSize: 8, fontWeight: FontWeight.bold)),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(width: 16),
//           CompositedTransformTarget(
//             link: _layerLink,
//             child: MouseRegion(
//               cursor: SystemMouseCursors.click,
//               onEnter: (_) {
//                 _isHoveringBadge = true;
//                 _hideTimer?.cancel();
//                 _showAdminMenu();
//               },
//               onExit: (_) {
//                 _isHoveringBadge = false;
//                 _scheduleHide();
//               },
//               child: GestureDetector(
//                 onTap: () {
//                   if (_overlayEntry == null) {
//                     _showAdminMenu();
//                   } else {
//                     _removeOverlay();
//                   }
//                 },
//                 child: Container(
//                   padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                   decoration: BoxDecoration(
//                     color: kCardBg,
//                     borderRadius: BorderRadius.circular(20),
//                     border: Border.all(color: kBorder),
//                   ),
//                   child: Row(
//                     children: [
//                       Container(
//                         width: 32,
//                         height: 32,
//                         decoration: BoxDecoration(
//                           color: kTealAccent,
//                           shape: BoxShape.circle,
//                         ),
//                         child: widget.profileImageBytes!= null
//                            ? ClipOval(child: Image.memory(widget.profileImageBytes!, fit: BoxFit.cover))
//                             : const Icon(Icons.person, color: kWhite, size: 18),
//                       ),
//                       const SizedBox(width: 8),
//                       const Text('farencer', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
//                       const SizedBox(width: 4),
//                       const Icon(Icons.keyboard_arrow_down, size: 18),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class Footer extends StatelessWidget {
//   const Footer({super.key});
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.symmetric(vertical: 12),
//       color: kBackground,
//       child: const Center(
//         child: Text(
//           'Copyright © A2026.Designed by Group 5',
//           style: TextStyle(color: kTeal, fontSize: 13, fontWeight: FontWeight.w600),
//         ),
//       ),
//     );
//   }
// }

import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';

import 'constants/api_constants.dart';
import 'admin_login_page.dart';
import 'admin_dashboard.dart';

// ─── CONSTANTS ───────────────────────────────────────────────────────────────
const kTeal = Color(0xFF0D7B6B);
const kTealLight = Color(0xFF1A9E8A);
const kTealDark = Color(0xFF095F54);
const kTealAccent = Color(0xFF4FC3B0);
const kBackground = Color(0xFFF0F4F4);
const kWhite = Color(0xFFFFFFFF);
const kTextDark = Color(0xFF1A2E2C);
const kTextGrey = Color(0xFF7A9490);
const kCardBg = Color(0xFFFFFFFF);
const kSuccess = Color(0xFF4CAF50);
const kWarning = Color(0xFFFF9800);
const kError = Color(0xFFF44336);
const kBorder = Color(0xFFE0E0E0);

const String _baseUrl = kApiBaseUrl;

// ─── MODELS ─────────────────────────────────────────────────────────────────
enum AppointmentType { IN_PERSON, VIRTUAL }

enum AppointmentStatus { SCHEDULED, CHECKED_IN, COMPLETED, CANCELLED }

class Doctor {
  final String id;
  final String name;
  final String department;
  final String? avatarUrl;

  const Doctor({
    required this.id,
    required this.name,
    required this.department,
    this.avatarUrl,
  });

  factory Doctor.fromJson(Map<String, dynamic> json) => Doctor(
    id: json['id'] ?? '',
    name: json['fullName'] ?? json['name'] ?? 'Unknown',
    department: json['department'] ?? 'General',
    avatarUrl: json['avatarUrl'],
  );
}

class Patient {
  final String id;
  final String name;
  final String phone;
  final String? avatarUrl;

  const Patient({
    required this.id,
    required this.name,
    required this.phone,
    this.avatarUrl,
  });

  factory Patient.fromJson(Map<String, dynamic> json) => Patient(
    id: json['id'] ?? '',
    name: json['fullName'] ?? json['name'] ?? 'Unknown',
    phone: json['phoneNumber'] ?? json['phone'] ?? '',
    avatarUrl: json['avatarUrl'],
  );
}

class AppointmentSlot {
  final String datetime; // "2025-01-20T08:00:00"
  final bool isBooked;

  const AppointmentSlot({required this.datetime, required this.isBooked});

  factory AppointmentSlot.fromJson(Map<String, dynamic> json) =>
      AppointmentSlot(
        datetime: json['slotDatetime'] ?? json['datetime'] ?? '',
        isBooked: json['isBooked'] ?? false,
      );

  String get timeDisplay {
    try {
      final dt = DateTime.parse(datetime);
      return DateFormat('h:mma').format(dt).toLowerCase();
    } catch (_) {
      return datetime;
    }
  }
}

class Appointment {
  final String id;
  final String patientId;
  final String patientName;
  final String? patientAvatar;
  final String doctorId;
  final String slotDatetime;
  final AppointmentStatus status;
  final AppointmentType type;

  const Appointment({
    required this.id,
    required this.patientId,
    required this.patientName,
    this.patientAvatar,
    required this.doctorId,
    required this.slotDatetime,
    required this.status,
    required this.type,
  });

  factory Appointment.fromJson(Map<String, dynamic> json) => Appointment(
    id: json['id'] ?? '',
    patientId: json['patientId'] ?? '',
    patientName: json['patientName'] ?? json['patient']?['name'] ?? 'Unknown',
    patientAvatar: json['patientAvatar'] ?? json['patient']?['avatarUrl'],
    doctorId: json['doctorId'] ?? '',
    slotDatetime: json['slotDatetime'] ?? '',
    status: _parseStatus(json['status']),
    type: json['type'] == 'VIRTUAL'
        ? AppointmentType.VIRTUAL
        : AppointmentType.IN_PERSON,
  );

  static AppointmentStatus _parseStatus(String? status) {
    switch (status?.toUpperCase()) {
      case 'CHECKED_IN':
        return AppointmentStatus.CHECKED_IN;
      case 'COMPLETED':
        return AppointmentStatus.COMPLETED;
      case 'CANCELLED':
        return AppointmentStatus.CANCELLED;
      default:
        return AppointmentStatus.SCHEDULED;
    }
  }

  String get timeDisplay {
    try {
      final dt = DateTime.parse(slotDatetime);
      return DateFormat('h:mma').format(dt).toLowerCase();
    } catch (_) {
      return slotDatetime;
    }
  }
}

class SearchResult {
  final String name;
  final String category;
  final String subtitle;
  const SearchResult({
    required this.name,
    required this.category,
    required this.subtitle,
  });
}

// ─── APPOINTMENT PAGE ───────────────────────────────────────────────────────
class AppointmentPage extends StatefulWidget {
  const AppointmentPage({super.key});

  @override
  State<AppointmentPage> createState() => _AppointmentPageState();
}

class _AppointmentPageState extends State<AppointmentPage> {
  Uint8List? _topBarProfileImageBytes;
  DateTime _selectedDate = DateTime.now();
  String _selectedDepartment = 'All Departments';
  Doctor? _selectedDoctor;
  Patient? _selectedPatient;
  AppointmentSlot? _selectedSlot;

  List<Doctor> _doctors = [];
  List<Patient> _patients = [];
  List<AppointmentSlot> _availableSlots = [];
  List<Appointment> _appointments = [];
  List<Appointment> _liveQueue = [];

  bool _isLoadingSlots = false;
  bool _isLoadingQueue = false;
  bool _isBooking = false;
  String? _errorMessage;
  Timer? _queuePollTimer;

  final _searchController = TextEditingController();
  final _patientNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _reasonController = TextEditingController();

  final List<String> _departments = [
    'All Departments',
    'General Medicine',
    'Pediatrics',
    'Cardiology',
    'Orthopedics',
    'Dermatology',
    'Neurology',
  ];

  @override
  void initState() {
    super.initState();
    _initData();
    _startQueuePolling();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _patientNameController.dispose();
    _phoneController.dispose();
    _reasonController.dispose();
    _queuePollTimer?.cancel();
    super.dispose();
  }

  Future<void> _initData() async {
    await Future.wait([_fetchDoctors(), _fetchPatients()]);
    if (_doctors.isNotEmpty) {
      _selectedDoctor = _doctors.first;
      await _loadSlotsAndQueue();
    }
  }

  void _startQueuePolling() {
    _queuePollTimer = Timer.periodic(const Duration(seconds: 15), (_) {
      if (_selectedDoctor != null) _fetchLiveQueue();
    });
  }

  Future<void> _loadSlotsAndQueue() async {
    await Future.wait([_fetchAvailableSlots(), _fetchLiveQueue()]);
  }

  Future<void> _fetchDoctors() async {
    try {
      final res = await http.get(Uri.parse('$_baseUrl/doctors'));
      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        final List data = body['data'] ?? body;
        if (!mounted) return;
        setState(() => _doctors = data.map((e) => Doctor.fromJson(e)).toList());
      }
    } catch (e) {
      _showError('Failed to load doctors: $e');
    }
  }

  Future<void> _fetchPatients() async {
    try {
      final res = await http.get(Uri.parse('$_baseUrl/patients'));
      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        final List data = body['data'] ?? body;
        if (!mounted) return;
        setState(
          () => _patients = data.map((e) => Patient.fromJson(e)).toList(),
        );
      }
    } catch (e) {
      _showError('Failed to load patients: $e');
    }
  }

  Future<void> _fetchAvailableSlots() async {
    if (_selectedDoctor == null) return;
    if (!mounted) return;
    setState(() => _isLoadingSlots = true);
    try {
      final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
      final res = await http.get(
        Uri.parse(
          '$_baseUrl/api/appointments/slots?doctor_id=${_selectedDoctor!.id}&date=$dateStr',
        ),
      );
      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        final List data = body['data'] ?? [];
        if (!mounted) return;
        setState(() {
          _availableSlots = data
              .map((e) => AppointmentSlot.fromJson(e))
              .toList();
          _isLoadingSlots = false;
        });
      } else {
        if (!mounted) return;
        setState(() => _isLoadingSlots = false);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoadingSlots = false);
      _showError('Failed to load slots: $e');
    }
  }

  Future<void> _fetchLiveQueue() async {
    if (_selectedDoctor == null) return;
    if (!mounted) return;
    setState(() => _isLoadingQueue = true);
    try {
      final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
      final res = await http.get(
        Uri.parse(
          '$_baseUrl/api/appointments/queue?doctor_id=${_selectedDoctor!.id}&date=$dateStr',
        ),
      );
      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        final List data = body['data'] ?? [];
        if (!mounted) return;
        setState(() {
          _liveQueue = data.map((e) => Appointment.fromJson(e)).toList();
          _isLoadingQueue = false;
        });
      } else {
        if (!mounted) return;
        setState(() => _isLoadingQueue = false);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoadingQueue = false);
    }
  }

  Future<void> _bookAppointment() async {
    if (_selectedPatient == null ||
        _selectedDoctor == null ||
        _selectedSlot == null) {
      _showError('Please select patient, doctor, and time slot');
      return;
    }

    if (!mounted) return;
    setState(() => _isBooking = true);
    try {
      final res = await http.post(
        Uri.parse('$_baseUrl/api/appointments'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'patientId': _selectedPatient!.id,
          'doctorId': _selectedDoctor!.id,
          'slotDatetime': _selectedSlot!.datetime,
          'type': 'IN_PERSON',
        }),
      );

      if (res.statusCode == 200) {
        _showSuccess('Appointment booked successfully');
        _clearBookingForm();
        await _loadSlotsAndQueue();
      } else if (res.statusCode == 409) {
        _showError('Slot already booked by another appointment');
        await _fetchAvailableSlots();
      } else {
        final body = jsonDecode(res.body);
        _showError(body['message'] ?? 'Failed to book appointment');
      }
    } catch (e) {
      _showError('Booking failed: $e');
    } finally {
      if (!mounted) return;
      setState(() => _isBooking = false);
    }
  }

  Future<void> _checkInPatient(String appointmentId) async {
    try {
      final res = await http.patch(
        Uri.parse('$_baseUrl/api/appointments/$appointmentId/checkin'),
      );
      if (res.statusCode == 200) {
        _showSuccess('Patient checked in');
        await _fetchLiveQueue();
      } else {
        final body = jsonDecode(res.body);
        _showError(body['message'] ?? 'Check-in failed');
      }
    } catch (e) {
      _showError('Check-in failed: $e');
    }
  }

  Future<void> _cancelAppointment(String appointmentId) async {
    try {
      final res = await http.patch(
        Uri.parse('$_baseUrl/api/appointments/$appointmentId/cancel'),
      );
      if (res.statusCode == 200) {
        _showSuccess('Appointment cancelled');
        await _loadSlotsAndQueue();
      } else {
        final body = jsonDecode(res.body);
        _showError(body['message'] ?? 'Cancel failed');
      }
    } catch (e) {
      _showError('Cancel failed: $e');
    }
  }

  void _clearBookingForm() {
    if (!mounted) return;
    setState(() {
      _selectedSlot = null;
      _selectedPatient = null;
      _patientNameController.clear();
      _phoneController.clear();
      _reasonController.clear();
    });
  }

  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(msg), backgroundColor: kError));
  }

  void _showSuccess(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(msg), backgroundColor: kSuccess));
  }

  void _goBack() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const AdminDashboard()),
    );
  }

  void _logout() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const AdminLoginPage()),
      (route) => false,
    );
  }

  List<Patient> get _filteredPatients {
    final query = _searchController.text.toLowerCase();
    if (query.isEmpty) return _patients;
    return _patients
        .where(
          (p) =>
              p.name.toLowerCase().contains(query) || p.phone.contains(query),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      body: Column(
        children: [
          TopBar(
            profileImageBytes: _topBarProfileImageBytes,
            onProfileImageChanged: (bytes) =>
                setState(() => _topBarProfileImageBytes = bytes),
            onLogout: _logout,
            onGoToProfile: () {},
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(28, 20, 28, 40),
              child: _AppointmentContent(
                selectedDate: _selectedDate,
                onDateChanged: (date) {
                  setState(() => _selectedDate = date);
                  _loadSlotsAndQueue();
                },
                selectedDepartment: _selectedDepartment,
                onDepartmentChanged: (dept) =>
                    setState(() => _selectedDepartment = dept),
                departments: _departments,
                selectedDoctor: _selectedDoctor,
                onDoctorChanged: (doc) {
                  setState(() => _selectedDoctor = doc);
                  _loadSlotsAndQueue();
                },
                doctors: _doctors,
                searchController: _searchController,
                filteredPatients: _filteredPatients,
                availableSlots: _availableSlots,
                liveQueue: _liveQueue,
                isLoadingSlots: _isLoadingSlots,
                selectedSlot: _selectedSlot,
                onSlotSelected: (slot) => setState(() => _selectedSlot = slot),
                selectedPatient: _selectedPatient,
                onPatientSelected: (p) {
                  setState(() {
                    _selectedPatient = p;
                    _patientNameController.text = p.name;
                    _phoneController.text = p.phone;
                  });
                },
                patientNameController: _patientNameController,
                phoneController: _phoneController,
                reasonController: _reasonController,
                onBookAppointment: _bookAppointment,
                onCancelBooking: _clearBookingForm,
                onCheckIn: _checkInPatient,
                onCancelAppointment: _cancelAppointment,
                isBooking: _isBooking,
                onBack: _goBack,
              ),
            ),
          ),
          const Footer(),
        ],
      ),
    );
  }
}

// ─── APPOINTMENT CONTENT ────────────────────────────────────────────────────
class _AppointmentContent extends StatelessWidget {
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateChanged;
  final String selectedDepartment;
  final ValueChanged<String> onDepartmentChanged;
  final List<String> departments;
  final Doctor? selectedDoctor;
  final ValueChanged<Doctor?> onDoctorChanged;
  final List<Doctor> doctors;
  final TextEditingController searchController;
  final List<Patient> filteredPatients;
  final List<AppointmentSlot> availableSlots;
  final List<Appointment> liveQueue;
  final bool isLoadingSlots;
  final AppointmentSlot? selectedSlot;
  final ValueChanged<AppointmentSlot> onSlotSelected;
  final Patient? selectedPatient;
  final ValueChanged<Patient> onPatientSelected;
  final TextEditingController patientNameController;
  final TextEditingController phoneController;
  final TextEditingController reasonController;
  final VoidCallback onBookAppointment;
  final VoidCallback onCancelBooking;
  final Function(String) onCheckIn;
  final Function(String) onCancelAppointment;
  final bool isBooking;
  final VoidCallback onBack;

  const _AppointmentContent({
    required this.selectedDate,
    required this.onDateChanged,
    required this.selectedDepartment,
    required this.onDepartmentChanged,
    required this.departments,
    required this.selectedDoctor,
    required this.onDoctorChanged,
    required this.doctors,
    required this.searchController,
    required this.filteredPatients,
    required this.availableSlots,
    required this.liveQueue,
    required this.isLoadingSlots,
    required this.selectedSlot,
    required this.onSlotSelected,
    required this.selectedPatient,
    required this.onPatientSelected,
    required this.patientNameController,
    required this.phoneController,
    required this.reasonController,
    required this.onBookAppointment,
    required this.onCancelBooking,
    required this.onCheckIn,
    required this.onCancelAppointment,
    required this.isBooking,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            InkWell(
              onTap: onBack,
              borderRadius: BorderRadius.circular(8),
              child: const Padding(
                padding: EdgeInsets.all(8.0),
                child: Icon(Icons.arrow_back, color: kTextDark, size: 24),
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              'Appointment Booking',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: kTextDark,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 280,
              child: _DateDepartmentPanel(
                selectedDate: selectedDate,
                onDateChanged: onDateChanged,
                selectedDepartment: selectedDepartment,
                onDepartmentChanged: onDepartmentChanged,
                departments: departments,
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: _CenterPanel(
                searchController: searchController,
                filteredPatients: filteredPatients,
                onPatientSelected: onPatientSelected,
                availableSlots: availableSlots,
                liveQueue: liveQueue,
                isLoadingSlots: isLoadingSlots,
                onCheckIn: onCheckIn,
                onCancelAppointment: onCancelAppointment,
                onSlotTap: onSlotSelected,
              ),
            ),
            const SizedBox(width: 20),
            SizedBox(
              width: 320,
              child: _BookingDrawer(
                selectedSlot: selectedSlot,
                selectedDoctor: selectedDoctor,
                doctors: doctors,
                onDoctorChanged: onDoctorChanged,
                patientNameController: patientNameController,
                phoneController: phoneController,
                reasonController: reasonController,
                onBookAppointment: onBookAppointment,
                onCancel: onCancelBooking,
                isBooking: isBooking,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _DateDepartmentPanel extends StatelessWidget {
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateChanged;
  final String selectedDepartment;
  final ValueChanged<String> onDepartmentChanged;
  final List<String> departments;

  const _DateDepartmentPanel({
    required this.selectedDate,
    required this.onDateChanged,
    required this.selectedDepartment,
    required this.onDepartmentChanged,
    required this.departments,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kCardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Select a date',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: kTextDark,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.access_time, size: 16, color: kTextGrey),
              const SizedBox(width: 6),
              const Text(
                '15 min appointments',
                style: TextStyle(fontSize: 12, color: kTextGrey),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              border: Border.all(color: kTeal),
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: selectedDepartment,
                isDense: true,
                isExpanded: true,
                icon: const Icon(
                  Icons.keyboard_arrow_down,
                  size: 18,
                  color: kTeal,
                ),
                items: departments
                    .map(
                      (d) => DropdownMenuItem(
                        value: d,
                        child: Row(
                          children: [
                            Icon(
                              Icons.medical_services_outlined,
                              size: 16,
                              color: kTeal,
                            ),
                            const SizedBox(width: 6),
                            Text(d, style: const TextStyle(fontSize: 13)),
                          ],
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (v) => onDepartmentChanged(v!),
              ),
            ),
          ),
          const SizedBox(height: 16),
          _MiniCalendar(
            selectedDate: selectedDate,
            onDateSelected: onDateChanged,
          ),
        ],
      ),
    );
  }
}

class _MiniCalendar extends StatelessWidget {
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateSelected;

  const _MiniCalendar({
    required this.selectedDate,
    required this.onDateSelected,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final firstDay = DateTime(selectedDate.year, selectedDate.month, 1);
    final daysInMonth = DateTime(
      selectedDate.year,
      selectedDate.month + 1,
      0,
    ).day;
    final startWeekday = firstDay.weekday % 7;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              DateFormat('E, MMMM d').format(selectedDate),
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
            ),
            Row(
              children: [
                InkWell(
                  onTap: () => onDateSelected(
                    DateTime(selectedDate.year, selectedDate.month - 1, 1),
                  ),
                  child: const Icon(Icons.chevron_left, size: 20),
                ),
                const SizedBox(width: 8),
                InkWell(
                  onTap: () => onDateSelected(
                    DateTime(selectedDate.year, selectedDate.month + 1, 1),
                  ),
                  child: const Icon(Icons.chevron_right, size: 20),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: ['S', 'M', 'T', 'W', 'T', 'F', 'S']
              .map(
                (d) => SizedBox(
                  width: 28,
                  child: Text(
                    d,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 11, color: kTextGrey),
                  ),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 8),
        ...List.generate(6, (week) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(7, (day) {
                final dayNum = week * 7 + day - startWeekday + 1;
                if (dayNum < 1 || dayNum > daysInMonth) {
                  return const SizedBox(width: 28, height: 28);
                }
                final date = DateTime(
                  selectedDate.year,
                  selectedDate.month,
                  dayNum,
                );
                final isSelected =
                    date.day == selectedDate.day &&
                    date.month == selectedDate.month &&
                    date.year == selectedDate.year;
                final isToday =
                    date.day == now.day &&
                    date.month == now.month &&
                    date.year == now.year;

                return InkWell(
                  onTap: () => onDateSelected(date),
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? kTeal
                          : isToday
                          ? kTeal.withOpacity(0.1)
                          : null,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '$dayNum',
                        style: TextStyle(
                          fontSize: 12,
                          color: isSelected ? kWhite : kTextDark,
                          fontWeight: isSelected || isToday
                              ? FontWeight.w700
                              : FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          );
        }),
      ],
    );
  }
}

class _CenterPanel extends StatelessWidget {
  final TextEditingController searchController;
  final List<Patient> filteredPatients;
  final ValueChanged<Patient> onPatientSelected;
  final List<AppointmentSlot> availableSlots;
  final List<Appointment> liveQueue;
  final bool isLoadingSlots;
  final Function(String) onCheckIn;
  final Function(String) onCancelAppointment;
  final ValueChanged<AppointmentSlot> onSlotTap;

  const _CenterPanel({
    required this.searchController,
    required this.filteredPatients,
    required this.onPatientSelected,
    required this.availableSlots,
    required this.liveQueue,
    required this.isLoadingSlots,
    required this.onCheckIn,
    required this.onCancelAppointment,
    required this.onSlotTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 44,
          decoration: BoxDecoration(
            border: Border.all(color: kBorder),
            borderRadius: BorderRadius.circular(22),
          ),
          child: Row(
            children: [
              const SizedBox(width: 14),
              const Icon(Icons.search, color: kTextGrey, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: searchController,
                  decoration: const InputDecoration(
                    hintText: 'Search Patients...',
                    border: InputBorder.none,
                    isDense: true,
                  ),
                  onChanged: (_) {},
                ),
              ),
              const Icon(Icons.keyboard_arrow_down, color: kTextGrey, size: 20),
              const SizedBox(width: 14),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _SlotsSection(
          title: 'Appointment Slots',
          slots: availableSlots,
          isLoading: isLoadingSlots,
          onSlotTap: onSlotTap,
        ),
        const SizedBox(height: 16),
        _QueueSection(
          appointments: liveQueue,
          onCheckIn: onCheckIn,
          onCancel: onCancelAppointment,
        ),
      ],
    );
  }
}

class _SlotsSection extends StatelessWidget {
  final String title;
  final List<AppointmentSlot> slots;
  final bool isLoading;
  final ValueChanged<AppointmentSlot> onSlotTap;

  const _SlotsSection({
    required this.title,
    required this.slots,
    required this.isLoading,
    required this.onSlotTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: kCardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kBorder),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: Row(
                    children: const [
                      Text(
                        'View all',
                        style: TextStyle(color: kTeal, fontSize: 13),
                      ),
                      Icon(Icons.chevron_right, size: 18, color: kTeal),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (isLoading)
            const Padding(
              padding: EdgeInsets.all(32),
              child: CircularProgressIndicator(color: kTeal),
            )
          else if (slots.isEmpty)
            const Padding(
              padding: EdgeInsets.all(32),
              child: Text(
                'No available slots',
                style: TextStyle(color: kTextGrey),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: slots.length > 5 ? 5 : slots.length,
              separatorBuilder: (_, __) => Divider(height: 1, color: kBorder),
              itemBuilder: (_, i) {
                final slot = slots[i];
                return InkWell(
                  onTap: () => onSlotTap(slot),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: Text(
                            'Available',
                            style: const TextStyle(fontSize: 13),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            slot.timeDisplay,
                            style: const TextStyle(fontSize: 13),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: kSuccess.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'Open',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 12,
                                color: kSuccess,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: TextButton(
                            onPressed: () => onSlotTap(slot),
                            child: const Text(
                              'Select',
                              style: TextStyle(color: kTeal, fontSize: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}

class _QueueSection extends StatelessWidget {
  final List<Appointment> appointments;
  final Function(String) onCheckIn;
  final Function(String) onCancel;

  const _QueueSection({
    required this.appointments,
    required this.onCheckIn,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: kCardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kBorder),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Live Queue',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
                Text(
                  '${appointments.length} patients',
                  style: const TextStyle(fontSize: 13, color: kTextGrey),
                ),
              ],
            ),
          ),
          if (appointments.isEmpty)
            const Padding(
              padding: EdgeInsets.all(32),
              child: Text(
                'No patients in queue',
                style: TextStyle(color: kTextGrey),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: appointments.length,
              separatorBuilder: (_, __) => Divider(height: 1, color: kBorder),
              itemBuilder: (_, i) {
                final apt = appointments[i];
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      // Patient avatar + name
                      Expanded(
                        flex: 3,
                        child: Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: kTealAccent.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: apt.patientAvatar != null
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(4),
                                      child: Image.network(
                                        apt.patientAvatar!,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) =>
                                            const Icon(
                                              Icons.person,
                                              size: 18,
                                              color: kTeal,
                                            ),
                                      ),
                                    )
                                  : const Icon(
                                      Icons.person,
                                      size: 18,
                                      color: kTeal,
                                    ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                apt.patientName,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Time
                      Expanded(
                        flex: 2,
                        child: Text(
                          apt.timeDisplay,
                          style: const TextStyle(fontSize: 13),
                        ),
                      ),
                      // Status badge
                      Expanded(
                        flex: 2,
                        child: _StatusBadge(status: apt.status),
                      ),
                      // Actions
                      Expanded(
                        flex: 3,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            if (apt.status == AppointmentStatus.SCHEDULED)
                              _ActionButton(
                                label: 'Check In',
                                color: kSuccess,
                                onTap: () => onCheckIn(apt.id),
                              )
                            else if (apt.status == AppointmentStatus.CHECKED_IN)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: kWarning.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  'In Queue',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: kWarning,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            const SizedBox(width: 8),
                            if (apt.status != AppointmentStatus.COMPLETED)
                              _ActionButton(
                                label: 'Cancel',
                                color: kError,
                                onTap: () => onCancel(apt.id),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          const SizedBox(height: 8),
          if (appointments.length > 3)
            TextButton(
              onPressed: () {},
              child: const Text(
                'See all in queue >',
                style: TextStyle(color: kTeal, fontSize: 13),
              ),
            ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final AppointmentStatus status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color textColor;
    String label;

    switch (status) {
      case AppointmentStatus.SCHEDULED:
        bgColor = kTeal.withOpacity(0.15);
        textColor = kTeal;
        label = 'Confirmed';
        break;
      case AppointmentStatus.CHECKED_IN:
        bgColor = kWarning.withOpacity(0.15);
        textColor = kWarning;
        label = 'Checked In';
        break;
      case AppointmentStatus.COMPLETED:
        bgColor = kSuccess.withOpacity(0.15);
        textColor = kSuccess;
        label = 'Completed';
        break;
      case AppointmentStatus.CANCELLED:
        bgColor = kError.withOpacity(0.15);
        textColor = kError;
        label = 'Cancelled';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 12,
          color: textColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          border: Border.all(color: color),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

// ─── BOOKING DRAWER ─────────────────────────────────────────────────────────
class _BookingDrawer extends StatelessWidget {
  final AppointmentSlot? selectedSlot;
  final Doctor? selectedDoctor;
  final List<Doctor> doctors;
  final ValueChanged<Doctor?> onDoctorChanged;
  final TextEditingController patientNameController;
  final TextEditingController phoneController;
  final TextEditingController reasonController;
  final VoidCallback onBookAppointment;
  final VoidCallback onCancel;
  final bool isBooking;

  const _BookingDrawer({
    required this.selectedSlot,
    required this.selectedDoctor,
    required this.doctors,
    required this.onDoctorChanged,
    required this.patientNameController,
    required this.phoneController,
    required this.reasonController,
    required this.onBookAppointment,
    required this.onCancel,
    required this.isBooking,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: kCardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: kWarning.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.person_outline,
                  color: kWarning,
                  size: 18,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'Selected Slot for Booking',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Book Appointment for Patient',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: kTextDark,
            ),
          ),
          const SizedBox(height: 16),
          // Selected time display
          if (selectedSlot != null)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: kTeal.withOpacity(0.08),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: kTeal.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.access_time, size: 16, color: kTeal),
                  const SizedBox(width: 8),
                  Text(
                    selectedSlot!.timeDisplay,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: kTeal,
                    ),
                  ),
                ],
              ),
            )
          else
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: kTextGrey.withOpacity(0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Select a time slot from the list',
                style: TextStyle(fontSize: 12, color: kTextGrey),
              ),
            ),
          const SizedBox(height: 16),
          // Doctor dropdown
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              border: Border.all(color: kBorder),
              borderRadius: BorderRadius.circular(8),
              color: kWhite,
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<Doctor>(
                value: selectedDoctor,
                isExpanded: true,
                hint: const Text(
                  'Select Doctor',
                  style: TextStyle(fontSize: 13),
                ),
                icon: const Icon(Icons.keyboard_arrow_down, size: 18),
                items: doctors
                    .map(
                      (d) => DropdownMenuItem(
                        value: d,
                        child: Text(
                          '${d.name} - ${d.department}',
                          style: const TextStyle(fontSize: 13),
                        ),
                      ),
                    )
                    .toList(),
                onChanged: onDoctorChanged,
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Patient Name
          _BookingField(
            controller: patientNameController,
            hint: 'Patient Name',
            enabled: true,
          ),
          const SizedBox(height: 12),
          // Phone
          _BookingField(
            controller: phoneController,
            hint: 'Enter phone number',
            enabled: true,
          ),
          const SizedBox(height: 12),
          // Reason
          _BookingField(
            controller: reasonController,
            hint: 'Reason for Visit',
            enabled: true,
            maxLines: 3,
          ),
          const SizedBox(height: 20),
          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onCancel,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: kBorder),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: kTextDark, fontSize: 14),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: isBooking ? null : onBookAppointment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kTeal,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: isBooking
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: kWhite,
                          ),
                        )
                      : const Text(
                          'Book Appointment',
                          style: TextStyle(
                            color: kWhite,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
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

class _BookingField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final bool enabled;
  final int maxLines;

  const _BookingField({
    required this.controller,
    required this.hint,
    this.enabled = true,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      enabled: enabled,
      maxLines: maxLines,
      style: const TextStyle(fontSize: 13),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: kTextGrey, fontSize: 13),
        filled: true,
        fillColor: kWhite,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: kBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: kBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: kTeal, width: 1.5),
        ),
      ),
    );
  }
}

// TopBar and Footer - reuse from previous code
class TopBar extends StatefulWidget {
  final Uint8List? profileImageBytes;
  final ValueChanged<Uint8List> onProfileImageChanged;
  final VoidCallback onLogout;
  final VoidCallback onGoToProfile;

  const TopBar({
    super.key,
    required this.profileImageBytes,
    required this.onProfileImageChanged,
    required this.onLogout,
    required this.onGoToProfile,
  });

  @override
  State<TopBar> createState() => _TopBarState();
}

class _TopBarState extends State<TopBar> {
  final _searchController = TextEditingController();
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  Timer? _hideTimer;
  bool _isHoveringBadge = false;
  bool _isHoveringMenu = false;
  List<SearchResult> _searchResults = [];
  bool _isSearching = false;
  Timer? _debounce;

  @override
  void dispose() {
    _searchController.dispose();
    _hideTimer?.cancel();
    _debounce?.cancel();
    _removeOverlay();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _debounce?.cancel();
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }
    _debounce = Timer(
      const Duration(milliseconds: 400),
      () => _runSearch(query.trim()),
    );
  }

  // DO NOT TOUCH - User specified block
  Future<void> _runSearch(String query) async {
    setState(() => _isSearching = true);

    final endpoints = {
      'Doctor': '$_baseUrl/doctors/search?q=$query',
      'Patient': '$_baseUrl/patients/search?q=$query',
      'Nurse': '$_baseUrl/nurses/search?q=$query',
      'Staff': '$_baseUrl/staff/search?q=$query',
    };

    final results = <SearchResult>[];
    final errors = <String>[]; // Track failed endpoints

    await Future.wait(
      endpoints.entries.map((entry) async {
        try {
          final response = await http
              .get(Uri.parse(entry.value))
              .timeout(const Duration(seconds: 30));

          if (response.statusCode == 200) {
            final body = jsonDecode(response.body);
            final List<dynamic> items = body is List
                ? body
                : (body['data'] as List? ?? []);
            for (final item in items) {
              results.add(
                SearchResult(
                  name:
                      item['fullName'] as String? ??
                      item['name'] as String? ??
                      'Unknown',
                  category: entry.key,
                  subtitle:
                      item['email'] as String? ?? item['id'] as String? ?? '',
                ),
              );
            }
          } else {
            // Non-200 response
            errors.add('${entry.key}: HTTP ${response.statusCode}');
            debugPrint(
              'Search failed for ${entry.key}: ${response.statusCode} ${response.body}',
            );
          }
        } on TimeoutException {
          errors.add('${entry.key}: Request timed out');
          debugPrint('Search timeout for ${entry.key}');
        } on FormatException catch (e) {
          errors.add('${entry.key}: Invalid JSON');
          debugPrint('Search JSON error for ${entry.key}: $e');
        } catch (e) {
          errors.add('${entry.key}: $e');
          debugPrint('Search error for ${entry.key}: $e');
        }
      }),
    );

    if (mounted) {
      setState(() {
        _searchResults = results;
        _isSearching = false;
      });

      // Show error snackbar if any endpoint failed
      if (errors.isNotEmpty && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Search errors: ${errors.join(', ')}'),
            backgroundColor: Colors.orange.shade700,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  void _showAdminMenu() {
    _hideTimer?.cancel();
    if (_overlayEntry != null) return;
    _overlayEntry = OverlayEntry(
      builder: (_) => Positioned(
        width: 150,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: const Offset(-40, 38),
          child: MouseRegion(
            onEnter: (_) {
              _isHoveringMenu = true;
              _hideTimer?.cancel();
            },
            onExit: (_) {
              _isHoveringMenu = false;
              _scheduleHide();
            },
            child: Material(
              elevation: 8,
              borderRadius: BorderRadius.circular(10),
              child: Container(
                decoration: BoxDecoration(
                  color: kWhite,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextButton.icon(
                      onPressed: () {
                        _removeOverlay();
                        widget.onGoToProfile();
                      },
                      icon: const Icon(
                        Icons.person_outline,
                        size: 16,
                        color: kTeal,
                      ),
                      label: const Text(
                        'Profile',
                        style: TextStyle(color: kTextDark, fontSize: 13),
                      ),
                      style: TextButton.styleFrom(
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                      ),
                    ),
                    Divider(height: 1, color: Colors.grey.shade200),
                    TextButton.icon(
                      onPressed: () {
                        _removeOverlay();
                        widget.onLogout();
                      },
                      icon: const Icon(
                        Icons.logout,
                        size: 16,
                        color: Colors.red,
                      ),
                      label: const Text(
                        'Logout',
                        style: TextStyle(color: Colors.red, fontSize: 13),
                      ),
                      style: TextButton.styleFrom(
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
    Overlay.of(context).insert(_overlayEntry!);
  }

  void _scheduleHide() {
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(milliseconds: 200), () {
      if (!_isHoveringBadge && !_isHoveringMenu) _removeOverlay();
    });
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
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
      color: kWhite,
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
      child: Row(
        children: [
          Row(
            children: [
              SizedBox(
                width: 38,
                height: 38,
                child: Image.asset(
                  'assets/images/Group.png',
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) =>
                      const Icon(Icons.local_hospital, color: kTeal, size: 32),
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'Heathos',
                style: TextStyle(
                  color: kTeal,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 16),
              Align(
                alignment: Alignment.center,
                child: Text(
                  'Appointment Booking',
                  style: TextStyle(
                    color: const Color.fromARGB(255, 17, 22, 21),
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const Spacer(),
          SizedBox(
            width: 260,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: 40,
                  decoration: BoxDecoration(
                    border: Border.all(color: kTeal, width: 1.5),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      const SizedBox(width: 14),
                      const Icon(
                        Icons.search_rounded,
                        color: kTextGrey,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          onChanged: _onSearchChanged,
                          decoration: const InputDecoration(
                            hintText: 'Search',
                            hintStyle: TextStyle(
                              color: kTextGrey,
                              fontSize: 14,
                            ),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ),
                      _isSearching
                          ? const SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(
                                strokeWidth: 1.5,
                                color: kTeal,
                              ),
                            )
                          : const Icon(
                              Icons.mic_rounded,
                              color: kTextGrey,
                              size: 18,
                            ),
                      const SizedBox(width: 14),
                    ],
                  ),
                ),
                if (_searchResults.isNotEmpty)
                  Container(
                    constraints: const BoxConstraints(maxHeight: 260),
                    margin: const EdgeInsets.only(top: 4),
                    decoration: BoxDecoration(
                      color: kWhite,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey.shade200),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ListView.separated(
                      shrinkWrap: true,
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      itemCount: _searchResults.length,
                      separatorBuilder: (_, __) =>
                          Divider(height: 1, color: Colors.grey.shade100),
                      itemBuilder: (_, i) {
                        final r = _searchResults[i];
                        return ListTile(
                          dense: true,
                          leading: CircleAvatar(
                            radius: 14,
                            backgroundColor: kTeal.withOpacity(0.12),
                            child: Text(
                              r.category[0],
                              style: const TextStyle(
                                fontSize: 11,
                                color: kTeal,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          title: Text(
                            r.name,
                            style: const TextStyle(
                              fontSize: 13,
                              color: kTextDark,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle: Text(
                            '${r.category} · ${r.subtitle}',
                            style: const TextStyle(
                              fontSize: 11,
                              color: kTextGrey,
                            ),
                          ),
                          onTap: () {
                            _searchController.clear();
                            setState(() => _searchResults = []);
                          },
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: kTeal, width: 1.5),
                ),
                child: const Icon(
                  Icons.notifications_rounded,
                  color: kTeal,
                  size: 20,
                ),
              ),
              Positioned(
                top: -4,
                right: -2,
                child: Container(
                  width: 14,
                  height: 14,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Text(
                      '3',
                      style: TextStyle(
                        color: kWhite,
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          CompositedTransformTarget(
            link: _layerLink,
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              onEnter: (_) {
                _isHoveringBadge = true;
                _hideTimer?.cancel();
                _showAdminMenu();
              },
              onExit: (_) {
                _isHoveringBadge = false;
                _scheduleHide();
              },
              child: GestureDetector(
                onTap: () {
                  if (_overlayEntry == null) {
                    _showAdminMenu();
                  } else {
                    _removeOverlay();
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: kCardBg,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: kBorder),
                  ),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: _pickProfileImage,
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: kTealAccent,
                            shape: BoxShape.circle,
                          ),
                          child: widget.profileImageBytes != null
                              ? ClipOval(
                                  child: Image.memory(
                                    widget.profileImageBytes!,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : const Icon(
                                  Icons.person,
                                  color: kWhite,
                                  size: 18,
                                ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'VERA DUGAH',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.keyboard_arrow_down, size: 18),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class Footer extends StatelessWidget {
  const Footer({super.key});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      color: kBackground,
      child: const Center(
        child: Text(
          'Copyright © A2026.Designed by Group 5',
          style: TextStyle(
            color: kTeal,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

// import 'dart:async';
// import 'dart:convert';
// import 'dart:html' as html;
// import 'dart:typed_data';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:intl/intl.dart';

// // ─── CONSTANTS ───────────────────────────────────────────────────────────────
// const kTeal = Color(0xFF0D7B6B);
// const kTealLight = Color(0xFF1A9E8A);
// const kTealAccent = Color(0xFF4FC3B0);
// const kBackground = Color(0xFFF0F4F4);
// const kWhite = Color(0xFFFFFFFF);
// const kTextDark = Color(0xFF1A2E2C);
// const kTextGrey = Color(0xFF7A9490);
// const kCardBg = Color(0xFFFFFFFF);
// const kSuccess = Color(0xFF4CAF50);
// const kWarning = Color(0xFFFF9800);
// const kError = Color(0xFFF44336);
// const kBorder = Color(0xFFE0E0);
// const kUrgent = Color(0xFFFF5252);

// const String _BaseUrl = 'https://heathos-api.onrender.com';

// // ─── MODELS ─────────────────────────────────────────────────────────────────
// enum AppointmentStatus { SCHEDULED, CHECKED_IN, COMPLETED, CANCELLED }
// enum Urgency { NORMAL, URGENT }

// class QueuePatient {
//   final String appointmentId;
//   final String patientId;
//   final String patientName;
//   final String? patientAvatar;
//   final String slotTime;
//   final String? complaint;
//   final DateTime checkInTime;

//   const QueuePatient({
//     required this.appointmentId,
//     required this.patientId,
//     required this.patientName,
//     this.patientAvatar,
//     required this.slotTime,
//     this.complaint,
//     required this.checkInTime,
//   });

//   factory QueuePatient.fromJson(Map<String, dynamic> json) => QueuePatient(
//         appointmentId: json['id'] ?? '',
//         patientId: json['patientId'] ?? '',
//         patientName: json['patientName'] ?? 'Unknown',
//         patientAvatar: json['patientAvatar'],
//         slotTime: json['slotDatetime'] ?? '',
//         complaint: json['complaint'],
//         checkInTime: DateTime.tryParse(json['checkInTime'] ?? '') ?? DateTime.now(),
//       );

//   String get waitTime {
//     final diff = DateTime.now().difference(checkInTime);
//     if (diff.inMinutes < 60) return '${diff.inMinutes}m';
//     return '${diff.inHours}h ${diff.inMinutes % 60}m';
//   }
// }

// class PatientSummary {
//   final List<ClinicalNote> notes;
//   final List<VitalRecord> vitals;

//   const PatientSummary({required this.notes, required this.vitals});

//   factory PatientSummary.fromJson(Map<String, dynamic> json) => PatientSummary(
//         notes: (json['notes'] as List? ?? []).map((e) => ClinicalNote.fromJson(e)).toList(),
//         vitals: (json['vitals'] as List? ?? []).map((e) => VitalRecord.fromJson(e)).toList(),
//       );
// }

// class ClinicalNote {
//   final String id;
//   final String complaint;
//   final String findings;
//   final String plan;
//   final String diagnosis;
//   final bool hereditary;
//   final DateTime createdAt;
//   final List<Prescription> prescriptions;
//   final List<LabOrder> labOrders;

//   const ClinicalNote({
//     required this.id,
//     required this.complaint,
//     required this.findings,
//     required this.plan,
//     required this.diagnosis,
//     required this.hereditary,
//     required this.createdAt,
//     required this.prescriptions,
//     required this.labOrders,
//   });

//   factory ClinicalNote.fromJson(Map<String, dynamic> json) => ClinicalNote(
//         id: json['id'] ?? '',
//         complaint: json['complaint'] ?? '',
//         findings: json['findings'] ?? '',
//         plan: json['plan'] ?? '',
//         diagnosis: json['diagnosis'] ?? '',
//         hereditary: json['hereditary'] ?? false,
//         createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
//         prescriptions: (json['prescriptions'] as List? ?? []).map((e) => Prescription.fromJson(e)).toList(),
//         labOrders: (json['labOrders'] as List? ?? []).map((e) => LabOrder.fromJson(e)).toList(),
//       );
// }

// class Prescription {
//   final String drugName;
//   final String dosage;
//   final String frequency;
//   final int durationDays;

//   const Prescription({
//     required this.drugName,
//     required this.dosage,
//     required this.frequency,
//     required this.durationDays,
//   });

//   factory Prescription.fromJson(Map<String, dynamic> json) => Prescription(
//         drugName: json['drugName'] ?? '',
//         dosage: json['dosage'] ?? '',
//         frequency: json['frequency'] ?? '',
//         durationDays: json['durationDays'] ?? 0,
//       );

//   Map<String, dynamic> toJson() => {
//         'drugName': drugName,
//         'dosage': dosage,
//         'frequency': frequency,
//         'durationDays': durationDays,
//       };
// }

// class LabOrder {
//   final String testName;
//   final Urgency urgency;

//   const LabOrder({required this.testName, required this.urgency});

//   factory LabOrder.fromJson(Map<String, dynamic> json) => LabOrder(
//         testName: json['testName'] ?? '',
//         urgency: json['urgency'] == 'URGENT' ? Urgency.URGENT : Urgency.NORMAL,
//       );

//   Map<String, dynamic> toJson() => {
//         'testName': testName,
//         'urgency': urgency == Urgency.URGENT ? 'URGENT' : 'NORMAL',
//       };
// }

// class VitalRecord {
//   final double? temperature;
//   final String? bloodPressure;
//   final int? pulse;
//   final int? o2Saturation;
//   final DateTime recordedAt;

//   const VitalRecord({
//     this.temperature,
//     this.bloodPressure,
//     this.pulse,
//     this.o2Saturation,
//     required this.recordedAt,
//   });

//   factory VitalRecord.fromJson(Map<String, dynamic> json) => VitalRecord(
//         temperature: (json['temperature'] as num?)?.toDouble(),
//         bloodPressure: json['bloodPressure'],
//         pulse: json['pulse'],
//         o2Saturation: json['o2Saturation'],
//         recordedAt: DateTime.tryParse(json['recordedAt'] ?? '') ?? DateTime.now(),
//       );
// }

// // ─── DOCTOR DASHBOARD ───────────────────────────────────────────────────────
// class DoctorDashboard extends StatefulWidget {
//   const DoctorDashboard({super.key});

//   @override
//   State<DoctorDashboard> createState() => _DoctorDashboardState();
// }

// class _DoctorDashboardState extends State<DoctorDashboard> {
//   List<QueuePatient> _queue = [];
//   QueuePatient? _activePatient;
//   PatientSummary? _patientHistory;
  
//   bool _isLoadingQueue = true;
//   bool _isLoadingHistory = false;
//   Timer? _queuePollTimer;
  
//   String _doctorId = '';
//   String _doctorName = 'Dr. Smith';

//   final _complaintController = TextEditingController();
//   final _findingsController = TextEditingController();
//   final _planController = TextEditingController();
//   final _diagnosisController = TextEditingController();
//   bool _hereditary = false;

//   final _tempController = TextEditingController();
//   final _bpController = TextEditingController();
//   final _pulseController = TextEditingController();
//   final _o2Controller = TextEditingController();

//   List<Prescription> _prescriptions = [];
//   List<LabOrder> _labOrders = [];
//   String? _currentNoteId;

//   @override
//   void initState() {
//     super.initState();
//     _loadDoctorInfo();
//     _fetchQueue();
//     _startQueuePolling();
//   }

//   @override
//   void dispose() {
//     _queuePollTimer?.cancel();
//     _complaintController.dispose();
//     _findingsController.dispose();
//     _planController.dispose();
//     _diagnosisController.dispose();
//     _tempController.dispose();
//     _bpController.dispose();
//     _pulseController.dispose();
//     _o2Controller.dispose();
//     super.dispose();
//   }

//   void _loadDoctorInfo() {
//     _doctorId = html.window.localStorage['userId'] ?? '';
//     _doctorName = html.window.localStorage['fullName'] ?? 'Doctor';
//   }

//   void _startQueuePolling() {
//     _queuePollTimer = Timer.periodic(const Duration(seconds: 20), (_) => _fetchQueue());
//   }

//   Future<void> _fetchQueue() async {
//     if (!mounted) return;
//     setState(() => _isLoadingQueue = true);
//     try {
//       final token = html.window.localStorage['token'] ?? '';
//       final dateStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
//       final res = await http.get(
//         Uri.parse('$_BaseUrl/api/appointments/queue?doctor_id=$_doctorId&date=$dateStr'),
//         headers: {'Authorization': 'Bearer $token'},
//       );

//       if (res.statusCode == 200) {
//         final body = jsonDecode(res.body);
//         final List data = body['data'] ?? [];
//         if (!mounted) return;
//         setState(() {
//           _queue = data.map((e) => QueuePatient.fromJson(e)).toList();
//           _isLoadingQueue = false;
//         });
//       } else {
//         if (!mounted) return;
//         setState(() => _isLoadingQueue = false);
//       }
//     } catch (e) {
//       if (!mounted) return;
//       setState(() => _isLoadingQueue = false);
//       _showError('Failed to load queue: $e');
//     }
//   }

//   Future<void> _startConsultation(QueuePatient patient) async {
//     setState(() {
//       _activePatient = patient;
//       _isLoadingHistory = true;
//     });
//     await _fetchPatientHistory(patient.patientId);
//     _clearForms();
//   }

//   Future<void> _fetchPatientHistory(String patientId) async {
//     try {
//       final token = html.window.localStorage['token'] ?? '';
//       final res = await http.get(
//         Uri.parse('$_BaseUrl/api/clinical/patients/$patientId/summary'),
//         headers: {'Authorization': 'Bearer $token'},
//       );

//       if (res.statusCode == 200) {
//         final body = jsonDecode(res.body);
//         if (!mounted) return;
//         setState(() {
//           _patientHistory = PatientSummary.fromJson(body['data'] ?? {});
//           _isLoadingHistory = false;
//         });
//       }
//     } catch (e) {
//       if (!mounted) return;
//       setState(() => _isLoadingHistory = false);
//       _showError('Failed to load patient history: $e');
//     }
//   }

//   Future<void> _saveVitals() async {
//     if (_activePatient == null) return;
//     try {
//       final token = html.window.localStorage['token'] ?? '';
//       final res = await http.post(
//         Uri.parse('$_BaseUrl/api/clinical/vitals'),
//         headers: {
//           'Content-Type': 'application/json',
//           'Authorization': 'Bearer $token',
//         },
//         body: jsonEncode({
//           'patientId': _activePatient!.patientId,
//           'recordedBy': _doctorId,
//           'temperature': double.tryParse(_tempController.text),
//           'bloodPressure': _bpController.text,
//           'pulse': int.tryParse(_pulseController.text),
//           'o2Saturation': int.tryParse(_o2Controller.text),
//         }),
//       );

//       if (res.statusCode == 200) {
//         _showSuccess('Vitals recorded');
//         _tempController.clear();
//         _bpController.clear();
//         _pulseController.clear();
//         _o2Controller.clear();
//         await _fetchPatientHistory(_activePatient!.patientId);
//       } else {
//         _showError('Failed to save vitals');
//       }
//     } catch (e) {
//       _showError('Error: $e');
//     }
//   }

//   Future<void> _saveNote() async {
//     if (_activePatient == null) return;
//     try {
//       final token = html.window.localStorage['token'] ?? '';
//       final res = await http.post(
//         Uri.parse('$_BaseUrl/api/clinical/notes'),
//         headers: {
//           'Content-Type': 'application/json',
//           'Authorization': 'Bearer $token',
//         },
//         body: jsonEncode({
//           'patientId': _activePatient!.patientId,
//           'doctorId': _doctorId,
//           'appointmentId': _activePatient!.appointmentId,
//           'complaint': _complaintController.text,
//           'findings': _findingsController.text,
//           'plan': _planController.text,
//           'diagnosis': _diagnosisController.text,
//           'hereditary': _hereditary,
//         }),
//       );

//       if (res.statusCode == 200) {
//         final body = jsonDecode(res.body);
//         _currentNoteId = body['data']['id'];
//         _showSuccess('Note saved. Now add prescriptions or lab orders.');
//         await _fetchPatientHistory(_activePatient!.patientId);
//       } else {
//         _showError('Failed to save note');
//       }
//     } catch (e) {
//       _showError('Error: $e');
//     }
//   }

//   Future<void> _savePrescription() async {
//     if (_currentNoteId == null || _activePatient == null) {
//       _showError('Save clinical note first');
//       return;
//     }
//     try {
//       final token = html.window.localStorage['token'] ?? '';
//       for (final p in _prescriptions) {
//         final res = await http.post(
//           Uri.parse('$_BaseUrl/api/clinical/prescriptions'),
//           headers: {
//             'Content-Type': 'application/json',
//             'Authorization': 'Bearer $token',
//           },
//           body: jsonEncode({
//             'patientId': _activePatient!.patientId,
//             'noteId': _currentNoteId,
//             ...p.toJson(),
//           }),
//         );
//         if (res.statusCode != 200) throw Exception('Failed to save ${p.drugName}');
//       }
//       _showSuccess('Prescriptions saved');
//       setState(() => _prescriptions.clear());
//       await _fetchPatientHistory(_activePatient!.patientId);
//     } catch (e) {
//       _showError('Error: $e');
//     }
//   }

//   Future<void> _saveLabOrder() async {
//     if (_currentNoteId == null || _activePatient == null) {
//       _showError('Save clinical note first');
//       return;
//     }
//     try {
//       final token = html.window.localStorage['token'] ?? '';
//       for (final l in _labOrders) {
//         final res = await http.post(
//           Uri.parse('$_BaseUrl/api/clinical/lab-orders'),
//           headers: {
//             'Content-Type': 'application/json',
//             'Authorization': 'Bearer $token',
//           },
//           body: jsonEncode({
//             'patientId': _activePatient!.patientId,
//             'doctorId': _doctorId,
//             'noteId': _currentNoteId,
//             ...l.toJson(),
//           }),
//         );
//         if (res.statusCode != 200) throw Exception('Failed to order ${l.testName}');
//       }
//       _showSuccess('Lab orders placed');
//       setState(() => _labOrders.clear());
//       await _fetchPatientHistory(_activePatient!.patientId);
//     } catch (e) {
//       _showError('Error: $e');
//     }
//   }

//   Future<void> _completeConsultation() async {
//     if (_activePatient == null) return;
//     try {
//       final token = html.window.localStorage['token'] ?? '';
//       final res = await http.patch(
//         Uri.parse('$_BaseUrl/api/appointments/${_activePatient!.appointmentId}/complete'),
//         headers: {'Authorization': 'Bearer $token'},
//       );
//       if (res.statusCode == 200) {
//         _showSuccess('Consultation completed');
//         setState(() => _activePatient = null);
//         _clearForms();
//         await _fetchQueue();
//       }
//     } catch (e) {
//       _showError('Failed to complete: $e');
//     }
//   }

//   void _clearForms() {
//     _complaintController.clear();
//     _findingsController.clear();
//     _planController.clear();
//     _diagnosisController.clear();
//     _tempController.clear();
//     _bpController.clear();
//     _pulseController.clear();
//     _o2Controller.clear();
//     _hereditary = false;
//     _prescriptions.clear();
//     _labOrders.clear();
//     _currentNoteId = null;
//   }

//   void _addPrescriptionDialog() {
//     final drugController = TextEditingController();
//     final dosageController = TextEditingController();
//     final freqController = TextEditingController();
//     final daysController = TextEditingController();

//     showDialog(
//       context: context,
//       builder: (_) => AlertDialog(
//         title: const Text('Add Prescription'),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             TextField(controller: drugController, decoration: const InputDecoration(labelText: 'Drug Name')),
//             TextField(controller: dosageController, decoration: const InputDecoration(labelText: 'Dosage')),
//             TextField(controller: freqController, decoration: const InputDecoration(labelText: 'Frequency')),
//             TextField(controller: daysController, decoration: const InputDecoration(labelText: 'Duration (days)'), keyboardType: TextInputType.number),
//           ],
//         ),
//         actions: [
//           TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
//           ElevatedButton(
//             onPressed: () {
//               setState(() {
//                 _prescriptions.add(Prescription(
//                   drugName: drugController.text,
//                   dosage: dosageController.text,
//                   frequency: freqController.text,
//                   durationDays: int.tryParse(daysController.text) ?? 0,
//                 ));
//               });
//               Navigator.pop(context);
//             },
//             child: const Text('Add'),
//           ),
//         ],
//       ),
//     );
//   }

//   void _addLabDialog() {
//     final testController = TextEditingController();
//     Urgency urgency = Urgency.NORMAL;

//     showDialog(
//       context: context,
//       builder: (_) => StatefulBuilder(
//         builder: (context, setDialogState) => AlertDialog(
//           title: const Text('Order Lab Test'),
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               TextField(controller: testController, decoration: const InputDecoration(labelText: 'Test Name')),
//               const SizedBox(height: 16),
//               Row(
//                 children: [
//                   const Text('Urgency: '),
//                   Radio<Urgency>(
//                     value: Urgency.NORMAL,
//                     groupValue: urgency,
//                     onChanged: (v) => setDialogState(() => urgency = v!),
//                   ),
//                   const Text('Normal'),
//                   Radio<Urgency>(
//                     value: Urgency.URGENT,
//                     groupValue: urgency,
//                     onChanged: (v) => setDialogState(() => urgency = v!),
//                   ),
//                   const Text('Urgent'),
//                 ],
//               ),
//             ],
//           ),
//           actions: [
//             TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
//             ElevatedButton(
//               onPressed: () {
//                 setState(() {
//                   _labOrders.add(LabOrder(testName: testController.text, urgency: urgency));
//                 });
//                 Navigator.pop(context);
//               },
//               child: const Text('Add'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   void _showError(String msg) {
//     if (!mounted) return;
//     ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: kError));
//   }

//   void _showSuccess(String msg) {
//     if (!mounted) return;
//     ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: kSuccess));
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: kBackground,
//       body: Row(
//         children: [
//           Container(
//             width: 320,
//             color: kWhite,
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Container(
//                   padding: const EdgeInsets.all(20),
//                   color: kTeal,
//                   child: Row(
//                     children: [
//                       const Icon(Icons.medical_services, color: kWhite, size: 28),
//                       const SizedBox(width: 12),
//                       Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(_doctorName, style: const TextStyle(color: kWhite, fontSize: 16, fontWeight: FontWeight.bold)),
//                           const Text('Doctor Dashboard', style: TextStyle(color: kWhite, fontSize: 12)),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//                 Padding(
//                   padding: const EdgeInsets.all(16),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Text('Today\'s Queue', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: kTextDark)),
//                       Container(
//                         padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
//                         decoration: BoxDecoration(color: kTealLight, borderRadius: BorderRadius.circular(12)),
//                         child: Text('${_queue.length}', style: const TextStyle(color: kWhite, fontWeight: FontWeight.bold)),
//                       ),
//                     ],
//                   ),
//                 ),
//                 Expanded(
//                   child: _isLoadingQueue
//                       ? const Center(child: CircularProgressIndicator(color: kTeal))
//                       : _queue.isEmpty
//                           ? Center(child: Text('No patients waiting', style: TextStyle(color: kTextGrey)))
//                           : ListView.builder(
//                               itemCount: _queue.length,
//                               itemBuilder: (_, i) {
//                                 final p = _queue[i];
//                                 final isActive = _activePatient?.appointmentId == p.appointmentId;
//                                 return InkWell(
//                                   onTap: () => _startConsultation(p),
//                                   child: Container(
//                                     margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                                     padding: const EdgeInsets.all(12),
//                                     decoration: BoxDecoration(
//                                       color: isActive ? kTealLight.withOpacity(0.2) : kCardBg,
//                                       border: Border.all(color: isActive ? kTeal : kBorder, width: isActive ? 2 : 1),
//                                       borderRadius: BorderRadius.circular(10),
//                                     ),
//                                     child: Row(
//                                       children: [
//                                         CircleAvatar(
//                                           radius: 20,
//                                           backgroundColor: kTealAccent.withOpacity(0.3),
//                                           backgroundImage: p.patientAvatar != null ? NetworkImage(p.patientAvatar!) : null,
//                                           child: p.patientAvatar == null ? const Icon(Icons.person, color: kTeal) : null,
//                                         ),
//                                         const SizedBox(width: 12),
//                                         Expanded(
//                                           child: Column(
//                                             crossAxisAlignment: CrossAxisAlignment.start,
//                                             children: [
//                                               Text(p.patientName, style: const TextStyle(fontWeight: FontWeight.w600)),
//                                               Text(p.slotTime, style: TextStyle(fontSize: 12, color: kTextGrey)),
//                                             ],
//                                           ),
//                                         ),
//                                         Column(
//                                           crossAxisAlignment: CrossAxisAlignment.end,
//                                           children: [
//                                             Text(p.waitTime, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: kWarning)),
//                                             const Text('waiting', style: TextStyle(fontSize: 10, color: kTextGrey)),
//                                           ],
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                 );
//                               },
//                             ),
//                 ),
//               ],
//             ),
//           ),
//           Expanded(
//             child: _activePatient == null
//                 ? Center(
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Icon(Icons.person_search, size: 80, color: kTextGrey.withOpacity(0.5)),
//                         const SizedBox(height: 16),
//                         Text('Select a patient from the queue to start consultation', style: TextStyle(color: kTextGrey, fontSize: 16)),
//                       ],
//                     ),
//                   )
//                 : SingleChildScrollView(
//                     padding: const EdgeInsets.all(24),
//                     child: _ConsultationPanel(
//                       patient: _activePatient!,
//                       history: _patientHistory,
//                       isLoadingHistory: _isLoadingHistory,
//                       complaintController: _complaintController,
//                       findingsController: _findingsController,
//                       planController: _planController,
//                       diagnosisController: _diagnosisController,
//                       hereditary: _hereditary,
//                       onHereditaryChanged: (v) => setState(() => _hereditary = v),
//                       tempController: _tempController,
//                       bpController: _bpController,
//                       pulseController: _pulseController,
//                       o2Controller: _o2Controller,
//                       onSaveVitals: _saveVitals,
//                       prescriptions: _prescriptions,
//                       onAddPrescription: _addPrescriptionDialog,
//                       onRemovePrescription: (i) => setState(() => _prescriptions.removeAt(i)),
//                       labOrders: _labOrders,
//                       onAddLab: _addLabDialog,
//                       onRemoveLab: (i) => setState(() => _labOrders.removeAt(i)),
//                       onSaveNote: _saveNote,
//                       onSavePrescription: _savePrescription,
//                       onSaveLab: _saveLabOrder,
//                       onComplete: _completeConsultation,
//                     ),
//                   ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _ConsultationPanel extends StatelessWidget {
//   final QueuePatient patient;
//   final PatientSummary? history;
//   final bool isLoadingHistory;
//   final TextEditingController complaintController;
//   final TextEditingController findingsController;
//   final TextEditingController planController;
//   final TextEditingController diagnosisController;
//   final bool hereditary;
//   final ValueChanged<bool> onHereditaryChanged;
//   final TextEditingController tempController;
//   final TextEditingController bpController;
//   final TextEditingController pulseController;
//   final TextEditingController o2Controller;
//   final VoidCallback onSaveVitals;
//   final List<Prescription> prescriptions;
//   final VoidCallback onAddPrescription;
//   final ValueChanged<int> onRemovePrescription;
//   final List<LabOrder> labOrders;
//   final VoidCallback onAddLab;
//   final ValueChanged<int> onRemoveLab;
//   final VoidCallback onSaveNote;
//   final VoidCallback onSavePrescription;
//   final VoidCallback onSaveLab;
//   final VoidCallback onComplete;

//   const _ConsultationPanel({
//     required this.patient,
//     required this.history,
//     required this.isLoadingHistory,
//     required this.complaintController,
//     required this.findingsController,
//     required this.planController,
//     required this.diagnosisController,
//     required this.hereditary,
//     required this.onHereditaryChanged,
//     required this.tempController,
//     required this.bpController,
//     required this.pulseController,
//     required this.o2Controller,
//     required this.onSaveVitals,
//     required this.prescriptions,
//     required this.onAddPrescription,
//     required this.onRemovePrescription,
//     required this.labOrders,
//     required this.onAddLab,
//     required this.onRemoveLab,
//     required this.onSaveNote,
//     required this.onSavePrescription,
//     required this.onSaveLab,
//     required this.onComplete,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Container(
//           padding: const EdgeInsets.all(20),
//           decoration: BoxDecoration(color: kWhite, borderRadius: BorderRadius.circular(12), border: Border.all(color: kBorder)),
//           child: Row(
//             children: [
//               CircleAvatar(
//                 radius: 32,
//                 backgroundColor: kTealAccent.withOpacity(0.3),
//                 backgroundImage: patient.patientAvatar != null ? NetworkImage(patient.patientAvatar!) : null,
//                 child: patient.patientAvatar == null ? const Icon(Icons.person, size: 36, color: kTeal) : null,
//               ),
//               const SizedBox(width: 16),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(patient.patientName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
//                     Text('Appointment: ${patient.slotTime}', style: TextStyle(color: kTextGrey)),
//                     Text('Waiting: ${patient.waitTime}', style: TextStyle(color: kWarning, fontWeight: FontWeight.w600)),
//                   ],
//                 ),
//               ),
//               ElevatedButton.icon(
//                 onPressed: onComplete,
//                 icon: const Icon(Icons.check_circle, size: 18),
//                 label: const Text('Complete Visit'),
//                 style: ElevatedButton.styleFrom(backgroundColor: kSuccess),
//               ),
//             ],
//           ),
//         ),
//         const SizedBox(height: 20),
//         if (isLoadingHistory)
//           const Center(child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator(color: kTeal)))
//         else if (history != null)
//           _HistoryCard(history: history!),
//         const SizedBox(height: 20),
//         _SectionCard(
//           title: 'Record Vitals',
//           icon: Icons.favorite,
//           child: Column(
//             children: [
//               Row(
//                 children: [
//                   Expanded(child: _VitalField(controller: tempController, label: 'Temperature (°C)', icon: Icons.thermostat)),
//                   const SizedBox(width: 12),
//                   Expanded(child: _VitalField(controller: bpController, label: 'Blood Pressure', icon: Icons.monitor_heart)),
//                 ],
//               ),
//               const SizedBox(height: 12),
//               Row(
//                 children: [
//                   Expanded(child: _VitalField(controller: pulseController, label: 'Pulse (bpm)', icon: Icons.favorite)),
//                   const SizedBox(width: 12),
//                   Expanded(child: _VitalField(controller: o2Controller, label: 'O2 Saturation (%)', icon: Icons.air)),
//                 ],
//               ),
//               const SizedBox(height: 12),
//               Align(
//                 alignment: Alignment.centerRight,
//                 child: ElevatedButton(onPressed: onSaveVitals, child: const Text('Save Vitals')),
//               ),
//             ],
//           ),
//         ),
//         const SizedBox(height: 20),
//         _SectionCard(
//           title: 'Clinical Note',
//           icon: Icons.note_alt,
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               _NoteField(controller: complaintController, label: 'Chief Complaint'),
//               const SizedBox(height: 12),
//               _NoteField(controller: findingsController, label: 'Clinical Findings', maxLines: 3),
//               const SizedBox(height: 12),
//               _NoteField(controller: diagnosisController, label: 'Diagnosis'),
//               const SizedBox(height: 12),
//               _NoteField(controller: planController, label: 'Treatment Plan', maxLines: 3),
//               const SizedBox(height: 12),
//               Row(
//                 children: [
//                   Checkbox(value: hereditary, onChanged: (v) => onHereditaryChanged(v ?? false)),
//                   const Text('Hereditary condition'),
//                 ],
//               ),
//               const SizedBox(height: 12),
//               Align(
//                 alignment: Alignment.centerRight,
//                 child: ElevatedButton(onPressed: onSaveNote, child: const Text('Save Note')),
//               ),
//             ],
//           ),
//         ),
//         const SizedBox(height: 20),
//         _SectionCard(
//           title: 'Prescriptions',
//           icon: Icons.medication,
//           action: TextButton.icon(onPressed: onAddPrescription, icon: const Icon(Icons.add, size: 18), label: const Text('Add Drug')),
//           child: prescriptions.isEmpty
//               ? Padding(padding: const EdgeInsets.all(16), child: Text('No prescriptions added', style: TextStyle(color: kTextGrey)))
//               : Column(
//                   children: [
//                     ...prescriptions.asMap().entries.map((e) {
//                       final p = e.value;
//                       return ListTile(
//                         title: Text(p.drugName),
//                         subtitle: Text('${p.dosage} - ${p.frequency} for ${p.durationDays} days'),
//                         trailing: IconButton(icon: const Icon(Icons.delete, color: kError), onPressed: () => onRemovePrescription(e.key)),
//                       );
//                     }),
//                     const SizedBox(height: 8),
//                     Align(
//                       alignment: Alignment.centerRight,
//                       child: ElevatedButton(onPressed: onSavePrescription, child: const Text('Save Prescriptions')),
//                     ),
//                   ],
//                 ),
//         ),
//         const SizedBox(height: 20),
//         _SectionCard(
//           title: 'Lab Orders',
//           icon: Icons.science,
//           action: TextButton.icon(onPressed: onAddLab, icon: const Icon(Icons.add, size: 18), label: const Text('Add Test')),
//           child: labOrders.isEmpty
//               ? Padding(padding: const EdgeInsets.all(16), child: Text('No lab tests ordered', style: TextStyle(color: kTextGrey)))
//               : Column(
//                   children: [
//                     ...labOrders.asMap().entries.map((e) {
//                       final l = e.value;
//                       return ListTile(
//                         title: Text(l.testName),
//                         trailing: Row(
//                           mainAxisSize: MainAxisSize.min,
//                           children: [
//                             Container(
//                               padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                               decoration: BoxDecoration(
//                                 color: l.urgency == Urgency.URGENT ? kUrgent.withOpacity(0.15) : kTeal.withOpacity(0.15),
//                                 borderRadius: BorderRadius.circular(8),
//                               ),
//                               child: Text(
//                                 l.urgency == Urgency.URGENT ? 'URGENT' : 'Normal',
//                                 style: TextStyle(fontSize: 11, color: l.urgency == Urgency.URGENT ? kUrgent : kTeal, fontWeight: FontWeight.w600),
//                               ),
//                             ),
//                             IconButton(icon: const Icon(Icons.delete, color: kError), onPressed: () => onRemoveLab(e.key)),
//                           ],
//                         ),
//                       );
//                     }),
//                     const SizedBox(height: 8),
//                     Align(
//                       alignment: Alignment.centerRight,
//                       child: ElevatedButton(onPressed: onSaveLab, child: const Text('Place Lab Orders')),
//                     ),
//                   ],
//                 ),
//         ),
//       ],
//     );
//   }
// }

// class _SectionCard extends StatelessWidget {
//   final String title;
//   final IconData icon;
//   final Widget child;
//   final Widget? action;

//   const _SectionCard({required this.title, required this.icon, required this.child, this.action});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(color: kWhite, borderRadius: BorderRadius.circular(12), border: Border.all(color: kBorder)),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Row(
//                 children: [
//                   Icon(icon, color: kTeal, size: 22),
//                   const SizedBox(width: 8),
//                   Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
//                 ],
//               ),
//               if (action != null) action!,
//             ],
//           ),
//           const SizedBox(height: 16),
//           child,
//         ],
//       ),
//     );
//   }
// }

// class _VitalField extends StatelessWidget {
//   final TextEditingController controller;
//   final String label;
//   final IconData icon;

//   const _VitalField({required this.controller, required this.label, required this.icon});

//   @override
//   Widget build(BuildContext context) {
//     return TextField(
//       controller: controller,
//       keyboardType: TextInputType.number,
//       decoration: InputDecoration(
//         labelText: label,
//         prefixIcon: Icon(icon, size: 18, color: kTeal),
//         border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
//         contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
//       ),
//     );
//   }
// }

// class _NoteField extends StatelessWidget {
//   final TextEditingController controller;
//   final String label;
//   final int maxLines;

//   const _NoteField({required this.controller, required this.label, this.maxLines = 1});

//   @override
//   Widget build(BuildContext context) {
//     return TextField(
//       controller: controller,
//       maxLines: maxLines,
//       decoration: InputDecoration(
//         labelText: label,
//         border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
//         contentPadding: const EdgeInsets.all(12),
//       ),
//     );
//   }
// }

// class _HistoryCard extends StatelessWidget {
//   final PatientSummary history;
//   const _HistoryCard({required this.history});

//   @override
//   Widget build(BuildContext context) {
//     return _SectionCard(
//       title: 'Patient History',
//       icon: Icons.history,
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           if (history.vitals.isNotEmpty) ...[
//             const Text('Recent Vitals', style: TextStyle(fontWeight: FontWeight.bold)),
//             const SizedBox(height: 8),
//             ...history.vitals.take(3).map((v) => Padding(
//                   padding: const EdgeInsets.only(bottom: 8),
//                   child: Row(
//                     children: [
//                       Icon(Icons.circle, size: 8, color: kTeal),
//                       const SizedBox(width: 8),
//                       Text(
//                         DateFormat('MMM d, yyyy').format(v.recordedAt),
//                         style: const TextStyle(fontSize: 12, color: kTextGrey),
//                       ),
//                       const SizedBox(width: 12),
//                       Text(
//                         'Temp: ${v.temperature?.toStringAsFixed(1) ?? '-'}°C  BP: ${v.bloodPressure ?? '-'}  Pulse: ${v.pulse ?? '-'}  O2: ${v.o2Saturation ?? '-'}%',
//                         //TextStyle(fontSize: 12),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//             const SizedBox(height: 16),
//           ],
//           if (history.notes.isNotEmpty) ...[
//             const Text(
//               'Last 10 Clinical Notes',
//               style: TextStyle(fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 8),
//             ...history.notes
//                 .take(3)
//                 .map(
//                   (n) => Container(
//                     margin: const EdgeInsets.only(bottom: 12),
//                     padding: const EdgeInsets.all(12),
//                     decoration: BoxDecoration(
//                       color: kTealLight.withOpacity(0.1),
//                       borderRadius: BorderRadius.circular(8),
//                       border: Border.all(color: kTeal.withOpacity(0.3)),
//                     ),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Text(
//                               DateFormat('MMM d, yyyy').format(n.createdAt),
//                               style: const TextStyle(
//                                 fontSize: 12,
//                                 fontWeight: FontWeight.w600,
//                                 color: kTeal,
//                               ),
//                             ),
//                             if (n.hereditary)
//                               Container(
//                                 padding: const EdgeInsets.symmetric(
//                                   horizontal: 8,
//                                   vertical: 2,
//                                 ),
//                                 decoration: BoxDecoration(
//                                   color: kWarning.withOpacity(0.2),
//                                   borderRadius: BorderRadius.circular(8),
//                                 ),
//                                 child: const Text(
//                                   'Hereditary',
//                                   style: TextStyle(
//                                     fontSize: 10,
//                                     color: kWarning,
//                                     fontWeight: FontWeight.w600,
//                                   ),
//                                 ),
//                               ),
//                           ],
//                         ),
//                         const SizedBox(height: 8),
//                         if (n.complaint.isNotEmpty) ...[
//                           Text(
//                             'Complaint:',
//                             style: TextStyle(
//                               fontSize: 11,
//                               color: kTextGrey,
//                               fontWeight: FontWeight.w600,
//                             ),
//                           ),
//                           Text(
//                             n.complaint,
//                             style: const TextStyle(fontSize: 12),
//                           ),
//                           const SizedBox(height: 4),
//                         ],
//                         if (n.diagnosis.isNotEmpty) ...[
//                           Text(
//                             'Diagnosis:',
//                             style: TextStyle(
//                               fontSize: 11,
//                               color: kTextGrey,
//                               fontWeight: FontWeight.w600,
//                             ),
//                           ),
//                           Text(
//                             n.diagnosis,
//                             style: const TextStyle(
//                               fontSize: 12,
//                               fontWeight: FontWeight.w500,
//                             ),
//                           ),
//                           const SizedBox(height: 4),
//                         ],
//                         if (n.prescriptions.isNotEmpty) ...[
//                           const SizedBox(height: 4),
//                           Text(
//                             'Prescriptions:',
//                             style: TextStyle(
//                               fontSize: 11,
//                               color: kTextGrey,
//                               fontWeight: FontWeight.w600,
//                             ),
//                           ),
//                           ...n.prescriptions.map(
//                             (p) => Padding(
//                               padding: const EdgeInsets.only(left: 8, top: 2),
//                               child: Text(
//                                 '• ${p.drugName} ${p.dosage} - ${p.frequency} x ${p.durationDays}d',
//                                 style: const TextStyle(fontSize: 11),
//                               ),
//                             ),
//                           ),
//                         ],
//                         if (n.labOrders.isNotEmpty) ...[
//                           const SizedBox(height: 4),
//                           Text(
//                             'Lab Orders:',
//                             style: TextStyle(
//                               fontSize: 11,
//                               color: kTextGrey,
//                               fontWeight: FontWeight.w600,
//                             ),
//                           ),
//                           ...n.labOrders.map(
//                             (l) => Padding(
//                               padding: const EdgeInsets.only(left: 8, top: 2),
//                               child: Row(
//                                 children: [
//                                   Text(
//                                     '• ${l.testName}',
//                                     style: const TextStyle(fontSize: 11),
//                                   ),
//                                   if (l.urgency == Urgency.URGENT)
//                                     Container(
//                                       margin: const EdgeInsets.only(left: 6),
//                                       padding: const EdgeInsets.symmetric(
//                                         horizontal: 6,
//                                         vertical: 1,
//                                       ),
//                                       decoration: BoxDecoration(
//                                         color: kUrgent.withOpacity(0.2),
//                                         borderRadius: BorderRadius.circular(4),
//                                       ),
//                                       child: const Text(
//                                         'URGENT',
//                                         style: TextStyle(
//                                           fontSize: 9,
//                                           color: kUrgent,
//                                           fontWeight: FontWeight.bold,
//                                         ),
//                                       ),
//                                     ),
//                                 ],
//                               ),
//                             ),
//                           ),
//                         ],
//                       ],
//                     ),
//                   ),
//                 ),
//           ] else
//             Padding(
//               padding: const EdgeInsets.all(16),
//               child: Text(
//                 'No clinical history available',
//                 style: TextStyle(color: kTextGrey),
//               ),
//             ),
//         ],
//       ),
//     );
//   }
// }











// ===================== IMPORTS =====================
import 'dart:async';
import 'dart:convert';
import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

import 'admin_login_page.dart';

// ===================== CONSTANTS =====================
const kTeal = Color(0xFF0D7B6B);
const kTealLight = Color(0xFF1A9E8A);
const kTealAccent = Color(0xFF4FC3B0);
const kBackground = Color(0xFFF0F4F4);
const kWhite = Color(0xFFFFFFFF);
const kTextDark = Color(0xFF1A2E2C);
const kTextGrey = Color(0xFF7A9490);
const kCardBg = Color(0xFFFFFFFF);
const kSuccess = Color(0xFF4CAF50);
const kWarning = Color(0xFFFF9800);
const kError = Color(0xFFF44336);
const kBorder = Color(0xFFE0E0);
const kUrgent = Color(0xFFFF5252);

const String _BaseUrl = 'https://heathos-api.onrender.com';

// ===================== MODELS =====================
enum Urgency { NORMAL, URGENT }

class QueuePatient {
  final String appointmentId;
  final String patientId;
  final String patientName;
  final String? patientAvatar;
  final String slotTime;
  final DateTime checkInTime;

  const QueuePatient({
    required this.appointmentId,
    required this.patientId,
    required this.patientName,
    this.patientAvatar,
    required this.slotTime,
    required this.checkInTime,
  });

  factory QueuePatient.fromJson(Map<String, dynamic> json) => QueuePatient(
    appointmentId: json['id'] ?? '',
    patientId: json['patientId'] ?? '',
    patientName: json['patientName'] ?? 'Unknown',
    patientAvatar: json['patientAvatar'],
    slotTime: json['slotDatetime'] ?? '',
    checkInTime: DateTime.tryParse(json['checkInTime'] ?? '') ?? DateTime.now(),
  );

  String get waitTime {
    final diff = DateTime.now().difference(checkInTime);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    return '${diff.inHours}h ${diff.inMinutes % 60}m';
  }
}

// ===================== DASHBOARD =====================
class DoctorDashboard extends StatefulWidget {
  const DoctorDashboard({super.key});

  @override
  State<DoctorDashboard> createState() => _DoctorDashboardState();
}

class _DoctorDashboardState extends State<DoctorDashboard> {
  List<QueuePatient> _queue = [];
  bool _isLoadingQueue = true;

  String _doctorId = '';
  String _doctorName = 'Doctor';

  Timer? _pollTimer;
  late IO.Socket socket;

  // ===================== INIT =====================
  @override
  void initState() {
    super.initState();
    _loadDoctorInfo();
    _fetchQueue();
    _startPolling(); // fallback
    _initSocket(); // REAL-TIME
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    socket.dispose();
    super.dispose();
  }

  // ===================== LOAD USER =====================
  void _loadDoctorInfo() {
    _doctorId = html.window.localStorage['userId'] ?? '';
    _doctorName = html.window.localStorage['fullName'] ?? 'Doctor';
  }

  // ===================== LOGOUT =====================
  void _logout() {
    html.window.localStorage.clear();

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const AdminLoginPage()),
      (route) => false,
    );
  }

  // ===================== SOCKET =====================
  void _initSocket() {
    socket = IO.io(
      _BaseUrl,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .build(),
    );

    socket.connect();

    socket.onConnect((_) {
      socket.emit('join_doctor', _doctorId);
    });

    socket.on('new_appointment', (data) {
      final newPatient = QueuePatient.fromJson(data);

      setState(() {
        _queue = [
          newPatient,
          ..._queue.where((p) => p.appointmentId != newPatient.appointmentId),
        ];
      });

      _showSuccess('New patient added');
    });
  }

  // ===================== POLLING (BACKUP) =====================
  void _startPolling() {
    _pollTimer = Timer.periodic(
      const Duration(seconds: 20),
      (_) => _fetchQueue(),
    );
  }

  // ===================== FETCH QUEUE =====================
  Future<void> _fetchQueue() async {
    try {
      final token = html.window.localStorage['token'];
      if (token == null) {
        _logout();
        return;
      }

      final date = DateFormat('yyyy-MM-dd').format(DateTime.now());

      final res = await http.get(
        Uri.parse(
          '$_BaseUrl/api/appointments/queue?doctor_id=$_doctorId&date=$date',
        ),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);

        setState(() {
          _queue = (body['data'] as List)
              .map((e) => QueuePatient.fromJson(e))
              .toList();
          _isLoadingQueue = false;
        });
      } else if (res.statusCode == 401) {
        _logout();
      }
    } catch (e) {
      _showError('Network error');
    }
  }

  // ===================== UI HELPERS =====================
  void _showError(String msg) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(msg), backgroundColor: kError));
  }

  void _showSuccess(String msg) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(msg), backgroundColor: kSuccess));
  }

  // ===================== UI =====================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      body: Row(
        children: [
          // ===================== SIDEBAR =====================
          Container(
            width: 300,
            color: kWhite,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  color: kTeal,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.medical_services, color: kWhite),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              _doctorName,
                              style: const TextStyle(
                                color: kWhite,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.logout, color: kWhite),
                            onPressed: _logout,
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Online", style: TextStyle(color: kWhite)),
                          IconButton(
                            icon: const Icon(Icons.refresh, color: kWhite),
                            onPressed: _fetchQueue,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // ===================== QUEUE =====================
                Expanded(
                  child: _isLoadingQueue
                      ? const Center(child: CircularProgressIndicator())
                      : ListView.builder(
                          itemCount: _queue.length,
                          itemBuilder: (_, i) {
                            final p = _queue[i];

                            return ListTile(
                              leading: const CircleAvatar(
                                child: Icon(Icons.person),
                              ),
                              title: Text(p.patientName),
                              subtitle: Text(p.slotTime),
                              trailing: Text(p.waitTime),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),

          // ===================== MAIN =====================
          Expanded(
            child: Center(
              child: Text(
                "Select patient to begin consultation",
                style: TextStyle(color: kTextGrey),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

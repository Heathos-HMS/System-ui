import 'package:flutter/material.dart';
import 'package:adaptive_screen_utils/adaptive_screen_utils.dart';
//import 'package:heathos_hms/admin_dashboard_1.dart.txt';
//import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:http/http.dart' as http;
import 'admin_login_page.dart';
import 'admin_dashboard.dart';
//import 'staff_login_page.dart';
import 'staff_dashboard.dart';
import 'patient_dashboard.dart';
import 'admin_profile.dart';
//import 'appointment_screen.dart';
import 'doctor_dashboard.dart';
import 'nurse_list.dart';
//import 'adminstaff_screen.dart';

//import 'billing_agent_screen.dart';
import 'overview_screen.dart';
//import 'doctor_login_page.dart';
import 'admin_signup_page.dart';
import 'doctor_list.dart';
import 'edit_patient_records.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: .fromSeed(seedColor: Colors.deepPurple),
      ),
      home: AdminSignUpPage(),
      debugShowCheckedModeBanner: false,

      // ── Named routes (for Logout navigation) ── 
      routes: {
        '/adminSignup': (context) => const AdminSignUpPage(),
        '/adminLogin': (context) => const AdminLoginPage(),
        '/adminDashboard': (context) => const AdminDashboard(),
        //'/doctorDashboard': (context) => const DoctorDashboard(),
        //'/staffDashboard': (context) => StaffDashboard(),
      },
    );
  }
}


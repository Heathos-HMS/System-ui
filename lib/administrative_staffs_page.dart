import 'package:flutter/material.dart';

class AdministrativeStaffsPage extends StatefulWidget {
  const AdministrativeStaffsPage({super.key});

  @override
  State<AdministrativeStaffsPage> createState() =>
      _AdministrativeStaffsPageState();
}

class _AdministrativeStaffsPageState extends State<AdministrativeStaffsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Administrative Staffs')),
      body: const Center(child: Text('Administrative Staffs List Page')),
    );
  }
}

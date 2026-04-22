import 'package:flutter/material.dart';

class PharmacistsPage extends StatefulWidget {
  const PharmacistsPage({super.key});

  @override
  State<PharmacistsPage> createState() => _PharmacistsPageState();
}

class _PharmacistsPageState extends State<PharmacistsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pharmacists')),
      body: const Center(child: Text('Pharmacists List Page')),
    );
  }
}

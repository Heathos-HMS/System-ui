import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

// ─── CONSTANTS (same palette as the rest of the project) ─────────────────────
const _kTeal = Color(0xFF0D7B6B);
const _kTealLight = Color(0xFF1A9E8A);
const _kTealAccent = Color(0xFF4FC3B0);
const _kBackground = Color(0xFFF0F4F4);
const _kWhite = Color(0xFFFFFFFF);
const _kTextDark = Color(0xFF1A2E2C);
const _kTextGrey = Color(0xFF7A9490);
const _kBorder = Color(0xFFCCDDDB);
const _kSidebarTeal = Color(0xFF0D7B6B);

class EditPatientRecords extends StatefulWidget {
  const EditPatientRecords({super.key});

  @override
  State<EditPatientRecords> createState() => _EditPatientRecordsState();
}

class _EditPatientRecordsState extends State<EditPatientRecords> {
  // ── Nav ───────────────────────────────────────────────────────────────────
  int _selectedNav = 1; // 0=Overview, 1=Patient, 2=Doctor

  // ── Profile image ─────────────────────────────────────────────────────────
  Uint8List? _profileImageBytes;

  // ── Form controllers ──────────────────────────────────────────────────────
  final _firstNameCtrl = TextEditingController();
  final _middleNameCtrl = TextEditingController();
  final _surnameCtrl = TextEditingController();
  final _genderCtrl = TextEditingController();
  final _dobCtrl = TextEditingController();
  final _ageCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _occupationCtrl = TextEditingController();
  final _weightCtrl = TextEditingController();
  final _heightCtrl = TextEditingController();
  final _nhisCtrl = TextEditingController();

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _middleNameCtrl.dispose();
    _surnameCtrl.dispose();
    _genderCtrl.dispose();
    _dobCtrl.dispose();
    _ageCtrl.dispose();
    _addressCtrl.dispose();
    _phoneCtrl.dispose();
    _occupationCtrl.dispose();
    _weightCtrl.dispose();
    _heightCtrl.dispose();
    _nhisCtrl.dispose();
    super.dispose();
  }

  // ── Pick profile photo ────────────────────────────────────────────────────
  Future<void> _pickPhoto() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png'],
      withData: true,
    );
    if (result != null && result.files.single.bytes != null) {
      setState(() => _profileImageBytes = result.files.single.bytes);
    }
  }

  // ── Save ──────────────────────────────────────────────────────────────────
  void _save() {
    // TODO: wire up to backend save endpoint
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Patient record saved.'),
        backgroundColor: _kTeal,
      ),
    );
  }

  // ─── BUILD ────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBackground,
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Sidebar ───────────────────────────────────────────────────────
          _Sidebar(
            selectedIndex: _selectedNav,
            onItemSelected: (i) => setState(() => _selectedNav = i),
          ),

          // ── Main area ─────────────────────────────────────────────────────
          Expanded(
            child: Column(
              children: [
                // Top bar
                _TopBar(),

                // Scrollable content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(28, 24, 28, 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── Page heading ─────────────────────────────────
                        const Text(
                          'Edit Patient Records',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: _kTextDark,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Enter patient details to create a new record and ensure accurate, efficient care management.',
                          style: TextStyle(fontSize: 12, color: _kTextGrey),
                        ),
                        const SizedBox(height: 24),

                        // ── Patient Profile Picture ───────────────────────
                        const Text(
                          'Patient Profile Picture',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: _kTextDark,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _ProfilePictureCard(
                          imageBytes: _profileImageBytes,
                          onUpload: _pickPhoto,
                        ),
                        const SizedBox(height: 28),

                        // ── Patient Personal Information ──────────────────
                        const Text(
                          'Patient Personal Information',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: _kTeal,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Two-column form grid
                        _FormGrid(
                          leftFields: [
                            _FieldData(
                              'First Name',
                              'Enter first name',
                              _firstNameCtrl,
                            ),
                            _FieldData(
                              'Middle Name',
                              'Enter middle name',
                              _middleNameCtrl,
                            ),
                            _FieldData(
                              'Surname',
                              'Enter surname',
                              _surnameCtrl,
                            ),
                            _FieldData('Gender', 'Enter Gender', _genderCtrl),
                            _FieldData(
                              'Date of Birth',
                              'Enter date for birth. eg: 16th April, 1990',
                              _dobCtrl,
                            ),
                            _FieldData('Age', 'Enter age. eg: 24', _ageCtrl),
                          ],
                          rightFields: [
                            _FieldData(
                              'Address',
                              'Enter address eg: Accra',
                              _addressCtrl,
                            ),
                            _FieldData(
                              'Phone Number',
                              'Enter Phone Number',
                              _phoneCtrl,
                            ),
                            _FieldData(
                              'Occupation',
                              'Enter Occupation. eg: Constructor',
                              _occupationCtrl,
                            ),
                            _FieldData(
                              'Weight',
                              'Enter weight. eg: 70kg',
                              _weightCtrl,
                            ),
                            _FieldData(
                              'Height',
                              'Enter Height. eg: 6.0ft',
                              _heightCtrl,
                            ),
                            _FieldData(
                              'NHIS ID Number',
                              'Enter NHIS ID Number',
                              _nhisCtrl,
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),

                        // ── Save button ───────────────────────────────────
                        Center(
                          child: SizedBox(
                            width: 180,
                            height: 44,
                            child: ElevatedButton(
                              onPressed: _save,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _kTeal,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text(
                                'Save',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: _kWhite,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // ── Footer ───────────────────────────────────────────────
                const _Footer(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── SIDEBAR ─────────────────────────────────────────────────────────────────

class _Sidebar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemSelected;

  const _Sidebar({required this.selectedIndex, required this.onItemSelected});

  static const _items = [
    _NavItem(icon: Icons.dashboard_rounded, label: 'Overview'),
    _NavItem(icon: Icons.personal_injury_rounded, label: 'Patient'),
    _NavItem(icon: Icons.medical_services_rounded, label: 'Doctor'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      height: double.infinity,
      color: _kSidebarTeal,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Logo
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
            child: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: _kWhite,
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: const Center(
                    child: Text(
                      'H',
                      style: TextStyle(
                        color: _kSidebarTeal,
                        fontWeight: FontWeight.w900,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Heathos',
                  style: TextStyle(
                    color: _kWhite,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),

          // Nav items
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: _items.length,
              itemBuilder: (_, i) => _SidebarItem(
                icon: _items[i].icon,
                label: _items[i].label,
                isSelected: selectedIndex == i,
                onTap: () => onItemSelected(i),
              ),
            ),
          ),

          // Logout
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
            child: InkWell(
              onTap: () => Navigator.of(context).pop(),
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 10,
                ),
                child: Row(
                  children: const [
                    Icon(Icons.logout_rounded, color: _kWhite, size: 18),
                    SizedBox(width: 10),
                    Text(
                      'Logout',
                      style: TextStyle(
                        color: _kWhite,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(width: 6),
                    Icon(Icons.arrow_forward_rounded, color: _kWhite, size: 16),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem({required this.icon, required this.label});
}

class _SidebarItem extends StatefulWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _SidebarItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_SidebarItem> createState() => _SidebarItemState();
}

class _SidebarItemState extends State<_SidebarItem> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovering = true),
        onExit: (_) => setState(() => _hovering = false),
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(8),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            decoration: BoxDecoration(
              color: widget.isSelected
                  ? _kWhite.withOpacity(0.20)
                  : _hovering
                  ? _kWhite.withOpacity(0.10)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              border: widget.isSelected
                  ? Border.all(color: _kWhite.withOpacity(0.3), width: 1)
                  : null,
            ),
            child: Row(
              children: [
                Icon(widget.icon, color: _kWhite, size: 18),
                const SizedBox(width: 10),
                Text(
                  widget.label,
                  style: TextStyle(
                    color: _kWhite,
                    fontSize: 13,
                    fontWeight: widget.isSelected
                        ? FontWeight.w700
                        : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── TOP BAR ─────────────────────────────────────────────────────────────────

class _TopBar extends StatelessWidget {
  const _TopBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _kWhite,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      child: Row(
        children: [
          const Spacer(),

          // Search
          Container(
            width: 220,
            height: 36,
            decoration: BoxDecoration(
              border: Border.all(color: _kTeal, width: 1.4),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: const [
                SizedBox(width: 12),
                Icon(Icons.search_rounded, color: _kTextGrey, size: 16),
                SizedBox(width: 6),
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search',
                      hintStyle: TextStyle(color: _kTextGrey, fontSize: 13),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
                Icon(Icons.mic_rounded, color: _kTextGrey, size: 16),
                SizedBox(width: 12),
              ],
            ),
          ),
          const SizedBox(width: 16),

          // Notification bell
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: _kTeal, width: 1.4),
                ),
                child: const Icon(
                  Icons.notifications_rounded,
                  color: _kTeal,
                  size: 18,
                ),
              ),
              Positioned(
                top: -3,
                right: -2,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 14),

          // Avatar + name
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: _kTealAccent,
                child: const Icon(
                  Icons.person_rounded,
                  color: _kWhite,
                  size: 20,
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Admin_Name',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: _kTextDark,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 5,
                      vertical: 1,
                    ),
                    decoration: BoxDecoration(
                      color: _kTealLight,
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: const Text(
                      'ADMIN',
                      style: TextStyle(
                        fontSize: 8,
                        color: _kWhite,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── PROFILE PICTURE CARD ────────────────────────────────────────────────────

class _ProfilePictureCard extends StatelessWidget {
  final Uint8List? imageBytes;
  final VoidCallback onUpload;

  const _ProfilePictureCard({required this.imageBytes, required this.onUpload});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: _kWhite,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _kBorder, width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Circular avatar preview
          CircleAvatar(
            radius: 38,
            backgroundColor: _kTealAccent.withOpacity(0.25),
            backgroundImage: imageBytes != null
                ? MemoryImage(imageBytes!)
                : null,
            child: imageBytes == null
                ? Icon(Icons.person_add_alt_1_rounded, color: _kTeal, size: 34)
                : null,
          ),
          const SizedBox(width: 20),

          // Upload button + hint text
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ElevatedButton.icon(
                onPressed: onUpload,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _kTeal,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                icon: const Icon(
                  Icons.upload_rounded,
                  color: _kWhite,
                  size: 16,
                ),
                label: const Text(
                  'Upload Profile Photo',
                  style: TextStyle(
                    color: _kWhite,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'You can upload .jpg or .png image files. max file size 500KB\nand image dimension of 512 × 512 px.',
                style: TextStyle(fontSize: 11, color: _kTextGrey, height: 1.5),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── TWO-COLUMN FORM GRID ────────────────────────────────────────────────────

class _FieldData {
  final String label;
  final String hint;
  final TextEditingController controller;
  const _FieldData(this.label, this.hint, this.controller);
}

class _FormGrid extends StatelessWidget {
  final List<_FieldData> leftFields;
  final List<_FieldData> rightFields;

  const _FormGrid({required this.leftFields, required this.rightFields});

  @override
  Widget build(BuildContext context) {
    final count = leftFields.length > rightFields.length
        ? leftFields.length
        : rightFields.length;

    return Column(
      children: List.generate(count, (i) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left column
              Expanded(
                child: i < leftFields.length
                    ? _FormField(data: leftFields[i])
                    : const SizedBox.shrink(),
              ),
              const SizedBox(width: 24),
              // Right column
              Expanded(
                child: i < rightFields.length
                    ? _FormField(data: rightFields[i])
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        );
      }),
    );
  }
}

class _FormField extends StatelessWidget {
  final _FieldData data;
  const _FormField({required this.data});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          data.label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: _kTextDark,
          ),
        ),
        const SizedBox(height: 6),
        SizedBox(
          height: 40,
          child: TextField(
            controller: data.controller,
            style: const TextStyle(fontSize: 13, color: _kTextDark),
            decoration: InputDecoration(
              hintText: data.hint,
              hintStyle: const TextStyle(color: _kTextGrey, fontSize: 12),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: const BorderSide(color: _kBorder, width: 1.2),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: const BorderSide(color: _kTeal, width: 1.6),
              ),
              filled: true,
              fillColor: _kWhite,
            ),
          ),
        ),
      ],
    );
  }
}

// ─── FOOTER ──────────────────────────────────────────────────────────────────

class _Footer extends StatelessWidget {
  const _Footer();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      color: _kBackground,
      child: const Center(
        child: Text(
          'Copyright © A2026.Designed by Group 5',
          style: TextStyle(
            color: _kTeal,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';

import 'constants/api_constants.dart';
// Import your actual page files
import 'admin_login_page.dart';
import 'admin_dashboard.dart';
import 'patient_dashboard.dart';
import 'appointment_page.dart';
import 'staff_page.dart';
import 'inventory_page.dart';
import 'billing_page.dart';
import 'doctor_dashboard.dart';
import 'administrative_staffs_page.dart';
import 'lab_technicians_page.dart';
import 'pharmacists_page.dart';

// ─── CONSTANTS ───────────────────────────────────────────────────────────────
const kTeal = Color(0xFF0D7B6B);
const kTealLight = Color(0xFF1A9E8A);
const kTealDark = Color(0xFF095F54);
const kTealAccent = Color(0xFF4FC3B0);
const kBackground = Color(0xFFF0F4F4);
const kWhite = Color(0xFFFFFFFF);
const kTextDark = Color(0xFF1A2E2C);
const kTextGrey = Color(0xFF7A9490);
const kTableHeader = Color(0xFFD0EFEC);
const kTabSelected = Color(0xFF0D7B6B);
const kTabUnselected = Color(0xFFFFFFFF);

const String _BaseUrl = 'https://heathos-api.onrender.com';

// ─── NAV INDEX CONSTANTS ────────────────────────────────────────────────────
const int kNavOverview = 0;
const int kNavPatient = 1;
const int kNavAppointment = 2;
const int kNavStaff = 3;
const int kNavInventory = 4;
const int kNavBillings = 5;

// ─── STAFF TAB CONSTANTS ────────────────────────────────────────────────────
enum StaffCategory { doctors, nurses, adminStaffs, labTechs, pharmacists }

// ─── MODELS ─────────────────────────────────────────────────────────────────
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

class NavItem {
  final IconData icon;
  final String label;
  final int index;
  const NavItem({required this.icon, required this.label, required this.index});
}

class Nurse {
  final String id;
  final String name;
  final String specialty;
  final String joinDate;
  final String? avatarUrl;

  const Nurse({
    required this.id,
    required this.name,
    required this.specialty,
    required this.joinDate,
    this.avatarUrl,
  });
}

// ─── NURSE LIST PAGE ────────────────────────────────────────────────────────
class NurseList extends StatefulWidget {
  const NurseList({super.key});

  @override
  State<NurseList> createState() => _NurseListState();
}

class _NurseListState extends State<NurseList> {
  Uint8List? _profileImageBytes;
  StaffCategory _selectedTab = StaffCategory.nurses; // Nurses tab is selected

  // Sidebar nav items - Staffs highlighted since we're in staff section
  final List<NavItem> _navItems = [
    NavItem(
      icon: Icons.dashboard_rounded,
      label: 'Overview',
      index: kNavOverview,
    ),
    NavItem(
      icon: Icons.personal_injury_rounded,
      label: 'Patient',
      index: kNavPatient,
    ),
    NavItem(
      icon: Icons.event_note_rounded,
      label: 'Appointment',
      index: kNavAppointment,
    ),
    NavItem(icon: Icons.groups_rounded, label: 'Staffs', index: kNavStaff),
    NavItem(
      icon: Icons.inventory_2_rounded,
      label: 'Inventory',
      index: kNavInventory,
    ),
    NavItem(
      icon: Icons.receipt_long_rounded,
      label: 'Billings',
      index: kNavBillings,
    ),
  ];

  // Mock data matching your screenshot
  final List<Nurse> _nurses = [
    Nurse(
      id: 'N#001',
      name: 'Abena Asiedu',
      specialty: 'General Nursing',
      joinDate: '05/03/2026',
      avatarUrl: 'https://i.pravatar.cc/150?img=31',
    ),
    Nurse(
      id: 'N#002',
      name: 'Akosua Frimpong',
      specialty: 'Paediatric Nursing',
      joinDate: '05/03/2026',
      avatarUrl: 'https://i.pravatar.cc/150?img=32',
    ),
    Nurse(
      id: 'N#003',
      name: 'Efua Nyamekye',
      specialty: 'General Nursing',
      joinDate: '05/03/2026',
      avatarUrl: 'https://i.pravatar.cc/150?img=33',
    ),
    Nurse(
      id: 'N#004',
      name: 'Adwoa Bentsi',
      specialty: 'Midwifery',
      joinDate: '05/03/2026',
      avatarUrl: 'https://i.pravatar.cc/150?img=34',
    ),
    Nurse(
      id: 'N#005',
      name: 'Yaa Opong',
      specialty: 'ICU / Critical Care',
      joinDate: '05/03/2026',
      avatarUrl: 'https://i.pravatar.cc/150?img=35',
    ),
    Nurse(
      id: 'N#006',
      name: 'Afia Koranteng',
      specialty: 'Midwifery',
      joinDate: '05/03/2026',
      avatarUrl: 'https://i.pravatar.cc/150?img=36',
    ),
    Nurse(
      id: 'N#007',
      name: 'Ama Gyan',
      specialty: 'ICU / Critical Care',
      joinDate: '05/03/2026',
      avatarUrl: 'https://i.pravatar.cc/150?img=37',
    ),
    Nurse(
      id: 'N#008',
      name: 'Esi Koomson',
      specialty: 'Public Health Nursing',
      joinDate: '05/03/2026',
      avatarUrl: 'https://i.pravatar.cc/150?img=38',
    ),
    Nurse(
      id: 'N#009',
      name: 'Dede Sefakor',
      specialty: 'Infection Control',
      joinDate: '05/03/2026',
      avatarUrl: 'https://i.pravatar.cc/150?img=39',
    ),
    Nurse(
      id: 'N#0010',
      name: 'Akua Mensima',
      specialty: 'Infection Control',
      joinDate: '05/03/2026',
      avatarUrl: 'https://i.pravatar.cc/150?img=40',
    ),
    Nurse(
      id: 'N#0011',
      name: 'Sena Ahiable',
      specialty: 'Public Health Nursing',
      joinDate: '05/03/2026',
      avatarUrl: 'https://i.pravatar.cc/150?img=41',
    ),
    Nurse(
      id: 'N#0012',
      name: 'Aba Kyei',
      specialty: 'Paediatric Nursing',
      joinDate: '05/03/2026',
      avatarUrl: 'https://i.pravatar.cc/150?img=42',
    ),
    Nurse(
      id: 'N#0013',
      name: 'Zainab Yakubu',
      specialty: 'Surgical Nursing',
      joinDate: '05/03/2026',
      avatarUrl: 'https://i.pravatar.cc/150?img=43',
    ),
    Nurse(
      id: 'N#0014',
      name: 'Fatima Sulemana',
      specialty: 'Surgical Nursing',
      joinDate: '05/03/2026',
      avatarUrl: 'https://i.pravatar.cc/150?img=44',
    ),
  ];

  // Handle sidebar navigation
  void _onNavItemSelected(int index) {
    if (index == kNavStaff) return; // Already in staff section
    switch (index) {
      case kNavOverview:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const AdminDashboard()),
        );
        break;
      case kNavPatient:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => PatientListPage()),
        );
        break;
      case kNavAppointment:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => AppointmentPage()),
        );
        break;
      case kNavInventory:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => InventoryPage()),
        );
        break;
      // case kNavBillings:
      //   Navigator.pushReplacement(
      //     context,
      //     MaterialPageRoute(builder: (_) => const BillingPage()),
      //   );
      //   break;
    }
  }

  // Handle staff category tab clicks - navigates to respective pages
  void _onStaffTabSelected(StaffCategory category) {
    if (category == StaffCategory.nurses) return; // Already here
    setState(() => _selectedTab = category);
    switch (category) {
      case StaffCategory.doctors:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const StaffPage()),
        );
        break;
      case StaffCategory.adminStaffs:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const AdministrativeStaffsPage()),
        );
        break;
      case StaffCategory.labTechs:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LabTechniciansPage()),
        );
        break;
      case StaffCategory.pharmacists:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const PharmacistsPage()),
        );
        break;
      case StaffCategory.nurses:
        break;
    }
  }

  void _logout() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const AdminLoginPage()),
      (route) => false,
    );
  }

  void _goToProfile() {}

  void _onProfileImageChanged(Uint8List bytes) {
    setState(() => _profileImageBytes = bytes);
  }

  void _addNurse() {
    // TODO: implement add nurse dialog/page
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      body: Row(
        children: [
          Sidebar(
            navItems: _navItems,
            selectedIndex: kNavStaff, // Staffs highlighted in sidebar
            onItemSelected: _onNavItemSelected,
            onLogout: _logout,
          ),
          Expanded(
            child: Column(
              children: [
                TopBar(
                  profileImageBytes: _profileImageBytes,
                  onProfileImageChanged: _onProfileImageChanged,
                  onLogout: _logout,
                  onGoToProfile: _goToProfile,
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(28, 20, 28, 28),
                    child: _NurseContent(
                      nurses: _nurses,
                      selectedTab: _selectedTab,
                      onTabSelected: _onStaffTabSelected,
                      onAddNurse: _addNurse,
                    ),
                  ),
                ),
                const Footer(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── NURSE CONTENT ──────────────────────────────────────────────────────────
class _NurseContent extends StatelessWidget {
  final List<Nurse> nurses;
  final StaffCategory selectedTab;
  final ValueChanged<StaffCategory> onTabSelected;
  final VoidCallback onAddNurse;

  const _NurseContent({
    required this.nurses,
    required this.selectedTab,
    required this.onTabSelected,
    required this.onAddNurse,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header: Title + Add Nurse button
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'List of Nurses',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: kTeal,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'View and Manage Nurses.',
                    style: TextStyle(
                      fontSize: 13,
                      color: kTextGrey,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            _AddNurseButton(onTap: onAddNurse),
          ],
        ),
        const SizedBox(height: 20),
        // Staff category tabs: Doctors, Nurses, Admin, Lab Techs, Pharmacists
        _StaffTabs(selectedTab: selectedTab, onTabSelected: onTabSelected),
        const SizedBox(height: 0), // No gap between tabs and table
        // Nurses data table
        _NursesTable(nurses: nurses),
      ],
    );
  }
}

class _AddNurseButton extends StatelessWidget {
  final VoidCallback onTap;
  const _AddNurseButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: kTeal,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.add_rounded, color: kWhite, size: 18),
            SizedBox(width: 8),
            Text(
              'Add Nurse',
              style: TextStyle(
                color: kWhite,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Staff category tabs - clickable to switch between staff types
class _StaffTabs extends StatelessWidget {
  final StaffCategory selectedTab;
  final ValueChanged<StaffCategory> onTabSelected;

  const _StaffTabs({required this.selectedTab, required this.onTabSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: kWhite,
        border: Border.all(color: kTeal, width: 1),
      ),
      child: Row(
        children: [
          _TabItem(
            icon: Icons.medical_services_outlined,
            label: 'Doctors',
            isSelected: selectedTab == StaffCategory.doctors,
            onTap: () => onTabSelected(StaffCategory.doctors),
          ),
          _TabItem(
            icon: Icons.local_hospital_outlined,
            label: 'Nurses',
            isSelected: selectedTab == StaffCategory.nurses,
            onTap: () => onTabSelected(StaffCategory.nurses),
          ),
          _TabItem(
            icon: Icons.business_center_outlined,
            label: 'Administrative Staffs',
            isSelected: selectedTab == StaffCategory.adminStaffs,
            onTap: () => onTabSelected(StaffCategory.adminStaffs),
            isMultiline: true,
          ),
          _TabItem(
            icon: Icons.science_outlined,
            label: 'Lab Technicians',
            isSelected: selectedTab == StaffCategory.labTechs,
            onTap: () => onTabSelected(StaffCategory.labTechs),
            isMultiline: true,
          ),
          _TabItem(
            icon: Icons.local_pharmacy_outlined,
            label: 'Pharmacists',
            isSelected: selectedTab == StaffCategory.pharmacists,
            onTap: () => onTabSelected(StaffCategory.pharmacists),
          ),
        ],
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isMultiline;

  const _TabItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.isMultiline = false,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            color: isSelected? kTabSelected : kTabUnselected,
            border: Border(right: BorderSide(color: kTeal, width: 1)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: isSelected? kWhite : kTeal, size: 24),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: isSelected? kWhite : kTeal,
                    height: isMultiline? 1.1 : 1.2,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NursesTable extends StatelessWidget {
  final List<Nurse> nurses;
  const _NursesTable({required this.nurses});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: kWhite,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Table header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            color: kTableHeader,
            child: Row(
              children: const [
                SizedBox(
                  width: 80,
                  child: Text(
                    'Staff ID',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: kTextDark,
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    'Name',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: kTextDark,
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    'Specialty',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: kTextDark,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'Joining Date',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: kTextDark,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'Action',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: kTextDark,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Table rows with alternating colors
         ...nurses.asMap().entries.map((entry) {
            final index = entry.key;
            final nurse = entry.value;
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: index % 2 == 0? kWhite : const Color(0xFFF8FCFB),
                border: index < nurses.length - 1
                   ? Border(bottom: BorderSide(color: Colors.grey.shade200))
                    : null,
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 80,
                    child: Text(
                      nurse.id,
                      style: const TextStyle(fontSize: 13, color: kTextDark),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: kTealAccent.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child:
                              nurse.avatarUrl!= null &&
                                  nurse.avatarUrl!.isNotEmpty
                             ? Image.network(
                                  nurse.avatarUrl!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => const Icon(
                                    Icons.person,
                                    size: 20,
                                    color: kTeal,
                                  ),
                                )
                              : const Icon(
                                  Icons.person,
                                  size: 20,
                                  color: kTeal,
                                ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          nurse.name,
                          style: const TextStyle(
                            fontSize: 13,
                            color: kTextDark,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text(
                      nurse.specialty,
                      style: const TextStyle(fontSize: 13, color: kTextDark),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      nurse.joinDate,
                      style: const TextStyle(fontSize: 13, color: kTextDark),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: InkWell(
                      onTap: () {
                        // TODO: Navigate to nurse details
                      },
                      child: Row(
                        children: const [
                          Icon(
                            Icons.north_east_rounded,
                            size: 14,
                            color: kTeal,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'View Details',
                            style: TextStyle(
                              fontSize: 13,
                              color: kTeal,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ─── SIDEBAR, TOPBAR, FOOTER ────────────────────────────────────────────────
// Reuse the same classes from patient_list_page.dart and billing_page.dart

class Sidebar extends StatelessWidget {
  final List<NavItem> navItems;
  final int selectedIndex;
  final ValueChanged<int> onItemSelected;
  final VoidCallback onLogout;

  const Sidebar({
    super.key,
    required this.navItems,
    required this.selectedIndex,
    required this.onItemSelected,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 240,
      height: double.infinity,
      color: kTeal,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
            child: Row(
              children: [
                SizedBox(
                  width: 38,
                  height: 38,
                  child: Image.asset(
                    'assets/images/Group.png',
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(width: 10),
                const Text(
                  'Heathos',
                  style: TextStyle(
                    color: kWhite,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          // Build nav items with special handling for Staffs selection
         ...navItems.map((item) {
            final isStaffs = item.index == kNavStaff;
            final isSelected = selectedIndex == item.index;
            return Container(
              color: isSelected? kWhite : Colors.transparent,
              child: SidebarItem(
                icon: item.icon,
                label: item.label,
                isSelected: isSelected,
                isInverted: isSelected, // White bg, teal text for Staffs
                onTap: () => onItemSelected(item.index),
              ),
            );
          }),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
            child: InkWell(
              onTap: onLogout,
              borderRadius: BorderRadius.circular(10),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                child: Row(
                  children: const [
                    Text(
                      'Logout',
                      style: TextStyle(
                        color: kWhite,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_forward_rounded, color: kWhite, size: 18),
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

class SidebarItem extends StatefulWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final bool isInverted; // For white background + teal text
  final VoidCallback onTap;

  const SidebarItem({
    super.key,
    required this.icon,
    required this.label,
    required this.isSelected,
    this.isInverted = false,
    required this.onTap,
  });

  @override
  State<SidebarItem> createState() => _SidebarItemState();
}

class _SidebarItemState extends State<SidebarItem> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    // Determine colors based on inverted state
    final Color textColor = widget.isInverted? kTeal : kWhite;
    final Color iconColor = widget.isInverted? kTeal : kWhite;
    final Color bgColor = widget.isInverted
       ? kWhite
        : widget.isSelected
       ? kWhite.withOpacity(0.20)
        : _hovering
       ? kWhite.withOpacity(0.10)
        : Colors.transparent;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovering = true),
        onExit: (_) => setState(() => _hovering = false),
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(10),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(10),
              border: widget.isSelected &&!widget.isInverted
                 ? Border.all(color: kWhite.withOpacity(0.3), width: 1)
                  : null,
            ),
            child: Row(
              children: [
                Icon(widget.icon, color: iconColor, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.label,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 14,
                      fontWeight: widget.isSelected
                         ? FontWeight.w700
                          : FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
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

// TopBar and Footer are identical to other pages
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
  List<SearchResult> _searchResults = [];
  bool _isSearching = false;
  Timer? _debounce;

  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  Timer? _hideTimer;
  bool _isHoveringBadge = false;
  bool _isHoveringMenu = false;

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    _hideTimer?.cancel();
    _removeOverlay();
    super.dispose();
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

  Future<void> _runSearch(String query) async {
    setState(() => _isSearching = true);

    final endpoints = {
      'Doctor': '$_BaseUrl/doctors/search?q=$query',
      'Patient': '$_BaseUrl/patients/search?q=$query',
      'Nurse': '$_BaseUrl/nurses/search?q=$query',
      'Staff': '$_BaseUrl/staff/search?q=$query',
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
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextButton.icon(
                      onPressed: () {
                        _removeOverlay();
                        widget.onGoToProfile();
                      },
                      icon: const Icon(
                        Icons.person_outline_rounded,
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
                        Icons.logout_rounded,
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

  @override
  Widget build(BuildContext context) {
    return Container(
      color: kWhite,
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
      child: Row(
        children: [
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
          Row(
            children: [
              GestureDetector(
                onTap: _pickProfileImage,
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: kTealAccent,
                      shape: BoxShape.circle,
                      border: Border.all(color: kTeal, width: 1.5),
                    ),
                    child: ClipOval(
                      child: widget.profileImageBytes != null
                          ? Image.memory(
                              widget.profileImageBytes!,
                              fit: BoxFit.cover,
                              width: 40,
                              height: 40,
                            )
                          : const Icon(
                              Icons.person_rounded,
                              color: kWhite,
                              size: 22,
                            ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Admin_Name',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: kTextDark,
                    ),
                  ),
                  const SizedBox(height: 2),
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
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: kTealLight,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Text(
                                'ADMIN',
                                style: TextStyle(
                                  fontSize: 9,
                                  color: kWhite,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.8,
                                ),
                              ),
                              SizedBox(width: 2),
                              Icon(
                                Icons.keyboard_arrow_down_rounded,
                                color: kWhite,
                                size: 12,
                              ),
                            ],
                          ),
                        ),
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

// ─── FOOTER ─────────────────────────────────────────────────────────────────
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

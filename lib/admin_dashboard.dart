import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';

// ── Page imports — add each file as you create it ────────────────────────────
import 'admin_login_page.dart';
import 'admin_profile.dart';
import 'patient_dashboard.dart';   // uncomment when ready
import 'doctor_list.dart';    // uncomment when ready
import 'nurse_list.dart';     // uncomment when ready

// ─── CONSTANTS ───────────────────────────────────────────────────────────────

const kTeal = Color(0xFF0D7B6B);
const kTealLight = Color(0xFF1A9E8A);
const kTealDark = Color(0xFF095F54);
const kTealAccent = Color(0xFF4FC3B0);
const kBackground = Color(0xFFF0F4F4);
const kWhite = Color(0xFFFFFFFF);
const kTextDark = Color(0xFF1A2E2C);
const kTextGrey = Color(0xFF7A9490);

const String _baseUrl = 'https://heathos-app-latest.onrender.com';

// ─── NAV INDEX CONSTANTS — update these as you add more pages ────────────────
const int _kNavOverview = 0;
const int _kNavPatient = 1;
const int _kNavDoctor = 2;
const int _kNavNurse = 3;

// ─── SEARCH RESULT MODEL ─────────────────────────────────────────────────────

class _SearchResult {
  final String name;
  final String category;
  final String subtitle;
  const _SearchResult({
    required this.name,
    required this.category,
    required this.subtitle,
  });
}

// ─── ADMIN DASHBOARD ─────────────────────────────────────────────────────────

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _selectedIndex = _kNavOverview;
  Uint8List? _profileImageBytes;

  final List<_NavItem> _navItems = const [
    _NavItem(
      icon: Icons.dashboard_rounded,
      label: 'Overview',
      index: _kNavOverview,
    ),
    _NavItem(
      icon: Icons.personal_injury_rounded,
      label: 'Patient',
      index: _kNavPatient,
    ),
    _NavItem(
      icon: Icons.medical_services_rounded,
      label: 'Doctor',
      index: _kNavDoctor,
    ),
    _NavItem(
      icon: Icons.health_and_safety_rounded,
      label: 'Nurse',
      index: _kNavNurse,
    ),
  ];

  // ── Navigation helpers ────────────────────────────────────────────────────

  /// Called when a sidebar nav item is tapped.
  /// Overview stays on this page; others push to their own page.
  void _onNavItemSelected(int index) {
    setState(() => _selectedIndex = index);

    switch (index) {
      case _kNavOverview:
        // Already on this page — do nothing
        break;

      case _kNavPatient:
        Navigator.push(context, MaterialPageRoute(builder: (_) =>  PatientDashboard()));
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Patient page coming soon.')),
        );
        break;

      case _kNavDoctor:
        Navigator.push(context, MaterialPageRoute(builder: (_) => const DoctorListPage()));
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Doctor page coming soon.')),
        );
        break;

      case _kNavNurse:
        Navigator.push(context, MaterialPageRoute(builder: (_) => const NurseList()));
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Nurse page coming soon.')),
        );
        break;
    }
  }

  /// Logout — clears the entire navigation stack and returns to login.
  void _logout() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const AdminLoginPage()),
      (route) => true,
    );
  }

  /// Profile — pushes to AdminProfilePage.
  void _goToProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AdminProfilePage()),
    );
  }

  void _onProfileImageChanged(Uint8List bytes) {
    setState(() => _profileImageBytes = bytes);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      body: Row(
        children: [
          // ── Sidebar ──────────────────────────────────────────────────────
          _Sidebar(
            navItems: _navItems,
            selectedIndex: _selectedIndex,
            onItemSelected: _onNavItemSelected,
            onLogout: _logout,
          ),
          // ── Main content ─────────────────────────────────────────────────
          Expanded(
            child: _MainContent(
              profileImageBytes: _profileImageBytes,
              onProfileImageChanged: _onProfileImageChanged,
              onLogout: _logout,
              onGoToProfile: _goToProfile,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── SIDEBAR ─────────────────────────────────────────────────────────────────

class _NavItem {
  final IconData icon;
  final String label;
  final int index;
  const _NavItem({
    required this.icon,
    required this.label,
    required this.index,
  });
}

class _Sidebar extends StatelessWidget {
  final List<_NavItem> navItems;
  final int selectedIndex;
  final ValueChanged<int> onItemSelected;
  final VoidCallback onLogout;

  const _Sidebar({
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
          // ── Logo ──
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
            child: Row(
              children: [
                Container(
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

          // ── Nav items ──
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: navItems.length,
              itemBuilder: (_, i) => _SidebarItem(
                icon: navItems[i].icon,
                label: navItems[i].label,
                isSelected: selectedIndex == navItems[i].index,
                onTap: () => onItemSelected(navItems[i].index),
              ),
            ),
          ),

          // ── Logout ──
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
            child: InkWell(
              onTap: onLogout, // ← navigates to AdminLoginPage
              borderRadius: BorderRadius.circular(10),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                child: Row(
                  children: const [
                    Icon(Icons.logout_rounded, color: kWhite, size: 20),
                    SizedBox(width: 12),
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
              color: widget.isSelected
                  ? kWhite.withOpacity(0.20)
                  : _hovering
                  ? kWhite.withOpacity(0.10)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
              border: widget.isSelected
                  ? Border.all(color: kWhite.withOpacity(0.3), width: 1)
                  : null,
            ),
            child: Row(
              children: [
                Icon(widget.icon, color: kWhite, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.label,
                    style: TextStyle(
                      color: kWhite,
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

// ─── MAIN CONTENT ────────────────────────────────────────────────────────────

class _MainContent extends StatelessWidget {
  final Uint8List? profileImageBytes;
  final ValueChanged<Uint8List> onProfileImageChanged;
  final VoidCallback onLogout;
  final VoidCallback onGoToProfile;

  const _MainContent({
    required this.profileImageBytes,
    required this.onProfileImageChanged,
    required this.onLogout,
    required this.onGoToProfile,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _TopBar(
          profileImageBytes: profileImageBytes,
          onProfileImageChanged: onProfileImageChanged,
          onLogout: onLogout,
          onGoToProfile: onGoToProfile,
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(28, 20, 28, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: const [_DoctorsPill(), Spacer(), _LiveDateTime()],
                ),
                const SizedBox(height: 24),
                const _StatsRow(),
                const SizedBox(height: 28),
                const _PatientStatsCard(),
              ],
            ),
          ),
        ),
        const _Footer(),
      ],
    );
  }
}

// ─── TOP BAR ─────────────────────────────────────────────────────────────────

class _TopBar extends StatefulWidget {
  final Uint8List? profileImageBytes;
  final ValueChanged<Uint8List> onProfileImageChanged;
  final VoidCallback onLogout;
  final VoidCallback onGoToProfile;

  const _TopBar({
    required this.profileImageBytes,
    required this.onProfileImageChanged,
    required this.onLogout,
    required this.onGoToProfile,
  });

  @override
  State<_TopBar> createState() => _TopBarState();
}

class _TopBarState extends State<_TopBar> {
  final _searchController = TextEditingController();
  List<_SearchResult> _searchResults = [];
  bool _isSearching = false;
  Timer? _debounce;

  // Overlay for ADMIN badge hover menu
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  bool _menuVisible = false;

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    _removeOverlay();
    super.dispose();
  }

  // ── Profile image picker ──────────────────────────────────────────────────
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

  // ── Search ────────────────────────────────────────────────────────────────
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
      'Doctor': '$_baseUrl/doctors/search?q=$query',
      'Patient': '$_baseUrl/patients/search?q=$query',
      'Nurse': '$_baseUrl/nurses/search?q=$query',
      'Staff': '$_baseUrl/staff/search?q=$query',
    };

    final results = <_SearchResult>[];

    await Future.wait(
      endpoints.entries.map((entry) async {
        try {
          final response = await http
              .get(Uri.parse(entry.value))
              .timeout(const Duration(seconds: 8));
          if (response.statusCode == 200) {
            final body = jsonDecode(response.body);
            final List<dynamic> items = body is List
                ? body
                : (body['data'] as List? ?? []);
            for (final item in items) {
              results.add(
                _SearchResult(
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
          }
        } catch (_) {
          // Silently skip failed endpoints
        }
      }),
    );

    if (mounted) {
      setState(() {
        _searchResults = results;
        _isSearching = false;
      });
    }
  }

  // ── ADMIN badge overlay menu ──────────────────────────────────────────────
  void _showAdminMenu() {
    if (_menuVisible) return;
    _overlayEntry = OverlayEntry(
      builder: (_) => Positioned(
        width: 150,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: const Offset(-40, 38),
          child: MouseRegion(
            // Keep open while hovering the menu itself
            onEnter: (_) {},
            onExit: (_) =>
                Future.delayed(const Duration(milliseconds: 150), () {
                  if (mounted) _removeOverlay();
                }),
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
                    // ── Profile ──────────────────────────────────────
                    _OverlayMenuItem(
                      icon: Icons.person_outline_rounded,
                      label: 'Profile',
                      onTap: () {
                        _removeOverlay();
                        widget.onGoToProfile(); // → AdminProfilePage
                      },
                    ),
                    Divider(height: 1, color: Colors.grey.shade200),
                    // ── Logout ───────────────────────────────────────
                    _OverlayMenuItem(
                      icon: Icons.logout_rounded,
                      label: 'Logout',
                      isDestructive: true,
                      onTap: () {
                        _removeOverlay();
                        widget.onLogout(); // → AdminLoginPage
                      },
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
    setState(() => _menuVisible = true);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    if (mounted) setState(() => _menuVisible = false);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: kWhite,
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
      child: Row(
        children: [
          // Welcome
          RichText(
            text: const TextSpan(
              style: TextStyle(fontSize: 16, color: kTextDark),
              children: [
                TextSpan(text: 'Welcome Back, '),
                TextSpan(
                  text: 'ADMIN',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
              ],
            ),
          ),
          const Spacer(),

          // ── Search ───────────────────────────────────────────────────
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

                // Search results dropdown
                if (_searchResults.isNotEmpty)
                  Container(
                    constraints: const BoxConstraints(maxHeight: 260),
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

          // ── Notification bell ─────────────────────────────────────────
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

          // ── Avatar + name + ADMIN badge ───────────────────────────────
          Row(
            children: [
              // Avatar — click to pick profile image
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

                  // ── ADMIN badge — hover shows Profile / Logout menu ──
                  CompositedTransformTarget(
                    link: _layerLink,
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      onEnter: (_) => _showAdminMenu(),
                      onExit: (_) =>
                          Future.delayed(const Duration(milliseconds: 200), () {
                            if (mounted) _removeOverlay();
                          }),
                      child: GestureDetector(
                        onTap: _menuVisible ? _removeOverlay : _showAdminMenu,
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

// ─── OVERLAY MENU ITEM ────────────────────────────────────────────────────────

class _OverlayMenuItem extends StatefulWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDestructive;

  const _OverlayMenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  State<_OverlayMenuItem> createState() => _OverlayMenuItemState();
}

class _OverlayMenuItemState extends State<_OverlayMenuItem> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final color = widget.isDestructive ? Colors.red : kTeal;
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(8),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: _hovering ? color.withOpacity(0.08) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(widget.icon, size: 15, color: color),
              const SizedBox(width: 8),
              Text(
                widget.label,
                style: TextStyle(
                  fontSize: 13,
                  color: widget.isDestructive ? Colors.red : kTextDark,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── LIVE DATE & TIME ────────────────────────────────────────────────────────

class _LiveDateTime extends StatefulWidget {
  const _LiveDateTime();

  @override
  State<_LiveDateTime> createState() => _LiveDateTimeState();
}

class _LiveDateTimeState extends State<_LiveDateTime> {
  late Timer _timer;
  late DateTime _now;

  @override
  void initState() {
    super.initState();
    _now = DateTime.now();
    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => setState(() => _now = DateTime.now()),
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String _pad(int n) => n.toString().padLeft(2, '0');

  String get _dateStr => '${_pad(_now.day)}/${_pad(_now.month)}/${_now.year}';

  String get _timeStr {
    final h = _now.hour % 12 == 0 ? 12 : _now.hour % 12;
    final period = _now.hour >= 12 ? 'pm' : 'am';
    return '$h:${_pad(_now.minute)}:${_pad(_now.second)}$period';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          _dateStr,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: kTeal,
          ),
        ),
        Text(
          _timeStr,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: kTextGrey,
          ),
        ),
      ],
    );
  }
}

// ─── DOCTORS PILL ────────────────────────────────────────────────────────────

class _DoctorsPill extends StatelessWidget {
  const _DoctorsPill();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      decoration: BoxDecoration(
        color: kTeal,
        borderRadius: BorderRadius.circular(32),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Text(
            '10',
            style: TextStyle(
              color: kWhite,
              fontSize: 26,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(width: 12),
          Text(
            'Available Doctors',
            style: TextStyle(
              color: kWhite,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(width: 8),
          Icon(Icons.monitor_heart_outlined, color: kWhite, size: 22),
        ],
      ),
    );
  }
}

// ─── STATS ROW ───────────────────────────────────────────────────────────────

class _StatData {
  final IconData icon;
  final String value;
  final String label;
  const _StatData({
    required this.icon,
    required this.value,
    required this.label,
  });
}

class _StatsRow extends StatelessWidget {
  const _StatsRow();

  @override
  Widget build(BuildContext context) {
    const stats = [
      _StatData(
        icon: Icons.local_hospital_rounded,
        value: '200+',
        label: 'Medical\nStaff',
      ),
      _StatData(
        icon: Icons.people_alt_rounded,
        value: '300+',
        label: 'Total\nPatients',
      ),
      _StatData(
        icon: Icons.groups_rounded,
        value: '5000+',
        label: 'Over\nVisitors',
      ),
      _StatData(
        icon: Icons.work_rounded,
        value: '100+',
        label: 'Administration\nstaff',
      ),
    ];

    return Row(
      children: List.generate(stats.length, (i) {
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: i < stats.length - 1 ? 16.0 : 0.0),
            child: _StatCard(data: stats[i]),
          ),
        );
      }),
    );
  }
}

class _StatCard extends StatefulWidget {
  final _StatData data;
  const _StatCard({super.key, required this.data});

  @override
  State<_StatCard> createState() => _StatCardState();
}

class _StatCardState extends State<_StatCard> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: _hovering ? kTealDark : kTeal,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: kTeal.withOpacity(_hovering ? 0.45 : 0.22),
              blurRadius: _hovering ? 20 : 10,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: kWhite.withOpacity(0.20),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(widget.data.icon, color: kWhite, size: 28),
            ),
            const SizedBox(height: 20),
            Text(
              widget.data.value,
              style: const TextStyle(
                color: kWhite,
                fontSize: 32,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              widget.data.label,
              style: TextStyle(
                color: kWhite.withOpacity(0.85),
                fontSize: 14,
                fontWeight: FontWeight.w500,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── PATIENT STATISTICS CARD ─────────────────────────────────────────────────

class _PatientStatsCard extends StatelessWidget {
  const _PatientStatsCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: kWhite,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Patient Statistics',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: kTextDark,
                ),
              ),
              const Spacer(),
              _LegendDot(color: kTeal, label: 'Admitted Patients'),
              const SizedBox(width: 16),
              _LegendDot(color: kTealAccent, label: 'Discharged Patients'),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(height: 260, child: _AreaChart()),
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 12, color: kTextGrey)),
      ],
    );
  }
}

// ─── AREA CHART ──────────────────────────────────────────────────────────────

class _AreaChart extends StatelessWidget {
  final List<double> series1 = const [280, 300, 260, 130, 310, 370, 440];
  final List<double> series2 = const [380, 260, 340, 240, 200, 290, 410];
  final List<String> days = const [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  _AreaChart();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _AreaChartPainter(
        series1: series1,
        series2: series2,
        days: days,
      ),
      child: Container(),
    );
  }
}

class _AreaChartPainter extends CustomPainter {
  final List<double> series1;
  final List<double> series2;
  final List<String> days;

  const _AreaChartPainter({
    required this.series1,
    required this.series2,
    required this.days,
  });

  static const double _leftPad = 48;
  static const double _bottomPad = 40;
  static const double _topPad = 12;
  static const double _maxVal = 600;
  static const int _gridLines = 4;

  @override
  void paint(Canvas canvas, Size size) {
    final chartW = size.width - _leftPad;
    final chartH = size.height - _bottomPad - _topPad;

    final gridPaint = Paint()
      ..color = Colors.grey.withOpacity(0.15)
      ..strokeWidth = 1;
    const labelStyle = TextStyle(color: kTextGrey, fontSize: 11);

    for (int i = 0; i <= _gridLines; i++) {
      final y = _topPad + chartH - (i / _gridLines) * chartH;
      canvas.drawLine(Offset(_leftPad, y), Offset(size.width, y), gridPaint);
      final val = ((i / _gridLines) * _maxVal).round();
      final tp = TextPainter(
        text: TextSpan(text: '$val', style: labelStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(0, y - tp.height / 2));
    }

    Offset pt(int index, double val) {
      final x = _leftPad + (index / (days.length - 1)) * chartW;
      final y = _topPad + chartH - (val / _maxVal) * chartH;
      return Offset(x, y);
    }

    _drawArea(
      canvas,
      series2,
      pt,
      chartH,
      size,
      const Color(0xFF4FC3B0).withOpacity(0.22),
      const Color(0xFF4FC3B0).withOpacity(0.0),
    );
    _drawArea(
      canvas,
      series1,
      pt,
      chartH,
      size,
      kTeal.withOpacity(0.50),
      kTeal.withOpacity(0.04),
    );
    _drawLine(canvas, series2, pt, kTealAccent, 2.0);
    _drawLine(canvas, series1, pt, kTeal, 2.5);

    final dotFill = Paint()
      ..color = kTeal
      ..style = PaintingStyle.fill;
    final dotBorder = Paint()
      ..color = kWhite
      ..style = PaintingStyle.fill;
    for (int i = 0; i < series1.length; i++) {
      final p = pt(i, series1[i]);
      canvas.drawCircle(p, 5.5, dotBorder);
      canvas.drawCircle(p, 3.5, dotFill);
    }

    for (int i = 0; i < days.length; i++) {
      final tp = TextPainter(
        text: TextSpan(text: days[i], style: labelStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      final x = _leftPad + (i / (days.length - 1)) * chartW;
      tp.paint(canvas, Offset(x - tp.width / 2, size.height - _bottomPad + 10));
    }

    canvas.drawLine(
      Offset(_leftPad, _topPad + chartH),
      Offset(size.width, _topPad + chartH),
      gridPaint..color = Colors.grey.withOpacity(0.30),
    );
  }

  void _drawArea(
    Canvas canvas,
    List<double> data,
    Offset Function(int, double) pt,
    double chartH,
    Size size,
    Color topColor,
    Color bottomColor,
  ) {
    final path = Path()
      ..moveTo(pt(0, data[0]).dx, _topPad + chartH)
      ..lineTo(pt(0, data[0]).dx, pt(0, data[0]).dy);
    for (int i = 1; i < data.length; i++) {
      final prev = pt(i - 1, data[i - 1]);
      final curr = pt(i, data[i]);
      final cpX = (prev.dx + curr.dx) / 2;
      path.cubicTo(cpX, prev.dy, cpX, curr.dy, curr.dx, curr.dy);
    }
    path
      ..lineTo(pt(data.length - 1, data.last).dx, _topPad + chartH)
      ..close();
    final rect = Rect.fromLTWH(
      _leftPad,
      _topPad,
      size.width - _leftPad,
      chartH,
    );
    canvas.drawPath(
      path,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [topColor, bottomColor],
        ).createShader(rect),
    );
  }

  void _drawLine(
    Canvas canvas,
    List<double> data,
    Offset Function(int, double) pt,
    Color color,
    double strokeWidth,
  ) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final path = Path()..moveTo(pt(0, data[0]).dx, pt(0, data[0]).dy);
    for (int i = 1; i < data.length; i++) {
      final prev = pt(i - 1, data[i - 1]);
      final curr = pt(i, data[i]);
      final cpX = (prev.dx + curr.dx) / 2;
      path.cubicTo(cpX, prev.dy, cpX, curr.dy, curr.dx, curr.dy);
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ─── FOOTER ──────────────────────────────────────────────────────────────────

class _Footer extends StatelessWidget {
  const _Footer();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      color: kBackground,
      child: const Center(
        child: Text(
          'Copyright © A2026. Designed by Group 5',
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

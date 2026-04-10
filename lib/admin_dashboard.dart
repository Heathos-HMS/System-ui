import 'package:flutter/material.dart';


// ─── CONSTANTS ──────────────────────────────────────────────────────────────

const kTeal = Color(0xFF0D7B6B);
const kTealLight = Color(0xFF1A9E8A);
const kTealDark = Color(0xFF095F54);
const kTealAccent = Color(0xFF4FC3B0);
const kBackground = Color(0xFFF0F4F4);
const kWhite = Color(0xFFFFFFFF);
const kTextDark = Color(0xFF1A2E2C);
const kTextGrey = Color(0xFF7A9490);

// ─── ADMIN DASHBOARD ────────────────────────────────────────────────────────

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _selectedIndex = 0;

  final List<_NavItem> _navItems = const [
    _NavItem(icon: Icons.dashboard_rounded, label: 'Overview'),
    _NavItem(icon: Icons.person_rounded, label: 'Profile'),
    _NavItem(icon: Icons.calendar_today_rounded, label: 'Appointment'),
    _NavItem(icon: Icons.personal_injury_rounded, label: 'Patient'),
    _NavItem(icon: Icons.medical_services_rounded, label: 'Doctor'),
    _NavItem(icon: Icons.health_and_safety_rounded, label: 'Nurse'),
    _NavItem(icon: Icons.science_rounded, label: 'Lab Technician'),
    _NavItem(icon: Icons.medication_rounded, label: 'Pharmacy'),
    _NavItem(icon: Icons.admin_panel_settings_rounded, label: 'Administrative Staff'),
    _NavItem(icon: Icons.receipt_long_rounded, label: 'Billings'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      body: Row(
        children: [
          // ── Sidebar ──
          _Sidebar(
            navItems: _navItems,
            selectedIndex: _selectedIndex,
            onItemSelected: (i) => setState(() => _selectedIndex = i),
          ),
          // ── Main content ──
          const Expanded(child: _MainContent()),
        ],
      ),
    );
  }
}

// ─── SIDEBAR ────────────────────────────────────────────────────────────────

class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem({required this.icon, required this.label});
}

class _Sidebar extends StatelessWidget {
  final List<_NavItem> navItems;
  final int selectedIndex;
  final ValueChanged<int> onItemSelected;

  const _Sidebar({
    required this.navItems,
    required this.selectedIndex,
    required this.onItemSelected,
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
                  decoration: BoxDecoration(
                    color: kWhite,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(
                    child: Text(
                      'H',
                      style: TextStyle(
                        color: kTeal,
                        fontWeight: FontWeight.w900,
                        fontSize: 22,
                      ),
                    ),
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
              itemBuilder: (context, index) {
                return _SidebarItem(
                  icon: navItems[index].icon,
                  label: navItems[index].label,
                  isSelected: selectedIndex == index,
                  onTap: () => onItemSelected(index),
                );
              },
            ),
          ),

          // ── Logout ──
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
            child: InkWell(
              onTap: () {
                Navigator.pushReplacementNamed(context, '/login');
              },
              borderRadius: BorderRadius.circular(10),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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

// ─── MAIN CONTENT ───────────────────────────────────────────────────────────

class _MainContent extends StatelessWidget {
  const _MainContent();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const _TopBar(),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(28, 20, 28, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Doctors pill + date ──
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: const [
                    _DoctorsPill(),
                    Spacer(),
                    _DateWidget(),
                  ],
                ),
                const SizedBox(height: 24),

                // ── Stats cards ──
                const _StatsRow(),
                const SizedBox(height: 28),

                // ── Chart ──
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

// ─── TOP BAR ────────────────────────────────────────────────────────────────

class _TopBar extends StatelessWidget {
  const _TopBar();

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

          // Search bar
          Container(
            width: 260,
            height: 40,
            decoration: BoxDecoration(
              border: Border.all(color: kTeal, width: 1.5),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: const [
                SizedBox(width: 14),
                Icon(Icons.search_rounded, color: kTextGrey, size: 18),
                SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search',
                      hintStyle: TextStyle(color: kTextGrey, fontSize: 14),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
                Icon(Icons.mic_rounded, color: kTextGrey, size: 18),
                SizedBox(width: 14),
              ],
            ),
          ),
          const SizedBox(width: 20),

          // Notification bell
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
                child: const Icon(Icons.notifications_rounded,
                    color: kTeal, size: 20),
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
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),

          // Admin avatar
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: kTealAccent,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.person_rounded,
                    color: kWhite, size: 22),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Admin_Name',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: kTextDark,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 1),
                    decoration: BoxDecoration(
                      color: kTealLight,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'ADMIN',
                      style: TextStyle(
                        fontSize: 9,
                        color: kWhite,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
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

// ─── DOCTORS PILL ───────────────────────────────────────────────────────────

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
            '20',
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

// ─── DATE WIDGET ────────────────────────────────────────────────────────────

class _DateWidget extends StatelessWidget {
  const _DateWidget();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          '09/04/2026',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: kTeal,
          ),
        ),
        Text(
          '10:30am',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: kTextGrey,
          ),
        ),
      ],
    );
  }
}

// ─── STATS ROW ──────────────────────────────────────────────────────────────

class _StatData {
  final IconData icon;
  final String value;
  final String label;
  const _StatData(
      {required this.icon, required this.value, required this.label});
}

class _StatsRow extends StatelessWidget {
  const _StatsRow();

  @override
  Widget build(BuildContext context) {
    const stats = [
      _StatData(
          icon: Icons.local_hospital_rounded,
          value: '200+',
          label: 'Medical\nStaff'),
      _StatData(
          icon: Icons.people_alt_rounded,
          value: '300+',
          label: 'Total\nPatients'),
      _StatData(
          icon: Icons.groups_rounded,
          value: '5000+',
          label: 'Over\nVisitors'),
      _StatData(
          icon: Icons.work_rounded,
          value: '100+',
          label: 'Administration\nstaff'),
    ];

    return Row(
      children: List.generate(stats.length, (index) {
        return Expanded(
          child: Padding(
            padding:
                EdgeInsets.only(right: index < stats.length - 1 ? 16.0 : 0.0),
            child: _StatCard(data: stats[index]),
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

// ─── PATIENT STATISTICS CARD ────────────────────────────────────────────────

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
          // Header row with legend
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
              _LegendDot(color: kTeal, label: 'Outpatients'),
              const SizedBox(width: 16),
              _LegendDot(color: kTealAccent, label: 'Inpatients'),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 260,
            child: _AreaChart(),
          ),
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
        Text(label,
            style: const TextStyle(fontSize: 12, color: kTextGrey)),
      ],
    );
  }
}

// ─── AREA CHART (Custom Painter) ─────────────────────────────────────────────

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
    'Sunday'
  ];

  _AreaChart();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _AreaChartPainter(
          series1: series1, series2: series2, days: days),
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

    // ── Grid + Y labels ──
    final gridPaint = Paint()
      ..color = Colors.grey.withOpacity(0.15)
      ..strokeWidth = 1;

    const labelStyle = TextStyle(
      color: kTextGrey,
      fontSize: 11,
    );

    for (int i = 0; i <= _gridLines; i++) {
      final y = _topPad + chartH - (i / _gridLines) * chartH;
      canvas.drawLine(
          Offset(_leftPad, y), Offset(size.width, y), gridPaint);
      final val = ((i / _gridLines) * _maxVal).round();
      final tp = TextPainter(
        text: TextSpan(text: '$val', style: labelStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(0, y - tp.height / 2));
    }

    // ── Point helper ──
    Offset pt(int index, double val) {
      final x = _leftPad + (index / (days.length - 1)) * chartW;
      final y = _topPad + chartH - (val / _maxVal) * chartH;
      return Offset(x, y);
    }

    // ── Areas ──
    _drawArea(canvas, series2, pt, chartH, size,
        const Color(0xFF4FC3B0).withOpacity(0.22),
        const Color(0xFF4FC3B0).withOpacity(0.0));

    _drawArea(canvas, series1, pt, chartH, size,
        kTeal.withOpacity(0.50), kTeal.withOpacity(0.04));

    // ── Lines ──
    _drawLine(canvas, series2, pt, kTealAccent, 2.0);
    _drawLine(canvas, series1, pt, kTeal, 2.5);

    // ── Dots (series1) ──
    final dotFill = Paint()..color = kTeal..style = PaintingStyle.fill;
    final dotBorder = Paint()..color = kWhite..style = PaintingStyle.fill;
    for (int i = 0; i < series1.length; i++) {
      final p = pt(i, series1[i]);
      canvas.drawCircle(p, 5.5, dotBorder);
      canvas.drawCircle(p, 3.5, dotFill);
    }

    // ── X axis labels ──
    for (int i = 0; i < days.length; i++) {
      final tp = TextPainter(
        text: TextSpan(text: days[i], style: labelStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      final x = _leftPad + (i / (days.length - 1)) * chartW;
      tp.paint(canvas,
          Offset(x - tp.width / 2, size.height - _bottomPad + 10));
    }

    // ── Baseline ──
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
        _leftPad, _topPad, size.width - _leftPad, chartH);
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [topColor, bottomColor],
      ).createShader(rect);

    canvas.drawPath(path, paint);
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

    final path = Path()
      ..moveTo(pt(0, data[0]).dx, pt(0, data[0]).dy);

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

// ─── FOOTER ─────────────────────────────────────────────────────────────────

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

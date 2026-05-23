import 'package:flutter/material.dart';
import '../metrics/health_metrics_screen.dart';
import '../reminders/reminder_screen.dart';
import '../chat/chat_screen.dart';
import '../profile/profile_screen.dart';
import '../admin/admin_screen.dart';
import '../../services/auth_service.dart';

class AppColors {
  static const pink100 = Color(0xFFFFF0F5);
  static const pink200 = Color(0xFFFBC6DB);
  static const pink400 = Color(0xFFE45A93); // Tăng độ tươi để làm điểm nhấn
  static const pink700 = Color(0xFF6B2D54);
  static const purple100 = Color(0xFFF5EEFD);
  static const purple400 = Color(0xFFAC69D6);
  static const purple700 = Color(0xFF4A2E80);
  static const mint100 = Color(0xE8EAFBF2);
  static const mint400 = Color(0xFF42B883);
  static const mint700 = Color(0xFF1B633E);
  static const amber100 = Color(0xFFFFF8EC);
  static const amber400 = Color(0xFFD9822B);
  static const blue100 = Color(0xFFE6F4FE);
  static const blue400 = Color(0xFF2D8CF0);
  static const text = Color(0xFF4A154B); // Đậm hơn một chút để dễ đọc text
  static const textSub = Color(0xFF8A5F82);
  static const textHint = Color(0xFFBCA0B4);
  static const bg = Color(0xFFFAF4F7); // Màu nền ấm áp hơn
  static const card = Color(0xFFFFFFFF);
}

// ─── Root ─────────────────────────────────────────────────────────
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final List<Widget> _screens = [
    const DashboardPage(),
    const HealthMetricsScreen(),
    const ReminderScreen(),
    const ChatScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: _screens[_currentIndex],
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.transparent,
        elevation: 0,
        selectedItemColor: AppColors.pink400,
        unselectedItemColor: AppColors.textHint,
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 11,
          letterSpacing: 0.2,
        ),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 11,
        ),
        items: const [
          BottomNavigationBarItem(
            icon: Padding(
              padding: EdgeInsets.only(bottom: 4),
              child: Icon(Icons.grid_view_rounded, size: 22),
            ),
            activeIcon: Padding(
              padding: EdgeInsets.only(bottom: 4),
              child: Icon(Icons.grid_view_rounded, size: 24),
            ),
            label: 'Trang chủ',
          ),
          BottomNavigationBarItem(
            icon: Padding(
              padding: EdgeInsets.only(bottom: 4),
              child: Icon(Icons.analytics_rounded, size: 22),
            ),
            activeIcon: Padding(
              padding: EdgeInsets.only(bottom: 4),
              child: Icon(Icons.analytics_rounded, size: 24),
            ),
            label: 'Chỉ số',
          ),
          BottomNavigationBarItem(
            icon: Padding(
              padding: EdgeInsets.only(bottom: 4),
              child: Icon(Icons.alarm_on_rounded, size: 22),
            ),
            activeIcon: Padding(
              padding: EdgeInsets.only(bottom: 4),
              child: Icon(Icons.alarm_on_rounded, size: 24),
            ),
            label: 'Lịch nhắc',
          ),
          BottomNavigationBarItem(
            icon: Padding(
              padding: EdgeInsets.only(bottom: 4),
              child: Icon(Icons.forum_rounded, size: 22),
            ),
            activeIcon: Padding(
              padding: EdgeInsets.only(bottom: 4),
              child: Icon(Icons.forum_rounded, size: 24),
            ),
            label: 'Trợ lý AI',
          ),
          BottomNavigationBarItem(
            icon: Padding(
              padding: EdgeInsets.only(bottom: 4),
              child: Icon(Icons.manage_accounts_rounded, size: 22),
            ),
            activeIcon: Padding(
              padding: EdgeInsets.only(bottom: 4),
              child: Icon(Icons.manage_accounts_rounded, size: 24),
            ),
            label: 'Hồ sơ',
          ),
        ],
      ),
    );
  }
}

// ─── Dashboard ────────────────────────────────────────────────────
class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});
  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int? _selectedMood;
  bool _isAdmin = false;
  String _userName = 'Bạn';

  final _moods = const [
    ('Tuyệt', Icons.sentiment_very_satisfied_rounded, Color(0xFFFFB000)),
    ('Tốt', Icons.sentiment_satisfied_rounded, Color(0xFF2EC4B6)),
    ('Bình', Icons.sentiment_neutral_rounded, Color(0xFF3A86FF)),
    ('Mệt', Icons.sentiment_dissatisfied_rounded, Color(0xFFFF006E)),
    ('Khó', Icons.sentiment_very_dissatisfied_rounded, Color(0xFFFB5607)),
  ];

  // Helper tạo shadow mịn màng chuẩn phong cách hiện đại
  List<BoxShadow> _neumorphicShadow() {
    return [
      BoxShadow(
        color: const Color(0xFF4A154B).withValues(alpha: 0.04),
        blurRadius: 16,
        offset: const Offset(0, 8),
      ),
    ];
  }

  @override
  void initState() {
    super.initState();
    _checkAdmin();
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    final user = await AuthService.getUser();
    if (mounted && user != null) {
      setState(() => _userName = user['fullName'] ?? 'Bạn');
    }
  }

  Future<void> _checkAdmin() async {
    final admin = await AuthService.isAdmin();
    if (mounted) setState(() => _isAdmin = admin);
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final weekdays = ['CN', 'T2', 'T3', 'T4', 'T5', 'T6', 'T7'];
    final months = [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    final dateStr =
        '${weekdays[now.weekday % 7]}, ${now.day} ${months[now.month]} ${now.year}';

    return SafeArea(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(dateStr),
            _buildHealthScoreCard(),
            const SizedBox(height: 20),
            _buildStatsRow(),
            const SizedBox(height: 20),
            _buildMoodSection(),
            const SizedBox(height: 20),
            _buildQuickActions(context),
            const SizedBox(height: 20),
            if (_isAdmin) _buildAdminBanner(context),
            if (_isAdmin) const SizedBox(height: 20),
            _buildSectionLabel('Nhắc nhở hôm nay'),
            const SizedBox(height: 10),
            _buildReminderCard(
              icon: Icons.medication_rounded,
              iconBg: AppColors.purple100,
              iconColor: AppColors.purple400,
              title: 'Uống vitamin D',
              time: '15:00',
              done: false,
            ),
            const SizedBox(height: 10),
            _buildReminderCard(
              icon: Icons.favorite_rounded,
              iconBg: AppColors.pink100,
              iconColor: AppColors.pink400,
              title: 'Đo huyết áp',
              time: '20:00',
              done: false,
            ),
            const SizedBox(height: 10),
            _buildReminderCard(
              icon: Icons.directions_run_rounded,
              iconBg: AppColors.mint100,
              iconColor: AppColors.mint700,
              title: 'Tập thể dục',
              time: '18:00',
              done: true,
            ),
            const SizedBox(height: 20),
            _buildTipCard(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────
  Widget _buildHeader(String dateStr) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Xin chào! 👋',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSub,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _userName,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: AppColors.text,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  dateStr,
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textHint),
                ),
              ],
            ),
          ),
          Row(
            children: [
              if (_isAdmin)
                GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AdminScreen()),
                  ),
                  child: Container(
                    margin: const EdgeInsets.only(right: 12),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                        color: AppColors.purple700,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.purple700.withValues(alpha: 0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          )
                        ]),
                    child: const Row(
                      children: [
                        Icon(Icons.admin_panel_settings_rounded,
                            color: Colors.white, size: 14),
                        SizedBox(width: 4),
                        Text(
                          'Admin',
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                    color: AppColors.pink100,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.pink400.withValues(alpha: 0.15),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      )
                    ]),
                child: const Icon(Icons.person_rounded,
                    color: AppColors.pink400, size: 26),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Admin Banner ──────────────────────────────────────────────
  Widget _buildAdminBanner(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GestureDetector(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AdminScreen()),
        ),
        child: Container(
          decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF512DA8), Color(0xFF9575CD)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF512DA8).withValues(alpha: 0.2),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                )
              ]),
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.admin_panel_settings_rounded,
                    color: Colors.white, size: 24),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Trang quản trị',
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.white),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Quản lý người dùng & Thống kê hệ thống',
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded,
                  color: Colors.white70, size: 14),
            ],
          ),
        ),
      ),
    );
  }

  // ── Health Score Card ─────────────────────────────────────────
  Widget _buildHealthScoreCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFEC407A), Color(0xFFAB47BC)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFEC407A).withValues(alpha: 0.25),
                blurRadius: 20,
                offset: const Offset(0, 10),
              )
            ]),
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Chỉ số sức khỏe tổng quát',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white.withValues(alpha: 0.8),
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text(
                        '85',
                        style: TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            height: 1),
                      ),
                      const SizedBox(width: 4),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(
                          '/100',
                          style: TextStyle(
                              fontSize: 16,
                              color: Colors.white.withValues(alpha: 0.6),
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Rất tốt! 🎉',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: 88,
              height: 88,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 80,
                    height: 80,
                    child: CircularProgressIndicator(
                      value: 0.85,
                      strokeWidth: 8,
                      strokeCap: StrokeCap.round,
                      backgroundColor: Colors.white.withValues(alpha: 0.15),
                      valueColor:
                          const AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  const Icon(Icons.favorite_rounded,
                      color: Colors.white, size: 30),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Stats Row ─────────────────────────────────────────────────
  Widget _buildStatsRow() {
    final stats = [
      (
        Icons.favorite_rounded,
        AppColors.pink100,
        AppColors.pink400,
        '72',
        'bpm',
        'Nhịp tim'
      ),
      (
        Icons.water_drop_rounded,
        AppColors.blue100,
        AppColors.blue400,
        '120/80',
        'mmHg',
        'Huyết áp'
      ),
      (
        Icons.directions_walk_rounded,
        AppColors.mint100,
        AppColors.mint700,
        '6,240',
        'bước',
        'Bước chân'
      ),
      (
        Icons.local_drink_rounded,
        AppColors.amber100,
        AppColors.amber400,
        '1.4',
        'L',
        'Nước uống'
      ),
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: stats
            .map((s) => Expanded(
                  child: Container(
                    margin: EdgeInsets.only(right: s == stats.last ? 0 : 8),
                    padding:
                        const EdgeInsets.symmetric(vertical: 14, horizontal: 6),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: _neumorphicShadow(),
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                              color: s.$2, shape: BoxShape.circle),
                          child: Icon(s.$1, color: s.$3, size: 18),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          s.$4,
                          style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: AppColors.text,
                              letterSpacing: -0.5),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          s.$5,
                          style: const TextStyle(
                              fontSize: 10,
                              color: AppColors.textSub,
                              fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          s.$6,
                          style: const TextStyle(
                              fontSize: 10,
                              color: AppColors.textHint,
                              fontWeight: FontWeight.w700),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ))
            .toList(),
      ),
    );
  }

  // ── Mood Section ──────────────────────────────────────────────
  Widget _buildMoodSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(20),
          boxShadow: _neumorphicShadow(),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Hôm nay bạn cảm thấy thế nào?',
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.text),
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(_moods.length, (i) {
                final selected = _selectedMood == i;
                return GestureDetector(
                  onTap: () => setState(() => _selectedMood = i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: selected
                          ? _moods[i].$3.withValues(alpha: 0.12)
                          : const Color(0xFFF9F5F7),
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: selected ? _moods[i].$3 : Colors.transparent,
                          width: 2),
                      boxShadow: selected
                          ? [
                              BoxShadow(
                                  color: _moods[i].$3.withValues(alpha: 0.15),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4))
                            ]
                          : null,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(_moods[i].$2,
                            color: selected ? _moods[i].$3 : AppColors.textHint,
                            size: selected ? 28 : 24),
                        if (selected) ...[
                          const SizedBox(height: 2),
                          Text(
                            _moods[i].$1,
                            style: TextStyle(
                                fontSize: 8,
                                fontWeight: FontWeight.w800,
                                color: _moods[i].$3),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  // ── Quick Actions ─────────────────────────────────────────────
  Widget _buildQuickActions(BuildContext context) {
    final actions = [
      (
        Icons.add_chart_rounded,
        AppColors.blue100,
        AppColors.blue400,
        'Thêm chỉ số'
      ),
      (
        Icons.alarm_add_rounded,
        AppColors.mint100,
        AppColors.mint700,
        'Đặt nhắc'
      ),
      (
        Icons.chat_bubble_rounded,
        AppColors.purple100,
        AppColors.purple400,
        'Hỏi AI'
      ),
      (
        Icons.bar_chart_rounded,
        AppColors.amber100,
        AppColors.amber400,
        'Thống kê'
      ),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionLabel('Thao tác nhanh'),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: actions
                .map((a) => Expanded(
                      child: Container(
                        margin:
                            EdgeInsets.only(right: a == actions.last ? 0 : 10),
                        decoration: BoxDecoration(
                          color: AppColors.card,
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: _neumorphicShadow(),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(18),
                            onTap: () {},
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              child: Column(
                                children: [
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                        color: a.$2, shape: BoxShape.circle),
                                    child: Icon(a.$1, color: a.$3, size: 20),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    a.$4,
                                    style: const TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.text),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ))
                .toList(),
          ),
        ),
      ],
    );
  }

  // ── Reminder Card ─────────────────────────────────────────────
  Widget _buildReminderCard({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required String time,
    required bool done,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: done ? 0.6 : 1.0,
        child: Container(
          decoration: BoxDecoration(
            color: done ? const Color(0xFFF1ECEF) : AppColors.card,
            borderRadius: BorderRadius.circular(18),
            boxShadow: done ? null : _neumorphicShadow(),
          ),
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                    color: done ? Colors.white70 : iconBg,
                    shape: BoxShape.circle),
                child: Icon(icon,
                    color: done ? AppColors.textHint : iconColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.text,
                        decoration: done ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      time,
                      style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSub,
                          fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
              done
                  ? const Icon(Icons.check_circle_rounded,
                      color: AppColors.mint400, size: 24)
                  : Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.pink100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Sắp tới',
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: AppColors.pink400),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Tip Card ──────────────────────────────────────────────────
  Widget _buildTipCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFE8F5E9), Color(0xFFE3F2FD)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: _neumorphicShadow(),
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                  color: Colors.white, shape: BoxShape.circle),
              child: const Icon(Icons.lightbulb_rounded,
                  color: AppColors.amber400, size: 22),
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Mẹo sức khỏe hôm nay 💡',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.mint700),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Uống một cốc nước ngay sau khi thức dậy giúp khởi động quá trình trao đổi chất và tăng năng lượng cho ngày mới!',
                    style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF2E5B42),
                        height: 1.4,
                        fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String t) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
        child: Text(
          t,
          style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: AppColors.text,
              letterSpacing: -0.2),
        ),
      );
}

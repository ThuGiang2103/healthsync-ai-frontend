import 'package:flutter/material.dart';
import '../metrics/health_metrics_screen.dart';
import '../reminders/reminder_screen.dart';
import '../chat/chat_screen.dart';
import '../profile/profile_screen.dart';
import '../admin/admin_screen.dart';
import '../../services/auth_service.dart';

class AppColors {
  static const pink100 = Color(0xFFFCE4EE);
  static const pink200 = Color(0xFFF5C0D4);
  static const pink400 = Color(0xFFE07FA8);
  static const pink700 = Color(0xFF7C3F6B);
  static const purple100 = Color(0xFFF0E6FB);
  static const purple400 = Color(0xFFC97FD4);
  static const purple700 = Color(0xFF6040A8);
  static const mint100 = Color(0xFFD5F5E3);
  static const mint400 = Color(0xFF6BBFA0);
  static const mint700 = Color(0xFF2A7A50);
  static const amber100 = Color(0xFFFEF3DE);
  static const amber400 = Color(0xFFC07A1A);
  static const blue100 = Color(0xFFDDF0FA);
  static const blue400 = Color(0xFF378ADD);
  static const text = Color(0xFF7C3F6B);
  static const textSub = Color(0xFFC47FA0);
  static const textHint = Color(0xFFC9ADC0);
  static const bg = Color(0xFFFDF6F9);
  static const card = Color(0xFFFFFFFF);
  static const border = Color(0xFFF5E0EC);
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
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFF5E6EF))),
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
          fontSize: 10,
        ),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 10,
        ),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: 'Trang chu',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.monitor_heart_rounded),
            label: 'Chi so',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today_rounded),
            label: 'Nhac lich',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.auto_awesome_rounded),
            label: 'AI Chat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle_rounded),
            label: 'Ho so',
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
  String _userName = 'Ban';

  final _moods = const [
    ('Tuyet', Icons.sentiment_very_satisfied_rounded, Color(0xFFFFD166)),
    ('Tot', Icons.sentiment_satisfied_rounded, Color(0xFF06D6A0)),
    ('Binh', Icons.sentiment_neutral_rounded, Color(0xFF74B9FF)),
    ('Met', Icons.sentiment_dissatisfied_rounded, Color(0xFFFF7675)),
    ('Kho', Icons.sentiment_very_dissatisfied_rounded, Color(0xFFE17055)),
  ];

  @override
  void initState() {
    super.initState();
    _checkAdmin();
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    final user = await AuthService.getUser();
    if (mounted && user != null) {
      setState(() => _userName = user['fullName'] ?? 'Ban');
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
      'Dec',
    ];
    final dateStr =
        '${weekdays[now.weekday % 7]}, ${now.day} ${months[now.month]} ${now.year}';

    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(dateStr),
            _buildHealthScoreCard(),
            const SizedBox(height: 14),
            _buildStatsRow(),
            const SizedBox(height: 14),
            _buildMoodSection(),
            const SizedBox(height: 14),
            _buildQuickActions(context),
            const SizedBox(height: 14),
            // Admin banner — chỉ hiện với admin
            if (_isAdmin) _buildAdminBanner(context),
            if (_isAdmin) const SizedBox(height: 14),
            _buildSectionLabel('Nhac nho hom nay'),
            const SizedBox(height: 8),
            _buildReminderCard(
              icon: Icons.medication_rounded,
              iconBg: AppColors.purple100,
              iconColor: AppColors.purple400,
              title: 'Uong vitamin D',
              time: '15:00',
              done: false,
            ),
            const SizedBox(height: 8),
            _buildReminderCard(
              icon: Icons.favorite_rounded,
              iconBg: AppColors.pink100,
              iconColor: AppColors.pink400,
              title: 'Do huyet ap',
              time: '20:00',
              done: false,
            ),
            const SizedBox(height: 8),
            _buildReminderCard(
              icon: Icons.directions_run_rounded,
              iconBg: AppColors.mint100,
              iconColor: AppColors.mint700,
              title: 'Tap the duc',
              time: '18:00',
              done: true,
            ),
            const SizedBox(height: 14),
            _buildTipCard(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────
  Widget _buildHeader(String dateStr) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFFCE4EE), Color(0xFFF0E6FB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Xin chao!',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSub,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _userName,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.text,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  dateStr,
                  style: TextStyle(fontSize: 11, color: AppColors.textSub),
                ),
              ],
            ),
          ),
          // Admin badge + avatar
          Row(
            children: [
              if (_isAdmin)
                GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AdminScreen()),
                  ),
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.purple700,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.admin_panel_settings_rounded,
                          color: Colors.white,
                          size: 14,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Admin',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: AppColors.pink100,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.pink200, width: 2),
                ),
                child: const Icon(
                  Icons.person_rounded,
                  color: AppColors.pink400,
                  size: 26,
                ),
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
              colors: [Color(0xFF6040A8), Color(0xFFC97FD4)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.admin_panel_settings_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Trang quan tri',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Quan ly users va thong ke he thong',
                      style: TextStyle(fontSize: 11, color: Colors.white70),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                color: Colors.white70,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Health Score Card ─────────────────────────────────────────
  Widget _buildHealthScoreCard() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFE07FA8), Color(0xFFC97FD4)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Chi so suc khoe tong quat',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.white70,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text(
                        '85',
                        style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Padding(
                        padding: EdgeInsets.only(bottom: 6),
                        child: Text(
                          '/100',
                          style: TextStyle(fontSize: 14, color: Colors.white70),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Rat tot!',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: 80,
              height: 80,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CircularProgressIndicator(
                    value: 0.85,
                    strokeWidth: 8,
                    backgroundColor: Colors.white.withValues(alpha: 0.3),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Colors.white,
                    ),
                  ),
                  const Icon(
                    Icons.favorite_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
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
        'Nhip tim',
      ),
      (
        Icons.water_drop_rounded,
        AppColors.blue100,
        AppColors.blue400,
        '120/80',
        'mmHg',
        'Huyet ap',
      ),
      (
        Icons.directions_walk_rounded,
        AppColors.mint100,
        AppColors.mint700,
        '6,240',
        'bc',
        'Buoc chan',
      ),
      (
        Icons.local_drink_rounded,
        AppColors.amber100,
        AppColors.amber400,
        '1.4',
        'L',
        'Nuoc uong',
      ),
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: stats
            .map(
              (s) => Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: s == stats.last ? 0 : 8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: s.$2,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(s.$1, color: s.$3, size: 16),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          s.$4,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.text,
                          ),
                        ),
                        Text(
                          s.$5,
                          style: TextStyle(
                            fontSize: 9,
                            color: AppColors.textSub,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          s.$6,
                          style: TextStyle(
                            fontSize: 9,
                            color: AppColors.textHint,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            )
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
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Hom nay ban cam thay the nao?',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.text,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(_moods.length, (i) {
                final selected = _selectedMood == i;
                return GestureDetector(
                  onTap: () => setState(() => _selectedMood = i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: selected
                          ? _moods[i].$3.withValues(alpha: 0.15)
                          : const Color(0xFFFDF6F9),
                      shape: BoxShape.circle,
                      border: selected
                          ? Border.all(color: _moods[i].$3, width: 2)
                          : Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _moods[i].$2,
                          color: _moods[i].$3,
                          size: selected ? 26 : 22,
                        ),
                        if (selected) ...[
                          const SizedBox(height: 1),
                          Text(
                            _moods[i].$1,
                            style: TextStyle(
                              fontSize: 7,
                              fontWeight: FontWeight.w700,
                              color: _moods[i].$3,
                            ),
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
        'Them chi so',
      ),
      (
        Icons.alarm_add_rounded,
        AppColors.mint100,
        AppColors.mint700,
        'Dat nhac',
      ),
      (
        Icons.chat_bubble_rounded,
        AppColors.purple100,
        AppColors.purple400,
        'Hoi AI',
      ),
      (
        Icons.bar_chart_rounded,
        AppColors.amber100,
        AppColors.amber400,
        'Thong ke',
      ),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionLabel('Thao tac nhanh'),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: actions
                .map(
                  (a) => Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(
                        right: a == actions.last ? 0 : 8,
                      ),
                      child: GestureDetector(
                        onTap: () {},
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: AppColors.card,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Column(
                            children: [
                              Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: a.$2,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(a.$1, color: a.$3, size: 18),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                a.$4,
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.text,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                )
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
      child: Opacity(
        opacity: done ? 0.5 : 1.0,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: iconBg,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.text,
                        decoration: done ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    Text(
                      time,
                      style: TextStyle(fontSize: 11, color: AppColors.textSub),
                    ),
                  ],
                ),
              ),
              done
                  ? const Icon(
                      Icons.check_circle_rounded,
                      color: AppColors.mint400,
                      size: 22,
                    )
                  : Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.pink100,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Sap toi',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: AppColors.pink400,
                        ),
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
            colors: [Color(0xFFD5F5E3), Color(0xFFDDF0FA)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.lightbulb_rounded,
                color: AppColors.amber400,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Meo suc khoe hom nay',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.mint700,
                    ),
                  ),
                  SizedBox(height: 3),
                  Text(
                    'Uong mot coc nuoc ngay sau khi thuc day giup khoi dong '
                    'trao doi chat va tang nang luong!',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.mint700,
                      height: 1.4,
                    ),
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
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: Text(
      t,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: AppColors.text,
      ),
    ),
  );
}

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';

import '../metrics/health_metrics_screen.dart';
import '../reminders/reminder_screen.dart';
import '../chat/chat_screen.dart';
import '../profile/profile_screen.dart';
import '../admin/admin_screen.dart';
import '../../services/auth_service.dart';

class AppColors {
  static const pink100 = Color(0xFFFFF0F5);
  static const pink400 = Color(0xFFE45A93);
  static const purple100 = Color(0xFFF5EEFD);
  static const purple400 = Color(0xFFAC69D6);
  static const mint100 = Color(0xFFE8FBF2);
  static const mint700 = Color(0xFF1B633E);
  static const amber100 = Color(0xFFFFF8EC);
  static const amber400 = Color(0xFFD9822B);
  static const blue100 = Color(0xFFE6F4FE);
  static const blue400 = Color(0xFF2D8CF0);
  static const orange100 = Color(0xFFFFF2E2);
  static const text = Color(0xFF4A154B);
  static const textSub = Color(0xFF8A5F82);
  static const textHint = Color(0xFFBCA0B4);
  static const bg = Color(0xFFFAF4F7);
  static const card = Color(0xFFFFFFFF);
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  bool _isAdmin = false;

  List<Widget> get _screens => [
        const DashboardPage(),
        const HealthMetricsScreen(),
        const ReminderScreen(),
        const ChatScreen(),
        const ProfileScreen(),
        if (_isAdmin) const AdminScreen(),
      ];

  List<BottomNavigationBarItem> get _navItems => [
        const BottomNavigationBarItem(
          icon: Icon(Icons.grid_view_rounded),
          label: 'Trang chủ',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.analytics_rounded),
          label: 'Chỉ số',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.alarm_on_rounded),
          label: 'Lịch nhắc',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.auto_awesome_rounded),
          label: 'AI Chat',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.person_rounded),
          label: 'Hồ sơ',
        ),
        if (_isAdmin)
          const BottomNavigationBarItem(
            icon: Icon(Icons.admin_panel_settings_rounded),
            label: 'Admin',
          ),
      ];

  @override
  void initState() {
    super.initState();
    _checkAdmin();
  }

  Future<void> _checkAdmin() async {
    final admin = await AuthService.isAdmin();

    if (!mounted) return;

    setState(() {
      _isAdmin = admin;
      if (_currentIndex >= _screens.length) {
        _currentIndex = 0;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screens = _screens;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: screens[_currentIndex],
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
        ),
        items: _navItems,
      ),
    );
  }
}

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int? _selectedMood;
  bool _isAdmin = false;
  String _userName = 'Bạn';

  StreamSubscription<StepCount>? _stepCountSubscription;
  int _steps = 0;

  final List<Map<String, dynamic>> _news = [
    {
      'title': 'Tại sao phải tập thể dục mỗi ngày',
      'color': AppColors.orange100,
      'image':
          'https://img.pikbest.com/origin/09/24/53/8pIkbEsTzpIkbEsTN4t.png!sw800',
      'content':
          'Tập thể dục mỗi ngày là một thói quen rất tốt cho sức khỏe cả về thể chất lẫn tinh thần. Khi cơ thể được vận động đều đặn, tim sẽ hoạt động hiệu quả hơn, máu lưu thông tốt hơn và các cơ bắp cũng trở nên linh hoạt hơn.',
    },
    {
      'title': 'Chạy 2 tiếng một ngày có tốt không',
      'color': AppColors.purple100,
      'image':
          'https://cdn-icons-png.magnific.com/256/12560/12560588.png?semt=ais_white_label',
      'content':
          'Chạy bộ là một hình thức vận động rất tốt, nhưng chạy 2 tiếng mỗi ngày không phải lúc nào cũng phù hợp với tất cả mọi người. Nếu mới bắt đầu, bạn nên chạy từ 20 đến 30 phút rồi tăng dần.',
    },
    {
      'title': 'Lợi ích của việc chạy bộ buổi sáng',
      'color': const Color.fromARGB(255, 220, 186, 231),
      'image':
          'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQg-rfAn5GsCfq-g704MnBDkLGUR8xrJ9ZyxA&s',
      'content':
          'Chạy bộ buổi sáng giúp cơ thể tỉnh táo hơn, hỗ trợ tuần hoàn máu và tạo cảm giác năng động cho ngày mới. Bạn nên khởi động kỹ trước khi chạy.',
    },
    {
      'title': 'Ăn hoa quả mỗi ngày có tốt không',
      'color': const Color.fromARGB(255, 238, 246, 186),
      'image':
          'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQvXQez6ovqJxmALdoVAEXD5P8s_tl8wspm7g&s',
      'content':
          'Ăn hoa quả mỗi ngày giúp bổ sung vitamin, khoáng chất và chất xơ. Tuy nhiên, bạn nên ăn đa dạng và tránh ăn quá nhiều các loại quả có lượng đường cao.',
    },
    {
      'title': 'Thực phẩm tốt cho tim mạch',
      'color': const Color.fromARGB(255, 82, 194, 228),
      'image':
          'https://png.pngtree.com/png-clipart/20210309/original/pngtree-anthropomorphic-vegetable-emoji-pack-png-image_5909439.jpg',
      'content':
          'Rau xanh, trái cây, cá béo, yến mạch, các loại hạt và dầu oliu là những thực phẩm tốt cho tim mạch. Bạn cũng nên hạn chế đồ chiên rán và thức ăn nhanh.',
    },
    {
      'title': 'Ngủ 8 tiếng một ngày có tốt không',
      'color': AppColors.orange100,
      'image':
          'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcROhP2ZQUU1j5gyp6Fl0SP5khq_K2QkF6MwcA&s',
      'content':
          'Ngủ đủ giấc giúp cơ thể phục hồi, cải thiện trí nhớ và tăng khả năng tập trung. Với nhiều người trưởng thành, ngủ khoảng 7 đến 8 tiếng mỗi ngày là phù hợp.',
    },
    {
      'title': 'Tác hại của hút thuốc lá',
      'color': const Color.fromARGB(255, 230, 202, 167),
      'image':
          'https://png.pngtree.com/png-clipart/20250109/original/pngtree-lungs-icon-design-vector-png-image_4998272.png',
      'content':
          'Hút thuốc lá gây hại cho phổi, tim mạch và làm tăng nguy cơ mắc nhiều bệnh nguy hiểm. Khói thuốc cũng ảnh hưởng đến người xung quanh.',
    },
  ];

  @override
  void initState() {
    super.initState();
    _checkAdmin();
    _loadUserName();
    _initStepCounter();
  }

  Future<void> _initStepCounter() async {
    final status = await Permission.activityRecognition.request();

    if (!status.isGranted) return;

    _stepCountSubscription = Pedometer.stepCountStream.listen(
      (StepCount event) {
        if (mounted) {
          setState(() {
            _steps = event.steps;
          });
        }
      },
      onError: (error) {
        debugPrint('Lỗi đếm bước: $error');
      },
    );
  }

  @override
  void dispose() {
    _stepCountSubscription?.cancel();
    super.dispose();
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
            _buildNewsSection(),
            const SizedBox(height: 20),
            _buildQuickActions(context),
            const SizedBox(height: 20),
            if (_isAdmin) _buildAdminBanner(context),
            _buildSectionLabel('Nhắc nhở hôm nay'),
            const SizedBox(height: 10),
            _buildReminderCard(
              Icons.medication_rounded,
              AppColors.purple100,
              AppColors.purple400,
              'Uống vitamin D',
              '15:00',
              false,
            ),
            const SizedBox(height: 10),
            _buildReminderCard(
              Icons.favorite_rounded,
              AppColors.pink100,
              AppColors.pink400,
              'Đo huyết áp',
              '20:00',
              false,
            ),
            const SizedBox(height: 20),
            _buildTipCard(),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildNewsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Thông tin hôm nay',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: AppColors.text,
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: AppColors.textHint,
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 160,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: _news.length,
            itemBuilder: (context, index) {
              final item = _news[index];

              return InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => NewsDetailScreen(news: item),
                    ),
                  );
                },
                child: Container(
                  width: 200,
                  margin: const EdgeInsets.only(right: 14),
                  decoration: BoxDecoration(
                    color: item['color'],
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: (item['color'] as Color).withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          item['title'],
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.text,
                            height: 1.3,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Positioned(
                        bottom: 10,
                        right: 10,
                        child: Image.network(
                          item['image'],
                          width: 60,
                          height: 60,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(String dateStr) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Xin chào! 👋',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textSub,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _userName,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: AppColors.text,
                ),
              ),
              Text(
                dateStr,
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textHint,
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(2),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const CircleAvatar(
              radius: 24,
              backgroundColor: AppColors.pink100,
              child: Icon(
                Icons.person_rounded,
                color: AppColors.pink400,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthScoreCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFE45A93), Color(0xFFAC69D6)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppColors.pink400.withValues(alpha: 0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Chỉ số sức khỏe tổng quát',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white70,
                      fontWeight: FontWeight.w600,
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
                          height: 1,
                        ),
                      ),
                      Text(
                        '/100',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Rất tốt! 🎉',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.favorite_rounded,
              color: Colors.white,
              size: 60,
            ),
          ],
        ),
      ),
    );
  }

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
        _steps.toString(),
        'bước',
        'Bước chân'
      ),
      (
        Icons.local_drink_rounded,
        AppColors.amber100,
        AppColors.amber400,
        '1.4',
        'L',
        'Nước'
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: stats
            .map(
              (s) => Expanded(
                child: Container(
                  margin: EdgeInsets.only(right: s == stats.last ? 0 : 8),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Icon(s.$1, color: s.$3, size: 20),
                      const SizedBox(height: 8),
                      Text(
                        s.$4,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: AppColors.text,
                        ),
                      ),
                      Text(
                        s.$6,
                        style: TextStyle(
                          fontSize: 9,
                          color: AppColors.textSub,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildMoodSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Hôm nay bạn cảm thấy thế nào?',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.text,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(5, (i) {
                final moods = [
                  Icons.sentiment_very_dissatisfied,
                  Icons.sentiment_dissatisfied,
                  Icons.sentiment_neutral,
                  Icons.sentiment_satisfied,
                  Icons.sentiment_very_satisfied,
                ];
                final colors = [
                  Colors.red,
                  Colors.orange,
                  Colors.blue,
                  Colors.green,
                  Colors.amber,
                ];

                return GestureDetector(
                  onTap: () => setState(() => _selectedMood = i),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _selectedMood == i
                          ? colors[i].withValues(alpha: 0.1)
                          : AppColors.bg,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color:
                            _selectedMood == i ? colors[i] : Colors.transparent,
                      ),
                    ),
                    child: Icon(
                      moods[i],
                      color:
                          _selectedMood == i ? colors[i] : AppColors.textHint,
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
        'Hỏi AI Chat'
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: actions
            .map(
              (a) => Expanded(
                child: Container(
                  margin: EdgeInsets.only(right: a == actions.last ? 0 : 10),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Icon(a.$1, color: a.$3),
                      const SizedBox(height: 4),
                      Text(
                        a.$4,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: AppColors.text,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  String _reminderStatus(String time, bool done) {
    if (done) return 'Đã xong';

    final parts = time.split(':');
    if (parts.length != 2) return 'Sắp tới';

    final hour = int.tryParse(parts[0]) ?? 0;
    final minute = int.tryParse(parts[1]) ?? 0;

    final now = DateTime.now();
    final reminderTime = DateTime(
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    final diff = reminderTime.difference(now).inMinutes;

    if (diff > 0) return 'Sắp tới';
    if (diff >= -5) return 'Đến giờ';
    return 'Quá giờ';
  }

  Color _reminderStatusColor(String status) {
    if (status == 'Đã xong') return AppColors.mint700;
    if (status == 'Đến giờ') return AppColors.amber400;
    if (status == 'Quá giờ') return Colors.redAccent;
    return AppColors.pink400;
  }

  Widget _buildReminderCard(
    IconData icon,
    Color bg,
    Color color,
    String title,
    String time,
    bool done,
  ) {
    final status = _reminderStatus(time, done);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: bg,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.text,
                    ),
                  ),
                  Text(
                    time,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSub,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              status,
              style: TextStyle(
                fontSize: 10,
                color: _reminderStatusColor(status),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTipCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.mint100, AppColors.blue100],
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Row(
          children: [
            Icon(Icons.lightbulb_rounded, color: AppColors.amber400),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Uống một cốc nước ngay sau khi thức dậy giúp khởi động trao đổi chất!',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.mint700,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String t) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Text(
        t,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w800,
          color: AppColors.text,
        ),
      ),
    );
  }

  Widget _buildAdminBanner(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AdminScreen()),
          );
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.purple100,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.purple400),
          ),
          child: const Row(
            children: [
              Icon(
                Icons.admin_panel_settings_rounded,
                color: AppColors.purple400,
              ),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Vào trang quản trị',
                  style: TextStyle(
                    color: AppColors.text,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: AppColors.textHint,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class NewsDetailScreen extends StatelessWidget {
  final Map<String, dynamic> news;

  const NewsDetailScreen({
    super.key,
    required this.news,
  });

  @override
  Widget build(BuildContext context) {
    final Color color = news['color'] as Color;

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppColors.text),
        title: const Text(
          'Thông tin sức khỏe',
          style: TextStyle(
            color: AppColors.text,
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.35),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    news['title'],
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: AppColors.text,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Image.network(
                      news['image'],
                      width: 120,
                      height: 120,
                      fit: BoxFit.contain,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 12,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Text(
                news['content'] ?? '',
                style: const TextStyle(
                  fontSize: 15,
                  height: 1.6,
                  color: AppColors.text,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

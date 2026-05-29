import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';

import '../metrics/health_metrics_screen.dart';
import '../reminders/reminder_screen.dart';
import '../chat/chat_screen.dart';
import '../profile/profile_screen.dart';
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
        ),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.grid_view_rounded),
            label: 'Trang chủ',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics_rounded),
            label: 'Chỉ số',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.alarm_on_rounded),
            label: 'Lịch nhắc',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.auto_awesome_rounded),
            label: 'AI Chat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_rounded),
            label: 'Hồ sơ',
          ),
        ],
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
          'Tập thể dục mỗi ngày là một thói quen rất tốt cho sức khỏe cả về thể chất lẫn tinh thần. Khi cơ thể được vận động đều đặn, tim sẽ hoạt động hiệu quả hơn, máu lưu thông tốt hơn và các cơ bắp cũng trở nên linh hoạt hơn. Việc tập luyện không nhất thiết phải quá nặng, bạn có thể bắt đầu bằng những hoạt động đơn giản như đi bộ, đạp xe, tập yoga hoặc vận động nhẹ trong nhà.\n\nNgoài việc giúp kiểm soát cân nặng, tập thể dục còn hỗ trợ giảm căng thẳng, cải thiện tâm trạng và giúp bạn ngủ ngon hơn. Khi duy trì thói quen này lâu dài, cơ thể sẽ có sức đề kháng tốt hơn và giảm nguy cơ mắc các bệnh như tim mạch, tiểu đường, béo phì hay đau nhức xương khớp. Điều quan trọng là lựa chọn hình thức tập phù hợp với sức khỏe của bản thân và duy trì đều đặn mỗi ngày.',
    },
    {
      'title': 'Chạy 2 tiếng một ngày có tốt không',
      'color': AppColors.purple100,
      'image':
          'https://cdn-icons-png.magnific.com/256/12560/12560588.png?semt=ais_white_label',
      'content':
          'Chạy bộ là một hình thức vận động rất tốt, nhưng chạy 2 tiếng mỗi ngày không phải lúc nào cũng phù hợp với tất cả mọi người. Với những người đã có nền tảng thể lực tốt, việc chạy trong thời gian dài có thể giúp tăng sức bền, cải thiện tim mạch và đốt cháy nhiều năng lượng. Tuy nhiên, nếu cơ thể chưa quen vận động hoặc mới bắt đầu tập luyện, chạy quá lâu có thể khiến cơ bắp mệt mỏi, đau khớp gối, đau cổ chân hoặc làm tăng nguy cơ chấn thương.\n\nThay vì cố gắng chạy thật lâu ngay từ đầu, bạn nên bắt đầu với thời gian ngắn hơn như 20 đến 30 phút mỗi ngày, sau đó tăng dần tùy theo khả năng của cơ thể. Trong quá trình chạy, cần chú ý khởi động kỹ, chọn giày phù hợp, uống đủ nước và dành thời gian nghỉ ngơi để cơ thể phục hồi. Một kế hoạch tập luyện hợp lý sẽ tốt hơn nhiều so với việc tập quá sức trong thời gian dài.',
    },
    {
      'title': 'Lợi ích của việc chạy bộ buổi sáng',
      'color': Color.fromARGB(255, 220, 186, 231),
      'image':
          'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQg-rfAn5GsCfq-g704MnBDkLGUR8xrJ9ZyxA&s',
      'content':
          'Chạy bộ buổi sáng mang lại nhiều lợi ích cho sức khỏe và tinh thần. Sau một đêm nghỉ ngơi, việc vận động nhẹ vào buổi sáng giúp cơ thể tỉnh táo hơn, kích thích tuần hoàn máu và tạo cảm giác tràn đầy năng lượng cho ngày mới. Không khí buổi sáng thường mát mẻ, dễ chịu nên việc chạy bộ cũng trở nên thoải mái hơn so với những thời điểm nắng nóng trong ngày.\n\nNgoài ra, chạy bộ buổi sáng còn giúp hình thành lối sống kỷ luật và tích cực hơn. Khi duy trì thói quen này, bạn có thể cải thiện sức bền, hỗ trợ kiểm soát cân nặng và giảm căng thẳng hiệu quả. Tuy nhiên, trước khi chạy nên khởi động kỹ, không chạy quá nhanh ngay từ đầu và có thể ăn nhẹ nếu cảm thấy đói. Điều quan trọng nhất là lắng nghe cơ thể và duy trì đều đặn với cường độ phù hợp.',
    },
    {
      'title': 'Ăn hoa quả mỗi ngày có tốt không',
      'color': Color.fromARGB(255, 238, 246, 186),
      'image':
          'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQvXQez6ovqJxmALdoVAEXD5P8s_tl8wspm7g&s',
      'content':
          'Ăn hoa quả mỗi ngày rất tốt cho sức khỏe vì hoa quả cung cấp nhiều vitamin, khoáng chất, chất xơ và chất chống oxy hóa. Những dưỡng chất này giúp cơ thể tăng sức đề kháng, hỗ trợ tiêu hóa, làm đẹp da và giúp các cơ quan hoạt động tốt hơn. Một số loại quả như cam, táo, chuối, đu đủ, dưa hấu hoặc bưởi đều có thể được bổ sung vào bữa ăn hằng ngày.\n\nTuy nhiên, ăn hoa quả cũng cần có sự cân đối. Không nên ăn quá nhiều một loại quả trong thời gian dài, đặc biệt là các loại quả có lượng đường cao nếu bạn đang cần kiểm soát cân nặng hoặc đường huyết. Tốt nhất nên ăn đa dạng nhiều loại quả, ưu tiên hoa quả tươi và hạn chế nước ép đóng chai hoặc hoa quả sấy nhiều đường. Khi ăn đúng cách, hoa quả sẽ là một phần rất quan trọng trong chế độ dinh dưỡng lành mạnh.',
    },
    {
      'title': 'Thực phẩm tốt cho tim mạch',
      'color': Color.fromARGB(255, 82, 194, 228),
      'image':
          'https://png.pngtree.com/png-clipart/20210309/original/pngtree-anthropomorphic-vegetable-emoji-pack-png-image_5909439.jpg',
      'content':
          'Một chế độ ăn uống lành mạnh có vai trò rất quan trọng trong việc bảo vệ sức khỏe tim mạch. Các thực phẩm tốt cho tim thường là những thực phẩm giàu chất xơ, vitamin, khoáng chất và chất béo tốt. Bạn có thể bổ sung rau xanh, trái cây tươi, cá béo, yến mạch, các loại hạt, đậu, dầu oliu và ngũ cốc nguyên hạt vào bữa ăn hằng ngày. Những thực phẩm này giúp hỗ trợ kiểm soát cholesterol, ổn định huyết áp và giảm nguy cơ mắc các bệnh về tim.\n\nBên cạnh việc ăn thực phẩm tốt, bạn cũng nên hạn chế các món chiên rán nhiều dầu mỡ, thức ăn nhanh, đồ ăn quá mặn và thực phẩm chế biến sẵn. Uống đủ nước, vận động đều đặn và ngủ đủ giấc cũng là những yếu tố quan trọng giúp trái tim khỏe mạnh hơn. Việc thay đổi thói quen ăn uống không cần quá đột ngột, chỉ cần bắt đầu từ những lựa chọn nhỏ nhưng duy trì lâu dài.',
    },
    {
      'title': 'Ngủ 8 tiếng một ngày có tốt không',
      'color': AppColors.orange100,
      'image':
          'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcROhP2ZQUU1j5gyp6Fl0SP5khq_K2QkF6MwcA&s',
      'content':
          'Ngủ đủ giấc là một trong những yếu tố quan trọng giúp cơ thể phục hồi sau một ngày học tập, làm việc và vận động. Đối với nhiều người trưởng thành, ngủ khoảng 7 đến 8 tiếng mỗi ngày là thời lượng phù hợp để cơ thể nghỉ ngơi, não bộ xử lý thông tin và hệ miễn dịch hoạt động tốt hơn. Khi ngủ đủ, bạn thường cảm thấy tỉnh táo hơn, tập trung tốt hơn và tâm trạng cũng ổn định hơn.\n\nTuy nhiên, chất lượng giấc ngủ cũng quan trọng không kém thời gian ngủ. Nếu ngủ đủ 8 tiếng nhưng thường xuyên thức giấc, ngủ muộn hoặc sử dụng điện thoại quá nhiều trước khi ngủ thì cơ thể vẫn có thể mệt mỏi. Để ngủ ngon hơn, bạn nên tạo thói quen đi ngủ đúng giờ, giữ phòng ngủ yên tĩnh, hạn chế caffeine vào buổi tối và tránh dùng thiết bị điện tử ngay trước khi ngủ.',
    },
    {
      'title': 'Tác hại của hút thuốc lá',
      'color': Color.fromARGB(255, 230, 202, 167),
      'image':
          'https://png.pngtree.com/png-clipart/20250109/original/pngtree-lungs-icon-design-vector-png-image_4998272.png',
      'content':
          'Hút thuốc lá gây ra nhiều tác hại nghiêm trọng đối với sức khỏe. Khói thuốc chứa nhiều chất độc hại có thể làm tổn thương phổi, ảnh hưởng đến tim mạch và làm tăng nguy cơ mắc các bệnh nguy hiểm như viêm phế quản, bệnh phổi tắc nghẽn mạn tính, đột quỵ và ung thư phổi. Người hút thuốc thường xuyên cũng dễ bị ho kéo dài, khó thở, giảm sức bền và cơ thể nhanh mệt hơn khi vận động.\n\nKhông chỉ người hút thuốc bị ảnh hưởng, khói thuốc còn gây hại cho những người xung quanh, đặc biệt là trẻ em, phụ nữ mang thai và người có bệnh nền. Việc bỏ thuốc lá có thể khó khăn lúc đầu, nhưng mang lại lợi ích rất lớn cho sức khỏe về lâu dài. Khi ngừng hút thuốc, phổi và tim sẽ dần phục hồi, hơi thở dễ chịu hơn và nguy cơ bệnh tật cũng giảm xuống theo thời gian.',
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

  Widget _buildReminderCard(
    IconData icon,
    Color bg,
    Color color,
    String title,
    String time,
    bool done,
  ) {
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
            const Text(
              'Sắp tới',
              style: TextStyle(
                fontSize: 10,
                color: AppColors.pink400,
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
    return Container();
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

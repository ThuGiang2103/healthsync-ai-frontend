import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../services/auth_service.dart';

class _C {
  static const bg = Color(0xFFF5F0FD);
  static const card = Color(0xFFFFFFFF);
  static const border = Color(0xFFE6D8F8);
  static const purple100 = Color(0xFFF0E6FB);
  static const purple400 = Color(0xFFC97FD4);
  static const purple700 = Color(0xFF6040A8);
  static const mint100 = Color(0xFFD5F5E3);
  static const mint700 = Color(0xFF2A7A50);
  static const red400 = Color(0xFFE05454);
  static const amber400 = Color(0xFFC07A1A);
  static const blue100 = Color(0xFFDDF0FA);
  static const blue400 = Color(0xFF378ADD);
  static const textMain = Color(0xFF6040A8);
  static const textSub = Color(0xFFA88DD4);
  static const textHint = Color(0xFFCCBBEE);
}

const String _baseUrl = 'https://healthsync-ai-y60b.onrender.com';

class _UserModel {
  final String id, fullName, email, role, createdAt;
  bool isActive;
  _UserModel({
    required this.id,
    required this.fullName,
    required this.email,
    required this.role,
    required this.isActive,
    required this.createdAt,
  });
  factory _UserModel.fromJson(Map<String, dynamic> j) => _UserModel(
    id: j['id'] ?? '',
    fullName: j['fullName'] ?? 'Chưa có tên',
    email: j['email'] ?? '',
    role: j['role'] ?? 'user',
    isActive: j['isActive'] ?? true,
    createdAt: j['createdAt'] ?? '',
  );
}

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});
  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tab;
  Map<String, dynamic> _stats = {};
  List<_UserModel> _users = [];
  bool _loadingStats = true, _loadingUsers = true;
  final _searchCtrl = TextEditingController();
  String _search = '';

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 3, vsync: this);
    _loadStats();
    _loadUsers();
  }

  @override
  void dispose() {
    _tab.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<String?> _token() => AuthService.getToken();

  Future<void> _loadStats() async {
    setState(() => _loadingStats = true);
    try {
      final token = await _token();
      final res = await http.get(
        Uri.parse('$_baseUrl/api/admin/stats'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (res.statusCode == 200) {
        setState(() {
          _stats = jsonDecode(res.body);
          _loadingStats = false;
        });
      } else {
        setState(() => _loadingStats = false);
      }
    } catch (_) {
      setState(() => _loadingStats = false);
    }
  }

  Future<void> _loadUsers() async {
    setState(() => _loadingUsers = true);
    try {
      final token = await _token();
      final uri = Uri.parse('$_baseUrl/api/admin/users').replace(
        queryParameters: _search.isNotEmpty ? {'search': _search} : null,
      );
      final res = await http.get(
        uri,
        headers: {'Authorization': 'Bearer $token'},
      );
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        setState(() {
          _users = (data['users'] as List)
              .map((u) => _UserModel.fromJson(u))
              .toList();
          _loadingUsers = false;
        });
      } else {
        setState(() => _loadingUsers = false);
      }
    } catch (_) {
      setState(() => _loadingUsers = false);
    }
  }

  // ==================== NGƯỜI DÙNG ====================
  void _showAddUserDialog() {
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final passCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Thêm người dùng mới'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: 'Họ và tên'),
            ),
            TextField(
              controller: emailCtrl,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: passCtrl,
              decoration: const InputDecoration(labelText: 'Mật khẩu'),
              obscureText: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Đã thêm người dùng')),
              );
              _loadUsers();
            },
            child: const Text('Thêm', style: TextStyle(color: Colors.green)),
          ),
        ],
      ),
    );
  }

  void _showEditUserDialog(_UserModel user) {
    final nameCtrl = TextEditingController(text: user.fullName);
    final emailCtrl = TextEditingController(text: user.email);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sửa thông tin người dùng'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: 'Họ và tên'),
            ),
            TextField(
              controller: emailCtrl,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Đã cập nhật thông tin')),
              );
              _loadUsers();
            },
            child: const Text('Lưu', style: TextStyle(color: Colors.blue)),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteUser(_UserModel user) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Xóa người dùng?'),
        content: Text('Bạn có chắc muốn xóa "${user.fullName}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Xóa', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (ok != true) return;

    try {
      final token = await _token();
      final res = await http.delete(
        Uri.parse('$_baseUrl/api/admin/users/${user.id}'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (res.statusCode == 200) {
        setState(() => _users.remove(user));
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Đã xóa thành công')));
        _loadStats();
      }
    } catch (_) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Lỗi kết nối')));
    }
  }

  // ==================== DỮ LIỆU HỆ THỐNG ====================
  void _showAddDataDialog(String title) {
    final tenCtrl = TextEditingController();
    final moTaCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Thêm $title'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: tenCtrl,
              decoration: const InputDecoration(labelText: 'Tên'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: moTaCtrl,
              decoration: const InputDecoration(labelText: 'Mô tả'),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('Đã thêm $title')));
            },
            child: const Text('Thêm', style: TextStyle(color: Colors.green)),
          ),
        ],
      ),
    );
  }

  void _showEditDataDialog(String title) {
    final tenCtrl = TextEditingController(text: "Tên mẫu $title");
    final moTaCtrl = TextEditingController(text: "Mô tả mẫu...");

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Sửa $title'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: tenCtrl,
              decoration: const InputDecoration(labelText: 'Tên'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: moTaCtrl,
              decoration: const InputDecoration(labelText: 'Mô tả'),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('Đã cập nhật $title')));
            },
            child: const Text('Lưu', style: TextStyle(color: Colors.blue)),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteData(String type, String label) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Xóa $label?'),
        content: const Text('Hành động này không thể hoàn tác!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Xóa', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (ok != true) return;

    try {
      final token = await _token();
      final res = await http.delete(
        Uri.parse('$_baseUrl/api/admin/data/$type'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (res.statusCode == 200) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Đã xóa $label')));
        _loadStats();
      }
    } catch (_) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Lỗi kết nối')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _C.bg,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Container(
              color: Colors.white,
              child: TabBar(
                controller: _tab,
                labelColor: _C.purple700,
                unselectedLabelColor: _C.textHint,
                indicatorColor: _C.purple400,
                indicatorWeight: 2.5,
                tabs: const [
                  Tab(
                    icon: Icon(Icons.bar_chart_rounded, size: 18),
                    text: 'Thống kê',
                  ),
                  Tab(
                    icon: Icon(Icons.people_rounded, size: 18),
                    text: 'Người dùng',
                  ),
                  Tab(
                    icon: Icon(Icons.storage_rounded, size: 18),
                    text: 'Dữ liệu',
                  ),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tab,
                children: [_buildStatsTab(), _buildUsersTab(), _buildDataTab()],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFF0E6FB), Color(0xFFE6E0FA)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: _C.purple100,
              shape: BoxShape.circle,
              border: Border.all(color: _C.border, width: 2),
            ),
            child: const Icon(
              Icons.admin_panel_settings_rounded,
              color: _C.purple400,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Quản trị viên',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: _C.purple700,
                  ),
                ),
                Text(
                  'HealthSync AI Admin Panel',
                  style: TextStyle(fontSize: 11, color: _C.textSub),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              _loadStats();
              _loadUsers();
            },
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _C.border),
              ),
              child: const Icon(
                Icons.refresh_rounded,
                color: _C.purple400,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsTab() {
    if (_loadingStats)
      return const Center(
        child: CircularProgressIndicator(color: _C.purple400),
      );

    final cards = [
      (
        Icons.people_rounded,
        'Tổng users',
        '${_stats['totalUsers'] ?? 0}',
        _C.purple400,
      ),
      (
        Icons.person_rounded,
        'Hoạt động',
        '${_stats['activeUsers'] ?? 0}',
        _C.mint700,
      ),
      (
        Icons.monitor_heart_rounded,
        'Chỉ số sức khỏe',
        '${_stats['totalMetrics'] ?? 0}',
        Colors.blue,
      ),
      (
        Icons.calendar_today_rounded,
        'Nhắc lịch',
        '${_stats['totalReminders'] ?? 0}',
        _C.amber400,
      ),
      (
        Icons.chat_bubble_rounded,
        'Cuộc trò chuyện',
        '${_stats['totalChats'] ?? 0}',
        Colors.orange,
      ),
      (
        Icons.person_add_rounded,
        'Mới hôm nay',
        '${_stats['newUsersToday'] ?? 0}',
        _C.purple400,
      ),
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tổng quan hệ thống',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: _C.textMain,
            ),
          ),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 2.3,
            children: cards
                .map((c) => _smallStatCard(c.$1, c.$2, c.$3, c.$4))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _smallStatCard(
    IconData icon,
    String title,
    String value,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _C.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _C.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(
                  title,
                  style: const TextStyle(fontSize: 12, color: _C.textSub),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUsersTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchCtrl,
                  onChanged: (v) {
                    _search = v;
                    _loadUsers();
                  },
                  decoration: InputDecoration(
                    hintText: 'Tìm kiếm theo tên hoặc email...',
                    prefixIcon: const Icon(Icons.search_rounded, size: 20),
                    filled: true,
                    fillColor: _C.card,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: _C.border),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              FloatingActionButton.small(
                backgroundColor: _C.purple400,
                onPressed: _showAddUserDialog,
                child: const Icon(Icons.person_add),
              ),
            ],
          ),
        ),
        Expanded(
          child: _loadingUsers
              ? const Center(
                  child: CircularProgressIndicator(color: _C.purple400),
                )
              : _users.isEmpty
              ? const Center(child: Text('Không tìm thấy người dùng'))
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  itemCount: _users.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (_, i) => _buildUserCard(_users[i]),
                ),
        ),
      ],
    );
  }

  Widget _buildUserCard(_UserModel user) {
    final isAdmin = user.role == 'admin';
    return Container(
      decoration: BoxDecoration(
        color: _C.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isAdmin ? _C.purple400 : _C.border),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: isAdmin ? _C.purple100 : _C.blue100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              isAdmin
                  ? Icons.admin_panel_settings_rounded
                  : Icons.person_rounded,
              color: isAdmin ? _C.purple400 : _C.blue400,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        user.fullName,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: isAdmin ? _C.purple100 : _C.mint100,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        isAdmin ? 'Admin' : 'User',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: isAdmin ? _C.purple700 : _C.mint700,
                        ),
                      ),
                    ),
                  ],
                ),
                Text(
                  user.email,
                  style: const TextStyle(fontSize: 11, color: _C.textSub),
                ),
                Text(
                  user.isActive ? 'Đang hoạt động' : 'Đã bị khóa',
                  style: TextStyle(
                    fontSize: 10,
                    color: user.isActive ? _C.mint700 : _C.red400,
                  ),
                ),
              ],
            ),
          ),
          if (!isAdmin) ...[
            IconButton(
              icon: const Icon(
                Icons.edit_outlined,
                color: Colors.blue,
                size: 20,
              ),
              onPressed: () => _showEditUserDialog(user),
            ),
            IconButton(
              icon: const Icon(
                Icons.delete_outline_rounded,
                color: Colors.redAccent,
                size: 20,
              ),
              onPressed: () => _deleteUser(user),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDataTab() {
    final dataItems = [
      (
        'Chỉ số sức khỏe',
        'metrics',
        Icons.monitor_heart_rounded,
        '${_stats['totalMetrics'] ?? 0} bản ghi',
      ),
      (
        'Nhắc lịch',
        'reminders',
        Icons.calendar_today_rounded,
        '${_stats['totalReminders'] ?? 0} bản ghi',
      ),
      (
        'Lịch sử trò chuyện',
        'chats',
        Icons.chat_bubble_rounded,
        '${_stats['totalChats'] ?? 0} phiên',
      ),
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quản lý dữ liệu hệ thống',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: _C.textMain,
            ),
          ),
          const SizedBox(height: 12),
          ...dataItems.map(
            (item) => _buildDataCard(item.$1, item.$2, item.$3, item.$4),
          ),
        ],
      ),
    );
  }

  Widget _buildDataCard(
    String title,
    String type,
    IconData icon,
    String count,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: _C.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _C.border),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: _C.purple100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: _C.purple400, size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  count,
                  style: const TextStyle(fontSize: 12, color: _C.textSub),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add, color: Colors.green, size: 22),
            onPressed: () => _showAddDataDialog(title),
          ),
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: Colors.blue, size: 22),
            onPressed: () => _showEditDataDialog(title),
          ),
          IconButton(
            icon: const Icon(
              Icons.delete_outline_rounded,
              color: Colors.redAccent,
              size: 22,
            ),
            onPressed: () => _deleteData(type, title),
          ),
        ],
      ),
    );
  }
}

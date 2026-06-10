import 'dart:async';
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
  final String id;
  final String fullName;
  final String email;
  final String phone;
  final String role;
  final String createdAt;
  final bool isActive;

  const _UserModel({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.role,
    required this.isActive,
    required this.createdAt,
  });

  factory _UserModel.fromJson(Map<String, dynamic> j) {
    return _UserModel(
      id: '${j['_id'] ?? j['id'] ?? ''}',
      fullName: '${j['fullName'] ?? j['name'] ?? 'Chưa có tên'}',
      email: '${j['email'] ?? ''}',
      phone: '${j['phone'] ?? j['phoneNumber'] ?? ''}',
      role: '${j['role'] ?? 'user'}',
      isActive: j['isActive'] is bool ? j['isActive'] : true,
      createdAt: '${j['createdAt'] ?? ''}',
    );
  }
}

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tab;

  final _searchCtrl = TextEditingController();
  Timer? _searchDebounce;

  Map<String, dynamic> _stats = {};
  List<_UserModel> _users = [];

  bool _loadingStats = true;
  bool _loadingUsers = true;
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
    _searchDebounce?.cancel();
    _tab.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<String?> _token() => AuthService.getToken();

  Future<Map<String, String>> _headers() async {
    final token = await _token();
    return {
      'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  dynamic _tryDecode(String body) {
    try {
      return jsonDecode(body);
    } catch (_) {
      return null;
    }
  }

  String _errorMessage(http.Response res, String fallback) {
    final data = _tryDecode(res.body);
    if (data is Map<String, dynamic>) {
      return '${data['message'] ?? data['error'] ?? fallback}';
    }
    return fallback;
  }

  void _showSnack(String message, {bool error = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: error ? _C.red400 : _C.mint700,
      ),
    );
  }

  Future<void> _loadStats() async {
    if (mounted) setState(() => _loadingStats = true);

    try {
      final res = await http.get(
        Uri.parse('$_baseUrl/api/admin/stats'),
        headers: await _headers(),
      );

      if (!mounted) return;

      if (res.statusCode == 200) {
        final data = _tryDecode(res.body);
        setState(() {
          _stats = data is Map<String, dynamic> ? data : {};
          _loadingStats = false;
        });
      } else {
        setState(() => _loadingStats = false);
      }
    } catch (_) {
      if (mounted) setState(() => _loadingStats = false);
    }
  }

  Future<void> _loadUsers() async {
    if (mounted) setState(() => _loadingUsers = true);

    try {
      final uri = Uri.parse('$_baseUrl/api/admin/users').replace(
        queryParameters:
            _search.trim().isNotEmpty ? {'search': _search.trim()} : null,
      );

      final res = await http.get(uri, headers: await _headers());

      if (!mounted) return;

      if (res.statusCode == 200) {
        final data = _tryDecode(res.body);
        final rawUsers = data is Map<String, dynamic>
            ? data['users']
            : data is List
                ? data
                : [];

        setState(() {
          _users = rawUsers is List
              ? rawUsers
                  .whereType<Map<String, dynamic>>()
                  .map(_UserModel.fromJson)
                  .toList()
              : [];
          _loadingUsers = false;
        });
      } else {
        setState(() => _loadingUsers = false);
        _showSnack('Không thể tải danh sách người dùng', error: true);
      }
    } catch (_) {
      if (!mounted) return;
      setState(() => _loadingUsers = false);
      _showSnack('Lỗi kết nối khi tải người dùng', error: true);
    }
  }

  Future<bool> _createUser({
    required String fullName,
    required String email,
    required String password,
    required String phone,
    required String role,
    required bool isActive,
  }) async {
    try {
      final res = await http.post(
        Uri.parse('$_baseUrl/api/admin/users'),
        headers: await _headers(),
        body: jsonEncode({
          'fullName': fullName.trim(),
          'email': email.trim(),
          'password': password,
          'phone': phone.trim(),
          'role': role,
          'isActive': isActive,
        }),
      );

      if (res.statusCode == 200 || res.statusCode == 201) {
        return true;
      }

      _showSnack(
        '${res.statusCode}: ${_errorMessage(res, 'Không thể thêm người dùng')}',
        error: true,
      );
      return false;
    } catch (e) {
      _showSnack('Không thể thêm người dùng: $e', error: true);
      return false;
    }
  }

  Future<bool> _updateUser({
    required _UserModel user,
    required String fullName,
    required String email,
    required String phone,
    required String role,
    required bool isActive,
  }) async {
    try {
      final res = await http.put(
        Uri.parse('$_baseUrl/api/admin/users/${user.id}'),
        headers: await _headers(),
        body: jsonEncode({
          'fullName': fullName.trim(),
          'email': email.trim(),
          'phone': phone.trim(),
          'role': role,
          'isActive': isActive,
        }),
      );

      if (res.statusCode == 200) {
        _showSnack('Cập nhật người dùng thành công');
        await _loadUsers();
        await _loadStats();
        return true;
      }

      _showSnack(
        _errorMessage(res, 'Không thể cập nhật người dùng'),
        error: true,
      );
      return false;
    } catch (_) {
      _showSnack('Không thể cập nhật người dùng', error: true);
      return false;
    }
  }

  Future<void> _deleteUser(_UserModel user) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Xóa người dùng?'),
        content: Text('Bạn có chắc muốn xóa "${user.fullName}" không?'),
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
      final res = await http.delete(
        Uri.parse('$_baseUrl/api/admin/users/${user.id}'),
        headers: await _headers(),
      );

      if (res.statusCode == 200) {
        _showSnack('Đã xóa người dùng');
        await _loadUsers();
        await _loadStats();
      } else {
        _showSnack(_errorMessage(res, 'Không thể xóa người dùng'), error: true);
      }
    } catch (_) {
      _showSnack('Không thể xóa người dùng', error: true);
    }
  }

  Future<void> _showAddUserDialog() async {
    final formKey = GlobalKey<FormState>();
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final passCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();

    String role = 'user';
    bool isActive = true;
    bool submitting = false;

    final added = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            Future<void> submitAdd() async {
              if (!(formKey.currentState?.validate() ?? false)) return;

              setDialogState(() => submitting = true);

              final success = await _createUser(
                fullName: nameCtrl.text,
                email: emailCtrl.text,
                password: passCtrl.text,
                phone: phoneCtrl.text,
                role: role,
                isActive: isActive,
              );

              if (!dialogContext.mounted) return;

              if (success) {
                Navigator.of(dialogContext).pop(true);
                return;
              }

              setDialogState(() => submitting = false);
            }

            return AlertDialog(
              title: const Text('Thêm người dùng'),
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: nameCtrl,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                          labelText: 'Họ và tên',
                          prefixIcon: Icon(Icons.person_outline),
                        ),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'Vui lòng nhập họ tên';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                          labelText: 'Email / tài khoản',
                          prefixIcon: Icon(Icons.email_outlined),
                        ),
                        validator: (v) {
                          final value = v?.trim() ?? '';
                          if (value.isEmpty) return 'Vui lòng nhập email';
                          if (!value.contains('@')) {
                            return 'Email không đúng định dạng';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: passCtrl,
                        obscureText: true,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                          labelText: 'Mật khẩu',
                          prefixIcon: Icon(Icons.lock_outline),
                        ),
                        validator: (v) {
                          final value = v ?? '';
                          if (value.isEmpty) return 'Vui lòng nhập mật khẩu';
                          if (value.length < 6) {
                            return 'Mật khẩu tối thiểu 6 ký tự';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: phoneCtrl,
                        keyboardType: TextInputType.phone,
                        textInputAction: TextInputAction.done,
                        decoration: const InputDecoration(
                          labelText: 'Số điện thoại',
                          prefixIcon: Icon(Icons.phone_outlined),
                        ),
                        validator: (v) {
                          final value = v?.trim() ?? '';
                          if (value.isEmpty) {
                            return 'Vui lòng nhập số điện thoại';
                          }
                          if (value.length < 9) {
                            return 'Số điện thoại không hợp lệ';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 10),
                      DropdownButtonFormField<String>(
                        initialValue: role,
                        decoration: const InputDecoration(
                          labelText: 'Vai trò',
                          prefixIcon: Icon(Icons.verified_user_outlined),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'user', child: Text('User')),
                          DropdownMenuItem(
                              value: 'admin', child: Text('Admin')),
                        ],
                        onChanged: submitting
                            ? null
                            : (v) => setDialogState(() => role = v ?? 'user'),
                      ),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        value: isActive,
                        title: const Text('Tài khoản hoạt động'),
                        onChanged: submitting
                            ? null
                            : (v) => setDialogState(() => isActive = v),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: submitting
                      ? null
                      : () {
                          Navigator.of(dialogContext).pop(false);
                        },
                  child: const Text('Hủy'),
                ),
                FilledButton.icon(
                  onPressed: submitting ? null : submitAdd,
                  icon: submitting
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.person_add_alt_1),
                  label: const Text('Thêm người dùng'),
                ),
              ],
            );
          },
        );
      },
    );

    nameCtrl.dispose();
    emailCtrl.dispose();
    passCtrl.dispose();
    phoneCtrl.dispose();

    if (added == true && mounted) {
      _showSnack('Thêm người dùng thành công');
      await _loadUsers();
      await _loadStats();
    }
  }

  Future<void> _showEditUserDialog(_UserModel user) async {
    final formKey = GlobalKey<FormState>();
    final nameCtrl = TextEditingController(text: user.fullName);
    final emailCtrl = TextEditingController(text: user.email);
    final phoneCtrl = TextEditingController(text: user.phone);

    String role = user.role == 'admin' ? 'admin' : 'user';
    bool isActive = user.isActive;
    bool submitting = false;

    await showDialog<void>(
      context: context,
      barrierDismissible: !submitting,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            Future<void> submitEdit() async {
              if (!(formKey.currentState?.validate() ?? false)) return;

              setDialogState(() => submitting = true);

              final success = await _updateUser(
                user: user,
                fullName: nameCtrl.text,
                email: emailCtrl.text,
                phone: phoneCtrl.text,
                role: role,
                isActive: isActive,
              );

              if (!dialogContext.mounted) return;

              if (success) {
                Navigator.of(dialogContext).pop();

                Future.microtask(() async {
                  await _loadUsers();
                  await _loadStats();
                });

                return;
              }

              setDialogState(() => submitting = false);
            }

            return AlertDialog(
              title: const Text('Sửa người dùng'),
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: nameCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Họ và tên',
                          prefixIcon: Icon(Icons.person_outline),
                        ),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'Vui lòng nhập họ tên';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          prefixIcon: Icon(Icons.email_outlined),
                        ),
                        validator: (v) {
                          final value = v?.trim() ?? '';
                          if (value.isEmpty) return 'Vui lòng nhập email';
                          if (!value.contains('@')) {
                            return 'Email không đúng định dạng';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: phoneCtrl,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          labelText: 'Số điện thoại',
                          prefixIcon: Icon(Icons.phone_outlined),
                        ),
                      ),
                      const SizedBox(height: 10),
                      DropdownButtonFormField<String>(
                        initialValue: role,
                        decoration: const InputDecoration(
                          labelText: 'Vai trò',
                          prefixIcon: Icon(Icons.verified_user_outlined),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'user', child: Text('User')),
                          DropdownMenuItem(
                              value: 'admin', child: Text('Admin')),
                        ],
                        onChanged: submitting
                            ? null
                            : (v) => setDialogState(() => role = v ?? 'user'),
                      ),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        value: isActive,
                        title: const Text('Tài khoản hoạt động'),
                        onChanged: submitting
                            ? null
                            : (v) => setDialogState(() => isActive = v),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: submitting
                      ? null
                      : () {
                          Navigator.of(dialogContext).pop();
                        },
                  child: const Text('Hủy'),
                ),
                FilledButton.icon(
                  onPressed: submitting ? null : submitEdit,
                  icon: submitting
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.save_outlined),
                  label: const Text('Lưu'),
                ),
              ],
            );
          },
        );
      },
    );

    nameCtrl.dispose();
    emailCtrl.dispose();
    phoneCtrl.dispose();
  }

  void _onSearchChanged(String value) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 450), () {
      _search = value;
      _loadUsers();
    });
  }

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
              _showSnack('Đã thêm $title');
              _loadStats();
            },
            child: const Text('Thêm', style: TextStyle(color: Colors.green)),
          ),
        ],
      ),
    ).whenComplete(() {
      tenCtrl.dispose();
      moTaCtrl.dispose();
    });
  }

  void _showEditDataDialog(String title) {
    final tenCtrl = TextEditingController(text: 'Tên mẫu $title');
    final moTaCtrl = TextEditingController(text: 'Mô tả mẫu...');

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
              _showSnack('Đã cập nhật $title');
              _loadStats();
            },
            child: const Text('Lưu', style: TextStyle(color: Colors.blue)),
          ),
        ],
      ),
    ).whenComplete(() {
      tenCtrl.dispose();
      moTaCtrl.dispose();
    });
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
      final res = await http.delete(
        Uri.parse('$_baseUrl/api/admin/data/$type'),
        headers: await _headers(),
      );

      if (res.statusCode == 200) {
        _showSnack('Đã xóa $label');
        _loadStats();
      } else {
        _showSnack(_errorMessage(res, 'Không thể xóa dữ liệu'), error: true);
      }
    } catch (_) {
      _showSnack('Không thể xóa dữ liệu', error: true);
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
                children: [
                  _buildStatsTab(),
                  _buildUsersTab(),
                  _buildDataTab(),
                ],
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
          IconButton.filledTonal(
            style: IconButton.styleFrom(backgroundColor: Colors.white),
            onPressed: () {
              _loadStats();
              _loadUsers();
            },
            icon: const Icon(
              Icons.refresh_rounded,
              color: _C.purple400,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsTab() {
    if (_loadingStats) {
      return const Center(
        child: CircularProgressIndicator(color: _C.purple400),
      );
    }

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

    return RefreshIndicator(
      onRefresh: _loadStats,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
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
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
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
                  onChanged: _onSearchChanged,
                  decoration: InputDecoration(
                    hintText: 'Tìm kiếm theo tên hoặc email...',
                    prefixIcon: const Icon(Icons.search_rounded, size: 20),
                    suffixIcon: _searchCtrl.text.isEmpty
                        ? null
                        : IconButton(
                            onPressed: () {
                              _searchCtrl.clear();
                              _search = '';
                              _loadUsers();
                              setState(() {});
                            },
                            icon: const Icon(Icons.close_rounded),
                          ),
                    filled: true,
                    fillColor: _C.card,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: _C.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: _C.border),
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
                  : RefreshIndicator(
                      onRefresh: _loadUsers,
                      child: ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                        itemCount: _users.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (_, i) => _buildUserCard(_users[i]),
                      ),
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
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
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
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 11, color: _C.textSub),
                ),
                if (user.phone.isNotEmpty)
                  Text(
                    user.phone,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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
          IconButton(
            tooltip: 'Sửa người dùng',
            icon: const Icon(
              Icons.edit_outlined,
              color: Colors.blue,
              size: 20,
            ),
            onPressed: () => _showEditUserDialog(user),
          ),
          IconButton(
            tooltip: 'Xóa người dùng',
            icon: const Icon(
              Icons.delete_outline_rounded,
              color: Colors.redAccent,
              size: 20,
            ),
            onPressed: () => _deleteUser(user),
          ),
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

    if (_loadingStats) {
      return const Center(
        child: CircularProgressIndicator(color: _C.purple400),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadStats,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
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
            tooltip: 'Thêm dữ liệu',
            icon: const Icon(Icons.add, color: Colors.green, size: 22),
            onPressed: () => _showAddDataDialog(title),
          ),
          IconButton(
            tooltip: 'Sửa dữ liệu',
            icon: const Icon(Icons.edit_outlined, color: Colors.blue, size: 22),
            onPressed: () => _showEditDataDialog(title),
          ),
          IconButton(
            tooltip: 'Xóa dữ liệu',
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

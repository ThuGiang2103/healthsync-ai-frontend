import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/auth_service.dart';

class _C {
  static const bg = Color(0xFFFDF6F9);
  static const card = Color(0xFFFFFFFF);
  static const border = Color(0xFFF5E0EC);
  static const pink100 = Color(0xFFFCE4EE);
  static const pink200 = Color(0xFFF5C0D4);
  static const pink400 = Color(0xFFE07FA8);
  static const pink700 = Color(0xFF7C3F6B);
  static const mint100 = Color(0xFFD5F5E3);
  static const mint700 = Color(0xFF2A7A50);
  static const amber100 = Color(0xFFFEF3DE);
  static const amber400 = Color(0xFFC07A1A);
  static const purple100 = Color(0xFFF0E6FB);
  static const purple400 = Color(0xFF8A4FA8);
  static const blue100 = Color(0xFFDDF0FA);
  static const blue400 = Color(0xFF378ADD);
  static const textMain = Color(0xFF7C3F6B);
  static const textSub = Color(0xFFC47FA0);
  static const textHint = Color(0xFFC9ADC0);
}

// ─── Profile Screen ───────────────────────────────────────────────
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameCtrl = TextEditingController(text: 'Tran Thu Giang');
  final _emailCtrl = TextEditingController(text: 'thugiang@gmail.com');
  final _phoneCtrl = TextEditingController(text: '09876322');
  final _genderCtrl = TextEditingController(text: 'Nu');
  final _heightCtrl = TextEditingController(text: '154');
  final _weightCtrl = TextEditingController(text: '58');
  final _medCtrl = TextEditingController(text: 'Khong co benh ly nen');

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = await AuthService.getUser();
    if (mounted && user != null) {
      setState(() {
        _nameCtrl.text = user['fullName'] ?? 'Nguoi dung';
        _emailCtrl.text = user['email'] ?? '';
      });
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _genderCtrl.dispose();
    _heightCtrl.dispose();
    _weightCtrl.dispose();
    _medCtrl.dispose();
    super.dispose();
  }

  void _showEditDialog(String label, TextEditingController ctrl) {
    final tmp = TextEditingController(text: ctrl.text);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Chinh sua $label',
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            color: _C.textMain,
          ),
        ),
        content: TextField(
          controller: tmp,
          autofocus: true,
          decoration: InputDecoration(
            filled: true,
            fillColor: _C.pink100,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Huy', style: TextStyle(color: _C.textHint)),
          ),
          GestureDetector(
            onTap: () {
              setState(() => ctrl.text = tmp.text);
              Navigator.pop(context);
              _showSnack('Da luu $label thanh cong');
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: _C.pink400,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'Luu',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _deleteField(String label, TextEditingController ctrl) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Xoa $label?',
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            color: _C.textMain,
          ),
        ),
        content: Text(
          'Ban co chac muon xoa thong tin "$label" nay khong?',
          style: const TextStyle(color: _C.textSub),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Huy', style: TextStyle(color: _C.textHint)),
          ),
          GestureDetector(
            onTap: () {
              setState(() => ctrl.text = '');
              Navigator.pop(context);
              _showSnack('Da xoa $label');
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'Xoa',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSnack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: const TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: isError ? Colors.red : _C.mint700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _C.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle('Thong tin ca nhan'),
                    const SizedBox(height: 8),
                    _buildInfoCard(),
                    const SizedBox(height: 24),
                    _buildSectionTitle('Suc khoe'),
                    const SizedBox(height: 8),
                    _buildHealthCard(),
                    const SizedBox(height: 24),
                    _buildSectionTitle('Cai dat'),
                    const SizedBox(height: 8),
                    _buildSettingsCard(),
                    const SizedBox(height: 30),
                    _buildLogoutBtn(),
                    const SizedBox(height: 12),
                    _buildDeleteProfileBtn(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 32),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFFCE4EE), Color(0xFFFEF3E2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 45,
            backgroundColor: Colors.white,
            child: const Icon(
              Icons.person_rounded,
              size: 55,
              color: _C.pink400,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            _nameCtrl.text,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: _C.pink700,
            ),
          ),
          Text(
            _emailCtrl.text,
            style: const TextStyle(fontSize: 14, color: _C.textSub),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String t) => Padding(
    padding: const EdgeInsets.only(left: 4),
    child: Text(
      t,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: _C.textMain,
      ),
    ),
  );

  Widget _buildInfoCard() {
    return Container(
      decoration: BoxDecoration(
        color: _C.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _C.border),
      ),
      child: Column(
        children: [
          _infoField(Icons.person_outline_rounded, 'Ho va ten', _nameCtrl),
          _divider(),
          _infoField(Icons.email_outlined, 'Email', _emailCtrl),
          _divider(),
          _infoField(Icons.phone_outlined, 'So dien thoai', _phoneCtrl),
          _divider(),
          _infoField(Icons.person_2_outlined, 'Gioi tinh', _genderCtrl),
          _divider(),
          _infoField(Icons.height_rounded, 'Chieu cao (cm)', _heightCtrl),
          _divider(),
          _infoField(
            Icons.monitor_weight_outlined,
            'Can nang (kg)',
            _weightCtrl,
          ),
        ],
      ),
    );
  }

  Widget _infoField(IconData icon, String label, TextEditingController ctrl) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _C.pink100,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: _C.pink400, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontSize: 12, color: _C.textSub),
                ),
                Text(
                  ctrl.text.isEmpty ? '---' : ctrl.text,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: Colors.grey, size: 20),
            onPressed: () => _showEditDialog(label, ctrl),
          ),
          IconButton(
            icon: const Icon(
              Icons.delete_outline_rounded,
              color: Colors.redAccent,
              size: 20,
            ),
            onPressed: () => _deleteField(label, ctrl),
          ),
        ],
      ),
    );
  }

  Widget _divider() => const Divider(
    height: 1,
    thickness: 1,
    indent: 56,
    endIndent: 16,
    color: Color(0xFFF5E0EC),
  );

  Widget _buildHealthCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _C.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _C.border),
      ),
      child: Text(
        _medCtrl.text,
        style: const TextStyle(fontSize: 14, color: _C.textMain),
      ),
    );
  }

  Widget _buildSettingsCard() {
    return Container(
      decoration: BoxDecoration(
        color: _C.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _C.border),
      ),
      child: Column(
        children: [
          _settingsItem(
            Icons.notifications_outlined,
            _C.pink100,
            _C.pink400,
            'Thong bao',
            'Bat/tat thong bao',
            onTap: () => _push(const NotificationSettingsScreen()),
          ),
          _divider(),
          _settingsItem(
            Icons.lock_outline_rounded,
            _C.purple100,
            _C.purple400,
            'Bao mat',
            'Mat khau, xac thuc hai lop',
            onTap: () => _push(const SecuritySettingsScreen()),
          ),
          _divider(),
          _settingsItem(
            Icons.info_outline_rounded,
            _C.blue100,
            _C.blue400,
            'Gioi thieu ung dung',
            '',
            onTap: () => _push(const AboutAppScreen()),
          ),
          _divider(),
          _settingsItem(
            Icons.language_rounded,
            _C.mint100,
            _C.mint700,
            'Quan ly ngon ngu',
            'Tieng Viet',
            onTap: () => _push(const LanguageSettingsScreen()),
          ),
          _divider(),
          _settingsItem(
            Icons.support_agent_rounded,
            _C.amber100,
            _C.amber400,
            'Ho tro',
            'Lien he doi ngu ho tro',
            onTap: () => _push(const SupportScreen()),
          ),
          _divider(),
          _settingsItem(
            Icons.system_update_alt_rounded,
            _C.mint100,
            _C.mint700,
            'Cap nhat phan mem',
            'Phien ban 1.0.0',
            onTap: () => _push(const UpdateScreen()),
          ),
          _divider(),
          _settingsItem(
            Icons.help_outline_rounded,
            _C.blue100,
            _C.blue400,
            'Huong dan nguoi dung',
            '',
            onTap: () => _push(const UserGuideScreen()),
          ),
        ],
      ),
    );
  }

  void _push(Widget screen) =>
      Navigator.push(context, MaterialPageRoute(builder: (_) => screen));

  Widget _settingsItem(
    IconData icon,
    Color iconBg,
    Color iconColor,
    String title,
    String subtitle, {
    VoidCallback? onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: iconBg,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor, size: 24),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
      ),
      subtitle: subtitle.isNotEmpty
          ? Text(
              subtitle,
              style: const TextStyle(fontSize: 12, color: _C.textSub),
            )
          : null,
      trailing: const Icon(Icons.chevron_right_rounded, color: Colors.grey),
      onTap: onTap ?? () {},
    );
  }

  Widget _buildLogoutBtn() {
    return GestureDetector(
      onTap: _confirmLogout,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: _C.pink100,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.logout_rounded, color: _C.pink400),
            SizedBox(width: 8),
            Text(
              'Dang xuat',
              style: TextStyle(fontWeight: FontWeight.w700, color: _C.pink400),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeleteProfileBtn() {
    return GestureDetector(
      onTap: _confirmDeleteProfile,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.red.shade200),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.delete_forever_rounded, color: Colors.red),
            SizedBox(width: 8),
            Text(
              'Xoa ho so',
              style: TextStyle(fontWeight: FontWeight.w700, color: Colors.red),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Dang xuat?',
          style: TextStyle(fontWeight: FontWeight.w700, color: _C.textMain),
        ),
        content: const Text(
          'Ban co chac muon dang xuat khong?',
          style: TextStyle(color: _C.textSub),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Huy', style: TextStyle(color: _C.textHint)),
          ),
          GestureDetector(
            onTap: () async {
              Navigator.pop(context);
              await AuthService.logout();
              if (context.mounted) {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/login',
                  (r) => false,
                );
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: _C.pink400,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'Dang xuat',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteProfile() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Xoa ho so?',
          style: TextStyle(fontWeight: FontWeight.w700, color: Colors.red),
        ),
        content: const Text(
          'Toan bo thong tin tai khoan se bi xoa vinh vien. Hanh dong nay KHONG the hoan tac!',
          style: TextStyle(color: _C.textSub),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Huy', style: TextStyle(color: _C.textHint)),
          ),
          GestureDetector(
            onTap: () async {
              Navigator.pop(context);
              await AuthService.logout();
              if (context.mounted) {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/login',
                  (r) => false,
                );
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'Xoa vinh vien',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── THONG BAO ────────────────────────────────────────────────────
class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});
  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  bool _all = true,
      _sound = true,
      _vibrate = true,
      _silent = false,
      _lockScreen = true,
      _dnd = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final p = await SharedPreferences.getInstance();
    setState(() {
      _all = p.getBool('notif_all') ?? true;
      _sound = p.getBool('notif_sound') ?? true;
      _vibrate = p.getBool('notif_vibrate') ?? true;
      _silent = p.getBool('notif_silent') ?? false;
      _lockScreen = p.getBool('notif_lock') ?? true;
      _dnd = p.getBool('notif_dnd') ?? false;
    });
  }

  Future<void> _save() async {
    final p = await SharedPreferences.getInstance();
    await p.setBool('notif_all', _all);
    await p.setBool('notif_sound', _sound);
    await p.setBool('notif_vibrate', _vibrate);
    await p.setBool('notif_silent', _silent);
    await p.setBool('notif_lock', _lockScreen);
    await p.setBool('notif_dnd', _dnd);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _C.bg,
      appBar: _appBar(context, 'Thong bao'),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _card([
            _switchTile(
              'Bat thong bao',
              'Cho phep nhan thong bao tu ung dung',
              _all,
              (v) {
                setState(() => _all = v);
                _save();
              },
            ),
          ]),
          if (_all) ...[
            const SizedBox(height: 16),
            _sectionLabel('Am thanh & Rung'),
            _card([
              _switchTile('Am thanh', '', _sound, (v) {
                setState(() => _sound = v);
                _save();
              }),
              const Divider(height: 1, color: _C.border),
              _switchTile('Rung', '', _vibrate, (v) {
                setState(() => _vibrate = v);
                _save();
              }),
              const Divider(height: 1, color: _C.border),
              _switchTile('Im lang', 'Tat am thanh va rung', _silent, (v) {
                setState(() => _silent = v);
                _save();
              }),
            ]),
            const SizedBox(height: 16),
            _sectionLabel('Hien thi'),
            _card([
              _switchTile('Hien thi tren man hinh khoa', '', _lockScreen, (v) {
                setState(() => _lockScreen = v);
                _save();
              }),
              const Divider(height: 1, color: _C.border),
              _switchTile(
                'Khong lam phien',
                'Chi nhan thong bao khan cap',
                _dnd,
                (v) {
                  setState(() => _dnd = v);
                  _save();
                },
              ),
            ]),
          ],
        ],
      ),
    );
  }
}

// ─── BAO MAT ─────────────────────────────────────────────────────
class SecuritySettingsScreen extends StatefulWidget {
  const SecuritySettingsScreen({super.key});
  @override
  State<SecuritySettingsScreen> createState() => _SecuritySettingsScreenState();
}

class _SecuritySettingsScreenState extends State<SecuritySettingsScreen> {
  bool _biometric = false, _twoFactor = false;
  final _oldPwCtrl = TextEditingController();
  final _newPwCtrl = TextEditingController();
  final _cfmPwCtrl = TextEditingController();
  bool _showOld = false, _showNew = false, _showCfm = false;

  @override
  void dispose() {
    _oldPwCtrl.dispose();
    _newPwCtrl.dispose();
    _cfmPwCtrl.dispose();
    super.dispose();
  }

  void _changePassword() {
    if (_newPwCtrl.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mat khau moi phai co it nhat 6 ky tu')),
      );
      return;
    }
    if (_newPwCtrl.text != _cfmPwCtrl.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mat khau xac nhan khong khop')),
      );
      return;
    }
    _oldPwCtrl.clear();
    _newPwCtrl.clear();
    _cfmPwCtrl.clear();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          'Da doi mat khau thanh cong!',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: _C.mint700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _C.bg,
      appBar: _appBar(context, 'Bao mat'),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _sectionLabel('Doi mat khau'),
          _card([
            _pwField(
              'Mat khau hien tai',
              _oldPwCtrl,
              _showOld,
              () => setState(() => _showOld = !_showOld),
            ),
            const Divider(height: 1, color: _C.border),
            _pwField(
              'Mat khau moi',
              _newPwCtrl,
              _showNew,
              () => setState(() => _showNew = !_showNew),
            ),
            const Divider(height: 1, color: _C.border),
            _pwField(
              'Xac nhan mat khau moi',
              _cfmPwCtrl,
              _showCfm,
              () => setState(() => _showCfm = !_showCfm),
            ),
          ]),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: _changePassword,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: _C.purple400,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Center(
                child: Text(
                  'Doi mat khau',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          _sectionLabel('Bao mat nang cao'),
          _card([
            _switchTile(
              'Xac thuc sinh trac hoc',
              'Van tay / Khuon mat',
              _biometric,
              (v) => setState(() => _biometric = v),
            ),
            const Divider(height: 1, color: _C.border),
            _switchTile(
              'Xac thuc hai lop (2FA)',
              'Tang cuong bao mat tai khoan',
              _twoFactor,
              (v) => setState(() => _twoFactor = v),
            ),
          ]),
          const SizedBox(height: 16),
          _sectionLabel('Hoat dong tai khoan'),
          _card([
            _infoTile(
              Icons.login_rounded,
              _C.blue100,
              _C.blue400,
              'Dang nhap gan day',
              'Hom nay, 14:32',
            ),
            const Divider(height: 1, color: _C.border),
            _infoTile(
              Icons.devices_rounded,
              _C.mint100,
              _C.mint700,
              'Thiet bi dang hoat dong',
              '1 thiet bi',
            ),
          ]),
        ],
      ),
    );
  }

  Widget _pwField(
    String label,
    TextEditingController ctrl,
    bool show,
    VoidCallback toggle,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: TextField(
        controller: ctrl,
        obscureText: !show,
        style: const TextStyle(fontSize: 14, color: _C.textMain),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: _C.textSub, fontSize: 13),
          border: InputBorder.none,
          suffixIcon: IconButton(
            icon: Icon(
              show ? Icons.visibility_off_rounded : Icons.visibility_rounded,
              color: _C.textHint,
              size: 20,
            ),
            onPressed: toggle,
          ),
        ),
      ),
    );
  }
}

// ─── GIOI THIEU UNG DUNG ─────────────────────────────────────────
class AboutAppScreen extends StatelessWidget {
  const AboutAppScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _C.bg,
      appBar: _appBar(context, 'Gioi thieu ung dung'),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFE07FA8), Color(0xFFC97FD4)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.health_and_safety_rounded,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'HealthSync AI',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const Text(
                  'Phien ban 1.0.0',
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _sectionLabel('Ve ung dung'),
          _card([
            _textBlock(
              'HealthSync AI la ung dung quan ly suc khoe ca nhan tich hop tri tue nhan tao, '
              'giup nguoi dung theo doi cac chi so suc khoe, dat nhac lich uong thuoc va nhan tu van '
              'suc khoe co ban. Ung dung duoc phat trien bang Flutter (frontend) va Node.js (backend), '
              'su dung PostgreSQL lam co so du lieu.',
            ),
          ]),
          const SizedBox(height: 16),
          _sectionLabel('Thong tin phat trien'),
          _card([
            _infoTile(
              Icons.code_rounded,
              _C.purple100,
              _C.purple400,
              'Ngon ngu',
              'Flutter / Dart / Node.js',
            ),
            const Divider(height: 1, color: _C.border),
            _infoTile(
              Icons.storage_rounded,
              _C.blue100,
              _C.blue400,
              'Co so du lieu',
              'PostgreSQL / Prisma ORM',
            ),
            const Divider(height: 1, color: _C.border),
            _infoTile(
              Icons.cloud_rounded,
              _C.mint100,
              _C.mint700,
              'Trien khai',
              'Render.com',
            ),
            const Divider(height: 1, color: _C.border),
            _infoTile(
              Icons.calendar_today_rounded,
              _C.amber100,
              _C.amber400,
              'Nam phat trien',
              '2025 - 2026',
            ),
          ]),
          const SizedBox(height: 16),
          _sectionLabel('Luu y phap ly'),
          _card([
            _textBlock(
              'Ung dung chi mang tinh tham khao va ho tro. Cac tu van suc khoe '
              'khong thay the cho chan doan y khoa chuyen nghiep. Vui long tham khao '
              'y kien bac si khi can thiet.',
            ),
          ]),
        ],
      ),
    );
  }
}

// ─── NGON NGU ─────────────────────────────────────────────────────
class LanguageSettingsScreen extends StatefulWidget {
  const LanguageSettingsScreen({super.key});
  @override
  State<LanguageSettingsScreen> createState() => _LanguageSettingsScreenState();
}

class _LanguageSettingsScreenState extends State<LanguageSettingsScreen> {
  String _selected = 'vi';
  final _langs = [('vi', 'Tieng Viet', 'VI'), ('en', 'English', 'EN')];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _C.bg,
      appBar: _appBar(context, 'Quan ly ngon ngu'),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _sectionLabel('Chon ngon ngu hien thi'),
          _card(
            _langs
                .map(
                  (l) => Column(
                    children: [
                      GestureDetector(
                        onTap: () {
                          setState(() => _selected = l.$1);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Da chuyen sang ${l.$2}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              backgroundColor: _C.mint700,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              margin: const EdgeInsets.all(16),
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: _C.blue100,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Center(
                                  child: Text(
                                    l.$3,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      color: _C.blue400,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Text(
                                  l.$2,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: _C.textMain,
                                  ),
                                ),
                              ),
                              if (_selected == l.$1)
                                const Icon(
                                  Icons.check_circle_rounded,
                                  color: _C.mint700,
                                  size: 22,
                                ),
                            ],
                          ),
                        ),
                      ),
                      if (l != _langs.last)
                        const Divider(height: 1, color: _C.border),
                    ],
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

// ─── HO TRO ───────────────────────────────────────────────────────
class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _C.bg,
      appBar: _appBar(context, 'Ho tro'),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _sectionLabel('Lien he chung toi'),
          _card([
            _infoTile(
              Icons.email_outlined,
              _C.blue100,
              _C.blue400,
              'Email ho tro',
              'support@healthsync.ai',
            ),
            const Divider(height: 1, color: _C.border),
            _infoTile(
              Icons.phone_outlined,
              _C.mint100,
              _C.mint700,
              'Hotline',
              '1800 - xxxx - xxxx (Mien phi)',
            ),
            const Divider(height: 1, color: _C.border),
            _infoTile(
              Icons.access_time_rounded,
              _C.amber100,
              _C.amber400,
              'Gio lam viec',
              'Thu 2 - Thu 6: 8:00 - 17:00',
            ),
          ]),
          const SizedBox(height: 16),
          _sectionLabel('Cau hoi thuong gap (FAQ)'),
          _card([
            _faqItem(
              'Ung dung co an toan khong?',
              'Co, du lieu duoc ma hoa bang bcrypt va JWT. Chung toi cam ket bao ve '
                  'thong tin ca nhan cua ban.',
            ),
            const Divider(height: 1, color: _C.border),
            _faqItem(
              'AI co chan doan benh chinh xac khong?',
              'AI chi mang tinh tham khao. Vui long tham khao bac si de duoc chan doan chinh xac.',
            ),
            const Divider(height: 1, color: _C.border),
            _faqItem(
              'Lam sao de xuat du lieu?',
              'Tinh nang xuat du lieu dang duoc phat trien va se co trong phien ban tiep theo.',
            ),
            const Divider(height: 1, color: _C.border),
            _faqItem(
              'Quen mat khau phai lam gi?',
              'Su dung chuc nang "Quen mat khau" tren man hinh dang nhap. He thong se gui '
                  'email khoi phuc den dia chi email cua ban.',
            ),
          ]),
          const SizedBox(height: 16),
          _sectionLabel('Gui phan hoi'),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _C.card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _C.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Noi dung phan hoi',
                  style: TextStyle(
                    fontSize: 13,
                    color: _C.textSub,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: 'Nhap phan hoi cua ban...',
                    hintStyle: const TextStyle(
                      color: _C.textHint,
                      fontSize: 13,
                    ),
                    filled: true,
                    fillColor: _C.bg,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: _C.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: _C.border),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text(
                        'Da gui phan hoi thanh cong!',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      backgroundColor: _C.mint700,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      margin: const EdgeInsets.all(16),
                    ),
                  ),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: _C.pink400,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: Text(
                        'Gui phan hoi',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _faqItem(String q, String a) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.help_outline_rounded,
                color: _C.purple400,
                size: 18,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  q,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: _C.textMain,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.only(left: 26),
            child: Text(
              a,
              style: const TextStyle(
                fontSize: 12,
                color: _C.textSub,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── CAP NHAT PHAN MEM ────────────────────────────────────────────
class UpdateScreen extends StatelessWidget {
  const UpdateScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _C.bg,
      appBar: _appBar(context, 'Cap nhat phan mem'),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFD5F5E3), Color(0xFFDDF0FA)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle_rounded,
                    color: _C.mint700,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ban dang dung phien ban moi nhat!',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: _C.mint700,
                        ),
                      ),
                      Text(
                        'HealthSync AI v1.0.0',
                        style: TextStyle(fontSize: 12, color: _C.mint700),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _sectionLabel('Lich su cap nhat'),
          _card([
            _updateItem('v1.0.0', '08/05/2026', [
              'Ra mat ung dung chinh thuc',
              'Theo doi chi so suc khoe (huyet ap, nhip tim, can nang...)',
              'He thong nhac lich thong minh',
              'AI tu van suc khoe co ban',
              'Quan tri vien (Admin panel)',
            ]),
          ]),
          const SizedBox(height: 16),
          _sectionLabel('Sap ra mat'),
          _card([
            _textBlock(
              'v1.1.0 (Du kien Q3/2026):\n'
              '- Thong bao push notification thuc te\n'
              '- Xuat du lieu ra file PDF/Excel\n'
              '- Ket noi voi thiet bi deo (smartwatch)\n'
              '- Giao dien dark mode',
            ),
          ]),
        ],
      ),
    );
  }

  Widget _updateItem(String ver, String date, List<String> notes) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: _C.purple100,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  ver,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: _C.purple400,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                date,
                style: const TextStyle(fontSize: 12, color: _C.textSub),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...notes.map(
            (n) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('• ', style: TextStyle(color: _C.mint700)),
                  Expanded(
                    child: Text(
                      n,
                      style: const TextStyle(
                        fontSize: 12,
                        color: _C.textMain,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── HUONG DAN NGUOI DUNG ─────────────────────────────────────────
class UserGuideScreen extends StatelessWidget {
  const UserGuideScreen({super.key});

  final _guides = const [
    (
      'Dang ky & Dang nhap',
      Icons.login_rounded,
      _C.blue100,
      _C.blue400,
      'Tao tai khoan bang email va mat khau (it nhat 6 ky tu). Sau khi dang nhap thanh cong, '
          'he thong luu phien lam viec tu dong. Ban co the dang xuat bat cu luc nao tu tab Ho so.',
    ),
    (
      'Ghi chi so suc khoe',
      Icons.monitor_heart_rounded,
      _C.pink100,
      _C.pink400,
      'Vao tab "Chi so" > nhan "Them chi so moi" > chon loai chi so (huyet ap, nhip tim, '
          'can nang...) > nhap gia tri > nhan Luu. Chi so se hien thi trong danh sach va bieu do.',
    ),
    (
      'Xem bieu do thong ke',
      Icons.bar_chart_rounded,
      _C.purple100,
      _C.purple400,
      'Trong tab "Chi so", nhan bieu tuong bieu do goc tren phai. Chon loai chi so muon xem '
          'va khoang thoi gian (7 ngay hoac 30 ngay). Bieu do se cap nhat tu dong.',
    ),
    (
      'Dat nhac lich',
      Icons.calendar_today_rounded,
      _C.mint100,
      _C.mint700,
      'Vao tab "Nhac lich" > nhan "Them nhac nho moi" > nhap tieu de > chon thoi gian > nhan Luu. '
          'Nhan vao checkbox de danh dau da hoan thanh. Nhan nut thung rac de xoa nhac lich.',
    ),
    (
      'Tu van AI',
      Icons.auto_awesome_rounded,
      _C.amber100,
      _C.amber400,
      'Vao tab "AI Chat" > nhap cau hoi ve suc khoe > nhan nut gui. AI se tra loi dua tren '
          'cac quy tac suc khoe co ban. Ban cung co the nhan cac chip goi y de hoi nhanh.',
    ),
    (
      'Quan ly ho so',
      Icons.person_rounded,
      _C.pink100,
      _C.pink400,
      'Vao tab "Ho so" de xem va chinh sua thong tin ca nhan. Nhan bieu tuong but chi de sua, '
          'bieu tuong thung rac de xoa tung truong thong tin. He thong tinh BMI tu dong.',
    ),
    (
      'Cai dat thong bao',
      Icons.notifications_rounded,
      _C.blue100,
      _C.blue400,
      'Vao Ho so > Cai dat > Thong bao de bat/tat am thanh, rung, hien thi tren man hinh khoa '
          'va che do khong lam phien. Cai dat duoc luu tu dong.',
    ),
    (
      'Bao mat tai khoan',
      Icons.lock_rounded,
      _C.purple100,
      _C.purple400,
      'Vao Ho so > Cai dat > Bao mat de doi mat khau. Nhap mat khau hien tai, mat khau moi '
          '(it nhat 6 ky tu) va xac nhan lai. Nhan "Doi mat khau" de luu thay doi.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _C.bg,
      appBar: _appBar(context, 'Huong dan nguoi dung'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFCE4EE), Color(0xFFF0E6FB)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.tips_and_updates_rounded,
                  color: _C.pink400,
                  size: 22,
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Chon chuong de xem huong dan chi tiet',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: _C.textMain,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ..._guides.asMap().entries.map((e) {
            final i = e.key;
            final g = e.value;
            return _GuideItem(
              number: i + 1,
              title: g.$1,
              icon: g.$2,
              iconBg: g.$3,
              iconColor: g.$4,
              content: g.$5,
            );
          }),
        ],
      ),
    );
  }
}

class _GuideItem extends StatefulWidget {
  final int number;
  final String title, content;
  final IconData icon;
  final Color iconBg, iconColor;
  const _GuideItem({
    required this.number,
    required this.title,
    required this.content,
    required this.icon,
    required this.iconBg,
    required this.iconColor,
  });
  @override
  State<_GuideItem> createState() => _GuideItemState();
}

class _GuideItemState extends State<_GuideItem> {
  bool _open = false;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        decoration: BoxDecoration(
          color: _C.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _open ? _C.pink200 : _C.border),
        ),
        child: Column(
          children: [
            GestureDetector(
              onTap: () => setState(() => _open = !_open),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: widget.iconBg,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        widget.icon,
                        color: widget.iconColor,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        '${widget.number}. ${widget.title}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: _C.textMain,
                        ),
                      ),
                    ),
                    Icon(
                      _open
                          ? Icons.keyboard_arrow_up_rounded
                          : Icons.keyboard_arrow_down_rounded,
                      color: _C.textHint,
                    ),
                  ],
                ),
              ),
            ),
            if (_open)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                child: Text(
                  widget.content,
                  style: const TextStyle(
                    fontSize: 13,
                    color: _C.textSub,
                    height: 1.6,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ─── HELPERS DUNG CHUNG ───────────────────────────────────────────
AppBar _appBar(BuildContext context, String title) => AppBar(
  title: Text(
    title,
    style: const TextStyle(fontWeight: FontWeight.w700, color: _C.pink700),
  ),
  backgroundColor: Colors.white,
  foregroundColor: _C.pink700,
  elevation: 0,
  leading: IconButton(
    icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
    onPressed: () => Navigator.pop(context),
  ),
);

Widget _card(List<Widget> children) => Container(
  decoration: BoxDecoration(
    color: _C.card,
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: _C.border),
  ),
  child: Column(children: children),
);

Widget _sectionLabel(String t) => Padding(
  padding: const EdgeInsets.only(left: 4, bottom: 8),
  child: Text(
    t,
    style: const TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w700,
      color: _C.textMain,
    ),
  ),
);

Widget _switchTile(
  String title,
  String sub,
  bool val,
  ValueChanged<bool> onChanged,
) {
  return SwitchListTile(
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    title: Text(
      title,
      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
    ),
    subtitle: sub.isNotEmpty
        ? Text(sub, style: const TextStyle(fontSize: 12, color: _C.textSub))
        : null,
    value: val,
    activeColor: _C.pink400,
    onChanged: onChanged,
  );
}

Widget _infoTile(
  IconData icon,
  Color bg,
  Color color,
  String title,
  String value,
) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    child: Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: _C.textMain,
                ),
              ),
              Text(
                value,
                style: const TextStyle(fontSize: 12, color: _C.textSub),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

Widget _textBlock(String text) => Padding(
  padding: const EdgeInsets.all(16),
  child: Text(
    text,
    style: const TextStyle(fontSize: 13, color: _C.textSub, height: 1.6),
  ),
);

import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';

class _C {
  static const bg = Color(0xFFFDF6F9);
  static const pink100 = Color(0xFFFCE4EE);
  static const pink200 = Color(0xFFF5C0D4);
  static const pink400 = Color(0xFFE07FA8);
  static const mint100 = Color(0xFFD5F5E3);
  static const mint4 = Color(0xFF2A7A50);
  static const textMain = Color(0xFF7C3F6B);
  static const textSub = Color(0xFFC47FA0);
  static const textHint = Color(0xFFC9ADC0);
  static const border = Color(0xFFF5C0D4);
  static const card = Color(0xFFFFFFFF);
}

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _isLoading = false;
  bool _showPassword = false;
  int _step = 0;

  Future<void> _register() async {
    if (_nameCtrl.text.isEmpty ||
        _emailCtrl.text.isEmpty ||
        _passwordCtrl.text.isEmpty) {
      _showSnack('Vui long nhap day du thong tin', isError: true);
      return;
    }
    if (!_emailCtrl.text.contains('@')) {
      _showSnack('Email khong hop le', isError: true);
      return;
    }
    if (_passwordCtrl.text.length < 6) {
      _showSnack('Mat khau phai co it nhat 6 ky tu', isError: true);
      return;
    }
    setState(() => _isLoading = true);
    final result = await ApiService.register(
      fullName: _nameCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      password: _passwordCtrl.text,
    );
    setState(() => _isLoading = false);
    if (!mounted) return;
    if (result['error'] != null) {
      _showSnack(result['error'], isError: true);
    } else {
      await AuthService.saveLoginData(
        result['token'] ?? '',
        result['user'] ?? {},
      );
      setState(() => _step = 1);
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) Navigator.pushReplacementNamed(context, '/home');
    }
  }

  void _showSnack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: const TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: isError ? const Color(0xFFD4714A) : _C.mint4,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final formWidth = w > 600 ? 400.0 : w - 48.0;
    return Scaffold(
      backgroundColor: _C.bg,
      body: Stack(
        children: [
          Positioned(
            top: -60,
            left: -60,
            child: _blob(200, const Color(0xFFF0E6FB)),
          ),
          Positioned(
            bottom: -80,
            right: -80,
            child: _blob(250, const Color(0xFFFCE4EE)),
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 8, 0, 0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: _C.card,
                          shape: BoxShape.circle,
                          border: Border.all(color: _C.border),
                        ),
                        child: const Icon(
                          Icons.arrow_back_rounded,
                          color: _C.textMain,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: _step == 1
                          ? _buildSuccess(formWidth)
                          : _buildForm(formWidth),
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

  Widget _buildForm(double formWidth) {
    return Column(
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: _C.pink100,
            shape: BoxShape.circle,
            border: Border.all(color: _C.pink200, width: 2),
          ),
          child: const Icon(
            Icons.health_and_safety_rounded,
            size: 38,
            color: _C.pink400,
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Tao tai khoan moi',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: _C.textMain,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Dang ky de bat dau hanh trinh suc khoe',
          style: TextStyle(fontSize: 12, color: _C.textSub),
        ),
        const SizedBox(height: 28),
        Container(
          width: formWidth,
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: _C.card,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: _C.pink200),
            boxShadow: [
              BoxShadow(
                color: _C.pink200.withValues(alpha: 0.4),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStepIndicator(),
              const SizedBox(height: 20),
              _buildField(
                controller: _nameCtrl,
                label: 'Ho va ten',
                icon: Icons.person_outline_rounded,
              ),
              const SizedBox(height: 14),
              _buildField(
                controller: _emailCtrl,
                label: 'Email',
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 14),
              _buildField(
                controller: _passwordCtrl,
                label: 'Mat khau (it nhat 6 ky tu)',
                icon: Icons.lock_outline_rounded,
                obscure: !_showPassword,
                suffix: IconButton(
                  icon: Icon(
                    _showPassword
                        ? Icons.visibility_off_rounded
                        : Icons.visibility_rounded,
                    color: _C.textHint,
                    size: 20,
                  ),
                  onPressed: () =>
                      setState(() => _showPassword = !_showPassword),
                ),
              ),
              const SizedBox(height: 24),
              _buildButton(
                label: 'Tao tai khoan',
                onTap: _isLoading ? null : _register,
                isLoading: _isLoading,
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Da co tai khoan? ',
              style: TextStyle(fontSize: 13, color: _C.textSub),
            ),
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: const Text(
                'Dang nhap',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: _C.pink400,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStepIndicator() => Row(
    children: [
      _stepDot(active: true, label: 'Thong tin'),
      Expanded(child: Container(height: 2, color: _C.pink200)),
      _stepDot(active: false, label: 'Hoan thanh'),
    ],
  );

  Widget _stepDot({required bool active, required String label}) => Column(
    children: [
      Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: active ? _C.pink400 : _C.pink100,
          shape: BoxShape.circle,
          border: Border.all(
            color: active ? _C.pink400 : _C.pink200,
            width: 1.5,
          ),
        ),
        child: Icon(
          active ? Icons.edit_rounded : Icons.check_rounded,
          color: active ? Colors.white : _C.textHint,
          size: 14,
        ),
      ),
      const SizedBox(height: 4),
      Text(
        label,
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w600,
          color: active ? _C.pink400 : _C.textHint,
        ),
      ),
    ],
  );

  Widget _buildSuccess(double formWidth) => Container(
    width: formWidth,
    padding: const EdgeInsets.all(36),
    decoration: BoxDecoration(
      color: _C.card,
      borderRadius: BorderRadius.circular(28),
      border: Border.all(color: _C.pink200),
    ),
    child: Column(
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: const BoxDecoration(
            color: _C.mint100,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.check_rounded, color: _C.mint4, size: 38),
        ),
        const SizedBox(height: 16),
        const Text(
          'Dang ky thanh cong!',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: _C.textMain,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Dang chuyen den trang chu...',
          style: TextStyle(fontSize: 13, color: _C.textSub),
        ),
        const SizedBox(height: 20),
        const CircularProgressIndicator(color: _C.pink400, strokeWidth: 2.5),
      ],
    ),
  );

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscure = false,
    TextInputType keyboardType = TextInputType.text,
    Widget? suffix,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      style: const TextStyle(
        fontSize: 14,
        color: _C.textMain,
        fontWeight: FontWeight.w600,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: _C.textHint, fontSize: 13),
        prefixIcon: Icon(icon, color: _C.pink400, size: 20),
        suffixIcon: suffix,
        filled: true,
        fillColor: _C.bg,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _C.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _C.pink400, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 16,
        ),
      ),
    );
  }

  Widget _buildButton({
    required String label,
    required VoidCallback? onTap,
    bool isLoading = false,
  }) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: double.infinity,
      height: 52,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFE07FA8), Color(0xFFC97FD4)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: _C.pink400.withValues(alpha: 0.35),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              )
            : Text(
                label,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
      ),
    ),
  );

  Widget _blob(double size, Color color) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
  );
}

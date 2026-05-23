import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';

class _C {
  static const bg = Color(0xFFFDF6F9);
  static const pink100 = Color(0xFFFCE4EE);
  static const pink200 = Color(0xFFF5C0D4);
  static const pink400 = Color(0xFFE07FA8);
  static const purple4 = Color(0xFF7B5EA7);
  static const textMain = Color(0xFF7C3F6B);
  static const textSub = Color(0xFFC47FA0);
  static const textHint = Color(0xFFC9ADC0);
  static const border = Color(0xFFF5C0D4);
  static const card = Color(0xFFFFFFFF);
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _isLoading = false;
  bool _showPassword = false;

  Future<void> _login() async {
    if (_emailCtrl.text.isEmpty || _passwordCtrl.text.isEmpty) {
      _showSnack('Vui long nhap day du thong tin', isError: true);
      return;
    }
    setState(() => _isLoading = true);
    final result = await ApiService.login(
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
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  void _showSnack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: const TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: isError ? const Color(0xFFD4714A) : _C.pink400,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  void dispose() {
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
            right: -60,
            child: _blob(200, const Color(0xFFFCE4EE)),
          ),
          Positioned(
            bottom: -80,
            left: -80,
            child: _blob(250, const Color(0xFFF0E6FB)),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(vertical: 32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildLogo(),
                    const SizedBox(height: 40),
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
                          const Text(
                            'Chao mung tro lai!',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: _C.textMain,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Dang nhap de tiep tuc',
                            style: TextStyle(fontSize: 13, color: _C.textSub),
                          ),
                          const SizedBox(height: 24),
                          _buildField(
                            controller: _emailCtrl,
                            label: 'Email',
                            icon: Icons.email_outlined,
                            keyboardType: TextInputType.emailAddress,
                          ),
                          const SizedBox(height: 14),
                          _buildField(
                            controller: _passwordCtrl,
                            label: 'Mat khau',
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
                              onPressed: () => setState(
                                () => _showPassword = !_showPassword,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Align(
                            alignment: Alignment.centerRight,
                            child: GestureDetector(
                              onTap: () {},
                              child: const Text(
                                'Quen mat khau?',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: _C.purple4,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          _buildButton(
                            label: 'Dang nhap',
                            onTap: _isLoading ? null : _login,
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
                          'Chua co tai khoan? ',
                          style: TextStyle(fontSize: 13, color: _C.textSub),
                        ),
                        GestureDetector(
                          onTap: () =>
                              Navigator.pushNamed(context, '/register'),
                          child: const Text(
                            'Dang ky ngay',
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
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogo() => Column(
    children: [
      Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: _C.pink100,
          shape: BoxShape.circle,
          border: Border.all(color: _C.pink200, width: 2),
        ),
        child: const Icon(
          Icons.health_and_safety_rounded,
          size: 44,
          color: _C.pink400,
        ),
      ),
      const SizedBox(height: 14),
      const Text(
        'HealthSync AI',
        style: TextStyle(
          fontSize: 26,
          fontWeight: FontWeight.w700,
          color: _C.textMain,
        ),
      ),
      const SizedBox(height: 4),
      const Text(
        'Quan ly suc khoe ca nhan',
        style: TextStyle(fontSize: 13, color: _C.textSub),
      ),
    ],
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

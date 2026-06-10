import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';

  // ==================== TOKEN ====================
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  // ==================== USER DATA ====================
  static Future<void> saveUserData(Map<String, dynamic> user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(user));
  }

  static Future<Map<String, dynamic>?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final String? userStr = prefs.getString(_userKey);
    if (userStr == null) return null;
    try {
      return jsonDecode(userStr);
    } catch (_) {
      return null;
    }
  }

  // ==================== SAVE LOGIN DATA (hàm bị thiếu) ====================
  static Future<void> saveLoginData(
      String token, Map<String, dynamic> user) async {
    await saveToken(token);
    await saveUserData(user);
  }

  // ==================== KIỂM TRA ADMIN ====================
  static Future<bool> isAdmin() async {
    final user = await getUser();
    if (user == null) return false;
    return user['role'] == 'admin' || user['isAdmin'] == true;
  }

  // ==================== LOGOUT ====================
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
  }

  // ==================== KIỂM TRA ĐĂNG NHẬP ====================
  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
}

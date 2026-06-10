import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';

  static Future<void> saveLoginData(
    String token,
    Map<String, dynamic> user,
  ) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(_tokenKey, token);
    await prefs.setString('token', token);

    await prefs.setString(_userKey, jsonEncode(user));
    await prefs.setString('user', jsonEncode(user));
  }

  static Future<void> saveAuthData({
    required String token,
    required Map<String, dynamic> user,
  }) async {
    await saveLoginData(token, user);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getString(_tokenKey) ??
        prefs.getString('token') ??
        prefs.getString('accessToken');
  }

  static Future<Map<String, dynamic>?> getUser() async {
    final prefs = await SharedPreferences.getInstance();

    final raw = prefs.getString(_userKey) ??
        prefs.getString('user') ??
        prefs.getString('current_user');

    if (raw == null || raw.isEmpty) return null;

    try {
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  static Future<bool> isAdmin() async {
    final user = await getUser();
    return user?['role'] == 'admin';
  }

  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
    await prefs.remove('token');
    await prefs.remove('user');
    await prefs.remove('accessToken');
    await prefs.remove('current_user');
  }
}

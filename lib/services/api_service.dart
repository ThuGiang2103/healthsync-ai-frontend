import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

// Import AuthService
import 'auth_service.dart';

class ApiService {
  static const String baseUrl = "https://healthsync-ai-y60b.onrender.com";

  // ==================== REGISTER ====================
  static Future<Map<String, dynamic>> register({
    required String fullName,
    required String email,
    required String password,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/api/auth/register'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'fullName': fullName,
              'email': email,
              'password': password,
            }),
          )
          .timeout(const Duration(seconds: 15));

      debugPrint("📝 REGISTER STATUS: ${response.statusCode}");
      debugPrint("📄 REGISTER BODY: ${response.body}");

      return jsonDecode(response.body);
    } catch (e) {
      debugPrint("❌ Lỗi register: $e");
      return {'error': 'Không kết nối được server'};
    }
  }

  // ==================== LOGIN ====================
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/api/auth/login'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'email': email, 'password': password}),
          )
          .timeout(const Duration(seconds: 15));

      debugPrint("🔑 LOGIN STATUS: ${response.statusCode}");
      debugPrint("📄 LOGIN BODY: ${response.body}");

      final data = jsonDecode(response.body);

      // Xử lý nhiều kiểu trả token
      if (data['token'] != null) return data;
      if (data['accessToken'] != null)
        return {'token': data['accessToken'], ...data};
      if (data['data'] != null && data['data']['token'] != null) {
        return {'token': data['data']['token'], ...data};
      }

      return data;
    } catch (e) {
      debugPrint("❌ Lỗi login: $e");
      return {'error': 'Không kết nối được server'};
    }
  }

  // ==================== GET USER ====================
  static Future<Map<String, dynamic>> getUser() async {
    try {
      final token = await AuthService.getToken();
      if (token == null) return {'error': 'Chưa đăng nhập'};

      final response = await http.get(
        Uri.parse('$baseUrl/api/auth/me'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      debugPrint("👤 GET USER STATUS: ${response.statusCode}");
      debugPrint("📄 GET USER BODY: ${response.body}");

      return jsonDecode(response.body);
    } catch (e) {
      debugPrint("❌ Lỗi getUser: $e");
      return {'error': 'Không lấy được thông tin người dùng'};
    }
  }

  // ==================== LOGOUT ====================
  static Future<Map<String, dynamic>> logout() async {
    try {
      final token = await AuthService.getToken();
      if (token == null) return {'success': true};

      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/logout'),
        headers: {'Authorization': 'Bearer $token'},
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {'success': true};
    }
  }

  // Helper kiểm tra có token không
  static bool hasToken(Map<String, dynamic> response) {
    return response['token'] != null ||
        response['accessToken'] != null ||
        (response['data'] != null && response['data']['token'] != null);
  }
}

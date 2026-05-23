import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = "https://healthsync-ai-y60b.onrender.com";

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

      debugPrint("Status: ${response.statusCode}");
      debugPrint("Body: ${response.body}");

      return jsonDecode(response.body);
    } catch (e) {
      debugPrint("Loi: $e");
      return {'error': 'Khong ket noi duoc server'};
    }
  }

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

      return jsonDecode(response.body);
    } catch (e) {
      debugPrint("Loi login: $e");
      return {'error': 'Khong ket noi duoc server'};
    }
  }
}

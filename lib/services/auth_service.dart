import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/login_request.dart';
import '../models/login_response.dart';

class AuthService {
  static const String baseUrl = 'http://localhost:8080';

  Future<LoginResponse?> login(String username, String password) async {
    try {
      final request = LoginRequest(username: username, password: password);

      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(request.toJson()),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;

        return LoginResponse.fromJson(data);
      } else if (response.statusCode == 401) {
        // Invalid credentials
        return null;
      } else {
        // Other errors
        throw Exception('Login failed: ${response.statusCode}');
      }
    } catch (e) {
      // Network error or other exception
      rethrow;
    }
  }

  Future<LoginResponse?> register(String username, String password) async {
    try {
      final request = LoginRequest(username: username, password: password);

      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(request.toJson()),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;

        return LoginResponse.fromJson(data);
      } else if (response.statusCode == 409) {
        // Username already exists
        return null;
      } else {
        throw Exception('Registration failed: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<LoginResponse?> refreshToken(String refreshToken) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/refresh'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refreshToken': refreshToken}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;

        return LoginResponse.fromJson(data);
      } else {
        return null;
      }
    } catch (e) {
      rethrow;
    }
  }
}

import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/login_request.dart';
import '../models/login_response.dart';
import 'storage_service.dart';

class AuthService {
  static const String baseUrl = 'http://localhost:8080';

  Future<LoginResponse?> login(String username, String password) async {
    final response = await _sendLoginReq(username, password);

    if (response == null) {
      return null;
    }

    await StorageService.write('login_response', jsonEncode(response.toJson()));

    return response;
  }

  Future<LoginResponse?> _sendLoginReq(String username, String password) async {
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
      }

      if (response.statusCode == 401) {
        return null;
      }

      throw Exception('Login failed: ${response.statusCode}');
    } catch (e) {
      rethrow;
    }
  }

  Future<LoginResponse?> getCurrentUser() async {
    final jsonData = await StorageService.read('login_response');

    if (jsonData == null) {
      return null;
    }
    
    return LoginResponse.fromJson(jsonDecode(jsonData));
  }

  Future<void> logout() async {
    await StorageService.clear('login_response');
  }
}

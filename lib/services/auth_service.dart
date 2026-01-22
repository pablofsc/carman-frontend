import 'dart:convert' as convert;

import '../clients/api_client.dart';
import '../models/login_request.dart';
import '../models/login_response.dart';
import 'storage_service.dart';

class AuthService {
  Future<LoginResponse?> login(String username, String password) async {
    final response = await _sendLoginReq(username, password);

    if (response == null) {
      return null;
    }

    await StorageService.write(
      'login_response',
      convert.jsonEncode(response.toJson()),
    );

    return response;
  }

  Future<LoginResponse?> register(String username, String password) async {
    try {
      final request = LoginRequest(username: username, password: password);

      final response = await ApiClient.post(
        '/auth/register',
        headers: {'Content-Type': 'application/json'},
        body: convert.jsonEncode(request.toJson()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = convert.jsonDecode(response.body);
        final loginResponse = LoginResponse.fromJson(data);

        await StorageService.write(
          'login_response',
          convert.jsonEncode(loginResponse.toJson()),
        );

        return loginResponse;
      }

      if (response.statusCode == 409) {
        throw 'Username is not available';
      }

      return null;
    } catch (e) {
      rethrow;
    }
  }

  Future<LoginResponse?> _sendLoginReq(String username, String password) async {
    try {
      final request = LoginRequest(username: username, password: password);

      final response = await ApiClient.post(
        '/auth/login',
        headers: {'Content-Type': 'application/json'},
        body: convert.jsonEncode(request.toJson()),
      );

      if (response.statusCode == 200) {
        final data = convert.jsonDecode(response.body) as Map<String, dynamic>;
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
    
    return LoginResponse.fromJson(convert.jsonDecode(jsonData));
  }

  Future<void> logout() async {
    await StorageService.clear('login_response');
  }

  Future<String?> getAuthToken() async {
    final loginResponse = await getCurrentUser();
    return loginResponse?.accessToken;
  }

  Future<Map<String, String>> getAuthHeaders() async {
    final token = await getAuthToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }
}

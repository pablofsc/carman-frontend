import 'dart:convert' as convert;

import '../clients/api_client.dart';
import '../models/login_request.dart';
import '../models/login_response.dart';
import 'storage_service.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();

  AuthService._internal();

  factory AuthService() {
    return _instance;
  }

  Future<LoginResponse?>? _refreshInProgress;

  static const int _refreshBufferSeconds = 30;

  Future<LoginResponse?> login(String username, String password) async {
    final response = await _sendLoginReq(username, password);

    if (response == null) {
      return null;
    }

    await _saveLoginResponse(response);
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

        await _saveLoginResponse(loginResponse);
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
    final loginResponse = await _ensureValidToken();
    return loginResponse?.accessToken;
  }

  Future<Map<String, String>> getAuthHeaders() async {
    final token = await getAuthToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<LoginResponse?> _refreshToken() async {
    _refreshInProgress ??= (() async {
      try {
        final currentUser = await getCurrentUser();

        if (currentUser == null) {
          throw Exception('Cannot refresh token: no user logged in');
        }

        final newResponse = await _sendRefreshReq(currentUser.refreshToken);

        if (newResponse != null) {
          await _saveLoginResponse(newResponse);
        } else {
          await logout();
        }

        return newResponse;
      } catch (e) {
        await logout();
        return null;
      } finally {
        _refreshInProgress = null;
      }
    })();

    return await _refreshInProgress;
  }

  Future<LoginResponse?> _sendRefreshReq(String refreshToken) async {
    try {
      final response = await ApiClient.post(
        '/auth/refresh',
        headers: {'Content-Type': 'application/json'},
        body: convert.jsonEncode({'refreshToken': refreshToken}),
      );

      if (response.statusCode == 200) {
        final data = convert.jsonDecode(response.body) as Map<String, dynamic>;
        return LoginResponse.fromJson(data);
      }

      if (response.statusCode == 401 || response.statusCode == 403) {
        return null;
      }

      throw Exception('Token refresh failed: ${response.statusCode}');
    } catch (e) {
      rethrow;
    }
  }

  Future<LoginResponse?> _ensureValidToken() async {
    if (_refreshInProgress != null) {
      await _refreshInProgress;
    }

    final currentUser = await getCurrentUser();

    if (currentUser?.isExpiringSoon(_refreshBufferSeconds) ?? false) {
      await _refreshToken();
      return getCurrentUser();
    }

    return currentUser;
  }

  Future<void> _saveLoginResponse(LoginResponse response) async {
    await StorageService.write(
      'login_response',
      convert.jsonEncode(response.toJson()),
    );
  }
}

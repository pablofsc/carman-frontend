import 'package:flutter_riverpod/flutter_riverpod.dart' as riverpod;
import 'dart:convert' as convert;

import 'package:carman/adapters/api_client.dart';
import 'package:carman/models/login_request.dart';
import 'package:carman/models/login_response.dart';
import 'package:carman/providers/events_provider.dart';
import 'package:carman/providers/vehicles_provider.dart';
import 'package:carman/adapters/storage_adapter.dart';

final authProvider =
    riverpod.AsyncNotifierProvider<AuthNotifier, LoginResponse?>(
      AuthNotifier.new,
    );

class AuthNotifier extends riverpod.AsyncNotifier<LoginResponse?> {
  static const int _refreshBufferSeconds = 30;

  Future<LoginResponse?>? _refreshInProgress;

  @override
  Future<LoginResponse?> build() async {
    final jsonData = await StorageService.read('login_response');
    if (jsonData == null) return null;

    return LoginResponse.fromJson(convert.jsonDecode(jsonData));
  }

  Future<void> login(String username, String password) async {
    state = const riverpod.AsyncValue.loading();

    state = await riverpod.AsyncValue.guard(() async {
      final response = await _sendReqLogin(username, password);
      if (response != null) await _persist(response);

      return response;
    });

    if (state.value != null) _invalidateUserProviders();
  }

  Future<void> register(String username, String password) async {
    state = const riverpod.AsyncValue.loading();

    state = await riverpod.AsyncValue.guard(() async {
      final response = await _sendReqRegister(username, password);
      if (response != null) await _persist(response);

      return response;
    });

    if (state.value != null) _invalidateUserProviders();
  }

  Future<void> logout() async {
    await StorageService.clear('login_response');

    state = const riverpod.AsyncValue.data(null);
  }

  Future<String?> getToken() async {
    final user = state.value;
    if (user == null) return null;

    if (user.isExpiringSoon(_refreshBufferSeconds)) {
      final refreshed = await _refreshToken();
      return refreshed?.accessToken;
    }

    return user.accessToken;
  }

  Future<Map<String, String>> getHeaders() async {
    final token = await getToken();

    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<LoginResponse?> _refreshToken() async {
    _refreshInProgress ??= (() async {
      try {
        final user = state.value;
        if (user == null) return null;

        final refreshed = await _sendReqRefresh(user.refreshToken);

        if (refreshed != null) {
          await _persist(refreshed);
          state = riverpod.AsyncValue.data(refreshed);
        } else {
          await logout();
        }

        return refreshed;
      } finally {
        _refreshInProgress = null;
      }
    })();

    return _refreshInProgress;
  }

  Future<LoginResponse?> _sendReqLogin(String username, String password) async {
    final request = LoginRequest(username: username, password: password);

    final response = await ApiClient.post(
      '/auth/login',
      headers: {'Content-Type': 'application/json'},
      body: convert.jsonEncode(request.toJson()),
    );

    if (response.statusCode == 200) {
      return LoginResponse.fromJson(convert.jsonDecode(response.body));
    }

    if (response.statusCode == 401) throw 'Invalid username or password';

    throw Exception('Login failed: ${response.statusCode}');
  }

  Future<LoginResponse?> _sendReqRegister(
    String username,
    String password,
  ) async {
    final request = LoginRequest(username: username, password: password);

    final response = await ApiClient.post(
      '/auth/register',
      headers: {'Content-Type': 'application/json'},
      body: convert.jsonEncode(request.toJson()),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return LoginResponse.fromJson(convert.jsonDecode(response.body));
    }

    if (response.statusCode == 409) {
      throw 'Username is not available';
    }

    throw Exception('Register failed: ${response.statusCode}');
  }

  Future<LoginResponse?> _sendReqRefresh(String refreshToken) async {
    final response = await ApiClient.post(
      '/auth/refresh',
      headers: {'Content-Type': 'application/json'},
      body: convert.jsonEncode({'refreshToken': refreshToken}),
    );

    if (response.statusCode == 200) {
      return LoginResponse.fromJson(convert.jsonDecode(response.body));
    }

    if (response.statusCode == 401 || response.statusCode == 403) {
      return null;
    }

    throw Exception('Refresh failed: ${response.statusCode}');
  }

  void _invalidateUserProviders() {
    // TODO: create a userProvider or something so those can watch it
    ref.invalidate(eventsProvider);
    ref.invalidate(vehiclesProvider);
    // no need to invalidate selectedVehicleProvider since it watches vehiclesProvider
  }

  Future<void> _persist(LoginResponse response) async {
    await StorageService.write(
      'login_response',
      convert.jsonEncode(response.toJson()),
    );
  }
}

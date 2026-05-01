import 'package:flutter_riverpod/flutter_riverpod.dart' as riverpod;
import 'dart:convert' as convert;

import 'package:carman/adapters/backend_adapter.dart';
import 'package:carman/models/auth_response.dart';
import 'package:carman/providers/events_provider.dart';
import 'package:carman/providers/vehicles_provider.dart';
import 'package:carman/adapters/storage_adapter.dart';

final authProvider =
    riverpod.AsyncNotifierProvider<AuthNotifier, AuthResponse?>(
      AuthNotifier.new,
    );

class AuthNotifier extends riverpod.AsyncNotifier<AuthResponse?> {
  static const int _refreshBufferSeconds = 30;

  Future<AuthResponse?>? _refreshInProgress;

  @override
  Future<AuthResponse?> build() async {
    final jsonData = await StorageAdapter.read('login_response');
    if (jsonData == null) return null;

    return AuthResponse.fromJson(convert.jsonDecode(jsonData));
  }

  Future<bool> login(String username, String password) async {
    state = const riverpod.AsyncValue.loading();

    state = await riverpod.AsyncValue.guard(() async {
      final response = await BackendAdapter.login(username, password);
      if (response != null) await _persist(response);

      return response;
    });

    if (state.value != null) _invalidateUserProviders();

    return !state.hasError;
  }

  Future<bool> register(String username, String password) async {
    state = const riverpod.AsyncValue.loading();

    state = await riverpod.AsyncValue.guard(() async {
      final response = await BackendAdapter.register(username, password);
      if (response != null) await _persist(response);

      return response;
    });

    if (state.value != null) _invalidateUserProviders();

    return !state.hasError;
  }

  Future<void> logout() async {
    await StorageAdapter.clear('login_response');

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

  Future<AuthResponse?> _refreshToken() async {
    _refreshInProgress ??= (() async {
      try {
        final user = state.value;
        if (user == null) return null;

        final refreshed = await BackendAdapter.refreshToken(user.refreshToken);

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

  void _invalidateUserProviders() {
    // TODO: create a userProvider or something so those can watch it
    ref.invalidate(eventsProvider);
    ref.invalidate(vehiclesProvider);
    // no need to invalidate selectedVehicleProvider since it watches vehiclesProvider
  }

  Future<void> _persist(AuthResponse response) async {
    await StorageAdapter.write(
      'login_response',
      convert.jsonEncode(response.toJson()),
    );
  }

}

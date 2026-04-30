import 'package:flutter_riverpod/flutter_riverpod.dart' as riverpod;
import 'dart:convert' as convert;

import 'package:carman/adapters/storage_adapter.dart';
import 'package:carman/models/user.dart';
import 'package:carman/providers/auth_provider.dart';
import 'package:carman/repositories/user_repository.dart';

final userProvider = riverpod.AsyncNotifierProvider<UserNotifier, User?>(
  UserNotifier.new,
);

class UserNotifier extends riverpod.AsyncNotifier<User?> {
  static const _storageKey = 'user';

  @override
  Future<User?> build() async {
    ref.listen(authProvider, (previous, next) {
      // Only react to identity changes (login/logout), not token refreshes
      final prevUserId = previous?.value?.user.id;
      final nextUserId = next.value?.user.id;
      if (prevUserId == nextUserId) return;

      if (next.value != null) {
        final user = next.value!.user;
        state = riverpod.AsyncValue.data(user);
        _persistLocally(user);
      } else {
        state = const riverpod.AsyncValue.data(null);
        StorageAdapter.clear(_storageKey);
      }
    });

    // Try own persisted user first
    final jsonData = await StorageAdapter.read(_storageKey);
    if (jsonData != null) {
      return User.fromJson(convert.jsonDecode(jsonData));
    }

    // Fall back to user data from the auth response (e.g. on first login restore)
    final auth = ref.read(authProvider).value;
    if (auth != null) return auth.user;

    return null;
  }

  Future<void> updateTheme(String themeKey) async {
    final current = state.value;
    if (current == null) return;

    final updated = current.copyWith(selectedTheme: themeKey);
    state = riverpod.AsyncValue.data(updated);
    await _persistLocally(updated);

    _syncToBackend((headers) => UserRepository.setSelectedTheme(themeKey, headers));
  }

  Future<void> updateLanguage(String languageCode) async {
    final current = state.value;
    if (current == null) return;

    final updated = current.copyWith(selectedLanguage: languageCode);
    state = riverpod.AsyncValue.data(updated);
    await _persistLocally(updated);

    _syncToBackend((headers) => UserRepository.setSelectedLanguage(languageCode, headers));
  }

  Future<void> updateCurrency(String currencyCode) async {
    final current = state.value;
    if (current == null) return;

    final updated = current.copyWith(selectedCurrency: currencyCode);
    state = riverpod.AsyncValue.data(updated);
    await _persistLocally(updated);

    _syncToBackend((headers) => UserRepository.setSelectedCurrency(currencyCode, headers));
  }

  Future<void> _syncToBackend(
    Future<void> Function(Map<String, String> headers) call,
  ) async {
    try {
      final headers = await ref.read(authProvider.notifier).getHeaders();
      if (headers.containsKey('Authorization')) await call(headers);
    } catch (_) {
      // Backend sync failure is non-critical
    }
  }

  Future<void> _persistLocally(User user) async {
    await StorageAdapter.write(_storageKey, convert.jsonEncode(user.toJson()));
  }
}

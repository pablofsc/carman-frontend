import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' as riverpod;

import 'package:carman/adapters/api_client.dart';
import 'package:carman/adapters/storage_adapter.dart';
import 'package:carman/providers/auth_provider.dart';

const _storageKey = 'selected_locale';

// can't use AppLocalizations' supported locales list because it doesn't have the display names
const Map<String, String> supportedLocaleNames = {
  'en': 'English',
  'pt': 'Português',
};

final localeProvider = riverpod.NotifierProvider<LocaleNotifier, Locale>(
  LocaleNotifier.new,
);

class LocaleNotifier extends riverpod.Notifier<Locale> {
  @override
  Locale build() {
    ref.listen(authProvider, (previous, next) {
      final lang = next.value?.selectedLanguage;
      if (lang != null) _setFrontendLocale(Locale(lang));
    });

    _loadFromStorage();
    return const Locale('en');
  }

  Future<void> _loadFromStorage() async {
    final saved = await StorageAdapter.read(_storageKey);
    if (saved != null) state = Locale(saved);
  }

  void _setFrontendLocale(Locale locale) {
    state = locale;
    StorageAdapter.write(_storageKey, locale.languageCode);
  }

  Future<void> setLocale(Locale locale) async {
    _setFrontendLocale(locale);

    try {
      final headers = await ref.read(authProvider.notifier).getHeaders();

      if (headers.containsKey('Authorization')) {
        await ApiClient.put(
          '/users/selected-language?code=${locale.languageCode}',
          headers: headers,
        );
      }
    } catch (_) {
      // Backend sync failure is non-critical
    }
  }
}

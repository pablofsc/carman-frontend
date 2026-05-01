import 'package:carman/adapters/backend_adapter.dart';

class UserRepository {
  static Future<void> setSelectedTheme(
    String themeKey,
    Map<String, String> headers,
  ) async {
    await BackendAdapter.setUserSelectedTheme(themeKey, headers);
  }

  static Future<void> setSelectedLanguage(
    String languageCode,
    Map<String, String> headers,
  ) async {
    await BackendAdapter.setUserSelectedLanguage(languageCode, headers);
  }

  static Future<void> setSelectedCurrency(
    String currencyCode,
    Map<String, String> headers,
  ) async {
    await BackendAdapter.setUserSelectedCurrency(currencyCode, headers);
  }
}

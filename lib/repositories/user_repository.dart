import 'package:carman/adapters/api_client.dart';

class UserRepository {
  static Future<void> setSelectedTheme(
    String themeKey,
    Map<String, String> headers,
  ) async {
    await ApiClient.put(
      '/users/selected-theme?key=$themeKey',
      headers: headers,
    );
  }

  static Future<void> setSelectedLanguage(
    String languageCode,
    Map<String, String> headers,
  ) async {
    await ApiClient.put(
      '/users/selected-language?code=$languageCode',
      headers: headers,
    );
  }

  static Future<void> setSelectedCurrency(
    String currencyCode,
    Map<String, String> headers,
  ) async {
    await ApiClient.put(
      '/users/selected-currency?code=$currencyCode',
      headers: headers,
    );
  }
}

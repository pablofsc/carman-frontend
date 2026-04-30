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
}

import 'package:http/http.dart' as http;

class ApiClient {
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8080',
  );

  static Future<http.Response> get(
    String endpoint, {
    Map<String, String>? headers,
  }) async {
    return http.get(Uri.parse('$baseUrl$endpoint'), headers: headers);
  }

  static Future<http.Response> post(
    String endpoint, {
    Map<String, String>? headers,
    String? body,
  }) async {
    return http.post(
      Uri.parse('$baseUrl$endpoint'),
      headers: headers,
      body: body,
    );
  }

  static Future<http.Response> put(
    String endpoint, {
    Map<String, String>? headers,
    String? body,
  }) async {
    return http.put(
      Uri.parse('$baseUrl$endpoint'),
      headers: headers,
      body: body,
    );
  }

  static Future<http.Response> patch(
    String endpoint, {
    Map<String, String>? headers,
    String? body,
  }) async {
    return http.patch(
      Uri.parse('$baseUrl$endpoint'),
      headers: headers,
      body: body,
    );
  }

  static Future<http.Response> delete(
    String endpoint, {
    Map<String, String>? headers,
    String? body,
  }) async {
    return http.delete(
      Uri.parse('$baseUrl$endpoint'),
      headers: headers,
      body: body,
    );
  }
}

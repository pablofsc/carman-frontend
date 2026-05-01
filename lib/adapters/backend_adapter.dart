import 'dart:convert' as convert;

import 'package:carman/infrastructure/api_client.dart';
import 'package:carman/models/auth_response.dart';
import 'package:carman/models/event.dart';
import 'package:carman/models/login_request.dart';
import 'package:carman/models/refuel_info.dart';
import 'package:carman/models/vehicle.dart';

class BackendAdapter {
  static Future<AuthResponse?> login(String username, String password) async {
    final request = LoginRequest(username: username, password: password);

    final response = await ApiClient.post(
      '/auth/login',
      headers: {'Content-Type': 'application/json'},
      body: convert.jsonEncode(request.toJson()),
    );

    if (response.statusCode == 200) {
      return AuthResponse.fromJson(convert.jsonDecode(response.body));
    }

    if (response.statusCode == 401) throw 'Invalid username or password';

    throw Exception('Login failed: ${response.statusCode}');
  }

  static Future<AuthResponse?> register(
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
      return AuthResponse.fromJson(convert.jsonDecode(response.body));
    }

    if (response.statusCode == 409) {
      throw 'Username is not available';
    }

    throw Exception('Register failed: ${response.statusCode}');
  }

  static Future<AuthResponse?> refreshToken(String refreshToken) async {
    final response = await ApiClient.post(
      '/auth/refresh',
      headers: {'Content-Type': 'application/json'},
      body: convert.jsonEncode({'refreshToken': refreshToken}),
    );

    if (response.statusCode == 200) {
      return AuthResponse.fromJson(convert.jsonDecode(response.body));
    }

    if (response.statusCode == 401 || response.statusCode == 403) {
      return null;
    }

    throw Exception('Refresh failed: ${response.statusCode}');
  }

  static Future<void> setUserSelectedTheme(
    String themeKey,
    Map<String, String> headers,
  ) async {
    await ApiClient.put(
      '/users/selected-theme?key=$themeKey',
      headers: headers,
    );
  }

  static Future<void> setUserSelectedLanguage(
    String languageCode,
    Map<String, String> headers,
  ) async {
    await ApiClient.put(
      '/users/selected-language?code=$languageCode',
      headers: headers,
    );
  }

  static Future<void> setUserSelectedCurrency(
    String currencyCode,
    Map<String, String> headers,
  ) async {
    await ApiClient.put(
      '/users/selected-currency?code=$currencyCode',
      headers: headers,
    );
  }

  static Future<List<Event>> getEventsByVehicle(
    String vehicleId,
    Map<String, String> headers,
  ) async {
    final response = await ApiClient.get(
      '/events?vehicle=$vehicleId',
      headers: headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = convert.jsonDecode(response.body);
      return data.map((json) => Event.fromJson(json)).toList();
    }

    throw Exception('Failed to fetch events: ${response.statusCode}');
  }

  static Future<Event> getEventById(
    String id,
    Map<String, String> headers,
  ) async {
    final response = await ApiClient.get('/events/$id', headers: headers);

    if (response.statusCode == 200) {
      return Event.fromJson(convert.jsonDecode(response.body));
    }

    if (response.statusCode == 404) {
      throw Exception('Event not found');
    }

    throw Exception('Failed to fetch event: ${response.statusCode}');
  }

  static Future<Event> createEvent({
    required String vehicleId,
    required String type,
    String? description,
    double? odometer,
    int? costValueMinor,
    String? costCurrencyCode,
    DateTime? occurredAt,
    RefuelInfo? refuelInfo,
    required Map<String, String> headers,
  }) async {
    final body = convert.jsonEncode({
      'vehicle': {'id': vehicleId},
      'type': type,
      'description': description,
      'odometer': odometer,
      'costValueMinor': costValueMinor,
      'costCurrencyCode': costCurrencyCode,
      if (occurredAt != null)
        'occurredAt': occurredAt.toUtc().toIso8601String(),
      if (refuelInfo != null) 'refuelInfo': refuelInfo.toJson(),
    });

    final response = await ApiClient.post(
      '/events',
      headers: headers,
      body: body,
    );

    if (response.statusCode == 201) {
      return Event.fromJson(convert.jsonDecode(response.body));
    }

    throw Exception('Failed to create event: ${response.statusCode}');
  }

  static Future<Event> updateEvent({
    required String eventId,
    required String type,
    String? description,
    double? odometer,
    int? costValueMinor,
    String? costCurrencyCode,
    DateTime? occurredAt,
    RefuelInfo? refuelInfo,
    required Map<String, String> headers,
  }) async {
    final body = convert.jsonEncode({
      'type': type,
      'description': description,
      'odometer': odometer,
      'costValueMinor': costValueMinor,
      'costCurrencyCode': costCurrencyCode,
      if (occurredAt != null)
        'occurredAt': occurredAt.toUtc().toIso8601String(),
      if (refuelInfo != null) 'refuelInfo': refuelInfo.toJson(),
    });

    final response = await ApiClient.put(
      '/events/$eventId',
      headers: headers,
      body: body,
    );

    if (response.statusCode == 200) {
      return Event.fromJson(convert.jsonDecode(response.body));
    }

    throw Exception('Failed to update event: ${response.statusCode}');
  }

  static Future<void> deleteEvent(
    String id,
    Map<String, String> headers,
  ) async {
    final response = await ApiClient.delete('/events/$id', headers: headers);

    if (response.statusCode == 204) {
      return;
    }

    if (response.statusCode == 404) {
      throw Exception('Event not found');
    }

    throw Exception('Failed to delete event: ${response.statusCode}');
  }

  static Future<Vehicle?> createVehicle({
    required String type,
    required String make,
    required String model,
    required String year,
    required Map<String, String> headers,
  }) async {
    final body = convert.jsonEncode({
      'type': type,
      'make': make,
      'model': model,
      'year': year,
    });

    final response = await ApiClient.post(
      '/vehicles',
      headers: headers,
      body: body,
    );

    if (response.statusCode == 201) {
      return Vehicle.fromResponseBody(response.body);
    }

    throw Exception('Failed to create vehicle: ${response.statusCode}');
  }

  static Future<List<Vehicle>> getAllVehicles(
    Map<String, String> headers,
  ) async {
    final response = await ApiClient.get('/vehicles', headers: headers);

    if (response.statusCode == 200) {
      final List<dynamic> data = convert.jsonDecode(response.body);
      return data.map((json) => Vehicle.fromJson(json)).toList();
    }

    throw Exception('Failed to fetch vehicles: ${response.statusCode}');
  }

  static Future<Vehicle> getVehicleById(
    String id,
    Map<String, String> headers,
  ) async {
    final response = await ApiClient.get('/vehicles/$id', headers: headers);

    if (response.statusCode == 200) {
      return Vehicle.fromResponseBody(response.body);
    }

    if (response.statusCode == 404) {
      throw Exception('Vehicle not found');
    }

    throw Exception('Failed to fetch vehicle: ${response.statusCode}');
  }

  static Future<void> deleteVehicle(
    String id,
    Map<String, String> headers,
  ) async {
    final response = await ApiClient.delete('/vehicles/$id', headers: headers);

    if (response.statusCode == 204) {
      return;
    }

    if (response.statusCode == 404) {
      throw Exception('Vehicle not found');
    }

    throw Exception('Failed to delete vehicle: ${response.statusCode}');
  }

  static Future<Vehicle?> getSelectedVehicle(
    Map<String, String> headers,
  ) async {
    final response = await ApiClient.get(
      '/users/selected-vehicle',
      headers: headers,
    );

    if (response.statusCode == 200) {
      return Vehicle.fromResponseBody(response.body);
    }

    if (response.statusCode == 204) {
      return null;
    }

    throw Exception('Failed to fetch selected vehicle: ${response.statusCode}');
  }

  static Future<void> setSelectedVehicle(
    String id,
    Map<String, String> headers,
  ) async {
    final response = await ApiClient.put(
      '/users/selected-vehicle?id=$id',
      headers: headers,
    );

    if (response.statusCode == 200) {
      return;
    }

    throw Exception(
      'Failed to update selected vehicle: ${response.statusCode}',
    );
  }
}

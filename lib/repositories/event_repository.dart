import 'dart:convert' as convert;

import '../clients/api_client.dart';
import '../models/event.dart';
import '../services/auth_service.dart';

class EventRepository {
  static final AuthService _authService = AuthService();

  static List<Event> _parseEvents(String body) {
    final List<dynamic> data = convert.jsonDecode(body);
    return data.map((json) => Event.fromJson(json)).toList();
  }

  static Future<List<Event>> getEventsByVehicle(String vehicleId) async {
    final response = await ApiClient.get(
      '/events?vehicle=$vehicleId',
      headers: await _authService.getAuthHeaders(),
    );

    if (response.statusCode == 200) {
      return _parseEvents(response.body);
    }

    throw Exception('Failed to fetch events: ${response.statusCode}');
  }

  static Future<Event> getEventById(String id) async {
    final response = await ApiClient.get(
      '/events/$id',
      headers: await _authService.getAuthHeaders(),
    );

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
  }) async {
    final body = convert.jsonEncode({
      'vehicle': {'id': vehicleId},
      'type': type,
      'description': description,
      'odometer': odometer,
    });

    final response = await ApiClient.post(
      '/events',
      headers: await _authService.getAuthHeaders(),
      body: body,
    );

    if (response.statusCode == 201) {
      return Event.fromJson(convert.jsonDecode(response.body));
    }

    throw Exception('Failed to create event: ${response.statusCode}');
  }

  static Future<void> deleteEvent(String id) async {
    final response = await ApiClient.delete(
      '/events/$id',
      headers: await _authService.getAuthHeaders(),
    );

    if (response.statusCode == 204) {
      return;
    }

    if (response.statusCode == 404) {
      throw Exception('Event not found');
    }

    throw Exception('Failed to delete event: ${response.statusCode}');
  }
}

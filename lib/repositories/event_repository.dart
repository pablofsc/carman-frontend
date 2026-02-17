import 'dart:convert' as convert;

import 'package:carman/adapters/api_client.dart';
import 'package:carman/models/event.dart';

class EventRepository {
  static List<Event> _parseEvents(String body) {
    final List<dynamic> data = convert.jsonDecode(body);
    return data.map((json) => Event.fromJson(json)).toList();
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
      return _parseEvents(response.body);
    }

    throw Exception('Failed to fetch events: ${response.statusCode}');
  }

  static Future<Event> getEventById(
    String id,
    Map<String, String> headers,
  ) async {
    final response = await ApiClient.get(
      '/events/$id',
      headers: headers,
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
    required Map<String, String> headers,
  }) async {
    final body = convert.jsonEncode({
      'vehicle': {'id': vehicleId},
      'type': type,
      'description': description,
      'odometer': odometer,
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

  static Future<void> deleteEvent(
    String id,
    Map<String, String> headers,
  ) async {
    final response = await ApiClient.delete(
      '/events/$id',
      headers: headers,
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

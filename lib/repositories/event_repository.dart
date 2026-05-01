import 'package:carman/adapters/backend_adapter.dart';
import 'package:carman/models/event.dart';
import 'package:carman/models/refuel_info.dart';

class EventRepository {
  static Future<List<Event>> getEventsByVehicle(
    String vehicleId,
    Map<String, String> headers,
  ) async {
    return BackendAdapter.getEventsByVehicle(vehicleId, headers);
  }

  static Future<Event> getEventById(
    String id,
    Map<String, String> headers,
  ) async {
    return BackendAdapter.getEventById(id, headers);
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
    return BackendAdapter.createEvent(
      vehicleId: vehicleId,
      type: type,
      description: description,
      odometer: odometer,
      costValueMinor: costValueMinor,
      costCurrencyCode: costCurrencyCode,
      occurredAt: occurredAt,
      refuelInfo: refuelInfo,
      headers: headers,
    );
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
    return BackendAdapter.updateEvent(
      eventId: eventId,
      type: type,
      description: description,
      odometer: odometer,
      costValueMinor: costValueMinor,
      costCurrencyCode: costCurrencyCode,
      occurredAt: occurredAt,
      refuelInfo: refuelInfo,
      headers: headers,
    );
  }

  static Future<void> deleteEvent(
    String id,
    Map<String, String> headers,
  ) async {
    return BackendAdapter.deleteEvent(id, headers);
  }
}

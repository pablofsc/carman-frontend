import 'dart:convert' as convert;

import 'package:carman/adapters/api_client.dart';
import 'package:carman/models/vehicle.dart';

class VehicleRepository {
  static List<Vehicle> _parseVehicles(String body) {
    final List<dynamic> data = convert.jsonDecode(body);
    return data.map((json) => Vehicle.fromJson(json)).toList();
  }

  static Future<Vehicle?> createVehicleFromInstance(
    Vehicle vehicle,
    Map<String, String> headers,
  ) async {
    return createVehicle(
      type: vehicle.type,
      make: vehicle.make,
      model: vehicle.model,
      year: vehicle.year,
      headers: headers,
    );
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
    final response = await ApiClient.get(
      '/vehicles',
      headers: headers,
    );

    if (response.statusCode == 200) {
      return _parseVehicles(response.body);
    }

    throw Exception('Failed to fetch vehicles: ${response.statusCode}');
  }

  static Future<Vehicle> getVehicleById(
    String id,
    Map<String, String> headers,
  ) async {
    final response = await ApiClient.get(
      '/vehicles/$id',
      headers: headers,
    );

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
    final response = await ApiClient.delete(
      '/vehicles/$id',
      headers: headers,
    );

    if (response.statusCode == 204) {
      return;
    }

    if (response.statusCode == 404) {
      throw Exception('Vehicle not found');
    }

    throw Exception('Failed to delete vehicle: ${response.statusCode}');
  }

  static Future<Vehicle?> getSelected(Map<String, String> headers) async {
    // TODO: maybe move this to a "UserRepository"?

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

  static Future<void> setSelected(
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

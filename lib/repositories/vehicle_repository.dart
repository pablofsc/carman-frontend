import 'dart:convert' as convert;

import '../clients/api_client.dart';
import '../models/vehicle.dart';
import '../services/auth_service.dart';

class VehicleRepository {
  static final AuthService _authService = AuthService();

  static List<Vehicle> _parseVehicles(String body) {
    final List<dynamic> data = convert.jsonDecode(body);
    return data.map((json) => Vehicle.fromJson(json)).toList();
  }

  static Future<Vehicle?> createVehicleFromInstance(Vehicle vehicle) async {
    return createVehicle(
      type: vehicle.type,
      make: vehicle.make,
      model: vehicle.model,
      year: vehicle.year,
    );
  }

  static Future<Vehicle?> createVehicle({
    required String type,
    required String make,
    required String model,
    required String year,
  }) async {
    final body = convert.jsonEncode({
      'type': type,
      'make': make,
      'model': model,
      'year': year,
    });

    final response = await ApiClient.post(
      '/vehicles',
      headers: await _authService.getAuthHeaders(),
      body: body,
    );

    if (response.statusCode == 201) {
      return Vehicle.fromResponseBody(response.body);
    }

    throw Exception('Failed to create vehicle: ${response.statusCode}');
  }

  static Future<List<Vehicle>> getAllVehicles() async {
    final response = await ApiClient.get(
      '/vehicles',
      headers: await _authService.getAuthHeaders(),
    );

    if (response.statusCode == 200) {
      return _parseVehicles(response.body);
    }

    throw Exception('Failed to fetch vehicles: ${response.statusCode}');
  }

  static Future<Vehicle> getVehicleById(String id) async {
    final response = await ApiClient.get(
      '/vehicles/$id',
      headers: await _authService.getAuthHeaders(),
    );

    if (response.statusCode == 200) {
      return Vehicle.fromResponseBody(response.body);
    }

    if (response.statusCode == 404) {
      throw Exception('Vehicle not found');
    }

    throw Exception('Failed to fetch vehicle: ${response.statusCode}');
  }

  static Future<void> deleteVehicle(String id) async {
    final response = await ApiClient.delete(
      '/vehicles/$id',
      headers: await _authService.getAuthHeaders(),
    );

    if (response.statusCode == 204) {
      return;
    }

    if (response.statusCode == 404) {
      throw Exception('Vehicle not found');
    }

    throw Exception('Failed to delete vehicle: ${response.statusCode}');
  }
}

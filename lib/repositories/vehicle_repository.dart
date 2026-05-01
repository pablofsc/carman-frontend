import 'package:carman/adapters/backend_adapter.dart';
import 'package:carman/models/vehicle.dart';

class VehicleRepository {
  static Future<Vehicle?> createVehicleFromInstance(
    Vehicle vehicle,
    Map<String, String> headers,
  ) async {
    return BackendAdapter.createVehicle(
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
    return BackendAdapter.createVehicle(
      type: type,
      make: make,
      model: model,
      year: year,
      headers: headers,
    );
  }

  static Future<List<Vehicle>> getAllVehicles(
    Map<String, String> headers,
  ) async {
    return BackendAdapter.getAllVehicles(headers);
  }

  static Future<Vehicle> getVehicleById(
    String id,
    Map<String, String> headers,
  ) async {
    return BackendAdapter.getVehicleById(id, headers);
  }

  static Future<void> deleteVehicle(
    String id,
    Map<String, String> headers,
  ) async {
    return BackendAdapter.deleteVehicle(id, headers);
  }

  static Future<Vehicle?> getSelected(Map<String, String> headers) async {
    return BackendAdapter.getSelectedVehicle(headers);
  }

  static Future<void> setSelected(
    String id,
    Map<String, String> headers,
  ) async {
    return BackendAdapter.setSelectedVehicle(id, headers);
  }
}

import 'package:flutter/material.dart';

import '../models/vehicle.dart';
import '../repositories/vehicle_repository.dart';
import 'selected_vehicle_service.dart';

class VehiclesService {
  static final VehiclesService _instance = VehiclesService._internal();

  late final ValueNotifier<List<Vehicle>> _vehiclesNotifier;
  late final ValueNotifier<bool> _isLoadingNotifier;

  VehiclesService._internal() {
    _vehiclesNotifier = ValueNotifier<List<Vehicle>>([]);
    _isLoadingNotifier = ValueNotifier<bool>(false);
  }

  factory VehiclesService() {
    return _instance;
  }

  final SelectedVehicleService _selVehService = SelectedVehicleService();

  ValueNotifier<List<Vehicle>> get vehiclesNotifier => _vehiclesNotifier;
  ValueNotifier<bool> get isLoadingNotifier => _isLoadingNotifier;

  List<Vehicle> get vehicles => _vehiclesNotifier.value;
  bool get isLoading => _isLoadingNotifier.value;

  Future<void> refreshVehicles() async {
    try {
      _isLoadingNotifier.value = true;
      final vehicles = await VehicleRepository.getAllVehicles();
      _vehiclesNotifier.value = vehicles;
    } catch (e) {
      debugPrint('Failed to load vehicles: $e');
    } finally {
      _isLoadingNotifier.value = false;
    }
  }

  Future<Vehicle?> createVehicle({
    required String type,
    required String make,
    required String model,
    required String year,
  }) async {
    try {
      final wasEmpty = vehicles.isEmpty;

      final newVehicle = await VehicleRepository.createVehicle(
        type: type,
        make: make,
        model: model,
        year: year,
      );

      await refreshVehicles();

      if (wasEmpty && newVehicle != null) {
        await _selVehService.setSelectedVehicle(newVehicle);
      }

      return newVehicle;
    } catch (e) {
      debugPrint('Failed to create vehicle: $e');
      rethrow;
    }
  }

  Future<void> deleteVehicle(String vehicleId) async {
    try {
      await VehicleRepository.deleteVehicle(vehicleId);
      await refreshVehicles();
    } catch (e) {
      debugPrint('Failed to delete vehicle: $e');
      rethrow;
    }
  }

  void dispose() {
    _vehiclesNotifier.dispose();
    _isLoadingNotifier.dispose();
  }
}

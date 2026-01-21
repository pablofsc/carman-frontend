import 'package:flutter/material.dart';

import '../models/vehicle.dart';
import '../repositories/vehicle_repository.dart';

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

  ValueNotifier<List<Vehicle>> get vehiclesNotifier => _vehiclesNotifier;
  ValueNotifier<bool> get isLoadingNotifier => _isLoadingNotifier;

  List<Vehicle> get vehicles => _vehiclesNotifier.value;
  bool get isLoading => _isLoadingNotifier.value;

  Future<void> fetchVehicles() async {
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

  Future<void> deleteVehicle(String vehicleId) async {
    try {
      await VehicleRepository.deleteVehicle(vehicleId);
      final vehicles = await VehicleRepository.getAllVehicles();
      _vehiclesNotifier.value = vehicles;
    } catch (e) {
      debugPrint('Failed to delete vehicle: $e');
      rethrow;
    }
  }

  void notifyVehiclesChanged(List<Vehicle> vehicles) {
    _vehiclesNotifier.value = vehicles;
  }

  void dispose() {
    _vehiclesNotifier.dispose();
    _isLoadingNotifier.dispose();
  }
}

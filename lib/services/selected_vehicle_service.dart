import 'dart:convert' as convert;

import 'package:flutter/material.dart';

import '../clients/api_client.dart';
import '../models/vehicle.dart';
import '../services/auth_service.dart';

class SelectedVehicleService {
  static final SelectedVehicleService _instance =
      SelectedVehicleService._internal();

  final AuthService _authService = AuthService();
  late final ValueNotifier<Vehicle?> _selVehNotifier;

  SelectedVehicleService._internal() {
    _selVehNotifier = ValueNotifier<Vehicle?>(null);
  }

  factory SelectedVehicleService() {
    return _instance;
  }

  ValueNotifier<Vehicle?> get selVehNotifier => _selVehNotifier;

  Vehicle? get selectedVehicle => _selVehNotifier.value;

  Future<void> setSelectedVehicle(Vehicle? vehicle) async {
    notifySelectedVehicleChanged(vehicle);
    String? id = vehicle?.id;

    if (vehicle != null && id != null) {
      try {
        await ApiClient.put(
          '/users/selected-vehicle?id=$id',
          headers: await _authService.getAuthHeaders(),
        );
      } catch (e) {
        debugPrint('Failed to update selected vehicle on backend: $e');
      }
    }
  }

  Future<void> fetchSelectedVehicle() async {
    try {
      final response = await ApiClient.get(
        '/users/selected-vehicle',
        headers: await _authService.getAuthHeaders(),
      );

      if (response.statusCode == 200) {
        final data = convert.jsonDecode(response.body) as Map<String, dynamic>;
        notifySelectedVehicleChanged(Vehicle.fromJson(data));
      } else if (response.statusCode == 204) {
        // No selected vehicle
        notifySelectedVehicleChanged(null);
      }
    } catch (e) {
      debugPrint('Failed to load selected vehicle from backend: $e');
    }
  }

  void notifySelectedVehicleChanged(Vehicle? vehicle) {
    _selVehNotifier.value = vehicle;
  }

  void dispose() {
    _selVehNotifier.dispose();
  }
}

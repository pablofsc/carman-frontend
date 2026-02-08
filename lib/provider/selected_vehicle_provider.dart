import 'package:flutter_riverpod/flutter_riverpod.dart' as riverpod;

import 'package:carman/models/vehicle.dart';
import 'package:carman/repositories/vehicle_repository.dart';

final selectedVehicleProvider =
    riverpod.AsyncNotifierProvider<SelectedVehicleNotifier, Vehicle?>(
      SelectedVehicleNotifier.new,
    );

class SelectedVehicleNotifier extends riverpod.AsyncNotifier<Vehicle?> {
  @override
  Future<Vehicle?> build() async {
    return await VehicleRepository.getSelected();
  }

  Future<void> set(String id) async {
    // TODO: improve this
    final vehicle = await VehicleRepository.getVehicleById(id);

    state = riverpod.AsyncData(vehicle);

    await VehicleRepository.setSelected(id);
  }
}

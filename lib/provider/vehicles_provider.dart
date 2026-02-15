import 'package:flutter_riverpod/flutter_riverpod.dart' as riverpod;

import 'package:carman/models/vehicle.dart';
import 'package:carman/provider/auth_provider.dart';
import 'package:carman/repositories/vehicle_repository.dart';

final vehiclesProvider =
    riverpod.AsyncNotifierProvider<VehiclesNotifier, List<Vehicle>>(
      VehiclesNotifier.new,
    );

class VehiclesNotifier extends riverpod.AsyncNotifier<List<Vehicle>> {
  @override
  Future<List<Vehicle>> build() async {
    return VehicleRepository.getAllVehicles(
      await ref.read(authProvider.notifier).getHeaders(),
    );
  }

  Future<void> create({
    required String type,
    required String make,
    required String model,
    required String year,
  }) async {
    await VehicleRepository.createVehicle(
      type: type,
      make: make,
      model: model,
      year: year,
      headers: await ref.read(authProvider.notifier).getHeaders(),
    );

    ref.invalidateSelf();
  }

  Future<void> remove(String id) async {
    await VehicleRepository.deleteVehicle(
      id,
      await ref.read(authProvider.notifier).getHeaders(),
    );

    ref.invalidateSelf();
  }
}

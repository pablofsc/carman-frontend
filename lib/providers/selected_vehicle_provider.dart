import 'package:flutter_riverpod/flutter_riverpod.dart' as riverpod;

import 'package:carman/models/vehicle.dart';
import 'package:carman/repositories/vehicle_repository.dart';
import 'package:carman/providers/vehicles_provider.dart';
import 'package:carman/providers/auth_provider.dart';

final selectedVehicleProvider =
    riverpod.AsyncNotifierProvider<SelectedVehicleNotifier, Vehicle?>(
      SelectedVehicleNotifier.new,
    );

class SelectedVehicleNotifier extends riverpod.AsyncNotifier<Vehicle?> {
  @override
  Future<Vehicle?> build() async {
    final selected = (await VehicleRepository.getSelected(
      await ref.read(authProvider.notifier).getHeaders(),
    ))?.id;

    if (selected == null) return null;

    return ref
        .watch(vehiclesProvider)
        .maybeWhen(
          data: (vehicles) => vehicles.firstWhere((v) => v.id == selected),
          orElse: () => null,
        );
  }

  Future<void> set(String id) async {
    // TODO: improve this
    final vehicles = ref.read(vehiclesProvider).requireValue;
    final selected = vehicles.firstWhere((v) => v.id == id);

    state = riverpod.AsyncData(selected);

    VehicleRepository.setSelected(
      id,
      await ref.read(authProvider.notifier).getHeaders(),
    );
  }
}

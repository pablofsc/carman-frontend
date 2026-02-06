import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' as riverpod;

import '../elements/vehicle_information.dart';
import '../elements/create_vehicle_dialog.dart';
import 'package:carman/provider/vehicles_provider.dart';

class VehiclePage extends riverpod.ConsumerStatefulWidget {
  const VehiclePage({super.key});

  @override
  riverpod.ConsumerState<VehiclePage> createState() => _VehiclePageState();
}

class _VehiclePageState extends riverpod.ConsumerState<VehiclePage> {
  @override
  Widget build(BuildContext context) {
    final vehicles = ref.watch(vehiclesProvider);

    return vehicles.when(
      loading: () => const Center(child: CircularProgressIndicator()),

      error: (e, _) => Center(child: Text(e.toString())),

      data: (vehicles) {
        if (vehicles.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.directions_car,
                    size: 80,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'No vehicles yet',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Add your first vehicle to get started',
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => CreateVehicleDialog.show(context),
                    icon: const Icon(Icons.add),
                    label: const Text('Add Vehicle'),
                  ),
                ]
              ),
            ),
          );
        }

        return SingleChildScrollView(
          child: Column(children: const [VehicleInformation()]),
        );
      },
    );
  }
}

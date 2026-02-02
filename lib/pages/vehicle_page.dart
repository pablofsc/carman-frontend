import 'package:flutter/material.dart';

import '../elements/vehicle_information.dart';
import '../elements/create_vehicle_dialog.dart';
import '../services/vehicles_service.dart';

class VehiclePage extends StatefulWidget {
  const VehiclePage({super.key});

  @override
  State<VehiclePage> createState() => _VehiclePageState();
}

class _VehiclePageState extends State<VehiclePage> {
  final VehiclesService _vehiclesService = VehiclesService();

  @override
  void initState() {
    super.initState();
    _vehiclesService.refreshVehicles();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([
        _vehiclesService.isLoadingNotifier,
        _vehiclesService.vehiclesNotifier,
      ]),
      builder: (context, child) {
        final vehicles = _vehiclesService.vehicles;

        if (_vehiclesService.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

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

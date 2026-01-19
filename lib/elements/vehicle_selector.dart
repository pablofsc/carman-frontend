import 'package:flutter/material.dart';

import '../models/vehicle.dart';
import '../repositories/vehicle_repository.dart';
import '../services/selected_vehicle_service.dart';

class VehicleSelector extends StatefulWidget {
  final Function(Vehicle?)? onVehicleSelected;

  const VehicleSelector({super.key, this.onVehicleSelected});

  @override
  State<VehicleSelector> createState() => _VehicleSelectorState();
}

class _VehicleSelectorState extends State<VehicleSelector> {
  final SelectedVehicleService _selVehService = SelectedVehicleService();

  late Future<List<Vehicle>> _vehiclesFuture;
  late String? _selectedVehicleId;

  @override
  void initState() {
    super.initState();

    _loadSelectedVehicle();
    _vehiclesFuture = _fetchVehicles();
  }

  Future<void> _loadSelectedVehicle() async {
    await _selVehService.fetchSelectedVehicle();

    if (mounted) {
      setState(() {
        _selectedVehicleId = _selVehService.selectedVehicle?.id;
      });
    }
  }

  Future<List<Vehicle>> _fetchVehicles() async {
    return VehicleRepository.getAllVehicles();
  }

  void _showVehicleSelector(BuildContext context, List<Vehicle> vehicles) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Select a Vehicle',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
              ListView.builder(
                shrinkWrap: true,
                itemCount: vehicles.length,
                itemBuilder: (BuildContext context, int index) {
                  final vehicle = vehicles[index];

                  return ListTile(
                    leading: const Icon(Icons.directions_car),
                    title: Text(vehicle.displayName),
                    subtitle: Text(
                      '${vehicle.year} • ${vehicle.type}  • ${vehicle.id}',
                    ),
                    trailing: vehicle.id == _selectedVehicleId
                        ? Icon(
                            Icons.check,
                            color: Theme.of(context).colorScheme.primary,
                          )
                        : null,
                    onTap: () async {
                      await _setSelectedVehicle(vehicle);

                      if (context.mounted) {
                        Navigator.pop(context);
                      }
                    },
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _setSelectedVehicle(Vehicle vehicle) async {
    if (mounted) {
      setState(() {
        _selectedVehicleId = vehicle.id;
      });

      await _selVehService.setSelectedVehicle(vehicle);
      widget.onVehicleSelected?.call(vehicle);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Vehicle>>(
      future: _vehiclesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            width: 200, child: LinearProgressIndicator(),
          );
        }

        if (snapshot.hasError) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TextButton(
              onPressed: () =>
                  setState(() => _vehiclesFuture = _fetchVehicles()),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('ERROR', style: TextStyle(fontWeight: FontWeight.bold)),
                  Icon(Icons.arrow_drop_down),
                ],
              ),
            ),
          );
        }

        final vehicles = snapshot.data ?? [];

        if (vehicles.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TextButton(
              onPressed: null,
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'NO VEHICLES',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Icon(Icons.arrow_drop_down),
                ],
              ),
            ),
          );
        }

        final selectedVehicle = vehicles.firstWhere(
          (v) => v.id == _selectedVehicleId,
          orElse: () => vehicles.first,
        );

        return TextButton(
          onPressed: () => _showVehicleSelector(context, vehicles),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.directions_car),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(
                  selectedVehicle.displayName.toUpperCase(),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),

              const Icon(Icons.arrow_drop_down),
            ],
          ),
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' as riverpod;

import '../models/vehicle.dart';
import '../services/selected_vehicle_service.dart';
import 'delete_vehicle_dialog.dart';
import 'create_vehicle_dialog.dart';
import 'package:carman/provider/vehicles_provider.dart';

class VehicleSelector extends riverpod.ConsumerStatefulWidget {
  final Function(Vehicle?)? onVehicleSelected;

  const VehicleSelector({super.key, this.onVehicleSelected});

  @override
  riverpod.ConsumerState<VehicleSelector> createState() => _VehSelState();
}

class _VehSelState extends riverpod.ConsumerState<VehicleSelector> {
  final SelectedVehicleService _selVehService = SelectedVehicleService();

  @override
  void initState() {
    super.initState();

    _selVehService.fetchSelectedVehicle();
  }

  Future<void> _setSelectedVehicle(Vehicle vehicle) async {
    await _selVehService.setSelectedVehicle(vehicle);
    widget.onVehicleSelected?.call(vehicle);
  }

  void _showVehicleSelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return riverpod.Consumer(
          builder: (context, ref, _) {
            final vehiclesAsync = ref.watch(vehiclesProvider);

            return vehiclesAsync.when(
              loading: () => const Padding(
                padding: EdgeInsets.all(24),
                child: CircularProgressIndicator(),
              ),
              error: (e, _) => Text(e.toString()),
              data: (vehicles) {
                return ValueListenableBuilder<Vehicle?>(
                  valueListenable: _selVehService.selVehNotifier,
                  builder: (context, selectedVehicle, _) {
                    return SafeArea(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Text(
                              'Select a Vehicle',
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                          ),
                          ConstrainedBox(
                            constraints: BoxConstraints(
                              maxHeight:
                                  MediaQuery.of(context).size.height * 0.7,
                            ),
                            child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: vehicles.length,
                              itemBuilder: (context, index) {
                                final vehicle = vehicles[index];

                                return ListTile(
                                  leading: const Icon(Icons.directions_car),
                                  title: Text(vehicle.displayName),
                                  subtitle: Text(
                                    '${vehicle.year} • ${vehicle.type}',
                                  ),
                                  trailing: vehicle.id == selectedVehicle?.id
                                      ? Icon(
                                          Icons.check,
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.primary,
                                        )
                                      : null,
                                  onTap: () async {
                                    await _setSelectedVehicle(vehicle);
                                    if (context.mounted) {
                                      Navigator.pop(context);
                                    }
                                  },
                                  onLongPress: () {
                                    DeleteVehicleDialog.show(context, vehicle);
                                  },
                                );
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(
                                  context,
                                ).colorScheme.surfaceContainer,
                              ),
                              onPressed: () =>
                                  CreateVehicleDialog.show(context),
                              child: const Text('Add new vehicle'),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final vehicles = ref.watch(vehiclesProvider);

    return vehicles.when(
      loading: () => const Center(child: CircularProgressIndicator()),

      error: (e, _) => Center(child: Text(e.toString())),

      data: (vehicles) {
        return ValueListenableBuilder<Vehicle?>(
          valueListenable: _selVehService.selVehNotifier,
          builder: (context, selectedVehicle, _) {
            final displayText = vehicles.isEmpty
                ? 'No vehicles available'
                : selectedVehicle != null
                ? selectedVehicle.displayName.toUpperCase()
                : 'Select a vehicle';

            return TextButton(
              onPressed: vehicles.isEmpty
                  ? null
                  : () => _showVehicleSelector(context),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.directions_car),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(
                      displayText,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Icon(Icons.arrow_drop_down),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

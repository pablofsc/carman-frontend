import 'package:flutter/material.dart';

import '../models/vehicle.dart';
import '../services/selected_vehicle_service.dart';
import '../services/vehicles_service.dart';
import 'delete_vehicle_dialog.dart';
import 'create_vehicle_dialog.dart';

class VehicleSelector extends StatefulWidget {
  final Function(Vehicle?)? onVehicleSelected;

  const VehicleSelector({super.key, this.onVehicleSelected});

  @override
  State<VehicleSelector> createState() => _VehicleSelectorState();
}

class _VehicleSelectorState extends State<VehicleSelector> {
  final SelectedVehicleService _selVehService = SelectedVehicleService();
  final VehiclesService _vehiclesService = VehiclesService();

  @override
  void initState() {
    super.initState();

    _selVehService.fetchSelectedVehicle();
    _vehiclesService.refreshVehicles();
  }

  Future<void> _setSelectedVehicle(Vehicle vehicle) async {
    await _selVehService.setSelectedVehicle(vehicle);
    widget.onVehicleSelected?.call(vehicle);
  }

  void _showVehicleSelector(BuildContext context, List<Vehicle> vehicles) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return ValueListenableBuilder<List<Vehicle>>(
          valueListenable: _vehiclesService.vehiclesNotifier,
          builder: (context, vehicles, child) {
            return ValueListenableBuilder<Vehicle?>(
              valueListenable: _selVehService.selVehNotifier,
              builder: (context, selectedVehicle, _) {
                return SafeArea(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text(
                          'Select a Vehicle',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                      ),
                      ConstrainedBox(
                        constraints: BoxConstraints(
                          maxHeight: MediaQuery.of(context).size.height * 0.7,
                        ),
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: vehicles.length,
                          itemBuilder: (BuildContext context, int index) {
                            final vehicle = vehicles[index];

                            return ListTile(
                              leading: Icon(Icons.directions_car),
                              title: Text(vehicle.displayName),
                              subtitle: Text(
                                '${vehicle.year} • ${vehicle.type} • ${vehicle.id}',
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
                        padding: EdgeInsets.all(16.0),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(
                              context,
                            ).colorScheme.surfaceContainer,
                          ),
                          onPressed: () =>
                            CreateVehicleDialog.show(context),
                          child: Text('Add new vehicle'),
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
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<Vehicle>>(
      valueListenable: _vehiclesService.vehiclesNotifier,
      builder: (context, vehicles, child) {
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
                  : () => _showVehicleSelector(context, vehicles),
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

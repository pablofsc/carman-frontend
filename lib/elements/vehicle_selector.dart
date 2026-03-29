import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' as riverpod;

import 'package:carman/elements/delete_vehicle_dialog.dart';
import 'package:carman/pages/create_vehicle_page.dart';
import 'package:carman/providers/vehicles_provider.dart';
import 'package:carman/providers/selected_vehicle_provider.dart';
import 'package:carman/extensions/l10n_extension.dart';

class VehicleSelector extends riverpod.ConsumerStatefulWidget {
  const VehicleSelector({super.key});

  @override
  riverpod.ConsumerState<VehicleSelector> createState() => _VehSelState();
}

class _VehSelState extends riverpod.ConsumerState<VehicleSelector> {
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
                final selectedVehicle = ref
                    .watch(selectedVehicleProvider)
                    .asData
                    ?.value;

                return SafeArea(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          context.l10n.selectVehicle,
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
                                await ref
                                    .read(selectedVehicleProvider.notifier)
                                    .set(vehicle.id);

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
                          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const CreateVehiclePage())),
                          child: Text(context.l10n.addNewVehicle),
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
    final vehicles = ref.watch(vehiclesProvider);

    return vehicles.when(
      loading: () => const Center(child: CircularProgressIndicator()),

      error: (e, _) => Center(child: Text(e.toString())),

      data: (vehicles) {
        final selectedVehicle = ref
            .watch(selectedVehicleProvider)
            .asData
            ?.value;

        final displayText = vehicles.isEmpty
            ? context.l10n.noVehiclesAvailable
            : selectedVehicle != null
            ? selectedVehicle.displayName.toUpperCase()
            : context.l10n.selectVehicle;

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
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' as riverpod;

import 'package:carman/provider/selected_vehicle_provider.dart';

class VehicleInformation extends riverpod.ConsumerWidget {
  const VehicleInformation({super.key});

  @override
  Widget build(BuildContext context, riverpod.WidgetRef ref) {
    final selectedVehicleAsync = ref.watch(selectedVehicleProvider);

    return selectedVehicleAsync.when(
      data: (vehicle) {
        if (vehicle == null) {
          return Card(
            margin: const EdgeInsets.all(16.0),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: Text(
                  'No vehicle selected',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ),
          );
        }

        return Card(
          margin: const EdgeInsets.all(16.0),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.directions_car,
                      color: Theme.of(context).colorScheme.primary,
                      size: 32,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            vehicle.displayName,
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          Text(
                            vehicle.year,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: Theme.of(context).colorScheme.outline,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _InfoRow(label: 'Make', value: vehicle.make),
                const SizedBox(height: 12),
                _InfoRow(label: 'Model', value: vehicle.model),
                const SizedBox(height: 12),
                _InfoRow(label: 'Type', value: vehicle.type),
                const SizedBox(height: 12),
                _InfoRow(label: 'ID', value: vehicle.id),
              ],
            ),
          ),
        );
      },
      loading: () => Card(
        margin: const EdgeInsets.all(16.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(child: CircularProgressIndicator()),
        ),
      ),
      error: (error, stack) => Card(
        margin: const EdgeInsets.all(16.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Text(
              'No vehicle selected',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.outline,
          ),
        ),
        Text(
          value,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}

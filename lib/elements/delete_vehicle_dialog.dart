import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' as riverpod;

import 'package:carman/providers/selected_vehicle_provider.dart';
import 'package:carman/providers/vehicles_provider.dart';
import 'package:carman/models/vehicle.dart';

class DeleteVehicleDialog extends riverpod.ConsumerStatefulWidget {
  final Vehicle vehicle;

  const DeleteVehicleDialog({super.key, required this.vehicle});

  static Future<bool?> show(BuildContext context, Vehicle vehicle) {
    return showDialog<bool>(
      context: context,
      builder: (context) => DeleteVehicleDialog(vehicle: vehicle),
    );
  }

  @override
  riverpod.ConsumerState<DeleteVehicleDialog> createState() =>
      _DeleteVehicleDialogState();
}

class _DeleteVehicleDialogState
    extends riverpod.ConsumerState<DeleteVehicleDialog> {
      
  bool _isDeleting = false;

  Future<void> _performDelete() async {
    await ref.read(vehiclesProvider.notifier).remove(widget.vehicle.id);

    ref.invalidate(selectedVehicleProvider);
  }

  Future<void> _deleteVehicle() async {
    setState(() => _isDeleting = true);

    try {
      await _performDelete();

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Vehicle deleted successfully')));
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isDeleting = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to delete vehicle: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Delete Vehicle'),
      content: Text(
        'Are you sure you want to delete ${widget.vehicle.displayName}?',
      ),
      actions: [
        TextButton(
          onPressed: _isDeleting ? null : () => Navigator.pop(context, false),
          child: Text('Cancel'),
        ),
        TextButton(
          onPressed: _isDeleting ? null : _deleteVehicle,
          child: _isDeleting
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text('Delete', style: TextStyle(color: Colors.red)),
        ),
      ],
    );
  }
}

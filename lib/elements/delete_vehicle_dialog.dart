import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' as riverpod;

import 'package:carman/providers/selected_vehicle_provider.dart';
import 'package:carman/providers/vehicles_provider.dart';
import 'package:carman/models/vehicle.dart';
import 'package:carman/extensions/l10n_extension.dart';

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
        ).showSnackBar(
          SnackBar(content: Text(context.l10n.vehicleDeletedSuccessfully)),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isDeleting = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(
          SnackBar(content: Text('${context.l10n.failedToDeleteVehicle}: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(context.l10n.deleteVehicle),
      content: Text(
        '${context.l10n.deleteVehicleConfirm} ${widget.vehicle.displayName}?',
      ),
      actions: [
        TextButton(
          onPressed: _isDeleting ? null : () => Navigator.pop(context, false),
          child: Text(context.l10n.cancel),
        ),
        TextButton(
          onPressed: _isDeleting ? null : _deleteVehicle,
          child: _isDeleting
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(context.l10n.delete, style: TextStyle(color: Colors.red)),
        ),
      ],
    );
  }
}

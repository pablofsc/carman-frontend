import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' as riverpod;

import '../models/vehicle.dart';
import 'package:carman/providers/vehicles_provider.dart';

const List<String> vehicleTypes = [
  'Sedan',
  'SUV',
  'Coupe',
  'Truck',
  'Van',
  'Hatchback',
  'Convertible',
  'Wagon',
  'Motorcycle',
  'Other',
];

class CreateVehicleDialog extends riverpod.ConsumerStatefulWidget {
  final Function(Vehicle?)? onVehicleCreated;

  const CreateVehicleDialog({super.key, this.onVehicleCreated});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) => CreateVehicleDialog(),
    );
  }

  @override
  riverpod.ConsumerState<CreateVehicleDialog> createState() =>
      _CreateVehicleDialogState();
}

class _CreateVehicleDialogState
    extends riverpod.ConsumerState<CreateVehicleDialog> {
    
  final _formKey = GlobalKey<FormState>();
  final _makeController = TextEditingController();
  final _modelController = TextEditingController();
  final _yearController = TextEditingController();

  String? _selectedType;
  bool _isLoading = false;

  Future<void> _addNewVehicle() async {
    await ref
        .read(vehiclesProvider.notifier)
        .create(
          type: _selectedType!,
          make: _makeController.text.trim(),
          model: _modelController.text.trim(),
          year: _yearController.text.trim(),
        );
  }

  Future<void> _createVehicle() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await _addNewVehicle();

      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      // TODO: make a global error dialog service/element
      if (mounted) {
        showDialog(
          context: context,
          builder: (BuildContext context) => AlertDialog(
            title: Row(
              children: [
                Icon(Icons.error, color: Colors.red),
                SizedBox(width: 12),
                Text('Failed to Create Vehicle'),
              ],
            ),
            content: Text(e.toString()),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('Close'),
              ),
            ],
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.directions_car),
          SizedBox(width: 12),
          Expanded(child: Text('Add new vehicle')),
          IconButton(
            icon: Icon(Icons.close),
            onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Enter the information for your new vehicle',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _makeController,
                      decoration: InputDecoration(
                        labelText: 'Make',
                        hintText: 'e.g., Toyota',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.business),
                      ),
                      textCapitalization: TextCapitalization.words,
                      validator: (value) =>
                          value?.isEmpty ?? true ? 'Make is required' : null,
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _modelController,
                      decoration: InputDecoration(
                        labelText: 'Model',
                        hintText: 'e.g., Corolla',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.drive_eta),
                      ),
                      textCapitalization: TextCapitalization.words,
                      validator: (value) =>
                          value?.isEmpty ?? true ? 'Model is required' : null,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _selectedType,
                      decoration: InputDecoration(
                        labelText: 'Type',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.category),
                      ),
                      items: vehicleTypes.map((String type) {
                        return DropdownMenuItem<String>(
                          value: type,
                          child: Text(type),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedType = newValue;
                        });
                      },
                      validator: (value) => value == null || value.isEmpty
                          ? 'Vehicle type is required'
                          : null,
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _yearController,
                      decoration: InputDecoration(
                        labelText: 'Model Year',
                        hintText: 'e.g., 2004',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.calendar_today),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value?.isEmpty ?? true) return 'Year is required';

                        final year = int.tryParse(value!);

                        if (year == null) {
                          return 'Please enter a valid year';
                        }

                        if (year < 1900 || year > DateTime.now().year + 1) {
                          return 'Must be 1900-${DateTime.now().year + 1}';
                        }

                        return null;
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        if (!_isLoading)
          TextButton(onPressed: _createVehicle, child: Text('Create'))
        else
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
      ],
    );
  }
}

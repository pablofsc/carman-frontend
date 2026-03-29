import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' as riverpod;

import 'package:carman/extensions/l10n_extension.dart';
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

class CreateVehiclePage extends riverpod.ConsumerStatefulWidget {
  const CreateVehiclePage({super.key});

  @override
  riverpod.ConsumerState<CreateVehiclePage> createState() =>
      _CreateVehiclePageState();
}

class _CreateVehiclePageState
    extends riverpod.ConsumerState<CreateVehiclePage> {
  final _formKey = GlobalKey<FormState>();
  final _makeController = TextEditingController();
  final _modelController = TextEditingController();
  final _yearController = TextEditingController();

  String? _selectedType;
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void dispose() {
    _makeController.dispose();
    _modelController.dispose();
    _yearController.dispose();
    super.dispose();
  }

  Future<void> _submitVehicle() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      await ref
          .read(vehiclesProvider.notifier)
          .create(
            type: _selectedType!,
            make: _makeController.text.trim(),
            model: _modelController.text.trim(),
            year: _yearController.text.trim(),
          );

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.addNewVehicle)),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _makeController,
              decoration: InputDecoration(
                labelText: context.l10n.make,
                hintText: context.l10n.makeHint,
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.business),
              ),
              textCapitalization: TextCapitalization.words,
              validator: (value) =>
                  value?.isEmpty ?? true ? context.l10n.makeRequired : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _modelController,
              decoration: InputDecoration(
                labelText: context.l10n.model,
                hintText: context.l10n.modelHint,
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.drive_eta),
              ),
              textCapitalization: TextCapitalization.words,
              validator: (value) =>
                  value?.isEmpty ?? true ? context.l10n.modelRequired : null,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _selectedType,
              decoration: InputDecoration(
                labelText: context.l10n.type,
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.category),
              ),
              items: vehicleTypes.map((String type) {
                return DropdownMenuItem<String>(value: type, child: Text(type));
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedType = newValue;
                });
              },
              validator: (value) => value == null || value.isEmpty
                  ? context.l10n.vehicleTypeRequired
                  : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _yearController,
              decoration: InputDecoration(
                labelText: context.l10n.modelYear,
                hintText: context.l10n.modelYearHint,
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.calendar_today),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return context.l10n.yearRequired;
                }

                final year = int.tryParse(value!);

                if (year == null) {
                  return context.l10n.pleaseEnterValidYear;
                }

                if (year < 1900 || year > DateTime.now().year + 1) {
                  return context.l10n.yearMustBeBetween(
                    '1900',
                    '${DateTime.now().year + 1}',
                  );
                }

                return null;
              },
            ),
            const SizedBox(height: 24),
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Card(
                  color: Theme.of(context).colorScheme.errorContainer,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(
                      _errorMessage!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onErrorContainer,
                      ),
                    ),
                  ),
                ),
              ),
            FilledButton(
              onPressed: _isSubmitting ? null : _submitVehicle,
              child: _isSubmitting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(context.l10n.addNewVehicle),
            ),
          ],
        ),
      ),
    );
  }
}

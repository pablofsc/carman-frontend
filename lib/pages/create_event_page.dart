import 'package:flutter/material.dart';
import 'package:flutter/services.dart' as services;
import 'package:flutter_riverpod/flutter_riverpod.dart' as riverpod;

import 'package:carman/providers/selected_vehicle_provider.dart';
import 'package:carman/providers/events_provider.dart';
import 'package:carman/extensions/l10n_extension.dart';

// TODO: improve this, maybe use a money input library?
class _DecimalInputFormatter extends services.TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) return newValue;

    final pattern = RegExp(r'^\d+\.?\d{0,2}$');
    if (pattern.hasMatch(newValue.text) || newValue.text == '.') {
      return newValue;
    }

    return oldValue;
  }
}

class CreateEventPage extends riverpod.ConsumerStatefulWidget {
  final String? initialType;

  const CreateEventPage({super.key, this.initialType});

  @override
  riverpod.ConsumerState<CreateEventPage> createState() =>
      _CreateEventPageState();
}

class _CreateEventPageState extends riverpod.ConsumerState<CreateEventPage> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedType;
  final _descriptionController = TextEditingController();
  final _odometerController = TextEditingController();
  final _costValueController = TextEditingController();
  final _currencyCodeController = TextEditingController();

  bool _isSubmitting = false;
  String? _errorMessage;

  final List<String> _eventTypes = [
    'Maintenance',
    'Refuel',
    'Repair',
    'Service',
    'Oil Change',
    'Tire Change',
    'Inspection',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    _currencyCodeController.text = 'BRL';

    if (widget.initialType != null) {
      _selectedType = widget.initialType;
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _odometerController.dispose();
    _costValueController.dispose();
    _currencyCodeController.dispose();
    super.dispose();
  }

  Future<void> _submitEvent() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final selectedVehicle = ref.watch(selectedVehicleProvider).asData?.value;

    if (selectedVehicle == null) {
      setState(() {
        _errorMessage = context.l10n.noVehicleSelected;
      });
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      await ref
          .read(eventsProvider.notifier)
          .createEvent(
            vehicleId: selectedVehicle.id,
            type: _selectedType!,
            description: _descriptionController.text.isEmpty
                ? null
                : _descriptionController.text,
            odometer: _odometerController.text.isEmpty
                ? null
                : double.tryParse(_odometerController.text),
            costValueMinor: _costValueController.text.isEmpty
                ? null
                : ((double.tryParse(_costValueController.text) ?? 0) * 100)
                      .toInt(),
            costCurrencyCode: _currencyCodeController.text.isEmpty
                ? null
                : _currencyCodeController.text,
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
    final selectedVehicle = ref.watch(selectedVehicleProvider).asData?.value;

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.createEvent)),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (selectedVehicle != null)
              Card(
                child: ListTile(
                  leading: const Icon(Icons.car_rental),
                  title: Text(selectedVehicle.displayName),
                  subtitle: Text(context.l10n.selectedVehicle),
                ),
              )
            else
              Card(
                color: Theme.of(context).colorScheme.errorContainer,
                child: ListTile(
                  leading: const Icon(Icons.warning),
                  title: Text(context.l10n.noVehicleSelected),
                  subtitle: Text(context.l10n.pleaseSelectVehicleFirst),
                ),
              ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _selectedType,
              decoration: InputDecoration(
                labelText: context.l10n.eventType,
                border: const OutlineInputBorder(),
              ),
              items: _eventTypes.map((type) {
                return DropdownMenuItem(value: type, child: Text(type));
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedType = value;
                });
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return context.l10n.pleaseSelectEventType;
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: context.l10n.descriptionOptional,
                border: const OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _odometerController,
              decoration: InputDecoration(
                labelText: context.l10n.odometerOptional,
                border: const OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _currencyCodeController,
                    decoration: InputDecoration(
                      labelText: context.l10n.currencyCode,
                      border: const OutlineInputBorder(),
                      counterText: '',
                    ),
                    maxLength: 3,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _costValueController,
                    decoration: InputDecoration(
                      labelText: context.l10n.amountOptional,
                      border: const OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [_DecimalInputFormatter()],
                  ),
                ),
              ],
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
              onPressed: _isSubmitting || selectedVehicle == null
                  ? null
                  : _submitEvent,
              child: _isSubmitting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(context.l10n.createEvent),
            ),
          ],
        ),
      ),
    );
  }
}

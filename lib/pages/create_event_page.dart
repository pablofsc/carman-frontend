import 'package:flutter/material.dart';
import 'package:flutter/services.dart' as services;
import 'package:flutter_riverpod/flutter_riverpod.dart' as riverpod;

import 'package:carman/providers/selected_vehicle_provider.dart';
import 'package:carman/providers/events_provider.dart';
import 'package:carman/extensions/l10n_extension.dart';
import 'package:carman/elements/refuel_info_form.dart';
import 'package:carman/elements/delete_event_dialog.dart';
import 'package:carman/models/event.dart';
import 'package:carman/models/refuel_info.dart';
import 'package:carman/models/vehicle.dart';

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
  final Event? editingEvent;

  const CreateEventPage({super.key, this.initialType, this.editingEvent});

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
  final _refuelInfoFormKey = GlobalKey<RefuelInfoFormState>();

  bool _isSubmitting = false;
  String? _errorMessage;
  late Vehicle _selectedVehicle;

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

  void _fillSelectedVehicle() {
    final vehicle = ref.read(selectedVehicleProvider).asData?.value;

    if (vehicle == null) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => Navigator.pop(context),
      );

      throw StateError('No vehicle selected');
    }

    _selectedVehicle = vehicle;
  }

  void _fillEditingEvent(Event e) {
    _selectedType = e.type;
    _descriptionController.text = e.description ?? '';

    if (e.odometer != null) {
      _odometerController.text = e.odometer!.toStringAsFixed(0);
    }

    if (e.costCurrencyCode != null) {
      _currencyCodeController.text = e.costCurrencyCode!;
    }

    if (e.costValueMinor != null) {
      _costValueController.text = (e.costValueMinor! / 100).toStringAsFixed(2);
    }
  }

  @override
  void initState() {
    super.initState();
    _currencyCodeController.text = 'BRL';

    _fillSelectedVehicle();

    final e = widget.editingEvent;

    if (e != null) {
      _fillEditingEvent(e);
    } else if (widget.initialType != null) {
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

  String? _description() =>
      _descriptionController.text.isEmpty ? null : _descriptionController.text;

  double? _odometer() => double.tryParse(_odometerController.text);

  int? _costValueMinor() => _costValueController.text.isEmpty
      ? null
      : ((double.tryParse(_costValueController.text) ?? 0) * 100).toInt();

  String? _currencyCode() => _currencyCodeController.text.isEmpty
      ? null
      : _currencyCodeController.text;

  Future<void> _createEvent(RefuelInfo? refuelInfo) {
    return ref
        .read(eventsProvider.notifier)
        .createEvent(
          vehicleId: _selectedVehicle.id,
          type: _selectedType!,
          description: _description(),
          odometer: _odometer(),
          costValueMinor: _costValueMinor(),
          costCurrencyCode: _currencyCode(),
          refuelInfo: refuelInfo,
        );
  }

  Future<void> _updateEvent(RefuelInfo? refuelInfo) {
    return ref
        .read(eventsProvider.notifier)
        .updateEvent(
          eventId: widget.editingEvent!.id,
          type: _selectedType!,
          description: _description(),
          odometer: _odometer(),
          costValueMinor: _costValueMinor(),
          costCurrencyCode: _currencyCode(),
          refuelInfo: refuelInfo,
        );
  }

  Future<void> _submitEvent() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      final refuelInfo = _selectedType == 'Refuel'
          ? _refuelInfoFormKey.currentState?.getRefuelInfo()
          : null;

      if (widget.editingEvent != null) {
        await _updateEvent(refuelInfo);
      } else {
        await _createEvent(refuelInfo);
      }

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
      appBar: AppBar(
        title: Text(
          widget.editingEvent != null
              ? context.l10n.editEvent
              : context.l10n.createEvent,
        ),
        actions: [
          if (widget.editingEvent != null)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () async {
                final nav = Navigator.of(context);
                final deleted = await DeleteEventDialog.show(
                  context,
                  widget.editingEvent!,
                );
                if (deleted == true) {
                  nav.pop(); // close edit page
                  nav.pop(); // close details page
                }
              },
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: ListTile(
                leading: const Icon(Icons.car_rental),
                title: Text(_selectedVehicle.displayName),
                subtitle: Text(context.l10n.selectedVehicle),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.event),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
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
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Icon(Icons.notes),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _descriptionController,
                    decoration: InputDecoration(
                      labelText: context.l10n.descriptionOptional,
                      border: const OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.speed),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _odometerController,
                    decoration: InputDecoration(
                      labelText: context.l10n.odometerOptional,
                      border: const OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),

            if (_selectedType == 'Refuel')
              RefuelInfoForm(
                key: _refuelInfoFormKey,
                initialRefuelInfo: widget.editingEvent?.refuelInfo,
                initialTotalCost: widget.editingEvent?.costValueMinor != null
                    ? widget.editingEvent!.costValueMinor! / 100
                    : null,
                onTotalCostChanged: (total) {
                  if (total != null) {
                    _costValueController.text = total.toStringAsFixed(2);
                  } else {
                    _costValueController.clear();
                  }
                },
              ),

            if (_selectedType != 'Refuel') ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(Icons.attach_money),
                  const SizedBox(width: 12),
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
                  const Icon(Icons.payments),
                  const SizedBox(width: 12),
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
            ],
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
              onPressed: _isSubmitting ? null : _submitEvent,
              child: _isSubmitting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(
                      widget.editingEvent != null
                          ? context.l10n.editEvent
                          : context.l10n.createEvent,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

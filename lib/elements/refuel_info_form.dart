import 'package:flutter/material.dart';
import 'package:flutter/services.dart' as services;

import 'package:carman/extensions/l10n_extension.dart';
import 'package:carman/models/refuel_info.dart';

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

class RefuelInfoForm extends StatefulWidget {
  final ValueChanged<double?>? onTotalCostChanged;

  const RefuelInfoForm({super.key, this.onTotalCostChanged});

  @override
  State<RefuelInfoForm> createState() => RefuelInfoFormState();
}

class RefuelInfoFormState extends State<RefuelInfoForm> {
  final _fuelTypeController = TextEditingController();
  final _fuelAmountController = TextEditingController();
  final _literPriceController = TextEditingController();
  final _totalCostController = TextEditingController();
  final _gasStationController = TextEditingController();
  String? _activeField;
  bool _isCalculating = false;

  @override
  void initState() {
    super.initState();
    _fuelAmountController.addListener(() => _onFieldChanged('amount'));
    _literPriceController.addListener(() => _onFieldChanged('price'));
    _totalCostController.addListener(() => _onFieldChanged('total'));
  }

  @override
  void dispose() {
    _fuelTypeController.dispose();
    _fuelAmountController.dispose();
    _literPriceController.dispose();
    _totalCostController.dispose();
    _gasStationController.dispose();
    super.dispose();
  }

  void _onFieldChanged(String field) {
    if (_isCalculating) return;
    _activeField = field;
    _recalculate();
  }

  void _recalculate() {
    final amount = double.tryParse(_fuelAmountController.text);
    final price = double.tryParse(_literPriceController.text);
    final total = double.tryParse(_totalCostController.text);

    _isCalculating = true;

    if (_activeField == 'amount' || _activeField == 'price') {
      if (amount != null && price != null) {
        _totalCostController.text = (amount * price).toStringAsFixed(2);
      }
    } else if (_activeField == 'total') {
      if (total != null && price != null && price != 0) {
        _fuelAmountController.text = (total / price).toStringAsFixed(2);
      } else if (total != null && amount != null && amount != 0) {
        _literPriceController.text = (total / amount).toStringAsFixed(2);
      }
    }

    _isCalculating = false;

    final computedTotal = double.tryParse(_totalCostController.text);
    widget.onTotalCostChanged?.call(computedTotal);
  }

  double? get totalCost => double.tryParse(_totalCostController.text);

  RefuelInfo? getRefuelInfo() {
    return RefuelInfo(
      fuelType: _fuelTypeController.text.isEmpty
          ? null
          : _fuelTypeController.text,
      fuelAmount: _fuelAmountController.text.isEmpty
          ? null
          : double.tryParse(_fuelAmountController.text),
      fuelAmountUnit: 'L',
      gasStation: _gasStationController.text.isEmpty
          ? null
          : _gasStationController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 16),
        Row(
          children: [
            const Expanded(child: Divider()),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                context.l10n.refuel,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
              ),
            ),
            const Expanded(child: Divider()),
          ],
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _fuelTypeController,
          decoration: InputDecoration(
            labelText: context.l10n.fuelType,
            border: const OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: TextFormField(
                controller: _literPriceController,
                decoration: InputDecoration(
                  labelText: context.l10n.literPrice,
                  border: const OutlineInputBorder(),
                  prefixText: 'R\$ ',
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [_DecimalInputFormatter()],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
              child: Text(
                '×',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
              ),
            ),
            Expanded(
              child: TextFormField(
                controller: _fuelAmountController,
                decoration: InputDecoration(
                  labelText: context.l10n.fuelAmount,
                  border: const OutlineInputBorder(),
                  suffixText: 'L',
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [_DecimalInputFormatter()],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
              child: Text(
                '=',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
              ),
            ),
            Expanded(
              child: TextFormField(
                controller: _totalCostController,
                decoration: InputDecoration(
                  labelText: context.l10n.totalCost,
                  border: const OutlineInputBorder(),
                  prefixText: 'R\$ ',
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [_DecimalInputFormatter()],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _gasStationController,
          decoration: InputDecoration(
            labelText: context.l10n.gasStation,
            border: const OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        const Divider(),
      ],
    );
  }
}

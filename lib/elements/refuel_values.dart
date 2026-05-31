import 'package:flutter/material.dart';
import 'package:flutter/services.dart' as services;
import 'package:flutter_riverpod/flutter_riverpod.dart' as riverpod;

import 'package:carman/utils/currency_utils.dart';
import 'package:carman/extensions/l10n_extension.dart';
import 'package:carman/providers/currency_provider.dart';

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

enum _Field { price, amount, total }

class RefuelValues extends riverpod.ConsumerStatefulWidget {
  final void Function({double? amount, double? total})? onChange;
  final double? initialFuelAmount;
  final double? initialCostTotal;

  const RefuelValues({
    super.key,
    this.onChange,
    this.initialFuelAmount,
    this.initialCostTotal,
  });

  @override
  riverpod.ConsumerState<RefuelValues> createState() => RefuelValuesState();
}

class RefuelValuesState extends riverpod.ConsumerState<RefuelValues> {
  final _priceController = TextEditingController();
  final _amountController = TextEditingController();
  final _totalController = TextEditingController();

  final _recentFields = <_Field>[];

  @override
  void initState() {
    super.initState();

    if (widget.initialFuelAmount != null) {
      _amountController.text = widget.initialFuelAmount!.toStringAsFixed(2);
    }

    if (widget.initialCostTotal != null) {
      _totalController.text = widget.initialCostTotal!.toStringAsFixed(2);
    }

    if (widget.initialFuelAmount != null && widget.initialCostTotal != null) {
      _recentFields.add(_Field.amount);
      _recalculate(_Field.total);
    }
  }

  @override
  void dispose() {
    _priceController.dispose();
    _amountController.dispose();
    _totalController.dispose();

    super.dispose();
  }

  void _recalculate(_Field modifiedField) {
    _recentFields.remove(modifiedField);

    final values = {
      _Field.price: double.tryParse(_priceController.text),
      _Field.amount: double.tryParse(_amountController.text),
      _Field.total: double.tryParse(_totalController.text),
    };

    if (values[modifiedField] == null) {
      _recentFields.add(modifiedField);
    } else {
      _recentFields.insert(0, modifiedField);
    }

    if (_recentFields.length >= 2) {
      final targetField = _Field.values.toSet().difference({
        _recentFields[0],
        _recentFields[1],
      }).first;

      final knownFields = {_recentFields[0], _recentFields[1]};

      if (knownFields.every((f) => (values[f] ?? 0) > 0)) {
        switch (targetField) {
          case _Field.total:
            final amount = values[_Field.amount]!;
            final price = values[_Field.price]!;

            _totalController.text = (price * amount).toStringAsFixed(2);

          case _Field.amount:
            final total = values[_Field.total]!;
            final price = values[_Field.price]!;

            _amountController.text = (total / price).toStringAsFixed(2);

          case _Field.price:
            final total = values[_Field.total]!;
            final amount = values[_Field.amount]!;

            _priceController.text = (total / amount).toStringAsFixed(2);
        }
      }
    }

    widget.onChange?.call(
      amount: double.tryParse(_amountController.text),
      total: double.tryParse(_totalController.text),
    );
  }

  Widget _operator(BuildContext context, String symbol) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
      child: Text(
        symbol,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          color: Theme.of(context).colorScheme.outline,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currencyCode = ref.watch(currencyProvider);

    return Row(
      children: [
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: TextFormField(
                  controller: _priceController,
                  decoration: InputDecoration(
                    labelText: context.l10n.literPrice,
                    border: const OutlineInputBorder(),
                    prefixText: '${CurrencyUtils.symbol(currencyCode)} ',
                  ),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [_DecimalInputFormatter()],
                  onChanged: (_) => _recalculate(_Field.price),
                ),
              ),

              _operator(context, '×'),

              Expanded(
                child: TextFormField(
                  controller: _amountController,
                  decoration: InputDecoration(
                    labelText: context.l10n.fuelAmount,
                    border: const OutlineInputBorder(),
                    suffixText: 'L',
                  ),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [_DecimalInputFormatter()],
                  onChanged: (_) => _recalculate(_Field.amount),
                ),
              ),

              _operator(context, '='),

              Expanded(
                child: TextFormField(
                  controller: _totalController,
                  decoration: InputDecoration(
                    labelText: context.l10n.totalCost,
                    border: const OutlineInputBorder(),
                    prefixText: '${CurrencyUtils.symbol(currencyCode)} ',
                  ),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [_DecimalInputFormatter()],
                  onChanged: (_) => _recalculate(_Field.total),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' as riverpod;

import 'package:carman/extensions/l10n_extension.dart';
import 'package:carman/models/refuel_info.dart';
import 'package:carman/elements/refuel_values.dart';

class RefuelInfoForm extends riverpod.ConsumerStatefulWidget {
  final void Function({double? total, RefuelInfo? refuelInfo})? onChange;
  final RefuelInfo? initialRefuelInfo;
  final double? initialTotalCost;

  const RefuelInfoForm({
    super.key,
    this.onChange,
    this.initialRefuelInfo,
    this.initialTotalCost,
  });

  @override
  riverpod.ConsumerState<RefuelInfoForm> createState() => RefuelInfoFormState();
}

class RefuelInfoFormState extends riverpod.ConsumerState<RefuelInfoForm> {
  bool _isFullTank = false;
  double? _amount;
  double? _total;

  @override
  void initState() {
    super.initState();
    
    final info = widget.initialRefuelInfo;

    if (info != null) {
      _prefillInputs(info);
    }
  }

  void _prefillInputs(RefuelInfo info) {
    _isFullTank = info.fullTank;
  }

  RefuelInfo? readInputs() {
    return RefuelInfo(
      fuelType: widget.initialRefuelInfo?.fuelType,
      fuelAmount: _amount,
      fuelAmountUnit: 'L',
      fullTank: _isFullTank,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 24),

        Row(
          children: [
            const Expanded(child: Divider()),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: const Icon(Icons.local_gas_station)
            ),
            const Expanded(child: Divider()),
          ],
        ),

        SwitchListTile.adaptive(
          title: Text(context.l10n.fullTank),
          value: _isFullTank,
          contentPadding: EdgeInsets.zero,
          onChanged: (isFullTank) {
            setState(() {
              _isFullTank = isFullTank;
            });
            widget.onChange?.call(total: _total, refuelInfo: readInputs());
          },
        ),

        const SizedBox(height: 16),

        RefuelValues(
          onChange: ({amount, total}) {
            _amount = amount;
            _total = total;
            widget.onChange?.call(total: total, refuelInfo: readInputs());
          },
          initialFuelAmount: widget.initialRefuelInfo?.fuelAmount,
          initialCostTotal: widget.initialTotalCost,
        )
      ],
    );
  }
}

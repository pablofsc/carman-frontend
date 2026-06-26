import 'package:flutter/material.dart';

import 'package:carman/models/event.dart';

class EventIcon extends StatelessWidget {
  static const double _radius = 20;

  final Event event;

  const EventIcon({super.key, required this.event});

  static IconData getIcon(Event event) {
    final type = event.type;
    if (type == null) return Icons.event;

    switch (type.toLowerCase()) {
      case 'maintenance':
        return Icons.build;
      case 'refuel':
        final isFullTank = event.refuelInfo?.fullTank ?? false;
        return isFullTank
            ? Icons.local_gas_station
            : Icons.local_gas_station_outlined;
      case 'repair':
        return Icons.car_repair;
      case 'service':
        return Icons.settings;
      default:
        return Icons.event;
    }
  }

  static Color? getColor(Event event) {
    final type = event.type;
    if (type == null) return null;

    switch (type.toLowerCase()) {
      case 'maintenance':
        return Colors.orange;
      case 'refuel':
        final isFullTank = event.refuelInfo?.fullTank ?? false;
        return isFullTank ? Colors.teal : Colors.green;
      case 'repair':
        return Colors.red;
      case 'service':
        return Colors.blue;
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final icon = getIcon(event);
    final color = getColor(event) ?? Theme.of(context).colorScheme.primary;

    return CircleAvatar(
      radius: _radius,
      backgroundColor: color.withValues(alpha: 0.15),
      child: Icon(icon, color: color, size: _radius),
    );
  }
}

import 'package:flutter/material.dart';

import 'package:carman/models/event.dart';

class IconUtils {
  IconUtils._();

  static IconData getEventIcon(Event event) {
    final type = event.type;
    if (type == null) return Icons.event;
    switch (type.toLowerCase()) {
      case 'maintenance':
        return Icons.build;
      case 'refuel':
        return event.refuelInfo?.fullTank == true
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

  static Color? getEventColor(Event event) {
    final type = event.type;
    if (type == null) return null;
    switch (type.toLowerCase()) {
      case 'maintenance':
        return Colors.orange;
      case 'refuel':
        return event.refuelInfo?.fullTank == true ? Colors.teal : Colors.green;
      case 'repair':
        return Colors.red;
      case 'service':
        return Colors.blue;
      default:
        return null;
    }
  }
}

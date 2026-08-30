import 'package:carman/models/event.dart';
import 'package:carman/models/enums/event_type_enum.dart';
import 'package:carman/utils/timezone_utils.dart';

/// Pure calculations over a vehicle's event history, used to power the
/// dashboard page.
class DashboardStats {
  DashboardStats._(); // this class is not meant to be instantiated

  /// The most recently recorded odometer reading, or null if none exists.
  static double? latestOdometer(List<Event> events) {
    final withOdometer = events.where((e) => e.odometer != null).toList()
      ..sort(
        (a, b) => (a.occurredAt ?? a.createdAt).compareTo(
          b.occurredAt ?? b.createdAt,
        ),
      );

    if (withOdometer.isEmpty) return null;
    return withOdometer.last.odometer;
  }

  /// Total distance driven, computed as the difference between the highest
  /// and lowest recorded odometer readings.
  static double? totalDistanceKm(List<Event> events) {
    final readings = events
        .where((e) => e.odometer != null)
        .map((e) => e.odometer!)
        .toList();

    if (readings.length < 2) return null;

    return readings.reduce((a, b) => a > b ? a : b) -
        readings.reduce((a, b) => a < b ? a : b);
  }

  /// The most recent occurrence date/time (converted to [timezone]) of an
  /// event with the given [type] (case-insensitive), or null if there isn't
  /// one.
  static DateTime? lastOccurrenceOfType(
    List<Event> events,
    EventTypeEnum type,
    String timezone,
  ) {
    final matching = events.where((e) => e.type == type);

    if (matching.isEmpty) return null;

    final latestInstant = matching
        .map((e) => e.occurredAt ?? e.createdAt)
        .reduce((a, b) => a.isAfter(b) ? a : b);

    return TimezoneUtils.toZone(latestInstant, timezone);
  }

  /// Sums [Event.costValueMinor] grouped by currency code. Events without a
  /// cost or currency are ignored. If [from] is provided, only events
  /// occurring on or after it are included.
  static Map<String, int> totalsByCurrency(
    List<Event> events, {
    DateTime? from,
  }) {
    final totals = <String, int>{};

    for (final event in events) {
      final cost = event.costValueMinor;
      final currency = event.costCurrencyCode;
      if (cost == null || currency == null) continue;

      final occurredAt = event.occurredAt ?? event.createdAt;
      if (from != null && occurredAt.isBefore(from)) continue;

      totals[currency] = (totals[currency] ?? 0) + cost;
    }

    return totals;
  }

  /// The currency with the highest all-time spend, or null if there's no
  /// cost data at all.
  static String? primaryCurrency(List<Event> events) {
    final totals = totalsByCurrency(events);
    if (totals.isEmpty) return null;

    return totals.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
  }

  /// Sums [Event.costValueMinor] for [currency], grouped by event type.
  static Map<EventTypeEnum, int> totalsByType(
    List<Event> events,
    String currency,
  ) {
    final totals = <EventTypeEnum, int>{};

    for (final event in events) {
      if (event.costCurrencyCode != currency || event.costValueMinor == null) {
        continue;
      }

      final type = event.type ?? EventTypeEnum.other;
      totals[type] = (totals[type] ?? 0) + event.costValueMinor!;
    }

    return totals;
  }

  /// Totals for [currency] over the last [months] calendar months (oldest
  /// first), keyed by the first day of each month, in [timezone].
  static List<MapEntry<DateTime, int>> monthlyTotals(
    List<Event> events,
    String currency,
    String timezone, {
    int months = 12,
  }) {
    final now = TimezoneUtils.toZone(DateTime.now(), timezone);
    final buckets = <DateTime, int>{
      for (var i = months - 1; i >= 0; i--)
        DateTime(now.year, now.month - i, 1): 0,
    };

    for (final event in events) {
      if (event.costCurrencyCode != currency || event.costValueMinor == null) {
        continue;
      }

      final occurredAt = TimezoneUtils.toZone(
        event.occurredAt ?? event.createdAt,
        timezone,
      );
      final bucket = DateTime(occurredAt.year, occurredAt.month, 1);

      if (buckets.containsKey(bucket)) {
        buckets[bucket] = buckets[bucket]! + event.costValueMinor!;
      }
    }

    final sortedKeys = buckets.keys.toList()..sort();
    return [for (final key in sortedKeys) MapEntry(key, buckets[key]!)];
  }

  /// Average fuel consumption in liters per 100km, computed between
  /// consecutive full-tank refuels (the only reliable checkpoints, since the
  /// fuel added between two full tanks equals the fuel consumed in between).
  /// Returns null if there isn't at least one full segment.
  static double? averageConsumptionLPer100Km(List<Event> events) {
    final refuels =
        events
            .where(
              (e) =>
                  e.type == EventTypeEnum.refuel &&
                  e.odometer != null &&
                  e.refuelInfo?.fuelAmount != null,
            )
            .toList()
          ..sort((a, b) => a.odometer!.compareTo(b.odometer!));

    final fullTankIndexes = [
      for (var i = 0; i < refuels.length; i++)
        if (refuels[i].refuelInfo!.fullTank) i,
    ];

    if (fullTankIndexes.length < 2) return null;

    var totalFuel = 0.0;
    var totalDistance = 0.0;

    for (var s = 0; s < fullTankIndexes.length - 1; s++) {
      final startIdx = fullTankIndexes[s];
      final endIdx = fullTankIndexes[s + 1];

      final distance = refuels[endIdx].odometer! - refuels[startIdx].odometer!;
      if (distance <= 0) continue;

      var fuelUsed = 0.0;
      for (var i = startIdx + 1; i <= endIdx; i++) {
        fuelUsed += refuels[i].refuelInfo!.fuelAmount!;
      }

      totalFuel += fuelUsed;
      totalDistance += distance;
    }

    if (totalDistance <= 0) return null;

    return (totalFuel / totalDistance) * 100;
  }

  /// Average price paid per liter (in minor currency units) for [currency].
  static double? averagePricePerLiter(List<Event> events, String currency) {
    final prices = events
        .where(
          (e) =>
              e.type == EventTypeEnum.refuel &&
              e.costCurrencyCode == currency &&
              e.refuelInfo?.fuelUnitPrice != null,
        )
        .map((e) => e.refuelInfo!.fuelUnitPrice!)
        .toList();

    if (prices.isEmpty) return null;

    return prices.reduce((a, b) => a + b) / prices.length;
  }

  /// Fraction (0-1) of [currency]'s all-time spend that came from Refuel
  /// events.
  static double? fuelSpendFraction(List<Event> events, String currency) {
    final byType = totalsByType(events, currency);
    if (byType.isEmpty) return null;

    final total = byType.values.reduce((a, b) => a + b);
    if (total == 0) return null;

    final fuel = byType.entries
        .where((e) => e.key == EventTypeEnum.refuel)
        .fold<int>(0, (sum, e) => sum + e.value);

    return fuel / total;
  }
}

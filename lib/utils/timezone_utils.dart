import 'package:timezone/timezone.dart' as tz;

class TimezoneUtils {
  TimezoneUtils._(); // this class is not meant to be instantiated

  /// Converts an absolute instant (e.g. a UTC timestamp from the backend)
  /// into a [tz.TZDateTime] representing that same instant in [timezoneIana].
  static tz.TZDateTime toZone(DateTime instant, String timezoneIana) {
    return tz.TZDateTime.from(instant, tz.getLocation(timezoneIana));
  }

  /// Builds a [tz.TZDateTime] out of wall-clock date/time components as if
  /// they were entered in [timezoneIana]. Useful to convert user input (e.g.
  /// from date/time pickers) into the correct UTC instant via `.toUtc()`.
  static tz.TZDateTime wallClock(
    String timezoneIana, {
    required int year,
    required int month,
    required int day,
    required int hour,
    required int minute,
  }) {
    return tz.TZDateTime(
      tz.getLocation(timezoneIana),
      year,
      month,
      day,
      hour,
      minute,
    );
  }
}

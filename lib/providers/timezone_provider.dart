import 'package:flutter_riverpod/flutter_riverpod.dart' as riverpod;
import 'package:timezone/timezone.dart' as tz;

import 'package:carman/adapters/storage_adapter.dart';
import 'package:carman/providers/user_provider.dart';

const _storageKey = 'selected_timezone';

final List<String> ianaTimezones = () {
  final zones = tz.timeZoneDatabase.locations.keys.toList()..sort();
  if (!zones.contains('UTC')) zones.insert(0, 'UTC');
  return zones;
}();

final timezoneProvider = riverpod.NotifierProvider<TimezoneNotifier, String>(
  TimezoneNotifier.new,
);

class TimezoneNotifier extends riverpod.Notifier<String> {
  @override
  String build() {
    ref.listen(userProvider, (previous, next) {
      final timezone = next.value?.selectedTimezone;
      if (timezone != null) _setFrontendTimezone(timezone);
    });

    _loadFromStorage();

    return 'UTC';
  }

  Future<void> _loadFromStorage() async {
    final saved = await StorageAdapter.read(_storageKey);
    if (saved != null) state = saved;
  }

  void _setFrontendTimezone(String timezoneIana) {
    state = timezoneIana;
    StorageAdapter.write(_storageKey, timezoneIana);
  }

  Future<void> setTimezone(String timezoneIana) async {
    _setFrontendTimezone(timezoneIana);
    ref.read(userProvider.notifier).updateTimezone(timezoneIana);
  }
}

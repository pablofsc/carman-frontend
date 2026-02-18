import 'package:flutter_riverpod/flutter_riverpod.dart' as riverpod;

import 'package:carman/providers/selected_vehicle_provider.dart';
import 'package:carman/providers/auth_provider.dart';
import 'package:carman/repositories/event_repository.dart';
import 'package:carman/models/event.dart';

final eventsProvider =
    riverpod.AsyncNotifierProvider<EventsNotifier, List<Event>>(
      EventsNotifier.new,
    );

class EventsNotifier extends riverpod.AsyncNotifier<List<Event>> {
  @override
  Future<List<Event>> build() async {
    final selectedVehicle = ref.watch(selectedVehicleProvider).asData?.value;

    // TODO: support showing all events when no vehicle is selected
    if (selectedVehicle == null) return [];

    return EventRepository.getEventsByVehicle(
      selectedVehicle.id,
      await ref.read(authProvider.notifier).getHeaders(),
    );
  }

  Future<void> createEvent({
    required String vehicleId,
    required String type,
    String? description,
    double? odometer,
    int? costValueMinor,
    String? costCurrencyCode,
  }) async {
    await EventRepository.createEvent(
      vehicleId: vehicleId,
      type: type,
      description: description,
      odometer: odometer,
      costValueMinor: costValueMinor,
      costCurrencyCode: costCurrencyCode,
      headers: await ref.read(authProvider.notifier).getHeaders(),
    );

    ref.invalidateSelf();
  }

  Future<void> deleteEvent(String eventId) async {
    await EventRepository.deleteEvent(
      eventId,
      await ref.read(authProvider.notifier).getHeaders(),
    );

    ref.invalidateSelf();
  }
}

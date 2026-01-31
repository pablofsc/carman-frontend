import 'package:flutter/material.dart';

import '../models/event.dart';
import '../repositories/event_repository.dart';
import 'selected_vehicle_service.dart';

class EventsService {
  static final EventsService _instance = EventsService._internal();

  late final ValueNotifier<List<Event>> _eventsNotifier;
  late final ValueNotifier<bool> _isLoadingNotifier;
  final SelectedVehicleService _selVehService = SelectedVehicleService();

  EventsService._internal() {
    _eventsNotifier = ValueNotifier<List<Event>>([]);
    _isLoadingNotifier = ValueNotifier<bool>(false);
    _selVehService.selVehNotifier.addListener(_onSelectedVehicleChanged);
  }

  factory EventsService() {
    return _instance;
  }

  void _onSelectedVehicleChanged() {
    refreshEvents();
  }

  ValueNotifier<List<Event>> get eventsNotifier => _eventsNotifier;
  ValueNotifier<bool> get isLoadingNotifier => _isLoadingNotifier;

  List<Event> get events => _eventsNotifier.value;
  bool get isLoading => _isLoadingNotifier.value;

  Future<void> refreshEvents() async {
    try {
      _isLoadingNotifier.value = true;
      final selectedVehicle = _selVehService.selectedVehicle;

      if (selectedVehicle == null) {
        _eventsNotifier.value = [];
        return;
      }

      final events = await EventRepository.getEventsByVehicle(
        selectedVehicle.id,
      );
      _eventsNotifier.value = events;
    } catch (e) {
      debugPrint('Failed to load events: $e');
    } finally {
      _isLoadingNotifier.value = false;
    }
  }

  Future<Event?> createEvent({
    required String vehicleId,
    required String type,
    String? description,
    double? odometer,
  }) async {
    try {
      final newEvent = await EventRepository.createEvent(
        vehicleId: vehicleId,
        type: type,
        description: description,
        odometer: odometer,
      );

      await refreshEvents();

      return newEvent;
    } catch (e) {
      debugPrint('Failed to create event: $e');
      rethrow;
    }
  }

  Future<void> deleteEvent(String eventId) async {
    try {
      await EventRepository.deleteEvent(eventId);
      await refreshEvents();
    } catch (e) {
      debugPrint('Failed to delete event: $e');
      rethrow;
    }
  }

  void dispose() {
    _eventsNotifier.dispose();
    _isLoadingNotifier.dispose();
  }
}

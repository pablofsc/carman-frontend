import 'package:flutter/material.dart';

import '../elements/delete_event_dialog.dart';
import '../models/event.dart';
import '../services/events_service.dart';
import 'create_event_page.dart';

class EventsPage extends StatefulWidget {
  const EventsPage({super.key});

  @override
  State<EventsPage> createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage> {
  final EventsService _eventsService = EventsService();

  @override
  void initState() {
    super.initState();
    _eventsService.refreshEvents();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreateEventPage()),
          );
        },
        child: const Icon(Icons.add),
      ),
      body: ValueListenableBuilder<List<Event>>(
        valueListenable: _eventsService.eventsNotifier,
        builder: (context, events, child) {
          if (events.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.event_note,
                    size: 64,
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No events yet',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Events will appear here',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _eventsService.refreshEvents,
            child: ListView.builder(
              itemCount: events.length,
              itemBuilder: (context, index) {
                final event = events[index];
                return _EventListItem(event: event);
              },
            ),
          );
        },
      ),
    );
  }
}

class _EventListItem extends StatelessWidget {
  final Event event;

  const _EventListItem({required this.event});

  IconData _getEventIcon(String? type) {
    if (type == null) return Icons.event;
    switch (type.toLowerCase()) {
      case 'maintenance':
        return Icons.build;
      case 'refuel':
        return Icons.local_gas_station;
      case 'repair':
        return Icons.car_repair;
      case 'service':
        return Icons.settings;
      default:
        return Icons.event;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        onLongPress: () => DeleteEventDialog.show(context, event),
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          child: Icon(
            _getEventIcon(event.type),
            color: Theme.of(context).colorScheme.onPrimaryContainer,
          ),
        ),
        title: Text(
          event.type ?? "unknown event type",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('${event.vehicle.make} ${event.vehicle.model}'),
            if (event.description != null && event.description!.isNotEmpty)
              Text(
                event.description!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  Icons.person_outline,
                  size: 14,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 4),
                Text(
                  event.author.username,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(width: 12),
                Icon(
                  Icons.calendar_today,
                  size: 14,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 4),
                Text(
                  event.createdAt.toString(),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ],
        ),
        trailing: event.odometer != null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${event.odometer!.toStringAsFixed(0)} km',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              )
            : null,
        isThreeLine: true,
      ),
    );
  }
}

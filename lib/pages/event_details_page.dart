import 'package:flutter/material.dart';

import 'package:carman/extensions/l10n_extension.dart';
import 'package:carman/models/event.dart';
import 'package:carman/pages/create_event_page.dart';
import 'package:carman/elements/delete_event_dialog.dart';

class EventDetailsPage extends StatelessWidget {
  final Event event;

  const EventDetailsPage({super.key, required this.event});

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

  String _formatDateTime(DateTime dt) {
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} '
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}:${dt.second.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DraggableScrollableSheet(
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        context.l10n.eventDetails,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.delete_outline,
                        color: theme.colorScheme.error,
                      ),
                      onPressed: () async {
                        final nav = Navigator.of(context);
                        final deleted = await DeleteEventDialog.show(
                          context,
                          event,
                        );
                        if (deleted == true) {
                          nav.pop(); // close details sheet
                        }
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                CreateEventPage(editingEvent: event),
                          ),
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    _buildHeader(context, theme),
                    const SizedBox(height: 16),
                    _buildInfoCard(context, theme),
                    if (event.description != null &&
                        event.description!.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      _buildDescriptionCard(context, theme),
                    ],
                    if (event.refuelInfo != null) ...[
                      const SizedBox(height: 16),
                      _buildRefuelCard(context, theme),
                    ],
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: theme.colorScheme.primaryContainer,
              child: Icon(
                _getEventIcon(event.type),
                size: 28,
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.type ?? context.l10n.unknownEventType,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    event.vehicle.displayName,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildInfoRow(
              context,
              Icons.person_outline,
              context.l10n.author,
              event.author.username,
            ),
            const Divider(),
            _buildInfoRow(
              context,
              Icons.calendar_today,
              context.l10n.createdAt,
              _formatDateTime(event.createdAt),
            ),
            if (event.modifiedAt != null) ...[
              const Divider(),
              _buildInfoRow(
                context,
                Icons.edit_calendar,
                context.l10n.modifiedAt,
                _formatDateTime(event.modifiedAt!),
              ),
            ],
            if (event.odometer != null) ...[
              const Divider(),
              _buildInfoRow(
                context,
                Icons.speed,
                context.l10n.odometer,
                '${event.odometer!.toStringAsFixed(0)} km',
              ),
            ],
            if (event.costValueMinor != null &&
                event.costCurrencyCode != null) ...[
              const Divider(),
              _buildInfoRow(
                context,
                Icons.attach_money,
                context.l10n.cost,
                '${(event.costValueMinor! / 100).toStringAsFixed(2)} ${event.costCurrencyCode}',
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionCard(BuildContext context, ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.notes,
                  size: 20,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 8),
                Text(
                  context.l10n.description,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(event.description!, style: theme.textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }

  Widget _buildRefuelCard(BuildContext context, ThemeData theme) {
    final refuel = event.refuelInfo!;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.local_gas_station,
                  size: 20,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 8),
                Text(
                  context.l10n.refuelDetails,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (refuel.fuelType != null)
              _buildInfoRow(
                context,
                Icons.local_gas_station_outlined,
                context.l10n.fuelType,
                refuel.fuelType!,
              ),
            if (refuel.fuelAmount != null) ...[
              if (refuel.fuelType != null) const Divider(),
              _buildInfoRow(
                context,
                Icons.water_drop_outlined,
                context.l10n.fuelAmount,
                '${refuel.fuelAmount!.toStringAsFixed(2)} ${refuel.fuelAmountUnit ?? 'L'}',
              ),
            ],
            if (refuel.gasStation != null) ...[
              if (refuel.fuelType != null || refuel.fuelAmount != null)
                const Divider(),
              _buildInfoRow(
                context,
                Icons.location_on_outlined,
                context.l10n.gasStation,
                refuel.gasStation!,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

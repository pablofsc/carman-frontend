import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' as riverpod;
import 'package:intl/intl.dart' as intl;

import 'package:carman/utils/currency_utils.dart';
import 'package:carman/utils/icon_utils.dart';
import 'package:carman/extensions/l10n_extension.dart';
import 'package:carman/providers/events_provider.dart';
import 'package:carman/models/event.dart';
import 'package:carman/pages/create_event_page.dart';
import 'package:carman/elements/delete_event_dialog.dart';

class EventDetailsSheet extends riverpod.ConsumerWidget {
  final String eventId;

  const EventDetailsSheet({super.key, required this.eventId});

  String _formatDateTime(BuildContext context, DateTime dt) {
    return intl.DateFormat.yMMMd(
      Localizations.localeOf(context).toString(),
    ).add_Hms().format(dt);
  }

  @override
  Widget build(BuildContext context, riverpod.WidgetRef ref) {
    final event = ref
        .watch(eventsProvider)
        .asData
        ?.value
        .where((e) => e.id == eventId)
        .firstOrNull;

    if (event == null) return const SizedBox.shrink();

    final theme = Theme.of(context);

    final eventColor =
        IconUtils.getEventColor(event) ?? theme.colorScheme.primary;

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
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: eventColor.withValues(alpha: 0.15),
                      child: Icon(
                        IconUtils.getEventIcon(event),
                        size: 20,
                        color: eventColor,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            event.type ?? context.l10n.unknownEventType,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            event.vehicle.displayName,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
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
                    const SizedBox(height: 8),
                    _buildInfoCard(context, theme, event),
                    if (event.description != null &&
                        event.description!.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      _buildDescriptionCard(context, theme, event),
                    ],
                    if (event.refuelInfo != null) ...[
                      const SizedBox(height: 16),
                      _buildRefuelCard(context, theme, event),
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

  Widget _buildInfoCard(BuildContext context, ThemeData theme, Event event) {
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
              _formatDateTime(context, event.createdAt),
            ),
            if (event.occurredAt != null) ...[
              const Divider(),
              _buildInfoRow(
                context,
                Icons.event_available,
                context.l10n.occurredAt,
                _formatDateTime(context, event.occurredAt!),
              ),
            ],
            if (event.modifiedAt != null) ...[
              const Divider(),
              _buildInfoRow(
                context,
                Icons.edit_calendar,
                context.l10n.modifiedAt,
                _formatDateTime(context, event.modifiedAt!),
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
                CurrencyUtils.format(
                  event.costValueMinor!,
                  event.costCurrencyCode!,
                ),
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

  Widget _buildDescriptionCard(
    BuildContext context,
    ThemeData theme,
    Event event,
  ) {
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

  Widget _buildRefuelCard(BuildContext context, ThemeData theme, Event event) {
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
            if (refuel.fuelType != null ||
                refuel.fuelAmount != null ||
                refuel.gasStation != null)
              const Divider(),
            _buildInfoRow(
              context,
              Icons.check_circle_outline,
              context.l10n.fullTank,
              refuel.fullTank
                  ? context.l10n.fullTankYes
                  : context.l10n.fullTankNo,
            ),
          ],
        ),
      ),
    );
  }
}

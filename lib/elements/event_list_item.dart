import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;

import 'package:carman/utils/currency_utils.dart';
import 'package:carman/utils/icon_utils.dart';
import 'package:carman/extensions/l10n_extension.dart';
import 'package:carman/models/event.dart';
import 'package:carman/elements/delete_event_dialog.dart';
import 'package:carman/elements/event_details_sheet.dart';

class EventListItem extends StatelessWidget {
  final Event event;

  const EventListItem({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasDescription =
        event.description != null && event.description!.isNotEmpty;

    final eventColor =
        IconUtils.getEventColor(event) ?? theme.colorScheme.primary;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        onTap: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (context) => EventDetailsSheet(eventId: event.id),
          );
        },
        onLongPress: () => DeleteEventDialog.show(context, event),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: eventColor.withValues(alpha: 0.15),
          child: Icon(IconUtils.getEventIcon(event), color: eventColor),
        ),
        title: Text(
          event.type ?? context.l10n.unknownEventType,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (hasDescription) ...[
              const SizedBox(height: 4),
              Text(
                event.description!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  size: 14,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 4),
                Text(
                  intl.DateFormat.yMMMd(
                    Localizations.localeOf(context).toString(),
                  ).add_Hm().format(event.occurredAt ?? event.createdAt),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: event.odometer != null || event.costValueMinor != null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (event.odometer != null)
                    Text(
                      '${event.odometer!.toStringAsFixed(0)} km',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  if (event.odometer != null && event.costValueMinor != null)
                    const SizedBox(height: 4),
                  if (event.costValueMinor != null &&
                      event.costCurrencyCode != null)
                    Text(
                      CurrencyUtils.format(
                        event.costValueMinor!,
                        event.costCurrencyCode!,
                      ),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                ],
              )
            : null,
        isThreeLine: hasDescription,
      ),
    );
  }
}

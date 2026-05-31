import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' as riverpod;
import 'package:intl/intl.dart' as intl;

import 'package:carman/elements/expandable_fab.dart';
import 'package:carman/extensions/l10n_extension.dart';
import 'package:carman/providers/events_provider.dart';
import 'package:carman/pages/create_event_page.dart';
import 'package:carman/elements/event_list_item.dart';

class EventsPage extends riverpod.ConsumerWidget {
  const EventsPage({super.key});

  @override
  Widget build(BuildContext context, riverpod.WidgetRef ref) {
    final eventsAsync = ref.watch(eventsProvider);
    return Scaffold(
      floatingActionButton: ExpandableFab(
        options: [
          ExpandableFabOption(
            icon: Icons.local_gas_station,
            label: context.l10n.refuel,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      const CreateEventPage(initialType: 'Refuel'),
                ),
              );
            },
          ),
          ExpandableFabOption(
            icon: Icons.event,
            label: context.l10n.otherEvent,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CreateEventPage(),
                ),
              );
            },
          ),
        ],
      ),
      body: eventsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('${context.l10n.error}: $error'),
            ],
          ),
        ),
        data: (events) {
          return RefreshIndicator(
            onRefresh: () async => ref.refresh(eventsProvider.future),
            child: events.isEmpty
                ? ListView(
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.7,
                        child: Center(
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
                                context.l10n.noEventsYet,
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                context.l10n.eventsWillAppearHere,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  )
                : ListView.builder(
                    itemCount: events.length,
                    itemBuilder: (context, index) {
                      final event = events[index];
                      final date = event.occurredAt ?? event.createdAt;

                      // Check if we need to show a month header before this item
                      bool showHeader = false;
                      if (index == 0) {
                        showHeader = true;
                      } else {
                        final prevEvent = events[index - 1];
                        final prevDate =
                            prevEvent.occurredAt ?? prevEvent.createdAt;
                        if (prevDate.year != date.year ||
                            prevDate.month != date.month) {
                          showHeader = true;
                        }
                      }

                      if (showHeader) {
                        final headerText = intl.DateFormat.yMMMM(
                          Localizations.localeOf(context).toString(),
                        ).format(date);

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(
                                left: 24,
                                right: 16,
                                top: 20,
                                bottom: 8,
                              ),
                              child: Text(
                                headerText,
                                style: Theme.of(context).textTheme.titleSmall
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary,
                                      letterSpacing: 0.5,
                                    ),
                              ),
                            ),
                            EventListItem(event: event),
                          ],
                        );
                      }

                      return EventListItem(event: event);
                    },
                  ),
          );
        },
      ),
    );
  }
}

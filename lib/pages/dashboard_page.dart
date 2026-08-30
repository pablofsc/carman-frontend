import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' as riverpod;
import 'package:fl_chart/fl_chart.dart' as chart;
import 'package:intl/intl.dart' as intl;

import 'package:carman/extensions/l10n_extension.dart';
import 'package:carman/elements/event_icon.dart';
import 'package:carman/models/event.dart';
import 'package:carman/providers/events_provider.dart';
import 'package:carman/providers/selected_vehicle_provider.dart';
import 'package:carman/providers/timezone_provider.dart';
import 'package:carman/utils/currency_utils.dart';
import 'package:carman/utils/dashboard_stats.dart';
import 'package:carman/utils/timezone_utils.dart';

String _typeLabel(String type) {
  final words = type.split('_').where((w) => w.isNotEmpty);
  return words
      .map((w) => w[0].toUpperCase() + w.substring(1).toLowerCase())
      .join(' ');
}

class DashboardPage extends riverpod.ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, riverpod.WidgetRef ref) {
    final vehicleAsync = ref.watch(selectedVehicleProvider);
    final eventsAsync = ref.watch(eventsProvider);
    final timezone = ref.watch(timezoneProvider);

    return vehicleAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(child: Text('${context.l10n.error}: $error')),
      data: (vehicle) {
        if (vehicle == null) {
          return Center(
            child: Text(
              context.l10n.noVehicleSelected,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          );
        }

        return eventsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) =>
              Center(child: Text('${context.l10n.error}: $error')),
          data: (events) {
            if (events.isEmpty) {
              return Center(
                child: Text(
                  context.l10n.noEventsYet,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async => ref.refresh(eventsProvider.future),
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _VehicleOverviewCard(events: events, timezone: timezone),
                  const SizedBox(height: 16),
                  _SpendingCard(events: events, timezone: timezone),
                  const SizedBox(height: 16),
                  _FuelEconomyCard(events: events),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _VehicleOverviewCard extends StatelessWidget {
  final List<Event> events;
  final String timezone;

  const _VehicleOverviewCard({required this.events, required this.timezone});

  @override
  Widget build(BuildContext context) {
    final odometer = DashboardStats.latestOdometer(events);
    final distance = DashboardStats.totalDistanceKm(events);
    final lastEventAt = events
        .map((e) => e.occurredAt ?? e.createdAt)
        .reduce((a, b) => a.isAfter(b) ? a : b);
    final daysAgo = TimezoneUtils.toZone(
      DateTime.now(),
      timezone,
    ).difference(TimezoneUtils.toZone(lastEventAt, timezone)).inDays;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _CardHeader(
              icon: Icons.directions_car_outlined,
              title: context.l10n.vehicleOverview,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _StatTile(
                    icon: Icons.speed,
                    label: context.l10n.currentOdometer,
                    value: odometer != null
                        ? '${odometer.toStringAsFixed(0)} km'
                        : '-',
                  ),
                ),
                Expanded(
                  child: _StatTile(
                    icon: Icons.route,
                    label: context.l10n.totalDistance,
                    value: distance != null
                        ? '${distance.toStringAsFixed(0)} km'
                        : '-',
                  ),
                ),
                Expanded(
                  child: _StatTile(
                    icon: Icons.event_available,
                    label: context.l10n.lastEvent,
                    value: daysAgo <= 0
                        ? context.l10n.today
                        : context.l10n.daysAgo(daysAgo.toString()),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SpendingCard extends StatelessWidget {
  final List<Event> events;
  final String timezone;

  const _SpendingCard({required this.events, required this.timezone});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currency = DashboardStats.primaryCurrency(events);

    if (currency == null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(context.l10n.notEnoughData),
        ),
      );
    }

    final now = TimezoneUtils.toZone(DateTime.now(), timezone);
    final monthStart = TimezoneUtils.wallClock(
      timezone,
      year: now.year,
      month: now.month,
      day: 1,
      hour: 0,
      minute: 0,
    );
    final yearStart = TimezoneUtils.wallClock(
      timezone,
      year: now.year,
      month: 1,
      day: 1,
      hour: 0,
      minute: 0,
    );

    final totalsAllTime = DashboardStats.totalsByCurrency(events);
    final allTime = totalsAllTime[currency] ?? 0;
    final thisMonth =
        DashboardStats.totalsByCurrency(events, from: monthStart)[currency] ??
        0;
    final thisYear =
        DashboardStats.totalsByCurrency(events, from: yearStart)[currency] ?? 0;
    final monthly = DashboardStats.monthlyTotals(events, currency, timezone);
    final distance = DashboardStats.totalDistanceKm(events);
    final hasOtherCurrencies = totalsAllTime.keys.any((c) => c != currency);
    final byType = DashboardStats.totalsByType(events, currency).entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _CardHeader(
              icon: Icons.savings_outlined,
              title: context.l10n.spending,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _StatTile(
                    icon: Icons.calendar_view_month,
                    label: context.l10n.thisMonth,
                    value: CurrencyUtils.format(thisMonth, currency),
                  ),
                ),
                Expanded(
                  child: _StatTile(
                    icon: Icons.calendar_today,
                    label: context.l10n.thisYear,
                    value: CurrencyUtils.format(thisYear, currency),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _StatTile(
                    icon: Icons.account_balance_wallet,
                    label: context.l10n.allTime,
                    value: CurrencyUtils.format(allTime, currency),
                  ),
                ),
                Expanded(
                  child: _StatTile(
                    icon: Icons.route,
                    label: context.l10n.costPerKm,
                    value: (distance != null && distance > 0)
                        ? CurrencyUtils.format(
                            (allTime / distance).round(),
                            currency,
                          )
                        : '-',
                  ),
                ),
              ],
            ),
            if (monthly.any((e) => e.value > 0)) ...[
              const Divider(height: 32),
              Text(
                context.l10n.monthlyTrend,
                style: theme.textTheme.titleSmall,
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 160,
                child: chart.BarChart(
                  chart.BarChartData(
                    alignment: chart.BarChartAlignment.spaceAround,
                    borderData: chart.FlBorderData(show: false),
                    gridData: const chart.FlGridData(show: false),
                    barTouchData: chart.BarTouchData(
                      touchTooltipData: chart.BarTouchTooltipData(
                        getTooltipColor: (_) =>
                            theme.colorScheme.inverseSurface,
                        getTooltipItem: (group, groupIndex, rod, rodIndex) {
                          return chart.BarTooltipItem(
                            CurrencyUtils.format(
                              (rod.toY * 100).round(),
                              currency,
                            ),
                            TextStyle(
                              color: theme.colorScheme.onInverseSurface,
                            ),
                          );
                        },
                      ),
                    ),
                    titlesData: chart.FlTitlesData(
                      topTitles: const chart.AxisTitles(
                        sideTitles: chart.SideTitles(showTitles: false),
                      ),
                      rightTitles: const chart.AxisTitles(
                        sideTitles: chart.SideTitles(showTitles: false),
                      ),
                      leftTitles: const chart.AxisTitles(
                        sideTitles: chart.SideTitles(showTitles: false),
                      ),
                      bottomTitles: chart.AxisTitles(
                        sideTitles: chart.SideTitles(
                          showTitles: true,
                          reservedSize: 24,
                          getTitlesWidget: (value, meta) {
                            final index = value.toInt();
                            if (index < 0 || index >= monthly.length) {
                              return const SizedBox.shrink();
                            }

                            return chart.SideTitleWidget(
                              meta: meta,
                              child: Text(
                                intl.DateFormat.MMM(
                                  Localizations.localeOf(context).toString(),
                                ).format(monthly[index].key),
                                style: theme.textTheme.bodySmall,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    barGroups: [
                      for (var i = 0; i < monthly.length; i++)
                        chart.BarChartGroupData(
                          x: i,
                          barRods: [
                            chart.BarChartRodData(
                              toY: monthly[i].value / 100,
                              gradient: LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                colors: [
                                  theme.colorScheme.primary.withValues(
                                    alpha: 0.6,
                                  ),
                                  theme.colorScheme.primary,
                                ],
                              ),
                              width: 10,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            ],
            if (byType.isNotEmpty) ...[
              const Divider(height: 32),
              Text(context.l10n.byType, style: theme.textTheme.titleSmall),
              const SizedBox(height: 12),
              for (final entry in byType)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      EventIcon(event: Event.preview(type: entry.key)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _typeLabel(entry.key),
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
                      Text(
                        CurrencyUtils.format(entry.value, currency),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
            if (hasOtherCurrencies) ...[
              const SizedBox(height: 12),
              Text(
                context.l10n.otherCurrenciesNote,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _FuelEconomyCard extends StatelessWidget {
  final List<Event> events;

  const _FuelEconomyCard({required this.events});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final consumption = DashboardStats.averageConsumptionLPer100Km(events);
    final currency = DashboardStats.primaryCurrency(events);
    final pricePerLiter = currency != null
        ? DashboardStats.averagePricePerLiter(events, currency)
        : null;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _CardHeader(
              icon: Icons.local_gas_station_outlined,
              title: context.l10n.fuelEconomy,
            ),
            const SizedBox(height: 12),
            if (consumption == null && pricePerLiter == null)
              Text(
                context.l10n.notEnoughData,
                style: theme.textTheme.bodyMedium,
              )
            else
              Row(
                children: [
                  Expanded(
                    child: _StatTile(
                      icon: Icons.local_gas_station,
                      label: context.l10n.averageConsumption,
                      value: consumption != null
                          ? '${consumption.toStringAsFixed(1)} L/100km'
                          : '-',
                    ),
                  ),
                  Expanded(
                    child: _StatTile(
                      icon: Icons.price_change,
                      label: context.l10n.averagePricePerLiter,
                      value: (pricePerLiter != null && currency != null)
                          ? CurrencyUtils.format(
                              pricePerLiter.round(),
                              currency,
                            )
                          : '-',
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _CardHeader extends StatelessWidget {
  final IconData icon;
  final String title;

  const _CardHeader({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Icon(icon, size: 20, color: theme.colorScheme.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 14,
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

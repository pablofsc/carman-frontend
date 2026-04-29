import 'package:flutter/material.dart';

import 'package:carman/extensions/l10n_extension.dart';
import 'package:carman/elements/vehicle_selector.dart';
import 'package:carman/pages/vehicle_page.dart';
import 'package:carman/pages/events_page.dart';
import 'package:carman/pages/settings_page.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _selectedIndex = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [const VehiclePage(), const EventsPage(), const SettingsPage()];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.secondaryContainer,
            borderRadius: BorderRadius.circular(16),
          ),
          child: VehicleSelector(),
        ),
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (int index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: <Widget>[
          NavigationDestination(
            icon: const Icon(Icons.car_rental_outlined),
            selectedIcon: const Icon(Icons.car_rental),
            label: context.l10n.navVehicle,
          ),
          NavigationDestination(
            icon: const Icon(Icons.event_note_outlined),
            selectedIcon: const Icon(Icons.event_note),
            label: context.l10n.navEvents,
          ),
          NavigationDestination(
            icon: const Icon(Icons.settings_outlined),
            selectedIcon: const Icon(Icons.settings),
            label: context.l10n.navSettings,
          ),
        ],
      ),
    );
  }
}

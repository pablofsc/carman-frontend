import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' as riverpod;

import 'package:carman/providers/auth_provider.dart';
import 'package:carman/extensions/l10n_extension.dart';
import 'package:carman/elements/account_details_sheet.dart';
import 'package:carman/elements/preferences_selectors.dart';

class SettingsPage extends riverpod.ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  riverpod.ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends riverpod.ConsumerState<SettingsPage> {

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.settings),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: context.l10n.logout,
            onPressed: () async {
              await ref.read(authProvider.notifier).logout();

              if (context.mounted) {
                Navigator.pushReplacementNamed(context, '/');
              }
            },
          ),
        ],
      ),
      body: authState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) =>
            Center(child: Text('${context.l10n.error}: $error')),
        data: (auth) {
          if (auth == null) {
            return Center(child: Text(context.l10n.noUserDataFound));
          }

          return ListView(
            padding: const EdgeInsets.fromLTRB(24.0, 0, 24.0, 0),
            children: [
              const PreferencesSelectors(),

              // Account Details button
              const SizedBox(height: 8),
              
              OutlinedButton.icon(
                onPressed: () => AccountDetailsSheet.show(context, auth),
                icon: const Icon(Icons.account_circle_outlined),
                label: Text(context.l10n.accountDetails),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

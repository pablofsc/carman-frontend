import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' as riverpod;

import 'package:carman/providers/auth_provider.dart';
import 'package:carman/providers/currency_provider.dart';
import 'package:carman/providers/locale_provider.dart';
import 'package:carman/utils/currency_utils.dart';
import 'package:carman/providers/theme_provider.dart';
import 'package:carman/extensions/l10n_extension.dart';
import 'package:carman/elements/account_details_sheet.dart';

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
        data: (user) {
          if (user == null) {
            return Center(child: Text(context.l10n.noUserDataFound));
          }

          return ListView(
            padding: const EdgeInsets.fromLTRB(24.0, 0, 24.0, 0),
            children: [
              // Language Section
              Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  title: Text(context.l10n.language),
                  leading: const Icon(Icons.language),
                  trailing: DropdownButton<Locale>(
                    value: ref.watch(localeProvider),
                    underline: const SizedBox.shrink(),
                    items: supportedLocaleNames.entries
                        .map(
                          (e) => DropdownMenuItem(
                            value: Locale(e.key),
                            child: Text(e.value),
                          ),
                        )
                        .toList(),
                    onChanged: (locale) {
                      if (locale != null) {
                        ref.read(localeProvider.notifier).setLocale(locale);
                      }
                    },
                  ),
                ),
              ),

              // Currency Section
              Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  title: Text(context.l10n.currency),
                  leading: const Icon(Icons.attach_money),
                  trailing: DropdownButton<String>(
                    value:
                        commonCurrencies.contains(ref.watch(currencyProvider))
                        ? ref.watch(currencyProvider)
                        : null,
                    underline: const SizedBox.shrink(),
                    items: commonCurrencies
                        .map(
                          (code) => DropdownMenuItem(
                            value: code,
                            child: Text(CurrencyUtils.displayName(code)),
                          ),
                        )
                        .toList(),
                    onChanged: (code) {
                      if (code != null) {
                        ref.read(currencyProvider.notifier).setCurrency(code);
                      }
                    },
                  ),
                ),
              ),

              // Theme Section
              Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  title: Text(context.l10n.theme),
                  leading: const Icon(Icons.palette),
                  trailing: DropdownButton<String>(
                    value: ref.watch(themeProvider).key,
                    underline: const SizedBox.shrink(),
                    items: themes
                        .map(
                          (theme) => DropdownMenuItem(
                            value: theme.key,
                            child: Text(theme.name),
                          ),
                        )
                        .toList(),
                    onChanged: (mode) {
                      if (mode != null) {
                        ref.read(themeProvider.notifier).setTheme(mode);
                      }
                    },
                  ),
                ),
              ),

              // Account Details button
              const SizedBox(height: 8),
              
              OutlinedButton.icon(
                onPressed: () => AccountDetailsSheet.show(context, user),
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

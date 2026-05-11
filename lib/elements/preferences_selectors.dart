import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' as riverpod;

import 'package:carman/extensions/l10n_extension.dart';
import 'package:carman/providers/currency_provider.dart';
import 'package:carman/providers/locale_provider.dart';
import 'package:carman/providers/theme_provider.dart';
import 'package:carman/utils/currency_utils.dart';

class PreferencesSelectors extends riverpod.ConsumerWidget {
  const PreferencesSelectors({super.key});

  @override
  Widget build(BuildContext context, riverpod.WidgetRef ref) {
    return Column(
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
              value: commonCurrencies.contains(ref.watch(currencyProvider))
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
      ],
    );
  }
}

import 'package:flutter/material.dart';

import 'package:carman/extensions/l10n_extension.dart';
import 'package:carman/elements/preferences_selectors.dart';

class SetupPage extends StatelessWidget {
  const SetupPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                context.l10n.setUpPreferences,
                style: Theme.of(context).textTheme.headlineMedium,
              ),

              const Spacer(),

              Text(
                context.l10n.setUpPreferencesWelcome,
                style: Theme.of(context).textTheme.bodyMedium,
              ),

              const SizedBox(height: 16),

              const PreferencesSelectors(),

              const SizedBox(height: 32),

              FilledButton(
                onPressed: () => Navigator.pushReplacementNamed(context, '/'),
                child: Text(context.l10n.continueButton),
              ),

              const SizedBox(height: 16),

              Text(
                context.l10n.setUpPreferencesSubtitle,
                style: Theme.of(context).textTheme.bodyMedium,
              ),

              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}

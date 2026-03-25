import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' as riverpod;

import 'package:carman/providers/auth_provider.dart';
import 'package:carman/providers/locale_provider.dart';
import 'package:carman/extensions/l10n_extension.dart';

class UserPage extends riverpod.ConsumerStatefulWidget {
  const UserPage({super.key});

  @override
  riverpod.ConsumerState<UserPage> createState() => _UserPageState();
}

class _UserPageState extends riverpod.ConsumerState<UserPage> {

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.userInfo),
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

          final expiryTime = user.generatedAt.add(
            Duration(seconds: user.expiresIn),
          );
          final now = DateTime.now();
          final timeRemaining = expiryTime.difference(now);
          final isExpiring = timeRemaining.inSeconds < 300; // 5 minutes

          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: ListView(
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
                      items: const [
                        DropdownMenuItem(
                          value: Locale('en'),
                          child: Text('English'),
                        ),
                        DropdownMenuItem(
                          value: Locale('pt'),
                          child: Text('Português'),
                        ),
                      ],
                      onChanged: (locale) {
                        if (locale != null) {
                          ref.read(localeProvider.notifier).setLocale(locale);
                        }
                      },
                    ),
                  ),
                ),

                // User Identity Section
                Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    title: Text(context.l10n.username),
                    subtitle: Text(user.username),
                    leading: const Icon(Icons.person),
                  ),
                ),
                Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    title: Text(context.l10n.userId),
                    subtitle: SelectableText(user.userId),
                    leading: const Icon(Icons.badge),
                  ),
                ),

                // Token Timestamps Section
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(
                    context.l10n.tokenTimestamps,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    title: Text(context.l10n.generatedAt),
                    subtitle: Text(user.generatedAt.toString()),
                    leading: const Icon(Icons.schedule),
                  ),
                ),
                Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    title: Text(context.l10n.expiresAt),
                    subtitle: Text(expiryTime.toString()),
                    leading: const Icon(Icons.access_time),
                    trailing: isExpiring
                        ? Chip(
                            label: Text(context.l10n.expiringSoon),
                            backgroundColor: Colors.orange,
                          )
                        : null,
                  ),
                ),

                // Token Duration Section
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(
                    context.l10n.tokenDuration,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    title: Text(context.l10n.expiresIn),
                    subtitle: Text(
                      '${user.expiresIn} ${context.l10n.seconds} (${(user.expiresIn / 60).toStringAsFixed(1)} ${context.l10n.minutes})',
                    ),
                    leading: const Icon(Icons.timer),
                  ),
                ),
                Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    title: Text(context.l10n.timeRemaining),
                    subtitle: Text(
                      '${timeRemaining.inHours}h ${timeRemaining.inMinutes % 60}m ${timeRemaining.inSeconds % 60}s',
                    ),
                    leading: const Icon(Icons.hourglass_bottom),
                    trailing: isExpiring
                        ? const Icon(Icons.warning, color: Colors.orange)
                        : null,
                  ),
                ),

                // Token Type Section
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(
                    context.l10n.tokenType,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    title: Text(context.l10n.type),
                    subtitle: Text(user.tokenType),
                    leading: const Icon(Icons.info_outline),
                  ),
                ),

                // Access Token Section
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(
                    context.l10n.tokens,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    title: Text(context.l10n.accessToken),
                    subtitle: SelectableText(
                      user.accessToken,
                      style: const TextStyle(fontSize: 10),
                    ),
                    leading: const Icon(Icons.vpn_key),
                  ),
                ),
                Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    title: Text(context.l10n.refreshToken),
                    subtitle: SelectableText(
                      user.refreshToken,
                      style: const TextStyle(fontSize: 10),
                    ),
                    leading: const Icon(Icons.refresh),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

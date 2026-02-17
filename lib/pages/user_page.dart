import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' as riverpod;

import 'package:carman/providers/auth_provider.dart';

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
        title: const Text('User Info'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
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
        error: (error, stack) => Center(child: Text('Error: $error')),
        data: (user) {
          if (user == null) {
            return const Center(child: Text('No user data found'));
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
                // User Identity Section
                Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    title: const Text('Username'),
                    subtitle: Text(user.username),
                    leading: const Icon(Icons.person),
                  ),
                ),
                Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    title: const Text('User ID'),
                    subtitle: SelectableText(user.userId),
                    leading: const Icon(Icons.badge),
                  ),
                ),

                // Token Timestamps Section
                const SizedBox(height: 16),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(
                    'Token Timestamps',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    title: const Text('Generated At'),
                    subtitle: Text(user.generatedAt.toString()),
                    leading: const Icon(Icons.schedule),
                  ),
                ),
                Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    title: const Text('Expires At'),
                    subtitle: Text(expiryTime.toString()),
                    leading: const Icon(Icons.access_time),
                    trailing: isExpiring
                        ? const Chip(
                            label: Text('Expiring Soon'),
                            backgroundColor: Colors.orange,
                          )
                        : null,
                  ),
                ),

                // Token Duration Section
                const SizedBox(height: 16),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(
                    'Token Duration',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    title: const Text('Expires In'),
                    subtitle: Text(
                      '${user.expiresIn} seconds (${(user.expiresIn / 60).toStringAsFixed(1)} minutes)',
                    ),
                    leading: const Icon(Icons.timer),
                  ),
                ),
                Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    title: const Text('Time Remaining'),
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
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(
                    'Token Type',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    title: const Text('Type'),
                    subtitle: Text(user.tokenType),
                    leading: const Icon(Icons.info_outline),
                  ),
                ),

                // Access Token Section
                const SizedBox(height: 16),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(
                    'Tokens',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    title: const Text('Access Token'),
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
                    title: const Text('Refresh Token'),
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

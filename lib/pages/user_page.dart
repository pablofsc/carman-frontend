import 'package:flutter/material.dart';

import '../models/login_response.dart';

class UserPage extends StatelessWidget {
  final LoginResponse user;
  const UserPage({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('User Info'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/');
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: ListView(
          children: [
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
                subtitle: Text(user.userId),
                leading: const Icon(Icons.badge),
              ),
            ),
            Card(
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: ListTile(
                title: const Text('Access Token'),
                subtitle: SelectableText(user.accessToken),
                leading: const Icon(Icons.vpn_key),
              ),
            ),
            Card(
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: ListTile(
                title: const Text('Refresh Token'),
                subtitle: SelectableText(user.refreshToken),
                leading: const Icon(Icons.refresh),
              ),
            ),
            Card(
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: ListTile(
                title: const Text('Token Type'),
                subtitle: Text(user.tokenType),
                leading: const Icon(Icons.info_outline),
              ),
            ),
            Card(
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: ListTile(
                title: const Text('Expires In'),
                subtitle: Text('${user.expiresIn} seconds'),
                leading: const Icon(Icons.timer),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

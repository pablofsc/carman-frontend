import 'package:flutter/material.dart';

import '../models/login_response.dart';
import '../services/auth_service.dart';

class UserPage extends StatefulWidget {
  const UserPage({super.key});

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  late Future<LoginResponse?> _userFuture;
  final _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _userFuture = _authService.getCurrentUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Info'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () async {
              await _authService.logout();

              if (mounted) {
                Navigator.pushReplacementNamed(context, '/');
              }
            },
          ),
        ],
      ),
      body: FutureBuilder<LoginResponse?>(
        future: _userFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('No user data found'));
          }

          final user = snapshot.data!;

          return Padding(
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
          );
        },
      ),
    );
  }
}

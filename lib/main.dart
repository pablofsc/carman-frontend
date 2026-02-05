import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' as riverpod;

import 'package:carman/pages/home_page.dart';
import 'package:carman/pages/login_page.dart';
import 'package:carman/services/auth_service.dart';

void main() {
  runApp(const riverpod.ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  FutureBuilder _decideRootPage() {
    return FutureBuilder(
      future: AuthService().getCurrentUser(),
      builder: (bc, as) {
        if (as.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (as.data != null) {
          return const HomePage();
        }

        return const LoginPage();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Carman',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: .fromSeed(seedColor: Colors.indigo),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => _decideRootPage(),
        '/home': (context) => const HomePage(),
        '/login': (context) => const LoginPage(),
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' as riverpod;

import 'package:carman/pages/home_page.dart';
import 'package:carman/pages/login_page.dart';
import 'package:carman/providers/auth_provider.dart';

void main() {
  runApp(const riverpod.ProviderScope(child: MyApp()));
}

class MyApp extends riverpod.ConsumerWidget {
  const MyApp({super.key});

  Widget _decideRootPage(riverpod.WidgetRef ref) {
    final auth = ref.watch(authProvider);

    return auth.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text(e.toString()))),
      data: (user) => user == null ? const LoginPage() : const HomePage(),
    );
  }

  @override
  Widget build(BuildContext context, riverpod.WidgetRef ref) {
    return MaterialApp(
      title: 'Carman',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: .fromSeed(seedColor: Colors.indigo),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => _decideRootPage(ref),
        '/home': (context) => const HomePage(),
        '/login': (context) => const LoginPage(),
      },
    );
  }
}

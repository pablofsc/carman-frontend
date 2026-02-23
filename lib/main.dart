import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' as riverpod;

import 'package:carman/pages/home_page.dart';
import 'package:carman/pages/login_page.dart';
import 'package:carman/providers/auth_provider.dart';
import 'package:carman/localization/app_localizations.dart';

void main() {
  runApp(const riverpod.ProviderScope(child: MyApp()));
}

class MyApp extends riverpod.ConsumerWidget {
  const MyApp({super.key});

  Widget _decideRootPage(riverpod.WidgetRef ref) {
    final auth = ref.watch(authProvider);

    return auth.maybeWhen(
      data: (user) => user == null ? const LoginPage() : const HomePage(),
      orElse: () => const LoginPage(),
    );
  }

  @override
  Widget build(BuildContext context, riverpod.WidgetRef ref) {
    return MaterialApp(
      title: 'Carman',
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
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

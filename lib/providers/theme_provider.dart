import 'package:flutter/material.dart' as material;
import 'package:flutter_riverpod/flutter_riverpod.dart' as riverpod;

import 'package:carman/providers/auth_provider.dart';
import 'package:carman/repositories/user_repository.dart';

class CustomTheme {
  final String key;
  final String name;
  final material.ThemeData themeData;

  CustomTheme({required this.key, required this.name, required this.themeData});
}

List<CustomTheme> themes = [
  CustomTheme(
    key: 'light',
    name: 'Light',
    themeData: material.ThemeData(
      useMaterial3: true,
      colorScheme: material.ColorScheme.fromSeed(
        seedColor: material.Colors.blueGrey,
        brightness: material.Brightness.light,
      ),
    ),
  ),

  CustomTheme(
    key: 'dark',
    name: 'Dark',
    themeData: material.ThemeData(
      useMaterial3: true,
      colorScheme: material.ColorScheme.fromSeed(
        seedColor: material.Colors.blueGrey,
        brightness: material.Brightness.dark,
      ),
    ),
  ),
];

final themeProvider = riverpod.NotifierProvider<ThemeNotifier, CustomTheme>(
  ThemeNotifier.new,
);

class ThemeNotifier extends riverpod.Notifier<CustomTheme> {
   
  @override
  CustomTheme build() {
    ref.listen(authProvider, (previous, next) {
      final theme = next.value?.selectedTheme;
      if (theme != null) {
        state = themes.firstWhere((t) => t.key == theme);
      }
    });

    final currentTheme = ref.read(authProvider).value?.selectedTheme;

    if (currentTheme != null) {
      return themes.firstWhere(
        (t) => t.key == currentTheme,
        orElse: () => themes.last,
      );
    }

    return themes.last; // default to dark theme
  }

  void setTheme(String themeKey) {
    state = themes.firstWhere(
      (t) => t.key == themeKey,
    );

    // this is a hack to update the theme in the persisted login response without having to implement a full UserProvider or SettingsProvider
    ref.read(authProvider.notifier).updateSelectedTheme(themeKey);

    ref
        .read(authProvider.notifier)
        .getHeaders()
        .then((headers) {
          if (headers.containsKey('Authorization')) {
            UserRepository.setSelectedTheme(themeKey, headers);
          }
        })
        .catchError((_) {
          // Backend sync failure is non-critical
        });
  }
}

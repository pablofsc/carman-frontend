import 'package:flutter/material.dart' as material;
import 'package:flutter_riverpod/flutter_riverpod.dart' as riverpod;

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
    return themes.last; // default to dark theme
  }

  void setTheme(String themeKey) {
    state = themes.firstWhere(
      (t) => t.key == themeKey,
      orElse: () => themes.first,
    );
  }
}

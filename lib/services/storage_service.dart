import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:web/web.dart';

class StorageService {
  // For non-web platforms (Android, iOS, macOS, Linux, Windows)
  static Future<void> write(String name, String value) async {
    if (kIsWeb) {
      _WebLocalStorage.write(name, value);
    } else {
      throw UnsupportedError(
        'Device storage is not yet implemented. This app currently only supports web.',
      );
    }
  }

  static Future<String?> read(String name) async {
    if (kIsWeb) {
      return _WebLocalStorage.read(name);
    } else {
      throw UnsupportedError(
        'Device storage is not yet implemented. This app currently only supports web.',
      );
    }
  }

  static Future<void> clear(String name) async {
    if (kIsWeb) {
      _WebLocalStorage.clear(name);
    } else {
      throw UnsupportedError(
        'Device storage is not yet implemented. This app currently only supports web.',
      );
    }
  }
}

class _WebLocalStorage {
  static void write(String name, String value) {
    try {
      window.localStorage[name] = value;
    } catch (e) {
      developer.log(
        'Error saving to localStorage: $e',
        name: 'LocalStorageService',
      );
    }
  }

  static String? read(String name) {
    try {
      return window.localStorage[name];
    } catch (e) {
      developer.log(
        'Error reading from localStorage: $e',
        name: 'LocalStorageService',
      );
    }
    return null;
  }

  static void clear(String name) {
    try {
      window.localStorage.removeItem(name);
    } catch (e) {
      developer.log(
        'Error clearing localStorage: $e',
        name: 'LocalStorageService',
      );
    }
  }
}

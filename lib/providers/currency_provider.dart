import 'package:flutter_riverpod/flutter_riverpod.dart' as riverpod;

import 'package:carman/adapters/api_client.dart';
import 'package:carman/adapters/storage_adapter.dart';
import 'package:carman/providers/auth_provider.dart';

const _storageKey = 'selected_currency';

// TODO: improve this, maybe use a library?
const List<String> commonCurrencies = [
  'BRL',
  'USD',
  'EUR',
  'JPY',
  'GBP',
  'CNY',
  'AUD',
  'CAD',
  'CHF',
  'HKD',
  'SGD',
  'SEK',
  'NOK',
  'DKK',
  'NZD',
  'MXN',
  'ZAR',
  'INR',
  'KRW',
  'TRY',
  'ARS',
  'CLP',
  'COP',
  'AED',
  'SAR',
];

final currencyProvider = riverpod.NotifierProvider<CurrencyNotifier, String>(
  CurrencyNotifier.new,
);

class CurrencyNotifier extends riverpod.Notifier<String> {
  @override
  String build() {
    ref.listen(authProvider, (previous, next) {
      final currency = next.value?.selectedCurrency;
      if (currency != null) _setFrontendCurrency(currency);
    });

    _loadFromStorage();

    return 'BRL';
  }

  Future<void> _loadFromStorage() async {
    final saved = await StorageAdapter.read(_storageKey);
    if (saved != null) state = saved;
  }

  void _setFrontendCurrency(String currencyCode) {
    state = currencyCode;
    StorageAdapter.write(_storageKey, currencyCode);
  }

  Future<void> setCurrency(String currencyCode) async {
    _setFrontendCurrency(currencyCode);

    try {
      final headers = await ref.read(authProvider.notifier).getHeaders();

      if (headers.containsKey('Authorization')) {
        await ApiClient.put(
          '/users/selected-currency?code=$currencyCode',
          headers: headers,
        );
      }
    } catch (_) {
      // Backend sync failure is non-critical
    }
  }
}

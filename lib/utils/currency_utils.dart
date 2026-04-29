import 'package:intl/intl.dart' as intl;

class CurrencyUtils {
  CurrencyUtils._(); // this class is not meant to be instantiated

  /// Formats the amount provided (in minor units) into a locale-aware currency string. e.g. `(12399, 'BRL')` => `R$ 123,99`
  static String format(int minorUnits, String currencyCode) {
    final simple = intl.NumberFormat.simpleCurrency(name: currencyCode);
    final decimals = simple.decimalDigits ?? 2;
    final divisor = decimals == 0 ? 1 : _pow10(decimals);

    final numberFormat = intl.NumberFormat.currency(
      name: currencyCode,
      symbol: '${simple.currencySymbol} ',
      decimalDigits: decimals,
    );

    return numberFormat.format(minorUnits / divisor);
  }

  /// Returns the currency symbol for the provided code. e.g. `BRL` => `R$`
  static String symbol(String currencyCode) {
    return intl.NumberFormat.simpleCurrency(name: currencyCode).currencySymbol;
  }

  /// Returns a label for the provided code. e.g. `BRL` => `BRL (R$)`
  static String displayName(String currencyCode) {
    final fmt = intl.NumberFormat.simpleCurrency(name: currencyCode);
    return '${fmt.currencyName ?? currencyCode} (${fmt.currencySymbol})';
  }

  static int _pow10(int exp) {
    var result = 1;

    for (var i = 0; i < exp; i++) {
      result *= 10;
    }

    return result;
  }
}

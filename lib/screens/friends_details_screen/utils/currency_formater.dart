import 'package:intl/intl.dart';
import 'package:kasa_w_grupie/models/group.dart';

String formatCurrency(double amount, CurrencyEnum currency) {
  final format = NumberFormat.currency(
    locale: _getLocale(currency),
    symbol: _getCurrencySymbol(currency),
  );
  return format.format(amount);
}

String _getCurrencySymbol(CurrencyEnum currency) {
  switch (currency) {
    case CurrencyEnum.eur:
      return '€';
    case CurrencyEnum.pln:
      return 'zł';
    case CurrencyEnum.gbp:
      return '£';
    case CurrencyEnum.usd:
      return '\$';
  }
}

String _getLocale(CurrencyEnum currency) {
  switch (currency) {
    case CurrencyEnum.eur:
      return 'de_DE';
    case CurrencyEnum.pln:
      return 'pl_PL';
    case CurrencyEnum.gbp:
      return 'en_GB';
    case CurrencyEnum.usd:
      return 'en_US';
  }
}

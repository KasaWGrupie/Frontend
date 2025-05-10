import 'package:intl/intl.dart';
import 'package:kasa_w_grupie/models/group.dart';

String formatCurrency(double amount, CurrencyEnum currency) {
  final format = NumberFormat.currency(
    locale: getLocale(currency),
    symbol: getCurrencySymbol(currency),
  );
  return format.format(amount);
}

String getCurrencySymbol(CurrencyEnum currency) {
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

String getLocale(CurrencyEnum currency) {
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

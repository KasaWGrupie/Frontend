import 'package:kasa_w_grupie/models/group.dart';

abstract class SettlementsService {
  Future<double> getTotalSettlementAmountInGivenCurrency(
      CurrencyEnum currency, List<Map<String, dynamic>> selectedGroups);
}

class SettlementsServiceMock implements SettlementsService {
  @override
  Future<double> getTotalSettlementAmountInGivenCurrency(
      CurrencyEnum currency, List<Map<String, dynamic>> groupBalances) async {
    double total = 0.0;

    // For now performing addition regardless of currency
    for (var balance in groupBalances) {
      total += (balance["amount"]);
    }

    return total;
  }
}

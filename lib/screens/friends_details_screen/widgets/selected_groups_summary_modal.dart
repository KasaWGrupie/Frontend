import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kasa_w_grupie/models/group.dart';
import 'package:kasa_w_grupie/screens/friends_details_screen/utils/currency_formater.dart';
import 'package:kasa_w_grupie/services/money_transactions_service.dart';

Future<void> showSelectedGroupsSummaryModal(
  BuildContext context,
  List<Map<String, dynamic>> selectedGroups,
  CurrencyEnum selectedCurrency,
  int friendId,
) async {
  final moneyTransactionService = context.read<MoneyTransactionService>();
  final navigator = Navigator.of(context);

  // TODO Create the money request here and integrate with backend
  // final MoneyRequest newMoneyRequest =
  //     await moneyTransactionService.createMoneyRequest(
  //   selectedCurrency,
  //   selectedGroups,
  //   friendId,
  // );

  // final total = newMoneyRequest.moneyValue;
  final total = 50.0;

  if (!navigator.mounted) {
    return;
  }

  await showModalBottomSheet(
    context: navigator.context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (builderContext) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'You are settling',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 16),
            const Text(
              'Confirm Settlement',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total to Settle:', style: TextStyle(fontSize: 16)),
                Text(
                  formatCurrency(total, selectedCurrency),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: total >= 0 ? Colors.green : Colors.red,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                if (builderContext.mounted) {
                  Navigator.pop(builderContext);
                }
              },
              child: const Text("Close"),
            ),
            const SizedBox(height: 16),
          ],
        ),
      );
    },
  );
}

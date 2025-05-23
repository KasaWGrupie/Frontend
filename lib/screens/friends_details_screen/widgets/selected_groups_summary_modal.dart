import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kasa_w_grupie/models/group.dart';
import 'package:kasa_w_grupie/screens/friends_details_screen/utils/currency_formater.dart';
import 'package:kasa_w_grupie/services/settlements_service.dart';

Future<void> showSelectedGroupsSummaryModal(
  BuildContext context,
  List<Map<String, dynamic>> selectedGroups,
  CurrencyEnum selectedCurrency,
) async {
  final settlementsService = context.read<SettlementsService>();
  final navigator = Navigator.of(context);

  // Get total amount for settlement
  final total =
      await settlementsService.getTotalSettlementAmountInGivenCurrency(
    selectedCurrency,
    selectedGroups,
  );

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
            const Text(
              'Confirm Settlement',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),

            // Display total amount of money to settle
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

            // Confirmation button
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(builderContext),
                    child: const Text("Cancel"),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: builderContext,
                        builder: (dialogContext) {
                          // Confiramtion alert dialog
                          return AlertDialog(
                            title: const Text('Confirm Settlement'),
                            content: const Text(
                                'Are you sure you want to confirm this settlement?'),
                            actions: [
                              TextButton(
                                onPressed: () =>
                                    Navigator.of(dialogContext).pop(false),
                                child: const Text('No'),
                              ),
                              TextButton(
                                onPressed: () =>
                                    Navigator.of(dialogContext).pop(true),
                                child: const Text('Yes'),
                              ),
                            ],
                          );
                        },
                      );

                      if (confirm == true) {
                        if (builderContext.mounted) {
                          Navigator.pop(builderContext);
                        }
                      }
                    },
                    child: const Text("Confirm"),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      );
    },
  );
}

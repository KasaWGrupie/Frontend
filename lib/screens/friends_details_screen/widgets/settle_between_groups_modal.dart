import 'package:flutter/material.dart';
import 'package:kasa_w_grupie/models/group.dart';
import 'package:kasa_w_grupie/screens/friends_details_screen/widgets/group_selection_tile.dart';
import 'package:kasa_w_grupie/screens/friends_details_screen/widgets/selected_groups_summary_modal.dart';

Future<void> showSettleBetweenGroupsModal(
  BuildContext context,
  List<Map<String, dynamic>> groupBalances,
  int friendId,
) async {
  List<String> selectedGroupNames = [];
  CurrencyEnum selectedCurrency = CurrencyEnum.pln;

  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
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
                SizedBox(height: 16),
                Text(
                  'Select Groups to Settle',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16),
                SizedBox(
                  height: 300,
                  child: ListView.builder(
                    itemCount: groupBalances.length,
                    itemBuilder: (context, index) {
                      final group = groupBalances[index];
                      final groupName = group["groupName"];
                      final groupAmount = group["amount"];
                      final currency = group["currency"];
                      final isSelected = selectedGroupNames.contains(groupName);

                      return GroupSelectionTile(
                        groupName: groupName,
                        amount: groupAmount,
                        currency: currency,
                        isSelected: isSelected,
                        onTap: () {
                          setState(() {
                            if (isSelected) {
                              selectedGroupNames.remove(groupName);
                            } else {
                              selectedGroupNames.add(groupName);
                            }
                          });
                        },
                        onCheckboxChanged: (value) {
                          setState(() {
                            if (isSelected) {
                              selectedGroupNames.remove(groupName);
                            } else {
                              selectedGroupNames.add(groupName);
                            }
                          });
                        },
                      );
                    },
                  ),
                ),
                SizedBox(height: 16),
                Row(
                  children: [
                    Text("Currency you want to settle in:"),
                    SizedBox(width: 16),
                    DropdownButton<CurrencyEnum>(
                      value: selectedCurrency,
                      onChanged: (newValue) {
                        if (newValue != null) {
                          setState(() {
                            selectedCurrency = newValue;
                          });
                        }
                      },
                      items: CurrencyEnum.values.map((currency) {
                        return DropdownMenuItem<CurrencyEnum>(
                          value: currency,
                          child: Text(currency.name.toUpperCase()),
                        );
                      }).toList(),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      final selectedGroups = groupBalances
                          .where((group) =>
                              selectedGroupNames.contains(group["groupName"]))
                          .toList();

                      if (selectedGroups.isEmpty) return;

                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (dialogContext) {
                          return AlertDialog(
                            title: const Text('Confirm Settlement'),
                            content: const Text(
                              'Are you sure you want to settle between these groups? '
                              'You confirm that you have either already completed the payment or will do so soon, and you want to record this settlement here.',
                            ),
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
                        if (context.mounted) {
                          Navigator.pop(context);

                          await showSelectedGroupsSummaryModal(
                            context,
                            selectedGroups,
                            selectedCurrency,
                            friendId,
                          );
                        }
                      }
                    },
                    child: Text('Settle Selected Groups'),
                  ),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}

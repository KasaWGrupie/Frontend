import 'package:flutter/material.dart';
import 'package:kasa_w_grupie/models/group.dart';
import 'package:kasa_w_grupie/screens/friends_details_screen/utils/currency_formater.dart';

Future<void> showSettleBetweenGroupsModal(
    BuildContext context, List<Map<String, dynamic>> groupBalances) async {
  List<String> selectedGroupNames = [];

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
                      final groupName = group["groupName"] ?? "Unknown Group";
                      final groupAmount = group["amount"] ?? 0.0;
                      final currency = group["currency"] as CurrencyEnum;
                      final isSelected = selectedGroupNames.contains(groupName);

                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.grey.shade300,
                          child: Icon(Icons.group, color: Colors.white),
                        ),
                        title: Row(
                          children: [
                            Expanded(child: Text(groupName)),
                            Text(
                              formatCurrency(groupAmount, currency),
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                        trailing: Checkbox(
                          value: isSelected,
                          onChanged: (value) {
                            setState(() {
                              if (isSelected) {
                                selectedGroupNames.remove(groupName);
                              } else {
                                selectedGroupNames.add(groupName);
                              }
                            });
                          },
                        ),
                        onTap: () {
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
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      final selectedGroups = groupBalances
                          .where(
                            (group) =>
                                selectedGroupNames.contains(group["groupName"]),
                          )
                          .toList();

                      if (selectedGroups.isNotEmpty) {
                        if (context.mounted) {
                          Navigator.pop(context);
                        }
                        await showSelectedGroupsSummaryModal(
                            context, selectedGroups);
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

Future<void> showSelectedGroupsSummaryModal(
    BuildContext context, List<Map<String, dynamic>> selectedGroups) async {
  // Calculate totals by currency
  final Map<CurrencyEnum, double> totalsByCurrency = {};

  for (var group in selectedGroups) {
    final amount = group["amount"] ?? 0.0;
    final currency = group["currency"] as CurrencyEnum;
    totalsByCurrency[currency] = (totalsByCurrency[currency] ?? 0.0) + amount;
  }

  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
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
              'Confirm Settlement',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            ...totalsByCurrency.entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      formatCurrency(entry.value, entry.key),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: entry.value >= 0 ? Colors.green : Colors.red,
                      ),
                    ),
                  ],
                ),
              );
            }),
            SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text("Cancel"),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text("Confirm"),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
          ],
        ),
      );
    },
  );
}

import 'package:flutter/material.dart';

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
          double totalSelectedAmount = selectedGroupNames.fold(
            0.0,
            (sum, name) {
              final group = groupBalances.firstWhere(
                  (g) => g["groupName"] == name,
                  orElse: () => {"amount": 0.0});
              return sum + (group["amount"] ?? 0.0);
            },
          );

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
                              getFormattedAmount(groupAmount),
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
                Divider(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Total Selected:",
                      style: TextStyle(fontSize: 16),
                    ),
                    Text(
                      getFormattedAmount(totalSelectedAmount),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color:
                            totalSelectedAmount > 0 ? Colors.green : Colors.red,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      bool? shouldProceed = await showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: Text("Confirm Settle"),
                            content: Text(
                              "Are you sure you want to settle the selected groups? The total amount is: ${getFormattedAmount(totalSelectedAmount)}",
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context, false);
                                },
                                child: Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context, true);
                                },
                                child: Text('Confirm'),
                              ),
                            ],
                          );
                        },
                      );

                      if (shouldProceed == true) {
                        if (context.mounted) {
                          Navigator.pop(context);
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

// Helper function to format the amount with the currency symbol
String getFormattedAmount(double amount) {
  // TODO resolve currency problems between groups
  return '€${amount.toStringAsFixed(2)}';
}

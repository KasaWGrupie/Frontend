import 'package:flutter/material.dart';

class GroupBalanceCard extends StatelessWidget {
  final String groupName;
  final String balanceAmount;
  final bool isOwes;

  const GroupBalanceCard({
    super.key,
    required this.groupName,
    required this.balanceAmount,
    required this.isOwes,
  });

  @override
  Widget build(BuildContext context) {
    final balanceText = isOwes ? "User owes you: " : "You owe: ";
    final formattedAmount = "${isOwes ? "+" : "-"} $balanceAmount";

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        title: Text(
          groupName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: RichText(
          text: TextSpan(
            text: balanceText,
            style: DefaultTextStyle.of(context).style,
            children: [
              TextSpan(
                text: formattedAmount,
                style: TextStyle(
                  color: isOwes ? Colors.green : Colors.red,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
        trailing: ElevatedButton(
          onPressed: () {
            isOwes
                ? showConfirmationDialog(
                    context,
                    "Are you sure you want to settle?",
                    () {},
                  )
                : showConfirmationDialog(
                    context,
                    "Are you sure you made a money transfer?",
                    () {},
                  );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: isOwes ? Colors.green : Colors.red,
          ),
          child: Text(isOwes ? "Settle" : "Pay"),
        ),
      ),
    );
  }

  Future<void> showConfirmationDialog(
      BuildContext context, String message, VoidCallback onConfirm) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirmation'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              onConfirm();
            },
            child: Text('Confirm'),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

class GroupBalanceCard extends StatelessWidget {
  final String groupName;
  final double balanceAmount;
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
    final formattedAmount =
        "${isOwes ? "+" : "-"} ${balanceAmount.abs().toStringAsFixed(2)}";

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
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: isOwes ? Colors.green : Colors.red,
          ),
          child: Text(isOwes ? "Settle" : "Pay"),
        ),
      ),
    );
  }
}

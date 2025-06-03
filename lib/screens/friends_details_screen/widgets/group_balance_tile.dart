import 'package:flutter/material.dart';
import 'package:kasa_w_grupie/models/group.dart';
import 'package:kasa_w_grupie/screens/friends_details_screen/utils/currency_formater.dart';

class GroupBalanceTile extends StatelessWidget {
  final String groupName;
  final double amount;
  final CurrencyEnum currency;
  final bool isOwed;

  const GroupBalanceTile({
    super.key,
    required this.groupName,
    required this.amount,
    required this.currency,
    required this.isOwed,
  });

  @override
  Widget build(BuildContext context) {
    final formattedAmount = formatCurrency(amount, currency);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border(
          left: BorderSide(
            color: isOwed ? Colors.green.shade400 : Colors.red.shade400,
            width: 4,
          ),
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: Colors.grey.shade100,
            child: Icon(Icons.group, size: 16, color: Colors.grey.shade600),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(groupName,
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
          ),
          Text(
            formattedAmount,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: isOwed ? Colors.green.shade600 : Colors.red.shade600,
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:kasa_w_grupie/models/group.dart';
import 'package:kasa_w_grupie/screens/friends_details_screen/utils/currency_formater.dart';

class GroupSelectionTile extends StatelessWidget {
  final String groupName;
  final double amount;
  final CurrencyEnum currency;
  final bool isSelected;
  final VoidCallback onTap;
  final ValueChanged<bool?> onCheckboxChanged;

  const GroupSelectionTile({
    super.key,
    required this.groupName,
    required this.amount,
    required this.currency,
    required this.isSelected,
    required this.onTap,
    required this.onCheckboxChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.grey.shade300,
        child: Icon(Icons.group, color: Colors.white),
      ),
      title: Row(
        children: [
          Expanded(child: Text(groupName)),
          Text(
            formatCurrency(amount, currency),
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
      trailing: Checkbox(
        value: isSelected,
        onChanged: onCheckboxChanged,
      ),
      onTap: onTap,
    );
  }
}

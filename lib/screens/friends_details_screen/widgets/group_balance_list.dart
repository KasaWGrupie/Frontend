import 'package:flutter/material.dart';
import 'package:kasa_w_grupie/models/group.dart';
import 'package:kasa_w_grupie/screens/friends_details_screen/widgets/group_balance_tile.dart';

class GroupBalanceList extends StatelessWidget {
  final List<Map<String, dynamic>> groupBalances;
  final CurrencyEnum defaultCurrency;

  const GroupBalanceList({
    super.key,
    required this.groupBalances,
    required this.defaultCurrency,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.symmetric(vertical: 8),
      itemCount: groupBalances.length,
      itemBuilder: (context, index) {
        final groupBalance = groupBalances[index];
        final amount = (groupBalance["amount"] ?? 0.0).toDouble();
        final currency = groupBalance["currency"] ?? defaultCurrency;
        final isOwed = groupBalance["isOwed"] ?? false;
        final groupName = groupBalance["groupName"] ?? "Unknown Group";

        return GroupBalanceTile(
          groupName: groupName,
          amount: amount,
          currency: currency,
          isOwed: isOwed,
        );
      },
    );
  }
}

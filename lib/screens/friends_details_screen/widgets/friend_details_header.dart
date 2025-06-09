import 'package:flutter/material.dart';
import 'package:kasa_w_grupie/models/group.dart';
import 'package:kasa_w_grupie/screens/friends_details_screen/utils/currency_formater.dart';

class FriendDetailsHeader extends StatelessWidget {
  final String friendName;
  final String friendEmail;
  final double totalBalance;
  final CurrencyEnum currency;

  const FriendDetailsHeader({
    super.key,
    required this.friendName,
    required this.friendEmail,
    required this.totalBalance,
    required this.currency,
  });

  @override
  Widget build(BuildContext context) {
    final isPositive = totalBalance > 0;
    final isZero = totalBalance == 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: Colors.blue.shade100,
                child: Icon(Icons.person, color: Colors.blue.shade700),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(friendName,
                        style: TextStyle(
                            fontSize: 17, fontWeight: FontWeight.w600)),
                    Text(friendEmail,
                        style: TextStyle(
                            fontSize: 14, color: Colors.grey.shade600)),
                  ],
                ),
              ),
            ],
          ),
          if (!isZero)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  color: isPositive ? Colors.green.shade50 : Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                      color: isPositive
                          ? Colors.green.shade200
                          : Colors.red.shade200),
                ),
                child: Text(
                  "${isPositive ? "Owes you: " : "You owe: "}${formatCurrency(totalBalance.abs(), currency)}",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isPositive
                        ? Colors.green.shade700
                        : Colors.red.shade700,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

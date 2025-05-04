import 'package:flutter/material.dart';
import 'package:kasa_w_grupie/models/expense.dart';
import 'package:kasa_w_grupie/models/group.dart';

class ExpenseTile extends StatelessWidget {
  const ExpenseTile({required this.expense, super.key, required this.currency});

  final Expense expense;
  final CurrencyEnum currency;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(expense.name),
        subtitle: Text(
            '${expense.amount.toStringAsFixed(2)} ${currency.name.toUpperCase()}'),
        trailing: Image.network(expense.pictureUrl),
      ),
    );
  }
}

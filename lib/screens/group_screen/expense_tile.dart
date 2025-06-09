import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kasa_w_grupie/models/expense.dart';
import 'package:kasa_w_grupie/models/group.dart';

class ExpenseTile extends StatelessWidget {
  const ExpenseTile({required this.expense, super.key, required this.currency});

  final Expense expense;
  final CurrencyEnum currency;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.push(
          '/edit_expense/${expense.id}',
          extra: expense,
        );
      },
      child: Card(
        child: ListTile(
          title: Text(expense.name),
          subtitle: Text(
              '${expense.amount.toStringAsFixed(2)} ${currency.name.toUpperCase()}'),
          trailing: Image.network(
            expense.pictureUrl == ''
                ? 'https://static.vecteezy.com/system/resources/previews/009/391/394/original/pack-of-dollars-money-clipart-design-illustration-free-png.png'
                : expense.pictureUrl,
          ),
        ),
      ),
    );
  }
}

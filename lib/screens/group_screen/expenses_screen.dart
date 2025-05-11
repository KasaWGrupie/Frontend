import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:kasa_w_grupie/cubits/group_cubit.dart';
import 'package:kasa_w_grupie/screens/group_screen/expense_tile.dart';

class ExpensesScreen extends StatelessWidget {
  const ExpensesScreen({super.key, required this.loadedState});

  final GroupLoaded loadedState;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () => BlocProvider.of<GroupCubit>(context).reload(),
      child: Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            context.go('/groups/${loadedState.group.id}/new_expense');
          },
          child: const Icon(Icons.add),
        ),
        body: Padding(
          padding: const EdgeInsets.all(10),
          child: ListView.builder(
            itemBuilder: (buildContext, index) {
              final expenses = loadedState.grouped;
              if (index >= expenses.keys.length) {
                return null;
              }
              final keys = expenses.keys.toList()
                ..sort(
                  (t1, t2) =>
                      t2.millisecondsSinceEpoch - t1.millisecondsSinceEpoch,
                );
              final key = keys[index];
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDateSeparator(key),
                  ...expenses[key]!.map(
                    (expense) => ExpenseTile(
                      expense: expense,
                      currency: loadedState.group.currency,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildDateSeparator(DateTime date) {
    final formattedDate = DateFormat.yMMMMd().format(date);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      width: double.infinity,
      child: Text(
        formattedDate,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }
}

import 'dart:math';

import 'package:kasa_w_grupie/models/expense.dart';
import 'package:kasa_w_grupie/models/new_expense.dart';
import 'package:kasa_w_grupie/services/group_service.dart';

abstract class GroupService {
  Future<Expense> addExpense(NewExpense newExpense);
  Future<Map<String, double>> getBalances(String groupId);
  Future<bool> addMember(String groupId, String email);

  Future<void> settle(
    String fromId,
    String toId,
    double amount,
    String groupId,
  ) async {}
}

class GroupServiceMock implements GroupService {
  final Map<String, List<Expense>> _groupExpenses = {};
  final Map<String, Map<String, double>> _groupBalances = {};

  @override
  Future<Expense> addExpense(NewExpense newExpense) async {
    final expense = Expense(
      Random().nextInt(1000).toString(),
      newExpense.title ?? "",
      newExpense.paidById!,
      newExpense.amount!,
      newExpense.participantsIds!,
      newExpense.groupId!,
      newExpense.date!,
    );

    _groupExpenses.putIfAbsent(newExpense.groupId, () => []).add(expense);

    // Update balances
    return expense;
  }

  @override
  Future<Map<String, double>> getBalances(String groupId) async {
    return _groupBalances[groupId] ?? {};
  }

  @override
  Future<bool> addMember(String groupId, String email) async {
    // Mock adding a member to a group
    _groupBalances.putIfAbsent(groupId, () => {});
    _groupBalances[groupId]![email] = 0.0;
    return true;
  }

  @override
  Future<void> settle(
    String fromId,
    String toId,
    double amount,
    String groupId,
  ) async {
    if (_groupBalances.containsKey(groupId)) {
      _groupBalances[groupId]!.update(
        fromId,
        (value) => value + amount,
        ifAbsent: () => amount,
      );
      _groupBalances[groupId]!.update(
        toId,
        (value) => value - amount,
        ifAbsent: () => -amount,
      );
    }
  }
}

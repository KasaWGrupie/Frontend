import 'package:kasa_w_grupie/models/expense.dart';

class NewExpense {
  String groupId;
  String? name;
  double? amount;
  DateTime? date;
  String? payer;
  String? description;
  ExpenseSplit? split;

  NewExpense({
    required this.groupId,
    this.name,
    this.amount,
    this.date,
    this.payer,
    this.split,
    this.description,
  });
}

abstract class ExpenseService {
  Future<String?> addExpense(NewExpense expense);
}

class MockExpenseService implements ExpenseService {
  @override
  Future<String?> addExpense(NewExpense expense) async {
    // Simulate a network call
    await Future.delayed(Duration(seconds: 1));
    return null;
  }
}

import 'package:kasa_w_grupie/models/new_expense.dart';

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

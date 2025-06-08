import 'package:kasa_w_grupie/models/expense.dart';
import 'package:kasa_w_grupie/models/new_expense.dart';

abstract class ExpenseService {
  Future<String?> addExpense(NewExpense expense);
  Future<String?> updateExpense(Expense expense);
  Future<Expense?> getExpenseById(String expenseId);
}

class MockExpenseService implements ExpenseService {
  @override
  Future<String?> addExpense(NewExpense expense) async {
    // Simulate a network call
    await Future.delayed(Duration(seconds: 1));
    return null;
  }

  @override
  Future<String?> updateExpense(Expense expense) async {
    // Simulate a network call
    await Future.delayed(Duration(seconds: 1));
    return null;
  }

  @override
  Future<Expense?> getExpenseById(String expenseId) async {
    // Simulate fetching an expense by ID
    return Expense(
      id: int.parse(expenseId),
      name: "Sample Expense",
      pictureUrl: "https://example.com/sample.jpg",
      date: DateTime.now(),
      amount: 100.0,
      payer: 6,
      split: ExpenseSplit.equal(participants: [6]),
      description: "Sample description",
    );
  }
}

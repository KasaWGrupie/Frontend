import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kasa_w_grupie/models/expense.dart';
import 'package:kasa_w_grupie/services/expense_service.dart';

class EditExpenseCubit extends Cubit<Expense> {
  final ExpenseService expenseService;

  EditExpenseCubit(
      {required this.expenseService, required Expense initialExpense})
      : super(initialExpense);

  void updateName(String name) {
    emit(state.copyWith(name: name));
  }

  void updateAmount(double amount) {
    emit(state.copyWith(amount: amount));
  }

  void updateDescription(String? description) {
    emit(state.copyWith(description: description));
  }

  void updatePayer(String payer) {
    emit(state.copyWith(payer: payer));
  }

  void updateSplit(ExpenseSplit split) {
    if (split.type == SplitType.byAmount ||
        split.type == SplitType.byPercentage) {
      final defaultValue = split.type == SplitType.byAmount ? 0.0 : 0.0;
      final updatedDetails = {
        for (var participant in split.participants)
          participant: split.details?[participant] ?? defaultValue,
      };
      emit(state.copyWith(
        split: split.type == SplitType.byAmount
            ? ExpenseSplit.byAmount(updatedDetails,
                participants: split.participants)
            : ExpenseSplit.byPercentage(updatedDetails,
                participants: split.participants),
      ));
    } else {
      emit(state.copyWith(split: split));
    }
  }

  Future<String?> saveChanges() async {
    try {
      return await expenseService.updateExpense(state);
    } catch (e) {
      return e.toString();
    }
  }
}

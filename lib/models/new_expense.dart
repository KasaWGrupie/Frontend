import 'package:kasa_w_grupie/models/expense.dart';

class NewExpense {
  int groupId;
  String? name;
  double? amount;
  DateTime? date;
  int? payer;
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

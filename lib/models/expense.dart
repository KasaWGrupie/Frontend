class Expense {
  Expense({
    required this.id,
    required this.name,
    required this.pictureUrl,
    required this.date,
    required this.amount,
    required this.payer,
    required this.split,
    this.description,
  });
  int id;
  String pictureUrl;
  String name;
  DateTime date;
  double amount;
  String payer;
  ExpenseSplit split;
  String? description;
}

class ExpenseSplit {}

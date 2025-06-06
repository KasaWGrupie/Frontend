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

  Expense copyWith({
    int? id,
    String? name,
    String? pictureUrl,
    DateTime? date,
    double? amount,
    String? payer,
    ExpenseSplit? split,
    String? description,
  }) {
    return Expense(
      id: id ?? this.id,
      name: name ?? this.name,
      pictureUrl: pictureUrl ?? this.pictureUrl,
      date: date ?? this.date,
      amount: amount ?? this.amount,
      payer: payer ?? this.payer,
      split: split ?? this.split,
      description: description ?? this.description,
    );
  }
}

class ExpenseSplit {
  final SplitType type;
  final Map<String, double>? amounts; // For "By Amount" and "By Percentage"
  final List<String> participants; // List of participant IDs

  // Constructor for Equal Split
  ExpenseSplit.equal({required this.participants})
      : type = SplitType.equal,
        amounts = null;

  // Constructor for Split By Amount
  ExpenseSplit.byAmount(Map<String, double> this.amounts,
      {required this.participants})
      : type = SplitType.byAmount;

  // Constructor for Split By Percentage
  ExpenseSplit.byPercentage(Map<String, double> percentages,
      {required this.participants})
      : type = SplitType.byPercentage,
        amounts = percentages;

  Map<String, double>? get details => amounts;
}

enum SplitType { equal, byAmount, byPercentage }

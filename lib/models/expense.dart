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
  int payer;
  ExpenseSplit split;
  String? description;

  Expense copyWith({
    int? id,
    String? name,
    String? pictureUrl,
    DateTime? date,
    double? amount,
    int? payer,
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
  final Map<int, double>? amounts; // For "By Amount" and "By Percentage"
  final List<int> participants; // List of participant IDs

  // Constructor for Equal Split
  ExpenseSplit.equal({required this.participants})
      : type = SplitType.equal,
        amounts = null;

  // Constructor for Split By Amount
  ExpenseSplit.byAmount(Map<int, double> this.amounts,
      {required this.participants})
      : type = SplitType.byAmount;

  // Constructor for Split By Percentage
  ExpenseSplit.byPercentage(Map<int, double> percentages,
      {required this.participants})
      : type = SplitType.byPercentage,
        amounts = percentages;

  Map<int, double>? get details => amounts;
}

enum SplitType {
  equal,
  byAmount,
  byPercentage;

  @override
  String toString() {
    switch (this) {
      case SplitType.equal:
        return 'Equal';
      case SplitType.byAmount:
        return 'By Amount';
      case SplitType.byPercentage:
        return 'By Percentage';
    }
  }
}

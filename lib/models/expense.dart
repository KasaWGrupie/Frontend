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

class ExpenseSplit {
  final SplitType type;
  final Map<String, double>? amounts; // For "By Amount" and "By Percentage"
  final List<String> participants; // List of participant IDs

  // Constructor for Equal Split
  ExpenseSplit.equal({required this.participants})
      : type = SplitType.equal,
        amounts = null;

  // Constructor for Split By Amount
  ExpenseSplit.byAmount(Map<String, double> amounts,
      {required this.participants})
      : type = SplitType.byAmount,
        this.amounts = amounts;

  // Constructor for Split By Percentage
  ExpenseSplit.byPercentage(Map<String, double> percentages,
      {required this.participants})
      : type = SplitType.byPercentage,
        this.amounts = percentages;
}

enum SplitType { equal, byAmount, byPercentage }

class Friend {
  late final String id;
  late final String name;
  late final String email;
  bool isSelected;
  double owesAmount;
  double owedAmount;

  Friend({
    required this.id,
    required this.name,
    required this.email,
    this.isSelected = false,
    this.owesAmount = 0.0,
    this.owedAmount = 0.0,
  });

  /// Helper method to display debt info
  String getBalanceInfo() {
    if (owesAmount > 0) {
      return "Owes you: ${owesAmount.toStringAsFixed(2)}";
    } else if (owedAmount > 0) {
      return "You owe: ${owedAmount.toStringAsFixed(2)}";
    } else {
      return "No debts";
    }
  }
}

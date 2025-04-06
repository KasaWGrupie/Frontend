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
}

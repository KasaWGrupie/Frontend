class Friend {
  late final int id;
  late final String name;
  late final String email;
  String? pictureUrl;
  bool isSelected;
  double owesAmount;
  double owedAmount;

  Friend({
    required this.id,
    required this.name,
    required this.email,
    this.pictureUrl,
    this.isSelected = false,
    this.owesAmount = 0.0,
    this.owedAmount = 0.0,
  });
}

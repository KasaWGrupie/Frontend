class Friend {
  late final String id;
  late final String name;
  late final String email;
  bool isSelected;

  Friend(
      {required this.id,
      required this.name,
      required this.email,
      this.isSelected = false});
}

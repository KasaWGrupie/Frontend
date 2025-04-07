class NewExpense {
  NewExpense(
    this.groupId, {
    this.title,
    this.paidById,
    this.amount,
    this.participantsIds,
    this.date,
  });
  String? title;
  String? paidById;
  double? amount;
  List<String>? participantsIds;
  String groupId;
  DateTime? date;
}

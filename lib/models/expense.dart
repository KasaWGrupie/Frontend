class Expense {
  Expense(
    this.id,
    this.title,
    this.paidById,
    this.amount,
    this.participantsIds,
    this.groupId,
    this.date,
  );

  Expense.fromJson(Map<String, Object> json) {
    id = json['id']! as String;
    title = json['title']! as String;
    paidById = json['paidBy']! as String;
    amount = double.parse(json['amount']! as String);
    participantsIds = List<String>.from(json['participants']! as List);
    groupId = json['groupId']! as String;
    date = DateTime.parse(json['date']! as String);
  }

  late final String id;
  late final String title;
  late final String paidById;
  late final double amount;
  late final List<String> participantsIds;
  late final String groupId;
  late final DateTime date;

  Map<String, Object> toJson() {
    return {
      'id': id,
      'title': title,
      'paidBy': paidById,
      'amount': amount.toString(),
      'participants': participantsIds,
      'groupId': groupId,
      'date': date.toIso8601String(),
    };
  }
}

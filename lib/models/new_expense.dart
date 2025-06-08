import 'package:kasa_w_grupie/models/expense.dart';

class NewExpense {
  int groupId;
  String? name;
  double? amount;
  DateTime? date;
  int? payer;
  String? description;
  ExpenseSplit? split;

  NewExpense({
    required this.groupId,
    this.name,
    this.amount,
    this.date,
    this.payer,
    this.split,
    this.description,
  });
}

extension NewExpenseJson on NewExpense {
  Map<String, dynamic> toJson() {
    // Convert split information to participants array
    List<Map<String, dynamic>> participants = [];

    if (split!.type == SplitType.equal) {
      for (var userId in split!.participants) {
        participants.add(
            {'userId': userId, 'amount': amount! / split!.participants.length});
      }
    } else {
      // For byAmount and byPercentage
      final details = split!.details;
      if (details != null) {
        for (var entry in details.entries) {
          double actualAmount;
          if (split!.type == SplitType.byAmount) {
            actualAmount = entry.value;
          } else {
            // Convert percentage to actual amount
            actualAmount = (entry.value / 100.0) * amount!;
          }

          participants.add({
            'userId': entry.key,
            'amount': actualAmount,
          });
        }
      }
    }
    final divisionMethod = switch (split!.type) {
      SplitType.equal => "Equally",
      SplitType.byAmount => "Custom",
      SplitType.byPercentage => "ByPercent",
    };

    return {
      'groupId': groupId,
      'paidBy': payer,
      'expenseName': name,
      'expensePictureUri': '',
      'description': description ?? '',
      'amount': amount,
      'date': date!.toUtc().toIso8601String(),
      'participants': participants,
      'divisionMethod': divisionMethod
    };
  }
}

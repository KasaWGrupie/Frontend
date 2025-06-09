enum MoneyTransferStatus { confirmed, rejected, pending }

class MoneyTransfer {
  late final int senderId;
  late final int recipientId;
  late final double amount;
  late final int groupId;
  late final MoneyTransferStatus status;
  late final DateTime? finalizedAt;

  MoneyTransfer({
    required this.senderId,
    required this.recipientId,
    required this.amount,
    required this.groupId,
    required this.status,
    this.finalizedAt,
  });

  MoneyTransfer.fromJson(Map<String, dynamic> json) {
    senderId = json['senderId']! as int;
    recipientId = json['recipientId'];
    amount = double.parse(json['amount']! as String);
    groupId = json['groupId'] as int;
    status = MoneyTransferStatus.values.firstWhere(
      (e) => e.name == json['status'],
      orElse: () => MoneyTransferStatus.pending,
    );
    finalizedAt = json['finalizedAt'] != null
        ? DateTime.parse(json['finalizedAt']! as String)
        : null;
  }

  Map<String, dynamic> toJson() {
    return {
      'senderId': senderId,
      'recipientId': recipientId,
      'amount': amount.toStringAsFixed(2),
      'groupId': groupId,
      'status': status.name,
      'finalizedAt': finalizedAt?.toIso8601String(),
    };
  }
}

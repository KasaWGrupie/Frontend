enum MoneyRequestStatus { pending, cancelled, paid, closed, rejected }

class MoneyRequest {
  late final String senderId;
  late final String recipientId;
  late final double moneyValue;
  late final List<String> groups;
  late final MoneyRequestStatus status;
  late final DateTime? finalizedAt;

  MoneyRequest({
    required this.senderId,
    required this.recipientId,
    required this.moneyValue,
    required this.groups,
    required this.status,
    this.finalizedAt,
  });

  MoneyRequest.fromJson(Map<String, Object?> json) {
    senderId = json['senderId']! as String;
    recipientId = json['recipientId']! as String;
    moneyValue = double.parse(json['moneyValue']! as String);
    groups = List<String>.from(json['groups'] as List);
    status = MoneyRequestStatus.values.firstWhere(
      (e) => e.name == json['status'],
      orElse: () => MoneyRequestStatus.pending,
    );
    finalizedAt = json['finalizedAt'] != null
        ? DateTime.parse(json['finalizedAt']! as String)
        : null;
  }

  Map<String, Object?> toJson() {
    return {
      'senderId': senderId,
      'recipientId': recipientId,
      'moneyValue': moneyValue.toStringAsFixed(2),
      'groups': groups,
      'status': status.name,
      'finalizedAt': finalizedAt?.toIso8601String(),
    };
  }
}

import 'package:kasa_w_grupie/models/group.dart';

enum MoneyRequestStatus { pending, cancelled, paid, closed, rejected }

class MoneyRequest {
  late final int id;
  late final int senderId;
  late final int recipientId;
  late final double moneyValue;
  late final List<int> groups;
  late final MoneyRequestStatus status;
  late final DateTime? finalizedAt;
  late final CurrencyEnum currency;

  MoneyRequest({
    required this.id,
    required this.senderId,
    required this.recipientId,
    required this.moneyValue,
    required this.groups,
    required this.status,
    required this.currency,
    this.finalizedAt,
  });

  MoneyRequest.fromJson(Map<String, dynamic?> json) {
    id = json["id"]! as int;
    senderId = json['senderId']! as int;
    recipientId = json['recipientId']! as int;
    moneyValue = double.parse(json['moneyValue']! as String);
    groups = List<int>.from(json['groups'] as List);
    status = MoneyRequestStatus.values.firstWhere(
      (e) => e.name == json['status'],
      orElse: () => MoneyRequestStatus.pending,
    );
    currency = CurrencyEnum.values.firstWhere(
      (e) => e.name == json['currency'],
      orElse: () => CurrencyEnum.eur,
    );
    finalizedAt = json['finalizedAt'] != null
        ? DateTime.parse(json['finalizedAt']! as String)
        : null;
  }

  Map<String, Object?> toJson() {
    return {
      'id': id,
      'senderId': senderId,
      'recipientId': recipientId,
      'moneyValue': moneyValue.toStringAsFixed(2),
      'groups': groups,
      'status': status.name,
      'currency': currency.name,
      'finalizedAt': finalizedAt?.toIso8601String(),
    };
  }
}

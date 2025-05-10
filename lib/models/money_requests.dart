import 'package:kasa_w_grupie/models/group.dart';

enum MoneyRequestStatus { pending, cancelled, paid, closed, rejected }

class MoneyRequest {
  late final String id;
  late final String senderId;
  late final String recipientId;
  late final double moneyValue;
  late final List<String> groups;
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

  MoneyRequest.fromJson(Map<String, Object?> json) {
    id = json["id"]! as String;
    senderId = json['senderId']! as String;
    recipientId = json['recipientId']! as String;
    moneyValue = double.parse(json['moneyValue']! as String);
    groups = List<String>.from(json['groups'] as List);
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

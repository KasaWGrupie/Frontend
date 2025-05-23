import 'package:kasa_w_grupie/models/money_requests.dart';
import 'package:kasa_w_grupie/models/money_transfer.dart';

class SettlementItem {
  final String senderId;
  final String recipientId;
  final double amount;
  final List<String> groupIds;
  final DateTime finalizedAt;
  final bool isTransfer;
  final bool isRejected;
  SettlementItem({
    required this.senderId,
    required this.recipientId,
    required this.amount,
    required this.groupIds,
    required this.finalizedAt,
    required this.isTransfer,
    required this.isRejected,
  });

  // Constructor to create from MoneyRequest
  factory SettlementItem.fromMoneyRequest(MoneyRequest request) {
    return SettlementItem(
      senderId: request.senderId,
      recipientId: request.recipientId,
      amount: request.moneyValue,
      groupIds: request.groups,
      finalizedAt: request.finalizedAt!,
      isTransfer: false,
      isRejected: request.status == MoneyRequestStatus.rejected,
    );
  }

  // Constructor to create from MoneyTransfer
  factory SettlementItem.fromMoneyTransfer(MoneyTransfer transfer) {
    return SettlementItem(
      senderId: transfer.senderId,
      recipientId: transfer.recipientId,
      amount: transfer.amount,
      groupIds: [transfer.groupId],
      finalizedAt: transfer.finalizedAt!,
      isTransfer: true,
      isRejected: false,
    );
  }
}

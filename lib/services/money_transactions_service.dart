import 'package:kasa_w_grupie/models/group.dart';
import 'package:kasa_w_grupie/models/money_requests.dart';
import 'package:kasa_w_grupie/models/money_transfer.dart';
import 'package:kasa_w_grupie/services/auth_service.dart';
import 'package:kasa_w_grupie/services/users_service.dart';

abstract class MoneyTransactionService {
  Future<List<MoneyRequest>> getMoneyRequestsForUser();
  Future<List<MoneyRequest>> getRejectedMoneyRequestsForUser();
  Future<List<MoneyTransfer>> getMoneyTransfersForUser();
  Future<void> markAsPaid(int requestId);
  Future<void> rejectRequest(int requestId);
}

class MoneyTransactionServiceMock implements MoneyTransactionService {
  final UsersService usersService;
  late final List<MoneyRequest> allMoneyRequests;
  late final List<MoneyTransfer> allMoneyTransfers;

  MoneyTransactionServiceMock({
    required this.usersService,
  }) {
    initializeRequests();
    initializeTransfers();
  }

  Future<void> initializeTransfers() async {
    final user = await usersService.getCurrentUser();
    if (user == null) {
      allMoneyTransfers = [];
      return;
    }

    final loggedUserId = user.id;

    allMoneyTransfers = [
      MoneyTransfer(
        senderId: loggedUserId,
        recipientId: 2,
        amount: 100.0,
        groupId: 1,
        status: MoneyTransferStatus.pending,
        finalizedAt: null,
      ),
      MoneyTransfer(
        senderId: 2,
        recipientId: loggedUserId,
        amount: 30.0,
        groupId: 1,
        status: MoneyTransferStatus.confirmed,
        finalizedAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
      MoneyTransfer(
        senderId: loggedUserId,
        recipientId: 6,
        amount: 50.0,
        groupId: 2,
        status: MoneyTransferStatus.confirmed,
        finalizedAt: DateTime.now().subtract(const Duration(days: 4)),
      ),
      MoneyTransfer(
        senderId: loggedUserId,
        recipientId: 7,
        amount: 70.0,
        groupId: 1,
        status: MoneyTransferStatus.confirmed,
        finalizedAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
      MoneyTransfer(
        senderId: 7,
        recipientId: loggedUserId,
        amount: 40.0,
        groupId: 1,
        status: MoneyTransferStatus.confirmed,
        finalizedAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
    ];
  }

  Future<void> initializeRequests() async {
    final user = await usersService.getCurrentUser();
    if (user == null) {
      allMoneyRequests = [];
      return;
    }

    final loggedUserId = user.id;

    allMoneyRequests = [
      MoneyRequest(
        id: 1,
        senderId: 2,
        recipientId: loggedUserId,
        moneyValue: 50.0,
        groups: [0],
        status: MoneyRequestStatus.pending,
        currency: CurrencyEnum.pln,
        finalizedAt: null,
      ),
      MoneyRequest(
        id: 2,
        senderId: 2,
        recipientId: loggedUserId,
        moneyValue: 20.0,
        groups: [0],
        status: MoneyRequestStatus.closed,
        currency: CurrencyEnum.gbp,
        finalizedAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      MoneyRequest(
        id: 3,
        senderId: 6,
        recipientId: loggedUserId,
        moneyValue: 30.0,
        groups: [0],
        status: MoneyRequestStatus.pending,
        currency: CurrencyEnum.eur,
        finalizedAt: null,
      ),
      MoneyRequest(
        id: 4,
        senderId: loggedUserId,
        recipientId: 7,
        moneyValue: 40.0,
        groups: [0],
        status: MoneyRequestStatus.closed,
        currency: CurrencyEnum.gbp,
        finalizedAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
      MoneyRequest(
        id: 5,
        senderId: loggedUserId,
        recipientId: 7,
        moneyValue: 40.0,
        groups: [0, 0],
        status: MoneyRequestStatus.rejected,
        currency: CurrencyEnum.usd,
        finalizedAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
    ];
  }

  @override
  Future<List<MoneyRequest>> getMoneyRequestsForUser() async {
    final user = await usersService.getCurrentUser();
    if (user == null) return [];

    return allMoneyRequests
        .where((r) =>
            r.status == MoneyRequestStatus.pending && r.recipientId == user.id)
        .toList();
  }

  @override
  Future<List<MoneyRequest>> getRejectedMoneyRequestsForUser() async {
    final user = await usersService.getCurrentUser();
    if (user == null) return [];

    return allMoneyRequests
        .where((r) =>
            r.senderId == user.id && r.status == MoneyRequestStatus.rejected)
        .toList();
  }

  @override
  Future<List<MoneyTransfer>> getMoneyTransfersForUser() async {
    final user = await usersService.getCurrentUser();
    if (user == null) return [];

    return allMoneyTransfers
        .where((t) =>
            (t.senderId == user.id || t.recipientId == user.id) &&
            t.status == MoneyTransferStatus.confirmed)
        .toList();
  }

  @override
  Future<void> markAsPaid(int requestId) async {
    allMoneyRequests.removeWhere((request) => request.id == requestId);
  }

  @override
  Future<void> rejectRequest(int requestId) async {
    allMoneyRequests.removeWhere((request) => request.id == requestId);
  }
}

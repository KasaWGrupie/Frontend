import 'package:kasa_w_grupie/models/money_requests.dart';
import 'package:kasa_w_grupie/services/auth_service.dart';

abstract class MoneyRequestService {
  Future<List<MoneyRequest>> getMoneyRequestsForUser();
  Future<List<MoneyRequest>> getSettlementsForUser();
}

class MoneyRequestServiceMock implements MoneyRequestService {
  final AuthService authService;
  late final List<MoneyRequest> allMoneyRequests;

  MoneyRequestServiceMock({required this.authService}) {
    initializeRequests();
  }

  Future<void> initializeRequests() async {
    final user = await authService.currentUser();
    if (user == null) {
      allMoneyRequests = [];
      return;
    }

    final loggedUserId = user.id;

    allMoneyRequests = [
      MoneyRequest(
        senderId: loggedUserId,
        recipientId: "2",
        moneyValue: 50.0,
        groups: ["0"],
        status: MoneyRequestStatus.pending,
        finalizedAt: null,
      ),
      MoneyRequest(
        senderId: "2",
        recipientId: loggedUserId,
        moneyValue: 20.0,
        groups: ["0"],
        status: MoneyRequestStatus.closed,
        finalizedAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      MoneyRequest(
        senderId: "6",
        recipientId: loggedUserId,
        moneyValue: 30.0,
        groups: ["0"],
        status: MoneyRequestStatus.pending,
        finalizedAt: null,
      ),
      MoneyRequest(
        senderId: loggedUserId,
        recipientId: "7",
        moneyValue: 40.0,
        groups: ["0"],
        status: MoneyRequestStatus.closed,
        finalizedAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
      MoneyRequest(
        senderId: loggedUserId,
        recipientId: "7",
        moneyValue: 40.0,
        groups: ["0", "0"],
        status: MoneyRequestStatus.rejected,
        finalizedAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
    ];
  }

  @override
  Future<List<MoneyRequest>> getMoneyRequestsForUser() async {
    final user = await authService.currentUser();
    if (user == null) return [];

    return allMoneyRequests
        .where((r) => r.status == MoneyRequestStatus.pending)
        .toList();
  }

  @override
  Future<List<MoneyRequest>> getSettlementsForUser() async {
    final user = await authService.currentUser();
    if (user == null) return [];

    return allMoneyRequests
        .where((r) =>
            ((r.senderId == user.id || r.recipientId == user.id) &&
                r.status == MoneyRequestStatus.closed) ||
            (r.senderId == user.id && r.status == MoneyRequestStatus.rejected))
        .toList();
  }
}

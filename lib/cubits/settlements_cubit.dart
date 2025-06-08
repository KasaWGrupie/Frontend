import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kasa_w_grupie/models/group.dart';
import 'package:kasa_w_grupie/models/money_requests.dart';
import 'package:kasa_w_grupie/models/user.dart';
import 'package:kasa_w_grupie/screens/settlements_screen/widgets/settlement_item.dart';
import 'package:kasa_w_grupie/services/group_service.dart';
import 'package:kasa_w_grupie/services/money_transactions_service.dart';
import 'package:kasa_w_grupie/services/users_service.dart';

class SettlementsCubit extends Cubit<SettlementsState> {
  final MoneyTransactionService _moneyTransactionService;
  final GroupService _groupService;
  final UsersService _usersService;

  SettlementsCubit({
    required MoneyTransactionService moneyTransactionService,
    required GroupService groupService,
    required UsersService usersService,
  })  : _moneyTransactionService = moneyTransactionService,
        _groupService = groupService,
        _usersService = usersService,
        super(SettlementsState.initial());

  Future<void> loadData() async {
    emit(SettlementsState.loading());

    try {
      final rejectedRequests =
          await _moneyTransactionService.getRejectedMoneyRequestsForUser();
      final moneyTransfers =
          await _moneyTransactionService.getMoneyTransfersForUser();
      final groups = await _groupService.getGroupsForUser();
      final user = await _usersService.getCurrentUser();
      final moneyRequests =
          await _moneyTransactionService.getMoneyRequestsForUser();

      final settlements = [
        ...rejectedRequests
            .where((r) => r.finalizedAt != null)
            .map(SettlementItem.fromMoneyRequest),
        ...moneyTransfers
            .where((t) => t.finalizedAt != null)
            .map(SettlementItem.fromMoneyTransfer),
      ]..sort((a, b) => b.finalizedAt.compareTo(a.finalizedAt));

      emit(SettlementsState.loaded(
        settlements: settlements,
        groups: groups,
        user: user!,
        moneyRequests: moneyRequests,
      ));
    } catch (e) {
      emit(SettlementsState.error('Failed to load data: $e'));
    }
  }

  void markRequestAsPaid(MoneyRequest request) async {
    if (state is SettlementsLoaded) {
      await _moneyTransactionService.markAsPaid(request.id);
      await loadData();
    }
  }

  void rejectRequest(MoneyRequest request) async {
    if (state is SettlementsLoaded) {
      await _moneyTransactionService.rejectRequest(request.id);
      await loadData();
    }
  }
}

abstract class SettlementsState {
  const SettlementsState();

  factory SettlementsState.initial() => SettlementsInitial();
  factory SettlementsState.loading() => SettlementsLoading();
  factory SettlementsState.loaded({
    required List<SettlementItem> settlements,
    required List<Group> groups,
    required User user,
    required List<MoneyRequest> moneyRequests,
  }) =>
      SettlementsLoaded(
        settlements: settlements,
        groups: groups,
        user: user,
        moneyRequests: moneyRequests,
      );
  factory SettlementsState.error(String message) => SettlementsError(message);
}

class SettlementsInitial extends SettlementsState {}

class SettlementsLoading extends SettlementsState {}

class SettlementsLoaded extends SettlementsState {
  final List<SettlementItem> settlements;
  final List<Group> groups;
  final User user;
  final List<MoneyRequest> moneyRequests;

  SettlementsLoaded({
    required this.settlements,
    required this.groups,
    required this.user,
    required this.moneyRequests,
  });
}

class SettlementsError extends SettlementsState {
  final String message;
  SettlementsError(this.message);
}

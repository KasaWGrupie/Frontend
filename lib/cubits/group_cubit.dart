import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kasa_w_grupie/models/expense.dart';
import 'package:kasa_w_grupie/models/group.dart';
import 'package:kasa_w_grupie/models/settlement.dart';
import 'package:kasa_w_grupie/models/user.dart';
import 'package:kasa_w_grupie/services/auth_service.dart';
import 'package:kasa_w_grupie/services/group_service.dart';
import 'package:kasa_w_grupie/services/users_service.dart';

sealed class GroupState {}

class GroupLoading extends GroupState {}

class GroupLoaded extends GroupState {
  GroupLoaded({
    required this.group,
    required this.expenses,
    required this.balances,
    required this.settlements,
    required this.members,
    required this.currentUserId,
  }) {
    grouped = {};
    for (var expense in expenses) {
      final key =
          DateTime(expense.date.year, expense.date.month, expense.date.day);
      if (grouped.containsKey(key)) {
        grouped[key]!.add(expense);
      } else {
        grouped.putIfAbsent(key, () => [expense]);
      }
    }
    for (var key in grouped.keys) {
      grouped[key]!.sort((a, b) =>
          b.date.millisecondsSinceEpoch - a.date.millisecondsSinceEpoch);
    }
  }

  final Group group;
  final List<Expense> expenses;
  late Map<DateTime, List<Expense>> grouped;
  final Map<String, double> balances;
  final List<Settlement> settlements;
  final List<User> members;
  final String currentUserId;
}

class GroupError extends GroupState {
  GroupError(this.message);
  final String message;
}

class GroupCubit extends Cubit<GroupState> {
  GroupCubit({
    required this.groupId,
    required this.groupService,
    required this.usersService,
    required this.authService,
  }) : super(GroupLoading());
  final String groupId;
  final GroupService groupService;
  final UsersService usersService;
  final AuthService authService;

  Future<void> fetch() async {
    emit(GroupLoading());
    await reload();
  }

  Future<void> reload() async {
    try {
      Group group = await groupService.getGroupById(groupId);
      final balances = await groupService.getBalances(groupId);
      final settlements = calculateSettlements(balances);
      final members = <User>[];
      for (var userId in group.membersId) {
        var user = await usersService.getUser(userId);
        if (user == null) {
          emit(GroupError("Error loading group"));
          return;
        }
        members.add(user);
      }

      return emit(
        GroupLoaded(
          group: group,
          expenses: await groupService.getExpensesForGroup(groupId),
          balances: balances,
          settlements: settlements,
          members: members,
          currentUserId: authService.userId,
        ),
      );
    } catch (e) {
      emit(GroupError("Error loading group"));
      return;
    }
  }

  List<Settlement> calculateSettlements(Map<String, double> balances) {
    final creditors = <String, double>{};
    final debtors = <String, double>{};
    balances.forEach((user, balance) {
      if (balance > 0) {
        creditors[user] = balance;
      } else if (balance < 0) {
        debtors[user] = -balance;
      }
    });

    final settlements = <Settlement>[];
    final creditorsSorted = creditors.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final debtorsSorted = debtors.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    while (creditorsSorted.isNotEmpty && debtorsSorted.isNotEmpty) {
      if (creditorsSorted.isEmpty && debtorsSorted.first.value.abs() > 0.01) {
        throw Exception('Error while calculating settlements');
      }
      if (debtorsSorted.isEmpty && creditorsSorted.first.value.abs() > 0.01) {
        throw Exception('Error while calculating settlements');
      }

      final creditor = creditorsSorted.first;
      final debtor = debtorsSorted.first;

      final transferAmount =
          creditor.value < debtor.value ? creditor.value : debtor.value;

      settlements.add(
        Settlement(
          from: debtor.key,
          to: creditor.key,
          amount: transferAmount,
        ),
      );

      if (creditor.value == transferAmount) {
        creditorsSorted.removeAt(0);
      } else {
        creditorsSorted[0] = MapEntry(
          creditor.key,
          creditor.value - transferAmount,
        );
      }

      if (debtor.value == transferAmount) {
        debtorsSorted.removeAt(0);
      } else {
        debtorsSorted[0] = MapEntry(
          debtor.key,
          debtor.value - transferAmount,
        );
      }
    }

    return settlements;
  }
}

import 'package:flutter_bloc/flutter_bloc.dart';

class GroupCubit extends Cubit<GroupState> {
  GroupCubit(this.groupId, this._groupRepository) : super(GroupLoading());
  final String groupId;
  final GroupRepository _groupRepository;

  Future<void> fetch() async {
    emit(GroupLoading());
    await reload();
  }

  Future<void> reload() async {
    final details = await _groupRepository.getDetails(groupId);
    if (details == null) {
      emit(GroupError('Group not found'));
      return;
    }
    final balances = await _groupRepository.getBalances(groupId);
    final settlements = calculateSettlements(balances);
    emit(
      GroupLoaded(
        details: details,
        balances: balances,
        settlements: settlements,
      ),
    );
  }

  List<Settlement> calculateSettlements(Map<String, Decimal> balances) {
    final creditors = <String, Decimal>{};
    final debtors = <String, Decimal>{};
    balances.forEach((user, balance) {
      if (balance > Decimal.zero) {
        creditors[user] = balance;
      } else if (balance < Decimal.zero) {
        debtors[user] = -balance;
      }
    });

    final settlements = <Settlement>[];
    final creditorsSorted = creditors.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final debtorsSorted = debtors.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    while (creditorsSorted.isNotEmpty && debtorsSorted.isNotEmpty) {
      if (creditorsSorted.isEmpty &&
          debtorsSorted.first.value.abs() > Decimal.parse('0.01')) {
        throw Exception('Error while calculating settlements');
      }
      if (debtorsSorted.isEmpty &&
          creditorsSorted.first.value.abs() > Decimal.parse('0.01')) {
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

  Future<bool> addMember(String email) async {
    if (state is GroupLoaded) {
      final loadedState = state as GroupLoaded;
      final details = loadedState.details;
      final members = details.members;
      if (members.any((element) => element.email == email)) {
        return false;
      }
      final ret = await _groupRepository.addMember(groupId, email);
      if (ret) {
        await reload();
        return true;
      }
      return false;
    }
    throw Exception('Group not loaded');
  }
}

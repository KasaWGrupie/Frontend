import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kasa_w_grupie/models/group.dart';
import 'package:kasa_w_grupie/services/friends_service.dart';

abstract class GroupBalanceState {}

class GroupBalanceInitial extends GroupBalanceState {}

class GroupBalanceLoading extends GroupBalanceState {}

class GroupBalanceLoaded extends GroupBalanceState {
  final List<Map<String, dynamic>> groupBalances;
  final double totalBalance;
  final CurrencyEnum totalBalanceCurrency;

  GroupBalanceLoaded(
      {required this.groupBalances,
      required this.totalBalance,
      required this.totalBalanceCurrency});
}

class GroupBalanceError extends GroupBalanceState {
  final String message;

  GroupBalanceError(this.message);
}

class GroupBalanceCubit extends Cubit<GroupBalanceState> {
  final FriendsService friendsService;

  GroupBalanceCubit({required this.friendsService})
      : super(GroupBalanceInitial());

  // Load the group balances
  Future<void> loadGroupBalances(int userId) async {
    emit(GroupBalanceLoading());
    try {
      final groupBalances =
          await friendsService.getUserBalancesWithGroups(userId);
      final balanceData = await friendsService.getUserBalances(userId);
      final double totalBalance = balanceData["isOwedToUser"] == true
          ? balanceData["amount"] ?? 0.0
          : -(balanceData["amount"] ?? 0.0);
      // Find most common currency
      final currencyCounts = <CurrencyEnum, int>{};
      for (final group in groupBalances) {
        final currency = group["currency"];
        currencyCounts[currency] = (currencyCounts[currency] ?? 0) + 1;
      }

      // Default to USD if empty
      final mostCommonCurrency = currencyCounts.entries.isEmpty
          ? CurrencyEnum.usd
          : currencyCounts.entries
              .reduce((a, b) => a.value >= b.value ? a : b)
              .key;
      if (!isClosed) {
        emit(GroupBalanceLoaded(
          groupBalances: groupBalances,
          totalBalance: totalBalance,
          totalBalanceCurrency: mostCommonCurrency,
        ));
      }
    } catch (e) {
      if (!isClosed) {
        emit(GroupBalanceError("Failed to load group balances"));
      }
    }
  }
}

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kasa_w_grupie/services/friends_service.dart';

abstract class GroupBalanceState {}

class GroupBalanceInitial extends GroupBalanceState {}

class GroupBalanceLoading extends GroupBalanceState {}

class GroupBalanceLoaded extends GroupBalanceState {
  final List<Map<String, dynamic>> groupBalances;

  GroupBalanceLoaded({required this.groupBalances});
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
  Future<void> loadGroupBalances(String userId) async {
    emit(GroupBalanceLoading());
    try {
      final groupBalances =
          await friendsService.getUserBalancesWithGroups(userId);
      emit(GroupBalanceLoaded(groupBalances: groupBalances));
    } catch (e) {
      emit(GroupBalanceError("Failed to load group balances"));
    }
  }
}

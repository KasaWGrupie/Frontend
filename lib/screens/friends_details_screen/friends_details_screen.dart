import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kasa_w_grupie/models/group.dart';
import 'package:kasa_w_grupie/screens/base_screen.dart';
import 'package:kasa_w_grupie/screens/friends_details_screen/widgets/friend_details_header.dart';
import 'package:kasa_w_grupie/screens/friends_details_screen/widgets/group_balance_list.dart';
import 'package:kasa_w_grupie/screens/friends_details_screen/widgets/settle_up_view.dart';
import 'package:kasa_w_grupie/screens/friends_details_screen/widgets/settlte_between_groups_button.dart';
import 'package:kasa_w_grupie/services/friends_service.dart';
import 'package:kasa_w_grupie/cubits/group_balance_cubit.dart';

class FriendDetailsScreen extends StatelessWidget {
  final String friendName;
  final String friendEmail;
  final int userId;
  final FriendsService friendsService;

  const FriendDetailsScreen({
    super.key,
    required this.friendName,
    required this.friendEmail,
    required this.userId,
    required this.friendsService,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => GroupBalanceCubit(friendsService: friendsService)
        ..loadGroupBalances(userId),
      child: BaseScreen(
        title: 'Balance Details',
        backgroundColor: Colors.white,
        child: BlocBuilder<GroupBalanceCubit, GroupBalanceState>(
          builder: (context, state) {
            if (state is GroupBalanceLoading) {
              return Center(child: CircularProgressIndicator());
            } else if (state is GroupBalanceError) {
              return Center(child: Text(state.message));
            } else if (state is GroupBalanceLoaded) {
              final groupBalances = state.groupBalances;
              final totalBalance = state.totalBalance;
              final totalBalanceCurrency = state.totalBalanceCurrency;

              return buildDesign(
                  context, groupBalances, totalBalance, totalBalanceCurrency);
            } else {
              return Center(child: Text('Unknown state'));
            }
          },
        ),
      ),
    );
  }

  Widget buildDesign(
    BuildContext context,
    List<Map<String, dynamic>> groupBalances,
    double totalBalance,
    CurrencyEnum currency,
  ) {
    return Column(
      children: [
        FriendDetailsHeader(
          friendName: friendName,
          friendEmail: friendEmail,
          totalBalance: totalBalance,
          currency: currency,
        ),
        Expanded(
          child: groupBalances.isEmpty
              ? const SettleUpView()
              : GroupBalanceList(
                  groupBalances: groupBalances,
                  defaultCurrency: currency,
                ),
        ),
        if (totalBalance != 0)
          SettleBetweenGroupsButton(
              groupBalances: groupBalances, friendId: userId),
      ],
    );
  }
}

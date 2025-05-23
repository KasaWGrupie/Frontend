import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kasa_w_grupie/models/group.dart';
import 'package:kasa_w_grupie/screens/base_screen.dart';
import 'package:kasa_w_grupie/screens/friends_details_screen/utils/currency_formater.dart';
import 'package:kasa_w_grupie/screens/friends_details_screen/widgets/group_balance_card.dart';
import 'package:kasa_w_grupie/screens/friends_details_screen/widgets/friend_balance_card.dart';
import 'package:kasa_w_grupie/screens/friends_details_screen/widgets/settle_between_groups_modal.dart';
import 'package:kasa_w_grupie/services/friends_service.dart';
import 'package:kasa_w_grupie/cubits/group_balance_cubit.dart';

class FriendDetailsScreen extends StatelessWidget {
  final String friendName;
  final String friendEmail;
  final String userId;
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

              return Column(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          // Friend Info Tile
                          FriendBalanceCard(
                            friendEmail: friendEmail,
                            friendName: friendName,
                          ),
                          SizedBox(height: 20),

                          // If no balances exist, show "You are settled up"
                          if (groupBalances.isEmpty)
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Text(
                                "You are settled up",
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black),
                              ),
                            ),

                          // Group balance details
                          if (groupBalances.isNotEmpty)
                            Expanded(
                              child: ListView.builder(
                                itemCount: groupBalances.length,
                                itemBuilder: (context, index) {
                                  final groupBalance = groupBalances[index];
                                  final amount = (groupBalance["amount"] ?? 0.0)
                                      .toDouble();
                                  final currency = groupBalance["currency"] ??
                                      CurrencyEnum.pln;
                                  final formatedAmount =
                                      formatCurrency(amount, currency);

                                  return GroupBalanceCard(
                                    groupName: groupBalance["groupName"] ??
                                        "Unknown Group",
                                    balanceAmount: formatedAmount,
                                    isOwes: groupBalance["isOwed"] ?? false,
                                  );
                                },
                              ),
                            ),

                          // Total balance message
                          if (groupBalances.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: RichText(
                                text: TextSpan(
                                  text: "Total balance: ",
                                  style: DefaultTextStyle.of(context)
                                      .style
                                      .copyWith(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                  children: [
                                    TextSpan(
                                      text: totalBalance == 0
                                          ? "You are settled up"
                                          : "${totalBalance >= 0 ? "+" : "-"} ${formatCurrency(totalBalance.abs(), totalBalanceCurrency)}",
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: totalBalance > 0
                                            ? Colors.green
                                            : (totalBalance < 0
                                                ? Colors.red
                                                : Colors.black),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),

                  // Settle All button
                  if (totalBalance != 0)
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            showSettleBetweenGroupsModal(
                                context, groupBalances);
                          },
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: Text(
                            "Settle Between Groups",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                ],
              );
            } else {
              return Center(child: Text('Unknown state'));
            }
          },
        ),
      ),
    );
  }
}

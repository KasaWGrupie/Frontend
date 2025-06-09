import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kasa_w_grupie/cubits/friends_cubit.dart';
import 'package:kasa_w_grupie/cubits/group_balance_cubit.dart';
import 'package:kasa_w_grupie/models/group.dart';
import 'package:kasa_w_grupie/screens/friends_details_screen/friends_details_screen.dart';
import 'package:kasa_w_grupie/screens/friends_details_screen/utils/currency_formater.dart';
import 'package:kasa_w_grupie/services/friends_service.dart';

class MyFriendsTab extends StatelessWidget {
  final FriendsService friendsService;

  const MyFriendsTab({super.key, required this.friendsService});

  // Helper function to get balance info
  String getBalanceInfo(double totalBalance, CurrencyEnum currency) {
    if (totalBalance > 0) {
      return "Owes you: ${formatCurrency(totalBalance, currency)}";
    } else if (totalBalance < 0) {
      return "You owe: ${formatCurrency(totalBalance.abs(), currency)}";
    } else {
      return "No debts";
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FriendsCubit, FriendsState>(
      builder: (context, state) {
        if (state is FriendsLoading) {
          return Center(child: CircularProgressIndicator());
        } else if (state is FriendsLoaded) {
          if (state.friends.isEmpty) {
            return Center(child: Text("You have no friends yet"));
          }

          return ListView.builder(
            itemCount: state.friends.length,
            itemBuilder: (context, index) {
              final friend = state.friends[index];

              return BlocProvider(
                create: (context) => GroupBalanceCubit(
                  friendsService: friendsService,
                )..loadGroupBalances(friend.id),
                child: BlocBuilder<GroupBalanceCubit, GroupBalanceState>(
                  builder: (context, balanceState) {
                    String balanceInfo = "Loading...";

                    if (balanceState is GroupBalanceLoaded) {
                      balanceInfo = getBalanceInfo(balanceState.totalBalance,
                          balanceState.totalBalanceCurrency);
                    } else if (balanceState is GroupBalanceError) {
                      balanceInfo = "Error loading balance";
                    }

                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.grey.shade300,
                        child: Icon(Icons.person, color: Colors.white),
                      ),
                      title: Text(friend.name),
                      subtitle: Text(balanceInfo),
                      trailing: Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => FriendDetailsScreen(
                              userId: friend.id,
                              friendName: friend.name,
                              friendEmail: friend.email,
                              friendsService: friendsService,
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              );
            },
          );
        } else if (state is FriendsError) {
          return Center(child: Text(state.message));
        }
        return Center(child: Text("Loading friends..."));
      },
    );
  }
}

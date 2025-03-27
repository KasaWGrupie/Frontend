import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kasa_w_grupie/cubits/friends_cubit.dart';
import 'package:kasa_w_grupie/services/friends_service.dart';

class MyFriendsTab extends StatelessWidget {
  final FriendsService friendsService;

  const MyFriendsTab({super.key, required this.friendsService});

  // Helper function to get balance info
  String getBalanceInfo(double owesAmount, double owedAmount) {
    if (owesAmount > 0) {
      return "Owes you: ${owesAmount.toStringAsFixed(2)}";
    } else if (owedAmount > 0) {
      return "You owe: ${owedAmount.toStringAsFixed(2)}";
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

              return FutureBuilder<Map<String, dynamic>>(
                future: friendsService.getUserBalances(int.parse(friend.id)),
                builder: (context, snapshot) {
                  String balanceInfo = "Loading...";

                  if (snapshot.connectionState == ConnectionState.done) {
                    if (snapshot.hasData) {
                      final data = snapshot.data!;
                      final bool? isOwedToUser = data["isOwedToUser"];
                      final double amount = data["amount"];

                      balanceInfo = getBalanceInfo(
                          amount, isOwedToUser == true ? 0.0 : amount);
                    } else {
                      balanceInfo = "Error loading balance";
                    }
                  }

                  return ListTile(
                    leading: CircleAvatar(child: Icon(Icons.person)),
                    title: Text(friend.name),
                    subtitle: Text(balanceInfo),
                    trailing: Icon(Icons.arrow_forward_ios),
                  );
                },
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

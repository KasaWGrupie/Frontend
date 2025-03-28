import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kasa_w_grupie/screens/base_screen.dart';
import 'package:kasa_w_grupie/services/friends_service.dart';
import 'package:kasa_w_grupie/cubits/group_balance_cubit.dart';

class FriendDetailsScreen extends StatefulWidget {
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
  FriendDetailsScreenState createState() => FriendDetailsScreenState();
}

class FriendDetailsScreenState extends State<FriendDetailsScreen> {
  double totalBalance = 0.0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchTotalBalance();
  }

  Future<void> fetchTotalBalance() async {
    try {
      final balanceData =
          await widget.friendsService.getUserBalances(widget.userId);
      final bool? isOwedToUser = balanceData["isOwedToUser"];
      final double amount = balanceData["amount"] ?? 0.0;

      setState(() {
        totalBalance = isOwedToUser == true ? amount : -amount;
        isLoading = false;
      });
    } catch (error) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => GroupBalanceCubit(
        friendsService: widget.friendsService,
      )..loadGroupBalances(widget.userId),
      child: BaseScreen(
        title: 'Balance Details',
        child: BlocBuilder<GroupBalanceCubit, GroupBalanceState>(
          builder: (context, state) {
            if (state is GroupBalanceLoading || isLoading) {
              return Center(child: CircularProgressIndicator());
            } else if (state is GroupBalanceError) {
              return Center(child: Text(state.message));
            } else if (state is GroupBalanceLoaded) {
              final groupBalances = state.groupBalances;

              return Column(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          // User Info Tile
                          Card(
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ListTile(
                              leading: CircleAvatar(
                                radius: 30,
                                child: Icon(Icons.person,
                                    size: 30, color: Colors.white),
                              ),
                              title: Text(
                                widget.friendName,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              subtitle: Text(
                                widget.friendEmail,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      color: Colors.grey,
                                    ),
                              ),
                            ),
                          ),
                          SizedBox(height: 20),

                          // Group balance details
                          if (groupBalances.isNotEmpty)
                            Expanded(
                              child: ListView.builder(
                                itemCount: groupBalances.length,
                                itemBuilder: (context, index) {
                                  final groupBalance = groupBalances[index];

                                  final groupName = groupBalance["groupName"] ??
                                      "Unknown Group";
                                  final balanceAmount =
                                      (groupBalance["amount"] ?? 0.0)
                                          .toDouble();
                                  final isOwes =
                                      groupBalance["isOwed"] ?? false;

                                  final balanceText =
                                      isOwes ? "User owes you: " : "You owe: ";
                                  final formattedAmount =
                                      "${isOwes ? "+" : "-"} ${balanceAmount.abs().toStringAsFixed(2)}";

                                  return Card(
                                    elevation: 4,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: ListTile(
                                      title: Text(
                                        groupName,
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      subtitle: RichText(
                                        text: TextSpan(
                                          text: balanceText,
                                          style: DefaultTextStyle.of(context)
                                              .style,
                                          children: [
                                            TextSpan(
                                              text: formattedAmount,
                                              style: TextStyle(
                                                color: isOwes
                                                    ? Colors.green
                                                    : Colors.red,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      trailing: ElevatedButton(
                                        onPressed: () {},
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: isOwes
                                              ? Colors.green
                                              : Colors.red,
                                        ),
                                        child: Text(isOwes ? "Settle" : "Pay"),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),

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

                          // Total balance message
                          if (groupBalances.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: RichText(
                                text: TextSpan(
                                  text: "Total balance: ", // Normal color
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
                                          : "${totalBalance >= 0 ? "+" : "-"} ${totalBalance.abs().toStringAsFixed(2)}",
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

                  // Settle All button at the bottom
                  if (totalBalance != 0)
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {},
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

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kasa_w_grupie/cubits/friends_cubit.dart';

class SentRequestsTab extends StatelessWidget {
  const SentRequestsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FriendsCubit, FriendsState>(
      builder: (context, state) {
        if (state is FriendsLoading) {
          return Center(child: CircularProgressIndicator());
        } else if (state is FriendsLoaded) {
          if (state.sentRequests.isEmpty) {
            return Center(child: Text("You didn't send any friend requests"));
          }

          return ListView.builder(
            itemCount: state.sentRequests.length,
            itemBuilder: (context, index) {
              final friend = state.sentRequests[index];
              return ListTile(
                leading: CircleAvatar(child: Icon(Icons.person)),
                title: Text(friend.name),
                subtitle: Text(friend.email),
                trailing: CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.orangeAccent,
                  child: IconButton(
                    onPressed: () {
                      // Show confirmation dialog
                      _showConfirmDialog(context, friend);
                    },
                    icon: Icon(Icons.cancel, color: Colors.white),
                  ),
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

  // Confirmation dialog to withdraw the request
  void _showConfirmDialog(BuildContext context, friend) {
    final friendsCubit = context.read<FriendsCubit>();

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text("Withdraw Friend Request"),
          content: Text(
              "Are you sure you want to withdraw your friend request to ${friend.name}?"),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                friendsCubit.withdrawFriendRequest(friend.id);
              },
              child: Text("Yes"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: Text("No"),
            ),
          ],
        );
      },
    );
  }
}

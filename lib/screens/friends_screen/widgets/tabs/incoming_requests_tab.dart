import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kasa_w_grupie/cubits/friends_cubit.dart';

class IncomingRequestsTab extends StatelessWidget {
  const IncomingRequestsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FriendsCubit, FriendsState>(
      builder: (context, state) {
        if (state is FriendsLoading) {
          return Center(child: CircularProgressIndicator());
        } else if (state is FriendsLoaded) {
          if (state.friendRequests.isEmpty) {
            return Center(child: Text("No incoming requests."));
          }

          return ListView.builder(
            itemCount: state.friendRequests.length,
            itemBuilder: (context, index) {
              final request = state.friendRequests[index];
              return ListTile(
                leading: CircleAvatar(child: Icon(Icons.person)),
                title: Text(request.user.name),
                subtitle: Text(request.user.email),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: const Color.fromARGB(255, 119, 180, 121),
                      child: IconButton(
                        onPressed: () {
                          context
                              .read<FriendsCubit>()
                              .acceptFriendRequest(request.requestId);
                        },
                        icon: Icon(Icons.check, color: Colors.white),
                      ),
                    ),
                    SizedBox(width: 8),
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: const Color.fromARGB(255, 231, 79, 79),
                      child: IconButton(
                        onPressed: () {
                          context
                              .read<FriendsCubit>()
                              .declineFriendRequest(request.requestId);
                        },
                        icon: Icon(Icons.close, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        } else if (state is FriendsError) {
          return Center(child: Text(state.message));
        }
        return Center(child: Text("Loading friend requests..."));
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kasa_w_grupie/cubits/friends_cubit.dart';
import 'package:kasa_w_grupie/models/user.dart';
import 'package:kasa_w_grupie/services/friends_service.dart';

class UserProfilePreview extends StatelessWidget {
  final User user;
  final FriendsService friendsService;

  const UserProfilePreview({
    super.key,
    required this.user,
    required this.friendsService,
  });

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<FriendsCubit, FriendsState>(
      listener: (context, state) {
        // Handle state changes
        if (state is FriendsError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      builder: (context, state) {
        bool isLoading = state is FriendsLoading;

        // Friendship status
        Future<bool> isFriend = friendsService.isAlreadyFriend(user.id);
        Future<bool> hasSentRequest =
            friendsService.isRequestSentByUser(user.id);
        Future<bool> hasReceivedRequest =
            friendsService.isRequestReceived(user.id);

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Profile Picture
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: Theme.of(context).primaryColor,
                    child: const Icon(
                      Icons.person,
                      size: 50,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // User Name
                  Text(
                    user.name,
                    style: Theme.of(context).textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),

                  // User Email
                  Text(
                    user.email,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.grey,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),

                  if (isLoading)
                    const CircularProgressIndicator()
                  else
                    buildActionButton(
                      context,
                      isFriend: isFriend,
                      hasSentRequest: hasSentRequest,
                      hasReceivedRequest: hasReceivedRequest,
                      user: user,
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // Helper widget showing buttons based on friendship status
  Widget buildActionButton(
    BuildContext context, {
    required Future<bool> isFriend,
    required Future<bool> hasSentRequest,
    required Future<bool> hasReceivedRequest,
    required User user,
  }) {
    final friendsCubit = context.read<FriendsCubit>();

    return FutureBuilder<List<bool>>(
      future: Future.wait([isFriend, hasSentRequest, hasReceivedRequest]),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const CircularProgressIndicator();
        }

        final isFriendResult = snapshot.data![0];
        final hasSentRequestResult = snapshot.data![1];
        final hasReceivedRequestResult = snapshot.data![2];

        if (isFriendResult) {
          return ElevatedButton.icon(
            onPressed: () => (),
            icon: const Icon(Icons.person),
            label: const Text('You are friends'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 119, 180, 121),
            ),
          );
        } else if (hasSentRequestResult) {
          return ElevatedButton.icon(
            onPressed: () => (),
            icon: const Icon(Icons.cancel),
            label: const Text('You\'ve sent request'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orangeAccent,
            ),
          );
        } else if (hasReceivedRequestResult) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: () => (),
                icon: const Icon(Icons.pending),
                label: const Text('This user sent you an invite'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 119, 180, 121),
                ),
              ),
            ],
          );
        } else {
          return ElevatedButton.icon(
            onPressed: () => friendsCubit.sendFriendRequest(user.email),
            icon: const Icon(Icons.person_add),
            label: const Text('Add Friend'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 119, 180, 121),
            ),
          );
        }
      },
    );
  }
}

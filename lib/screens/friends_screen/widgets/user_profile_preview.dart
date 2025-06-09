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
        bool isFriend = friendsService.isAlreadyFriend(user.id);
        bool hasSentRequest = friendsService.isRequestSentByUser(user.id);
        bool hasReceivedRequest = friendsService.isRequestReceived(user.id);

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
                    backgroundImage: user.pictureUrl.isNotEmpty
                        ? NetworkImage(user.pictureUrl)
                        : null,
                    child: user.pictureUrl.isEmpty
                        ? const Icon(
                            Icons.person,
                            size: 50,
                            color: Colors.white,
                          )
                        : null,
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
    required bool isFriend,
    required bool hasSentRequest,
    required bool hasReceivedRequest,
  }) {
    final friendsCubit = context.read<FriendsCubit>();

    if (isFriend) {
      return ElevatedButton.icon(
        onPressed: () => friendsCubit.removeFriend(user.id),
        icon: const Icon(Icons.person_remove),
        label: const Text('Unfriend'),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color.fromARGB(255, 231, 79, 79),
        ),
      );
    } else if (hasSentRequest) {
      return ElevatedButton.icon(
        onPressed: () => friendsCubit.withdrawFriendRequest(user.id),
        icon: const Icon(Icons.cancel),
        label: const Text('Cancel Request'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.orangeAccent,
        ),
      );
    } else if (hasReceivedRequest) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton.icon(
            onPressed: () => friendsCubit.acceptFriendRequest(user.id),
            icon: const Icon(Icons.check),
            label: const Text('Accept'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 119, 180, 121),
            ),
          ),
          const SizedBox(width: 10),
          ElevatedButton.icon(
            onPressed: () => friendsCubit.declineFriendRequest(user.id),
            icon: const Icon(Icons.close),
            label: const Text('Reject'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 231, 79, 79),
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
  }
}

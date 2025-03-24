import 'package:flutter/material.dart';
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
                child: Icon(
                  Icons.person,
                  size: 50,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 16),

              // User Name
              Text(
                user.name,
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8),

              // User Email
              Text(
                user.email,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.grey,
                    ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),

              // Buttons based on friendship status
              () {
                if (isFriend) {
                  return ElevatedButton.icon(
                    onPressed: () async {
                      await friendsService.removeFriend(user.id);
                    },
                    icon: Icon(Icons.person_remove),
                    label: Text('Unfriend'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 231, 79, 79),
                    ),
                  );
                } else if (hasSentRequest) {
                  return ElevatedButton.icon(
                    onPressed: () async {},
                    icon: Icon(Icons.cancel),
                    label: Text('Cancel Request'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orangeAccent,
                    ),
                  );
                } else if (hasReceivedRequest) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () async {
                          await friendsService.acceptFriendRequest(user.id);
                        },
                        icon: Icon(Icons.check),
                        label: Text('Accept'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color.fromARGB(255, 119, 180, 121),
                        ),
                      ),
                      SizedBox(width: 10),
                      ElevatedButton.icon(
                        onPressed: () async {
                          await friendsService.declineFriendRequest(user.id);
                        },
                        icon: Icon(Icons.close),
                        label: Text('Reject'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color.fromARGB(255, 231, 79, 79),
                        ),
                      ),
                    ],
                  );
                } else {
                  return ElevatedButton.icon(
                    onPressed: () async {
                      await friendsService.sendFriendRequest(user.email);
                    },
                    icon: Icon(Icons.person_add),
                    label: Text('Add Friend'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 119, 180, 121),
                    ),
                  );
                }
              }(),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:kasa_w_grupie/models/user.dart';
import 'package:kasa_w_grupie/screens/friends_screen/widgets/user_profile_preview.dart';
import 'package:kasa_w_grupie/services/friends_service.dart';

class FriendSearchDelegate extends SearchDelegate<User?> {
  final FriendsService friendsService;
  final String currentUserId;

  FriendSearchDelegate({
    required this.friendsService,
    required this.currentUserId,
  });

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          // Clear the query when clicked
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final email = query.trim();
    if (email.isEmpty) {
      return Center(child: Text('Please enter a valid email'));
    }

    return FutureBuilder<User?>(
      future: friendsService.getUserByEmail(email),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final user = snapshot.data;
        if (user == null) {
          return Center(child: Text('User not found'));
        }

        return UserProfilePreview(
          user: user,
          friendsService: friendsService,
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    // TODO work on sugestions
    return Container();
  }
}

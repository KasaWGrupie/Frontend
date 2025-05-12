import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kasa_w_grupie/cubits/friends_cubit.dart';
import 'package:kasa_w_grupie/models/user.dart';
import 'package:kasa_w_grupie/screens/friends_screen/widgets/user_profile_preview.dart';
import 'package:kasa_w_grupie/services/friends_service.dart';

class FriendSearchDelegate extends SearchDelegate<User?> {
  final FriendsService friendsService;
  final String currentUserId;
  final FriendsCubit friendsCubit;

  FriendSearchDelegate({
    required this.friendsService,
    required this.currentUserId,
    required this.friendsCubit,
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

        // Skip showing the current user
        if (user.id == currentUserId) {
          return Center(child: Text('This is your account'));
        }

        return BlocProvider.value(
          value: friendsCubit,
          child: UserProfilePreview(
            user: user,
            friendsService: friendsService,
          ),
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    // TODO: build more advanced suggestions

    if (query.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search, size: 64, color: Colors.grey.shade400),
            SizedBox(height: 16),
            Text(
              'Search for users by email',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    }

    // Show loading indicator when typing
    return Center(
      child: CircularProgressIndicator(),
    );
  }
}

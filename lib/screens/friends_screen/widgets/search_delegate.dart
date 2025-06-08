import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kasa_w_grupie/cubits/friends_cubit.dart';
import 'package:kasa_w_grupie/models/user.dart';
import 'package:kasa_w_grupie/screens/friends_screen/widgets/user_profile_preview.dart';
import 'package:kasa_w_grupie/services/friends_service.dart';
import 'package:kasa_w_grupie/services/users_service.dart';

class FriendSearchDelegate extends SearchDelegate<User?> {
  final UsersService usersService;
  final FriendsService friendsService;
  final int currentUserId;
  final FriendsCubit friendsCubit;

  FriendSearchDelegate({
    required this.usersService,
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
      future: usersService.getUserByEmail(email),
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
    final searchText = query.trim();
    if (searchText.isEmpty) {
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

    return FutureBuilder<List<User>>(
      future: friendsService.searchUsersByEmail(searchText),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final users = snapshot.data ?? [];

        if (users.isEmpty) {
          return Center(child: Text('No users found'));
        }

        return ListView.builder(
          itemCount: users.length,
          itemBuilder: (context, index) {
            final user = users[index];

            // Skip current user
            if (user.id == currentUserId) {
              return SizedBox.shrink();
            }

            return ListTile(
              leading: Icon(Icons.person),
              // leading: CircleAvatar(
              //   backgroundImage: NetworkImage(user.profilePictureUrl ?? ''),
              // ),
              title: Text(user.name),
              subtitle: Text(user.email),
              onTap: () {
                query = user.email;
                showResults(context);
              },
            );
          },
        );
      },
    );
  }
}

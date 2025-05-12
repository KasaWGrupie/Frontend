import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kasa_w_grupie/cubits/friends_cubit.dart';
import 'package:kasa_w_grupie/screens/friends_screen/widgets/tabs/incoming_requests_tab.dart';
import 'package:kasa_w_grupie/screens/friends_screen/widgets/tabs/my_friends_tab.dart';
import 'package:kasa_w_grupie/screens/friends_screen/widgets/search_delegate.dart';
import 'package:kasa_w_grupie/screens/friends_screen/widgets/tabs/sent_requests_tab.dart';
import 'package:kasa_w_grupie/services/friends_service.dart';
import 'package:kasa_w_grupie/services/auth_service.dart';

class FriendsScreen extends StatelessWidget {
  const FriendsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final friendsService = context.read<FriendsService>();
    final authService = context.read<AuthService>();

    return BlocProvider(
      create: (context) =>
          FriendsCubit(friendsService: friendsService)..loadFriends(),
      child: Builder(
        builder: (context) {
          final friendsCubit = context.read<FriendsCubit>();

          return Scaffold(
            appBar: AppBar(
              title: buildSearchBar(
                  context, friendsService, authService, friendsCubit),
            ),
            body: BlocListener<FriendsCubit, FriendsState>(
              listener: (context, state) {
                if (state is FriendsError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(state.message)),
                  );
                }
              },
              child: buildTabContent(context, friendsService),
            ),
          );
        },
      ),
    );
  }

  // Helper widget for building search bar
  Widget buildSearchBar(
    BuildContext context,
    FriendsService friendsService,
    AuthService authService,
    FriendsCubit friendsCubit,
  ) {
    return TextField(
      readOnly: true,
      onTap: () {
        showSearch(
          context: context,
          delegate: FriendSearchDelegate(
            friendsService: friendsService,
            currentUserId: authService.userId,
            friendsCubit: friendsCubit,
          ),
        );
      },
      decoration: InputDecoration(
        hintText: 'Search to add friends...',
        prefixIcon: const Icon(Icons.search),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 10.0),
      ),
    );
  }

  // Helper widget for building tabs connected to users friends
  Widget buildTabContent(BuildContext context, FriendsService friendsService) {
    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.people), text: "My Friends"),
              Tab(icon: Icon(Icons.group_add), text: "Requests"),
              Tab(icon: Icon(Icons.hourglass_bottom), text: "My Requests"),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                MyFriendsTab(friendsService: friendsService),
                const IncomingRequestsTab(),
                const SentRequestsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

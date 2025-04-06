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
    final authService = context.read<AuthService>();
    final currentUser = authService.currentUser!;
    final friendService = MockFriendsService(currentUserId: authService.userId);

    return BlocProvider(
      create: (context) => FriendsCubit(
        friendsService: friendService,
      )..loadFriends(),
      child: Scaffold(
        appBar: AppBar(
          title: TextField(
            onTap: () {
              showSearch(
                context: context,
                delegate: FriendSearchDelegate(
                  friendsService: friendService,
                  currentUserId: authService.userId,
                ),
              );
            },
            decoration: InputDecoration(
              hintText: 'Search to add friends...',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30.0),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: EdgeInsets.symmetric(vertical: 10.0),
            ),
          ),
        ),
        body: DefaultTabController(
          length: 3,
          child: Column(
            children: [
              TabBar(
                tabs: [
                  Tab(icon: Icon(Icons.people), text: "My Friends"),
                  Tab(icon: Icon(Icons.group_add), text: "Requests"),
                  Tab(icon: Icon(Icons.hourglass_bottom), text: "My Requests"),
                ],
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    MyFriendsTab(
                      friendsService: friendService,
                    ),
                    IncomingRequestsTab(),
                    SentRequestsTab(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

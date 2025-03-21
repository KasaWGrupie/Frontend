import 'package:flutter/material.dart';

class FriendsScreen extends StatelessWidget {
  const FriendsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: TextField(
            decoration: InputDecoration(
              hintText: 'Search friends...',
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
          bottom: TabBar(
            tabs: [
              Tab(icon: Icon(Icons.people), text: "My Friends"),
              Tab(icon: Icon(Icons.group_add), text: "Requests"),
              Tab(icon: Icon(Icons.hourglass_top), text: "My Requests"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            MyFriendsTab(),
            RequestsTab(),
            MyRequestsTab(),
          ],
        ),
      ),
    );
  }
}

// Placeholder widgets for the tabs
class MyFriendsTab extends StatelessWidget {
  const MyFriendsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(child: Text("My Friends List"));
  }
}

class RequestsTab extends StatelessWidget {
  const RequestsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(child: Text("Friend Requests"));
  }
}

class MyRequestsTab extends StatelessWidget {
  const MyRequestsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(child: Text("My Sent Requests"));
  }
}

import 'dart:async';
import 'package:kasa_w_grupie/models/user.dart';

class FriendsService {
  final String currentUserId;

  FriendsService({required this.currentUserId});

  // Mock users
  final List<User> mockUsers = [
    User(id: "1", name: "John Doe", email: "john@example.com"),
    User(id: "2", name: "Jane Smith", email: "jane@example.com"),
    User(id: "3", name: "Alice Brown", email: "alice@example.com"),
    User(id: "4", name: "Bob White", email: "bob@example.com"),
    User(id: "5", name: "Johnny Depp", email: "john2@example.com"),
    User(id: "6", name: "Jane Austin", email: "jane2@example.com"),
    User(id: "7", name: "Alice Wonderland", email: "alice2@example.com"),
    User(id: "8", name: "Bob Budowniczy", email: "bob2@example.com"),
    User(id: "9", name: "Johnny Black", email: "john3@example.com"),
    User(id: "10", name: "Jane Juice", email: "jane3@example.com"),
    User(id: "11", name: "Alice Wood", email: "alice3@example.com"),
    User(id: "12", name: "Bob Builder", email: "bob3@example.com"),
  ];

  // Mock friendships for logged-in user
  final List<String> friendships = ["1", "2", "3", "4"];

  // Mock pending friend requests for logged-in user
  final List<String> friendRequests = [
    "5",
    "6",
    "7",
    "8",
    "9",
    "10",
    "11",
    "12"
  ];

  // Fetch friends for the logged-in user
  Future<List<User>> getFriends() async {
    await Future.delayed(Duration(milliseconds: 250));
    return mockUsers.where((user) => friendships.contains(user.id)).toList();
  }

  // Fetch incoming friend requests for the logged-in user
  Future<List<User>> getFriendRequests() async {
    await Future.delayed(Duration(milliseconds: 250));
    return mockUsers.where((user) => friendRequests.contains(user.id)).toList();
  }

  // Accept friend request
  Future<void> acceptFriendRequest(String friendId) async {
    await Future.delayed(Duration(milliseconds: 100));

    // Since this is only a mock service we add new friend only for currently
    // logged user, in future it will be changed

    friendRequests.remove(friendId);
    friendships.add(friendId);
  }

  // Decline friend request
  Future<void> declineFriendRequest(String friendId) async {
    await Future.delayed(Duration(milliseconds: 100));
    friendRequests.remove(friendId);
  }
}

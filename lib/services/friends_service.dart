import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:kasa_w_grupie/config/api_config.dart';
import 'package:kasa_w_grupie/models/friend_request_user.dart';
import 'package:kasa_w_grupie/models/group.dart';
import 'package:kasa_w_grupie/models/user.dart';
import 'package:kasa_w_grupie/services/auth_service.dart';
import 'package:kasa_w_grupie/services/users_service.dart';

abstract class FriendsService {
  Future<List<User>> getFriends();
  Future<List<FriendRequestUser>> getFriendRequests();
  Future<List<FriendRequestUser>> getSentRequests();
  Future<void> acceptFriendRequest(int requestId);
  Future<void> declineFriendRequest(int requestId);
  Future<void> sendFriendRequest(String email);
  Future<void> withdrawFriendRequest(int requestId);
  Future<void> removeFriend(int targetUserId);
  bool isAlreadyFriend(int targetUserId);
  bool isRequestSentByUser(int targetUserId);
  bool isRequestReceived(int targetUserId);
  Future<Map<String, dynamic>> getUserBalances(int userId);
  Future<List<Map<String, dynamic>>> getUserBalancesWithGroups(int userId);
}

class FriendsServiceApi implements FriendsService {
  final AuthService authService;
  final UsersService usersService;

  FriendsServiceApi({
    required this.authService,
    required this.usersService,
  });

  String get baseUrl => ApiConfig.baseUrl;
  int get currentUserId => authService.userId;

  @override
  Future<List<User>> getFriends() async {
    final url = Uri.parse('${ApiConfig.baseUrl}/users/friends/$currentUserId');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => User.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load friends');
    }
  }

  @override
  Future<List<FriendRequestUser>> getFriendRequests() async {
    final url = Uri.parse('$baseUrl/users/$currentUserId/friendRequests');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);

      final List<FriendRequestUser> requestUsers = [];

      for (final request in data) {
        if (request['senderId'] != currentUserId) {
          int friendId = request['senderId'];
          final user = await usersService.getUser(friendId);
          if (user != null) {
            requestUsers.add(FriendRequestUser(
              user: user,
              requestId: request['id'],
            ));
          }
        }
      }

      return requestUsers;
    } else if (response.statusCode == 404) {
      return [];
    } else {
      throw Exception('Failed to load friend requests');
    }
  }

  @override
  Future<List<FriendRequestUser>> getSentRequests() async {
    final url = Uri.parse('$baseUrl/users/$currentUserId/friendRequests');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);

      final List<FriendRequestUser> sentRequestUsers = [];

      for (final request in data) {
        if (request['receiverId'] != currentUserId) {
          int friendId = request['receiverId'];
          final user = await usersService.getUser(friendId);
          if (user != null) {
            sentRequestUsers.add(FriendRequestUser(
              user: user,
              requestId: request['id'],
            ));
          }
        }
      }

      return sentRequestUsers;
    } else if (response.statusCode == 404) {
      return [];
    } else {
      throw Exception('Failed to load friend requests');
    }
  }

  @override
  Future<void> acceptFriendRequest(int requestId) => throw UnimplementedError();
  @override
  Future<void> declineFriendRequest(int requestId) =>
      throw UnimplementedError();
  @override
  Future<void> sendFriendRequest(String email) => throw UnimplementedError();
  @override
  Future<void> withdrawFriendRequest(int requestId) =>
      throw UnimplementedError();
  @override
  Future<void> removeFriend(int targetUserId) => throw UnimplementedError();
  @override
  bool isAlreadyFriend(int targetUserId) => throw UnimplementedError();
  @override
  bool isRequestSentByUser(int targetUserId) => throw UnimplementedError();
  @override
  bool isRequestReceived(int targetUserId) => throw UnimplementedError();
  @override
  Future<Map<String, dynamic>> getUserBalances(int userId) =>
      throw UnimplementedError();
  @override
  Future<List<Map<String, dynamic>>> getUserBalancesWithGroups(int userId) =>
      throw UnimplementedError();
}

class MockFriendsService implements FriendsService {
  final AuthService authService;
  final UsersService usersService;

  MockFriendsService({
    required this.authService,
    required this.usersService,
  });

  int get currentUserId => authService.userId;

  // Mock users
  final List<User> mockUsers = [
    User(id: 1, name: "John Doe", email: "john@example.com"),
    User(id: 2, name: "Jane Smith", email: "jane@example.com"),
    User(id: 3, name: "Alice Brown", email: "alice@example.com"),
    User(id: 4, name: "Bob White", email: "bob@example.com"),
    User(id: 5, name: "Johnny Depp", email: "john2@example.com"),
    User(id: 6, name: "Jane Austin", email: "jane2@example.com"),
    User(id: 7, name: "Alice Wonderland", email: "alice2@example.com"),
    User(id: 8, name: "Bob Budowniczy", email: "bob2@example.com"),
    User(id: 9, name: "Johnny Black", email: "john3@example.com"),
    User(id: 10, name: "Jane Juice", email: "jane3@example.com"),
    User(id: 11, name: "Alice Wood", email: "alice3@example.com"),
    User(id: 12, name: "Bob Builder", email: "bob3@example.com"),
    User(id: 13, name: "John Snow", email: "johnSnow@example.com"),
  ];

  // Mock friendships for logged-in user
  final List<int> friendships = [2, 3, 4];

  // Mock pending friend requests for logged-in user
  final List<Map<String, dynamic>> friendRequests = [
    {"userId": 5, "requestId": 100},
    {"userId": 6, "requestId": 101},
    {"userId": 7, "requestId": 102},
    {"userId": 8, "requestId": 103},
  ];

  final List<Map<String, dynamic>> sentByUserRequests = [
    {"userId": 10, "requestId": 200},
    {"userId": 11, "requestId": 201},
  ];

  final Map<int, Map<bool, double>> balances = {
    1: {true: 600.0},
    2: {false: 123.1},
    3: {true: 120.4},
  };

  final Map<int, Map<String, Map<bool, double>>> balancesPerGroupPerUser = {
    1: {
      "Trip one": {true: 100.0},
      "Trip two": {true: 150.0},
      "Trip three": {false: 50.0},
      "Trip four": {true: 100.0},
      "Trip five": {true: 150.0},
      "Trip six": {false: 50.0},
      "Trip seven": {true: 100.0},
      "Trip eight": {true: 150.0},
      "Trip nine": {false: 50.0},
    },
    2: {
      "Trip one": {false: 23.1},
      "Trip three": {false: 50.0},
      "Trip four": {true: 100.0},
      "Trip five": {false: 150.0},
    },
    3: {
      "Trip two": {true: 120.4}
    },
  };

  final Map<String, CurrencyEnum> groupCurrencies = {
    "Trip one": CurrencyEnum.pln,
    "Trip two": CurrencyEnum.eur,
    "Trip three": CurrencyEnum.usd,
    "Trip four": CurrencyEnum.gbp,
    "Trip five": CurrencyEnum.pln,
    "Trip six": CurrencyEnum.usd,
    "Trip seven": CurrencyEnum.eur,
    "Trip eight": CurrencyEnum.gbp,
    "Trip nine": CurrencyEnum.pln,
  };

  // Fetch friends for the logged-in user
  @override
  Future<List<User>> getFriends() async {
    await Future.delayed(Duration(milliseconds: 250));
    return mockUsers.where((user) => friendships.contains(user.id)).toList();
  }

  // Fetch incoming friend requests for the logged-in user
  @override
  Future<List<FriendRequestUser>> getFriendRequests() async {
    await Future.delayed(Duration(milliseconds: 250));
    return friendRequests.map((request) {
      final user = mockUsers.firstWhere((u) => u.id == request['userId']);
      return FriendRequestUser(user: user, requestId: request['requestId']);
    }).toList();
  }

  @override
  Future<List<FriendRequestUser>> getSentRequests() async {
    await Future.delayed(Duration(milliseconds: 250));
    return sentByUserRequests.map((request) {
      final user = mockUsers.firstWhere((u) => u.id == request['userId']);
      return FriendRequestUser(user: user, requestId: request['requestId']);
    }).toList();
  }

  // Accept friend request
  @override
  Future<void> acceptFriendRequest(int requestId) async {
    await Future.delayed(Duration(milliseconds: 100));
    final request =
        friendRequests.firstWhere((r) => r['requestId'] == requestId);
    friendships.add(request['userId']);
    friendRequests.removeWhere((r) => r['requestId'] == requestId);
  }

  // Decline friend request
  @override
  Future<void> declineFriendRequest(int requestId) async {
    await Future.delayed(Duration(milliseconds: 100));
    friendRequests.removeWhere((request) => request['requestId'] == requestId);
  }

  // Send a friend request to another user by their email
  @override
  Future<void> sendFriendRequest(String email) async {
    await Future.delayed(Duration(milliseconds: 500));

    User? user = await usersService.getUserByEmail(email);

    if (user != null && user.id != currentUserId) {
      // Prevent duplicates
      if (!sentByUserRequests.any((r) => r['userId'] == user.id)) {
        final int newRequestId = DateTime.now().millisecondsSinceEpoch;
        sentByUserRequests.add({
          'userId': user.id,
          'requestId': newRequestId,
        });
      }
    } else {
      throw Exception("User not found or invalid request.");
    }
  }

  // Withdraw friend request sent by logged-in user
  @override
  Future<void> withdrawFriendRequest(int requestId) async {
    await Future.delayed(Duration(milliseconds: 100));
    sentByUserRequests.removeWhere((r) => r['requestId'] == requestId);
  }

  // Delete user from logged-in user friends list
  @override
  Future<void> removeFriend(int targetUserId) async {
    await Future.delayed(Duration(milliseconds: 100));

    friendships.removeWhere((user) => user == targetUserId);
  }

  @override
  bool isAlreadyFriend(int targetUserId) {
    return friendships.any((user) => user == targetUserId);
  }

  @override
  bool isRequestSentByUser(int targetUserId) {
    return sentByUserRequests.any((r) => r['userId'] == targetUserId);
  }

  @override
  bool isRequestReceived(int targetUserId) {
    return friendRequests.any((r) => r['userId'] == targetUserId);
  }

  @override
  Future<Map<String, dynamic>> getUserBalances(int userId) async {
    await Future.delayed(const Duration(seconds: 1));
    if (balances.containsKey(userId)) {
      var entry = balances[userId]!;
      return {
        "isOwedToUser": entry.keys.first,
        "amount": entry.values.first,
      };
    } else {
      return {"isOwedToUser": null, "amount": 0.0};
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getUserBalancesWithGroups(
      int userId) async {
    await Future.delayed(Duration(milliseconds: 250));

    List<Map<String, dynamic>> balancesList = [];

    if (balancesPerGroupPerUser.containsKey(userId)) {
      final userBalances = balancesPerGroupPerUser[userId]!;

      userBalances.forEach((groupName, balanceInfo) {
        final currency = groupCurrencies[groupName] ?? CurrencyEnum.pln;
        balanceInfo.forEach((isOwed, amount) {
          balancesList.add({
            "groupName": groupName,
            "currency": currency,
            "amount": amount,
            "isOwed": isOwed,
          });
        });
      });
    }

    return balancesList;
  }
}

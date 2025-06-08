import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:kasa_w_grupie/config/api_config.dart';
import 'package:kasa_w_grupie/models/group.dart';
import 'package:kasa_w_grupie/models/user.dart';
import 'package:kasa_w_grupie/services/auth_service.dart';
import 'package:kasa_w_grupie/services/users_service.dart';

abstract class FriendsService {
  Future<List<User>> getFriends();
  Future<List<User>> getFriendRequests();
  Future<List<User>> getSentRequests();
  Future<void> acceptFriendRequest(int friendId);
  Future<void> declineFriendRequest(int friendId);
  Future<void> sendFriendRequest(String email);
  Future<void> withdrawFriendRequest(int friendId);
  Future<void> removeFriend(int targetUserId);
  bool isAlreadyFriend(int targetUserId);
  bool isRequestSentByUser(int targetUserId);
  bool isRequestReceived(int targetUserId);
  Future<Map<String, dynamic>> getUserBalances(int userId);
  Future<List<Map<String, dynamic>>> getUserBalancesWithGroups(int userId);
}

class FriendsServiceApi implements FriendsService {
  final UsersService usersService;

  FriendsServiceApi({
    required this.usersService,
  });

  String get baseUrl => ApiConfig.baseUrl;

  @override
  Future<List<User>> getFriends() async {
    final currentUser = await usersService.getCurrentUser();
    if (currentUser == null) {
      throw Exception('User not logged in');
    }
    final currentUserId = currentUser.id;
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
  Future<List<User>> getFriendRequests() => throw UnimplementedError();
  @override
  Future<List<User>> getSentRequests() => throw UnimplementedError();
  @override
  Future<void> acceptFriendRequest(int friendId) => throw UnimplementedError();
  @override
  Future<void> declineFriendRequest(int friendId) => throw UnimplementedError();
  @override
  Future<void> sendFriendRequest(String email) => throw UnimplementedError();
  @override
  Future<void> withdrawFriendRequest(int friendId) =>
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
  final UsersService usersService;

  MockFriendsService({
    required this.usersService,
  });

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
  final List<int> friendRequests = [
    5,
    6,
    7,
    8,
  ];

  final List<int> sentByUserRequests = [
    10,
    11,
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
  Future<List<User>> getFriendRequests() async {
    await Future.delayed(Duration(milliseconds: 250));
    return mockUsers.where((user) => friendRequests.contains(user.id)).toList();
  }

  @override
  Future<List<User>> getSentRequests() async {
    await Future.delayed(Duration(milliseconds: 250));
    return mockUsers
        .where((user) => sentByUserRequests.contains(user.id))
        .toList();
  }

  // Accept friend request
  @override
  Future<void> acceptFriendRequest(int friendId) async {
    await Future.delayed(Duration(milliseconds: 100));

    // Since this is only a mock service we add new friend only for currently
    // logged user, in future it will be changed

    friendRequests.remove(friendId);
    friendships.add(friendId);
  }

  // Decline friend request
  @override
  Future<void> declineFriendRequest(int friendId) async {
    await Future.delayed(Duration(milliseconds: 100));
    friendRequests.remove(friendId);
  }

  // Send a friend request to another user by their email
  @override
  Future<void> sendFriendRequest(String email) async {
    await Future.delayed(Duration(milliseconds: 500));

    User? user = await usersService.getUserByEmail(email);

    if (user != null) {
      sentByUserRequests.add(user.id);
    } else {
      throw Exception("User not found or invalid request.");
    }
  }

  // Withdraw friend request sent by logged-in user
  @override
  Future<void> withdrawFriendRequest(int friendId) async {
    await Future.delayed(Duration(milliseconds: 100));
    sentByUserRequests.remove(friendId);
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
    return sentByUserRequests.any((user) => user == targetUserId);
  }

  @override
  bool isRequestReceived(int targetUserId) {
    return friendRequests.any((user) => user == targetUserId);
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

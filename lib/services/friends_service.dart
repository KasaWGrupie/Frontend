import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:kasa_w_grupie/config/api_config.dart';
import 'package:kasa_w_grupie/models/friend_request_user.dart';
import 'package:kasa_w_grupie/models/group.dart';
import 'package:kasa_w_grupie/models/user.dart';
import 'package:kasa_w_grupie/services/users_service.dart';

abstract class FriendsService {
  Future<List<User>> getFriends();
  Future<List<FriendRequestUser>> getFriendRequests();
  Future<List<FriendRequestUser>> getSentRequests();
  Future<void> acceptFriendRequest(int requestId);
  Future<void> declineFriendRequest(int requestId);
  Future<void> sendFriendRequest(String email);
  Future<void> withdrawFriendRequest(int requestId);
  Future<bool> isAlreadyFriend(int targetUserId);
  Future<bool> isRequestSentByUser(int targetUserId);
  Future<bool> isRequestReceived(int targetUserId);
  Future<Map<String, dynamic>> getUserBalances(int userId);
  Future<List<Map<String, dynamic>>> getUserBalancesWithGroups(int userId);
  Future<List<User>> searchUsersByEmail(String query);
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
  Future<List<FriendRequestUser>> getFriendRequests() async {
    final currentUser = await usersService.getCurrentUser();
    if (currentUser == null) {
      throw Exception('User not logged in');
    }

    final url = Uri.parse('$baseUrl/users/${currentUser.id}}/friendRequests');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);

      final List<FriendRequestUser> requestUsers = [];

      for (final request in data) {
        if (request['senderId'] != currentUser.id) {
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
  //TODO change api request
  Future<List<FriendRequestUser>> getSentRequests() async {
    final currentUser = await usersService.getCurrentUser();
    if (currentUser == null) {
      throw Exception('User not logged in');
    }

    final url = Uri.parse('$baseUrl/users/${currentUser.id}/friendRequests');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);

      final List<FriendRequestUser> sentRequestUsers = [];

      for (final request in data) {
        if (request['receiverId'] != currentUser.id) {
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
  Future<void> acceptFriendRequest(int requestId) async {
    final url = Uri.parse('$baseUrl/users/friendRequests/$requestId');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'status': 'Confirmed',
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to accept friend request');
    }
  }

  @override
  Future<void> declineFriendRequest(int requestId) async {
    final url = Uri.parse('$baseUrl/users/friendRequests/$requestId');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'status': 'Rejected'}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to decline friend request');
    }
  }

  @override
  Future<void> sendFriendRequest(String email) async {
    final currentUser = await usersService.getCurrentUser();
    if (currentUser == null) {
      throw Exception('User not logged in');
    }
    final senderId = currentUser.id;
    final receiver = await usersService.getUserByEmail(email);

    if (receiver == null) {
      throw Exception('User with email $email not found');
    }

    final receiverId = receiver.id;

    final url = Uri.parse('$baseUrl/users/friendRequests');

    final body = jsonEncode({
      'senderId': senderId,
      'receiverId': receiverId,
    });

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to send friend request: ${response.body}');
    }
  }

  @override
  Future<void> withdrawFriendRequest(int requestId) async {
    await declineFriendRequest(requestId);
  }

  @override
  Future<bool> isAlreadyFriend(int targetUserId) async {
    final friends = await getFriends();
    return friends.any((friend) => friend.id == targetUserId);
  }

  @override
  Future<bool> isRequestSentByUser(int targetUserId) async {
    final sentRequests = await getSentRequests();
    return sentRequests.any((request) => request.user.id == targetUserId);
  }

  @override
  Future<bool> isRequestReceived(int targetUserId) async {
    final receivedRequests = await getFriendRequests();
    return receivedRequests.any((request) => request.user.id == targetUserId);
  }

  @override
  Future<Map<String, dynamic>> getUserBalances(int userId) async {
    final url = Uri.parse('$baseUrl/users/$userId/balances');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonBody = json.decode(response.body);

      if (jsonBody['isSuccess'] == true && jsonBody['value'] != null) {
        return Map<String, dynamic>.from(jsonBody['value']);
      } else {
        throw Exception(
            'Invalid response: ${jsonBody['errors'] ?? 'Unknown error'}');
      }
    } else {
      throw Exception('Failed to load user balances: ${response.statusCode}');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getUserBalancesWithGroups(
      int userId) async {
    final currentUser = await usersService.getCurrentUser();
    if (currentUser == null) {
      throw Exception('User not logged in');
    }
    final url = Uri.parse('$baseUrl/users/${currentUser.id}/balances/$userId');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonBody = json.decode(response.body);

      if (jsonBody['isSuccess'] == true && jsonBody['value'] != null) {
        return List<Map<String, dynamic>>.from(jsonBody['value']['balances']);
      } else {
        throw Exception('Invalid response structure');
      }
    } else {
      throw Exception('Failed to load balances: ${response.statusCode}');
    }
  }

  @override
  Future<List<User>> searchUsersByEmail(String query) async {
    final url = Uri.parse('$baseUrl/users/email/search/$query');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);

      return jsonList.map((json) => User.fromJson(json)).toList();
    } else {
      throw Exception('Failed to search users by email');
    }
  }
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

    if (user != null) {
      // Prevent duplicates
      if (!sentByUserRequests.any((r) => r['userId'] == user.id)) {
        final int newRequestId = DateTime.now().millisecondsSinceEpoch;
        sentByUserRequests.add({
          'userId': user.id,
          'requestId': newRequestId,
        });
      }
      // if (user != null) {
      //   sentByUserRequests.add(user.id);
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

  @override
  Future<bool> isAlreadyFriend(int targetUserId) async {
    return friendships.any((user) => user == targetUserId);
  }

  @override
  Future<bool> isRequestSentByUser(int targetUserId) async {
    return sentByUserRequests.any((r) => r['userId'] == targetUserId);
  }

  @override
  Future<bool> isRequestReceived(int targetUserId) async {
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

  @override
  Future<List<User>> searchUsersByEmail(String query) async {
    await Future.delayed(Duration(milliseconds: 300)); // simulate latency
    return mockUsers
        .where((user) => user.email.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }
}

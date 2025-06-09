import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:kasa_w_grupie/config/api_config.dart';
import 'package:kasa_w_grupie/models/expense.dart';
import 'package:kasa_w_grupie/models/group.dart';
import 'package:kasa_w_grupie/models/group_join_request.dart';
import 'package:kasa_w_grupie/models/user.dart';
import 'package:kasa_w_grupie/services/auth_service.dart';
import 'package:kasa_w_grupie/services/users_service.dart';

abstract class GroupService {
  Future<String?> addGroup(NewGroup group);

  Future<List<Group>> getGroupsForUser();
  Future<Group> getGroupById(int groupId);
  Future<String?> updateGroup(Group group);
  Future<String?> updateGroupStatus(int groupId, bool isActive);
  Future<List<User>> getUsersForGroup(int groupId);

  Future<List<Expense>> getExpensesForGroup(int groupId);
  Future<Map<int, double>> getBalances(int groupId);

  Future<String?> joinGroupByCode(String code);
  Future<List<GroupJoinRequest>> getJoinRequests(int groupId);
  Future<void> respondToJoinRequest(int groupId, int requestId, bool accept);
}

class GroupServiceApi implements GroupService {
  final AuthService authService;
  final UsersService usersService;

  GroupServiceApi({required this.authService, required this.usersService});

  @override
  Future<String?> addGroup(NewGroup group) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/groups');
    final idToken = await authService.userIdToken();

    final request = http.MultipartRequest('POST', url)
      ..headers['Authorization'] = 'Bearer $idToken';
    // ..headers['Accept'] = '*/*';

    if (!group.membersId.contains(group.adminId)) {
      group.membersId.add(group.adminId);
    }
    final dtoMap = {
      'name': group.name,
      'description': group.description,
      'currency': group.currency.name,
      'members': group.membersId,
      'adminId': group.adminId,
    };

    final dtoJson = jsonEncode(dtoMap);

    request.fields['dto'] = dtoJson;

    if (group.picture != null) {
      final pictureBytes = await group.picture!.readAsBytes();
      final multipartFile = http.MultipartFile.fromBytes(
        'image',
        pictureBytes,
        filename: 'avatar.jpg',
        contentType: MediaType('image', 'jpeg'),
      );

      request.files.add(multipartFile);
    }

    final response = await http.Response.fromStream(await request.send());

    if (response.statusCode == 200 || response.statusCode == 201) {
      return null;
    }
    return "Creating new account failed";
  }

  Future<Map<String, String>> _getAuthHeaders() async {
    final idToken = await authService.userIdToken();
    return {
      'Authorization': 'Bearer $idToken',
    };
  }

  @override
  Future<Map<int, double>> getBalances(int groupId) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/groups/$groupId/balances');
    final headers = await _getAuthHeaders();

    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = jsonDecode(response.body);

      // Extract the balances array from the response
      final List<dynamic> balancesData = responseData['balances'] ?? [];

      // Calculate net balance for each user
      Map<int, double> netBalances = {};

      for (var balance in balancesData) {
        final int fromUserId = balance['fromUserId'];
        final int toUserId = balance['toUserId'];
        final double amount = balance['amount'].toDouble();

        // The user who owes (fromUser) has negative balance
        netBalances[fromUserId] = (netBalances[fromUserId] ?? 0) - amount;

        // The user who is owed (toUser) has positive balance
        netBalances[toUserId] = (netBalances[toUserId] ?? 0) + amount;
      }

      return netBalances;
    } else {
      throw Exception('Failed to load balances: ${response.statusCode}');
    }
  }

  @override
  Future<List<Expense>> getExpensesForGroup(int groupId) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/groups/$groupId/expenses');
    final headers = await _getAuthHeaders();

    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      final List<dynamic> expensesJson = jsonDecode(response.body);

      // Convert each JSON expense to an Expense object using the fromJson factory
      final expenses = expensesJson
          .map((expenseJson) => Expense.fromJson(expenseJson))
          .toList();

      return expenses;
    } else {
      throw Exception('Failed to load expenses: ${response.statusCode}');
    }
  }

  @override
  Future<Group> getGroupById(int groupId) async {
    final headers = await _getAuthHeaders();
    final groupUrl = Uri.parse('${ApiConfig.baseUrl}/groups/$groupId');
    final groupResponse = await http.get(groupUrl, headers: headers);

    if (groupResponse.statusCode == 200) {
      final groupJson = jsonDecode(groupResponse.body);
      return Group.fromJson(groupJson);
    } else {
      throw Exception(
          'Failed to load group with ID $groupId: ${groupResponse.statusCode}');
    }
  }

  @override
  Future<List<Group>> getGroupsForUser() async {
    final currentUserEmail = authService.userEmail;
    final url = Uri.parse(
        '${ApiConfig.baseUrl}/users/user-groups?email=$currentUserEmail');
    final headers = await _getAuthHeaders();

    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      final List<dynamic> groupsJson = jsonDecode(response.body);

      // Convert each JSON group to a Group object using the fromJson factory
      List<int> groupIds =
          groupsJson.map<int>((groupJson) => groupJson['id']).toList();

      final groups = <Group>[];
      for (var groupId in groupIds) {
        final group = await getGroupById(groupId);
        groups.add(group);
      }

      return groups;
    } else {
      throw Exception('Failed to load groups: ${response.statusCode}');
    }
  }

  @override
  Future<List<GroupJoinRequest>> getJoinRequests(int groupId) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/groups/$groupId/joinRequests');
    final headers = await _getAuthHeaders();

    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = jsonDecode(response.body);

      // Extract the joinRequests array from the response
      final List<dynamic> requestsData = responseData['joinRequests'] ?? [];

      // Create a list of join requests
      final List<GroupJoinRequest> joinRequests = [];

      for (var requestData in requestsData) {
        final userId = requestData['userId'] as int;

        // Fetch user details to get name and email
        try {
          final user = await usersService.getUser(userId);

          if (user != null) {
            // Create join request with user details
            joinRequests.add(
              GroupJoinRequest(
                id: requestData['id'] ?? requestData['requestId'] ?? 0,
                name: user.name,
                email: user.email,
              ),
            );
          }
        } catch (e) {
          // If we can't get user details, create request with minimal info
          joinRequests.add(
            GroupJoinRequest(
              id: requestData['id'] ?? requestData['requestId'] ?? 0,
              name: "User #$userId",
              email: "",
            ),
          );
        }
      }

      return joinRequests;
    } else {
      throw Exception('Failed to load join requests: ${response.statusCode}');
    }
  }

  @override
  Future<List<User>> getUsersForGroup(int groupId) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/groups/$groupId/joinRequests');
    final headers = await _getAuthHeaders();

    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = jsonDecode(response.body);

      // Extract the users array from the response
      final List<int> usersIds = responseData['members'];
      final List<User> users = [];
      for (var userId in usersIds) {
        try {
          final user = await usersService.getUser(userId);
          if (user != null) {
            users.add(user);
          }
        } catch (e) {
          continue;
        }
      }

      return users;
    } else {
      throw Exception('Failed to load users: ${response.statusCode}');
    }
  }

  @override
  Future<String?> joinGroupByCode(String code) {
    // TODO: implement joinGroupByCode
    throw UnimplementedError();
  }

  @override
  Future<void> respondToJoinRequest(int groupId, int requestId, bool accept) {
    // TODO: implement respondToJoinRequest
    throw UnimplementedError();
  }

  @override
  Future<String?> updateGroup(Group group) {
    // TODO: implement updateGroup
    throw UnimplementedError();
  }

  @override
  Future<String?> updateGroupStatus(int groupId, bool isActive) {
    // TODO: implement updateGroupStatus
    throw UnimplementedError();
  }
}

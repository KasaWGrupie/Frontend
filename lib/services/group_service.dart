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

  GroupServiceApi({required this.authService});

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
        'profilePicture',
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
  Future<List<GroupJoinRequest>> getJoinRequests(int groupId) {
    // TODO: implement getJoinRequests
    throw UnimplementedError();
  }

  @override
  Future<List<User>> getUsersForGroup(int groupId) {
    // TODO: implement getUsersForGroup
    throw UnimplementedError();
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

// class GroupServiceMock implements GroupService {
//   final UsersService usersService;

//   final List<Group> allGroups = [
//     Group(
//       id: 0,
//       name: "Wycieczka Marki",
//       currency: CurrencyEnum.pln,
//       status: GroupStatus.active,
//       adminId: 6,
//       membersId: [6],
//       invitationCode: "fjh4390h094",
//     ),
//   ];

//   final List<Expense> allExpenses = [
//     Expense(
//       id: 0,
//       pictureUrl:
//           "https://cdn.pixabay.com/photo/2017/09/07/08/54/money-2724241__480.jpg",
//       date: DateTime.now(),
//       amount: 100,
//       payer: 6,
//       split: ExpenseSplit.equal(participants: []),
//       name: "Jedzenie",
//     ),
//     Expense(
//       id: 1,
//       pictureUrl:
//           "https://cdn.pixabay.com/photo/2017/09/07/08/54/money-2724241__480.jpg",
//       date: DateTime.now().subtract(const Duration(days: 1)),
//       amount: 100,
//       payer: 6,
//       split: ExpenseSplit.equal(participants: []),
//       name: "Paliwo",
//     ),
//     Expense(
//       id: 2,
//       pictureUrl:
//           "https://cdn.pixabay.com/photo/2017/09/07/08/54/money-2724241__480.jpg",
//       date: DateTime.now(),
//       amount: 100,
//       payer: 6,
//       split: ExpenseSplit.equal(participants: []),
//       name: "Spanie",
//     ),
//   ];

//   final Map<int, List<User>> usersPerGroups = {
//     0: [
//       User(id: 1, name: "John Doe", email: "john@example.com"),
//       User(id: 2, name: "Jane Smith", email: "jane@example.com"),
//       User(id: 6, name: "Jane Austin", email: "jane2@example.com"),
//       User(id: 7, name: "Alice Wonderland", email: "alice2@example.com"),
//     ]
//   };

//   final Map<int, List<GroupJoinRequest>> joinRequestsPerGroup = {
//     0: [
//       GroupJoinRequest(
//         id: 101,
//         name: "New User One",
//         email: "one@example.com",
//       ),
//       GroupJoinRequest(
//         id: 102,
//         name: "New User Two",
//         email: "two@example.com",
//       ),
//     ]
//   };

//   GroupServiceMock({required this.usersService});

//   @override
//   Future<String?> addGroup(NewGroup group) async {
//     try {
//       allGroups.add(Group(
//         id: allGroups.length,
//         name: group.name,
//         description: group.description,
//         currency: group.currency,
//         status: GroupStatus.active,
//         adminId: 6,
//         membersId: group.membersId,
//         invitationCode: group.invitationCode,
//       ));

//       return null;
//     } catch (e) {
//       return 'Failed to create group: $e';
//     }
//   }

//   @override
//   Future<List<Group>> getGroupsForUser() async {
//     try {
//       final user = await usersService.getCurrentUser();

//       if (user == null) {
//         return [];
//       }

//       // final userGroups = allGroups.where((group) {
//       //   return group.membersId.contains(user.id) || group.adminId == user.id;
//       // }).toList();

//       return allGroups;
//     } catch (e) {
//       return [];
//     }
//   }

//   @override
//   Future<List<User>> getUsersForGroup(int groupId) async {
//     // For now return the same set of users
//     return Future.value(usersPerGroups[0]);
//   }

//   // Get a group by its ID
//   @override
//   Future<Group> getGroupById(int groupId) async {
//     return allGroups.firstWhere(
//       (group) => group.id == 0,
//     );
//   }

//   // Update an existing group
//   @override
//   Future<String?> updateGroup(Group group) async {
//     try {
//       final index = allGroups.indexWhere((g) => g.id == group.id);

//       if (index != -1) {
//         final oldGroup = allGroups[index];
//         final oldMembers = Set<int>.from(oldGroup.membersId);
//         final newMembers = Set<int>.from(group.membersId);

//         final removedMembers = oldMembers.difference(newMembers);

//         final userList = usersPerGroups[group.id];
//         if userList != null) {
//           userList.removeWhere((user) => removedMembers.contains(user.id));
//         }

//         allGroups[index] = group;
//         return null;
//       } else {
//         return 'Group not found';
//       }
//     } catch (e) {
//       return 'Failed to update group: $e';
//     }
//   }

//   @override
//   Future<Map<int, double>> getBalances(int groupId) {
//     // For now return a static map of balances
//     return Future.value({
//       1: 100,
//       2: -50,
//       6: -25,
//       7: -25,
//     });
//   }

//   @override
//   Future<List<Expense>> getExpensesForGroup(int groupId) {
//     return Future.value(allExpenses);
//   }

//   @override
//   Future<String?> updateGroupStatus(int groupId, bool isActive) async {
//     // For now always changing status of the first group in the list
//     allGroups[0].status = isActive ? GroupStatus.active : GroupStatus.closed;
//     return null;
//   }

//   @override
//   Future<String?> joinGroupByCode(String code) async {
//     // Simulating no error
//     return null;
//   }

//   @override
//   Future<List<GroupJoinRequest>> getJoinRequests(int groupId) async {
//     return Future.value(joinRequestsPerGroup[groupId] ?? []);
//   }

//   @override
//   Future<void> respondToJoinRequest(
//       int groupId, int requestId, bool accept) async {
//     final requests = joinRequestsPerGroup[groupId];
//     if (requests != null) {
//       requests.removeWhere((r) => r.id == requestId);

//       if (accept) {
//         final newUser = User(
//           id: requestId,
//           name: "Accepted User",
//           email: "$requestId@example.com",
//         );

//         usersPerGroups[groupId] ??= [];
//         usersPerGroups[groupId]!.add(newUser);

//         final group = allGroups.firstWhere(
//           (g) => g.id == groupId,
//           orElse: () => throw Exception('Group not found'),
//         );

//         if (!group.membersId.contains(requestId)) {
//           group.membersId.add(requestId);
//         }
//       }
//     }
//   }
// }

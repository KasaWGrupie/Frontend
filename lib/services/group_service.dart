import 'package:kasa_w_grupie/models/expense.dart';
import 'package:kasa_w_grupie/models/group.dart';
import 'package:kasa_w_grupie/models/group_join_request.dart';
import 'package:kasa_w_grupie/models/user.dart';
import 'package:kasa_w_grupie/services/auth_service.dart';

abstract class GroupService {
  Future<String?> addGroup(Group group);

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

class GroupServiceMock implements GroupService {
  final AuthService authService;

  final List<Group> allGroups = [
    Group(
      id: 0,
      name: "Wycieczka Marki",
      currency: CurrencyEnum.pln,
      status: GroupStatus.active,
      adminId: 1,
      membersId: [
        1,
        2,
        6,
        7,
      ],
      invitationCode: "fjh4390h094",
    ),
  ];

  final List<Expense> allExpenses = [
    Expense(
      id: 0,
      pictureUrl:
          "https://cdn.pixabay.com/photo/2017/09/07/08/54/money-2724241__480.jpg",
      date: DateTime.now(),
      amount: 100,
      payer: "1",
      split: ExpenseSplit(),
      name: "Jedzenie",
    ),
    Expense(
      id: 1,
      pictureUrl:
          "https://cdn.pixabay.com/photo/2017/09/07/08/54/money-2724241__480.jpg",
      date: DateTime.now().subtract(const Duration(days: 1)),
      amount: 100,
      payer: "2",
      split: ExpenseSplit(),
      name: "Paliwo",
    ),
    Expense(
      id: 2,
      pictureUrl:
          "https://cdn.pixabay.com/photo/2017/09/07/08/54/money-2724241__480.jpg",
      date: DateTime.now(),
      amount: 100,
      payer: "1",
      split: ExpenseSplit(),
      name: "Spanie",
    ),
  ];

  final Map<int, List<User>> usersPerGroups = {
    0: [
      User(id: 1, name: "John Doe", email: "john@example.com"),
      User(id: 2, name: "Jane Smith", email: "jane@example.com"),
      User(id: 6, name: "Jane Austin", email: "jane2@example.com"),
      User(id: 7, name: "Alice Wonderland", email: "alice2@example.com"),
    ]
  };

  final Map<int, List<GroupJoinRequest>> joinRequestsPerGroup = {
    0: [
      GroupJoinRequest(
        id: 101,
        name: "New User One",
        email: "one@example.com",
      ),
      GroupJoinRequest(
        id: 102,
        name: "New User Two",
        email: "two@example.com",
      ),
    ]
  };

  GroupServiceMock({required this.authService});

  @override
  Future<String?> addGroup(Group group) async {
    try {
      allGroups.add(group);

      return null;
    } catch (e) {
      return 'Failed to create group: $e';
    }
  }

  @override
  Future<List<Group>> getGroupsForUser() async {
    try {
      final user = await authService.currentUser();

      if (user == null) {
        return [];
      }

      // final userGroups = allGroups.where((group) {
      //   return group.membersId.contains(user.id) || group.adminId == user.id;
      // }).toList();

      return allGroups;
    } catch (e) {
      return [];
    }
  }

  @override
  Future<List<User>> getUsersForGroup(int groupId) async {
    // For now return the same set of users
    return Future.value(usersPerGroups["0"]);
  }

  // Get a group by its ID
  @override
  Future<Group> getGroupById(int groupId) async {
    return allGroups.firstWhere(
      (group) => group.id == 0,
    );
  }

  // Update an existing group
  @override
  Future<String?> updateGroup(Group group) async {
    try {
      final index = allGroups.indexWhere((g) => g.id == group.id);

      if (index != -1) {
        final oldGroup = allGroups[index];
        final oldMembers = Set<String>.from(oldGroup.membersId);
        final newMembers = Set<String>.from(group.membersId);

        final removedMembers = oldMembers.difference(newMembers);

        final userList = usersPerGroups[group.id];
        if (userList != null) {
          userList.removeWhere((user) => removedMembers.contains(user.id));
        }

        allGroups[index] = group;
        return null;
      } else {
        return 'Group not found';
      }
    } catch (e) {
      return 'Failed to update group: $e';
    }
  }

  @override
  Future<Map<int, double>> getBalances(int groupId) {
    // For now return a static map of balances
    return Future.value({
      1: 100,
      2: -50,
      6: -25,
      7: -25,
    });
  }

  @override
  Future<List<Expense>> getExpensesForGroup(int groupId) {
    return Future.value(allExpenses);
  }

  @override
  Future<String?> updateGroupStatus(int groupId, bool isActive) async {
    // For now always changing status of the first group in the list
    allGroups[0].status = isActive ? GroupStatus.active : GroupStatus.closed;
    return null;
  }

  @override
  Future<String?> joinGroupByCode(String code) async {
    // Simulating no error
    return null;
  }

  @override
  Future<List<GroupJoinRequest>> getJoinRequests(int groupId) async {
    return Future.value(joinRequestsPerGroup[groupId] ?? []);
  }

  @override
  Future<void> respondToJoinRequest(
      int groupId, int requestId, bool accept) async {
    final requests = joinRequestsPerGroup[groupId];
    if (requests != null) {
      requests.removeWhere((r) => r.id == requestId);

      if (accept) {
        final newUser = User(
          id: requestId,
          name: "Accepted User",
          email: "$requestId@example.com",
        );

        usersPerGroups[groupId] ??= [];
        usersPerGroups[groupId]!.add(newUser);

        final group = allGroups.firstWhere(
          (g) => g.id == groupId,
          orElse: () => throw Exception('Group not found'),
        );

        if (!group.membersId.contains(requestId)) {
          group.membersId.add(requestId);
        }
      }
    }
  }
}

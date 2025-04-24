import 'package:kasa_w_grupie/models/group.dart';
import 'package:kasa_w_grupie/models/user.dart';
import 'package:kasa_w_grupie/services/auth_service.dart';

abstract class GroupService {
  Future<String?> addGroup(Group group);

  Future<List<Group>> getGroupsForUser();
  Future<Group> getGroupById(String groupId);
  Future<String?> updateGroup(Group group);
  Future<List<User>> getUsersForGroup(String groupId);
}

class GroupServiceMock implements GroupService {
  final AuthService authService;

  final List<Group> allGroups = [
    Group(
      id: "0",
      name: "Wycieczka Marki",
      currency: CurrencyEnum.pln,
      status: GroupStatus.active,
      adminId: "1",
      membersId: [
        "1",
        "2",
        "6",
        "7",
      ],
      invitationCode: "fjh4390h094",
    ),
  ];

  final Map<String, List<User>> usersPerGroups = {
    "0": [
      User(id: "1", name: "John Doe", email: "john@example.com"),
      User(id: "2", name: "Jane Smith", email: "jane@example.com"),
      User(id: "6", name: "Jane Austin", email: "jane2@example.com"),
      User(id: "7", name: "Alice Wonderland", email: "alice2@example.com"),
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

      final userGroups = allGroups.where((group) {
        return group.membersId.contains(user.id) || group.adminId == user.id;
      }).toList();

      return userGroups;
    } catch (e) {
      return [];
    }
  }

  @override
  Future<List<User>> getUsersForGroup(String groupId) async {
    // For now return the same set of users
    return Future.value(usersPerGroups["0"]);
  }

  // Get a group by its ID
  @override
  Future<Group> getGroupById(String groupId) async {
    return allGroups.firstWhere(
      (group) => group.id == "0",
    );
  }

  // Update an existing group
  @override
  Future<String?> updateGroup(Group group) async {
    try {
      final index = allGroups.indexWhere((g) => g.id == group.id);

      if (index != -1) {
        allGroups[index] = group;
        return null;
      } else {
        return 'Group not found';
      }
    } catch (e) {
      return 'Failed to update group: $e';
    }
  }
}

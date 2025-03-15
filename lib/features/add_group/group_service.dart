import 'package:kasa_w_grupie/core/group.dart';
import 'package:kasa_w_grupie/features/auth/auth_service.dart';
import 'package:kasa_w_grupie/core/user.dart';

abstract class GroupService {
  Future<String?> addGroup(Group group);
  Future<String> getUserId();

  Future<List<Group>> getGroupsForUser();
}

class GroupServiceMock implements GroupService {
  final AuthService authService;

  final List<Group> _allGroups = [];

  GroupServiceMock({required this.authService});

  @override
  Future<String?> addGroup(Group group) async {
    try {
      _allGroups.add(group);

      return null;
    } catch (e) {
      return 'Failed to create group: $e';
    }
  }

  @override
  Future<String> getUserId() async {
    final User? currUser = authService.currentUser;
    if (currUser == null) {
      throw Exception("No user is currently signed in.");
    }
    return currUser.id;
  }

  @override
  Future<List<Group>> getGroupsForUser() async {
    try {
      final user = authService.currentUser;

      if (user == null) {
        return [];
      }

      final userGroups = _allGroups.where((group) {
        return group.membersId.contains(user.id) || group.adminId == user.id;
      }).toList();

      return userGroups;
    } catch (e) {
      return [];
    }
  }
}

import 'package:kasa_w_grupie/models/group.dart';
import 'package:kasa_w_grupie/services/auth_service.dart';

abstract class GroupService {
  Future<String?> addGroup(Group group);

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

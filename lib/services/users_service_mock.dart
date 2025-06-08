import 'dart:io';

import 'package:kasa_w_grupie/models/user.dart';
import 'package:kasa_w_grupie/services/users_service.dart';

class UsersServiceMock implements UsersService {
  final Map<int, User> users = {
    0: User(name: "User", id: 0, email: "test@test.com"),
    1: User(id: 1, name: "John Doe", email: "john@example.com"),
    2: User(id: 2, name: "Jane Smith", email: "jane@example.com"),
    3: User(id: 3, name: "Alice Brown", email: "alice@example.com"),
    4: User(id: 4, name: "Bob White", email: "bob@example.com"),
    5: User(id: 5, name: "Johnny Depp", email: "john2@example.com"),
    6: User(id: 6, name: "Jane Austin", email: "jane2@example.com"),
    7: User(id: 7, name: "Alice Wonderland", email: "alice2@example.com"),
    8: User(id: 8, name: "Bob Budowniczy", email: "bob2@example.com"),
    9: User(id: 9, name: "Johnny Black", email: "john3@example.com"),
    10: User(id: 10, name: "Jane Juice", email: "jane3@example.com"),
    11: User(id: 11, name: "Alice Wood", email: "alice3@example.com"),
    12: User(id: 12, name: "Bob Builder", email: "bob3@example.com"),
    13: User(id: 13, name: "John Snow", email: "johnSnow@example.com"),
  };
  @override
  Future<User?> getUser(int uid) async {
    await Future.delayed(const Duration(milliseconds: 10));
    if (users[uid] == null) {
      return users[0];
    }
    return users[uid];
  }

  @override
  Future<User?> getUserByEmail(String email) async {
    await Future.delayed(const Duration(milliseconds: 10));
    try {
      return users.values.firstWhere((user) => user.email == email);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> createUser({
    required String name,
    required String email,
    File? profilePicture,
  }) async {
    return;
  }
}

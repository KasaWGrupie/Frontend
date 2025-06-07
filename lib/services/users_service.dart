import 'package:kasa_w_grupie/models/user.dart';

abstract class UsersService {
  Future<User?> getUser(int uid);
}

class UsersServiceMock implements UsersService {
  final Map<int, User> users = {
    0: User(name: "User", id: 0, email: "test@test.com"),
    1: User(id: 1, name: "John Doe", email: "john@example.com"),
    2: User(id: 2, name: "Jane Smith", email: "jane@example.com"),
    6: User(id: 6, name: "Jane Austin", email: "jane2@example.com"),
    7: User(id: 7, name: "Alice Wonderland", email: "alice2@example.com"),
  };
  @override
  Future<User?> getUser(int uid) async {
    await Future.delayed(const Duration(milliseconds: 10));
    if (users[uid] == null) {
      return users[0];
    }
    return users[uid];
  }
}

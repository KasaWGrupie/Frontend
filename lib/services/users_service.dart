import 'package:kasa_w_grupie/models/user.dart';

abstract class UsersService {
  Future<User?> getUser(String uid);
}

class UsersServiceMock implements UsersService {
  final List<User> allUsers = [
    User(name: "Captain Code", id: "0", email: "captain.code@test.com"),
    User(name: "Debugging Diva", id: "1", email: "debugging.diva@test.com"),
    User(name: "Syntax Samurai", id: "2", email: "syntax.samurai@test.com"),
    User(
        name: "Null Pointer Ninja",
        id: "3",
        email: "null.pointer.ninja@test.com"),
    User(name: "Runtime Rebel", id: "4", email: "runtime.rebel@test.com"),
    User(
        name: "Stacktrace Surfer",
        id: "5",
        email: "stacktrace.surfer@test.com"),
    User(name: "Binary Bandit", id: "6", email: "binary.bandit@test.com"),
    User(name: "Algorithm Ace", id: "7", email: "algorithm.ace@test.com"),
  ];

  @override
  Future<User?> getUser(String uid) async {
    return allUsers.firstWhere(
      (user) => user.id == uid,
    );
  }
}

import 'package:kasa_w_grupie/models/user.dart';

abstract class UsersService {
  Future<User?> getUser(String uid);
}

class UsersServiceMock implements UsersService {
  @override
  Future<User?> getUser(String uid) async {
    return User(name: "User", id: "0", email: "test@test.com");
  }
}

import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:kasa_w_grupie/config/api_config.dart';
import 'package:kasa_w_grupie/models/user.dart';

abstract class UsersService {
  Future<User?> getUser(int uid);
  Future<User?> getUserByEmail(String email);
  Future<bool> createUser({
    required String name,
    required String email,
    String? profilePicture,
    required String idToken,
  });
}

class UsersServiceApi implements UsersService {
  @override
  Future<User?> getUser(int uid) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/users/$uid');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return User.fromJson(json);
    } else if (response.statusCode == 404) {
      return null;
    } else {
      throw Exception('Failed to fetch user with id $uid');
    }
  }

  @override
  Future<User?> getUserByEmail(String email) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/users/email/$email');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return User.fromJson(json);
    } else if (response.statusCode == 404) {
      return null;
    } else {
      throw Exception('Failed to fetch user by email $email');
    }
  }

  @override
  Future<bool> createUser({
    required String name,
    required String email,
    String? profilePicture,
    required String idToken,
  }) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/users');

    final Map<String, dynamic> requestBody = {
      'name': name,
      'email': email,
    };

    //if (profilePicture != null) {
    requestBody['profilePicture'] = profilePicture;
    //}

    final String jsonBody = jsonEncode(requestBody);

    print('Request URL: $url');
    const JsonEncoder encoder = JsonEncoder.withIndent('  ');
    final prettyJson = encoder.convert(requestBody);
    print('Request body:\n$prettyJson');
    print('ID Token: ${idToken.substring(0, 20)}...');
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $idToken',
        'Content-Type': 'application/json; charset=utf-8',
      },
      body: jsonBody,
    );

    final encoder2 = const JsonEncoder.withIndent('  ');

    final fullRequestLog = {
      'method': 'POST',
      'url': url.toString(),
      'headers': {
        'Authorization': 'Bearer ${idToken.substring(0, 20)}...',
        'Content-Type': 'application/json; charset=utf-8',
      },
      'body': requestBody,
    };

    print('--- FULL HTTP REQUEST ---');
    print(encoder2.convert(fullRequestLog));

    print('Response status: ${response.statusCode}');
    print('Response headers: ${response.headers}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      return true;
    } else {
      print('Failed to create user: ${response.statusCode}');
      return false;
    }
  }
}

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

  // Get User object based on email
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
  Future<bool> createUser({
    required String name,
    required String email,
    String? profilePicture,
    required String idToken,
  }) async {
    return true;
  }
}

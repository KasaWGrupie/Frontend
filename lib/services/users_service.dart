import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:kasa_w_grupie/config/api_config.dart';
import 'package:kasa_w_grupie/models/user.dart';
import 'package:http_parser/http_parser.dart';
import 'package:kasa_w_grupie/services/auth_service.dart';

abstract class UsersService {
  Future<User?> getCurrentUser();
  Future<User?> getUser(int uid);
  Future<User?> getUserByEmail(String email);
  Future<void> createUser({
    required String name,
    required String email,
    File? profilePicture,
  });
}

class UsersServiceApi implements UsersService {
  UsersServiceApi({
    required this.authService,
  });

  final AuthService authService;

  Future<Map<String, String>> _getAuthHeaders() async {
    final idToken = await authService.userIdToken();
    return {
      'Authorization': 'Bearer $idToken',
      'Accept': '*/*',
      'Content-Type': 'application/json',
    };
  }

  @override
  Future<User?> getUser(int uid) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/users/$uid');
    final headers = await _getAuthHeaders();
    final response = await http.get(url, headers: headers);

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
    final headers = await _getAuthHeaders();
    final response = await http.get(url, headers: headers);

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
  Future<void> createUser({
    required String name,
    required String email,
    File? profilePicture,
  }) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/users');

    final idToken = await authService.userIdToken();
    final request = http.MultipartRequest('POST', url)
      ..headers['Authorization'] = 'Bearer $idToken'
      ..headers['Accept'] = '*/*';

    final dtoMap = {
      'name': name,
      'email': email,
    };

    final dtoJson = jsonEncode(dtoMap);

    request.fields['dto'] = dtoJson;

    if (profilePicture != null) {
      final pictureBytes = await profilePicture.readAsBytes();
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
      return;
    }
    throw Exception("Creating new account failed");
  }

  @override
  Future<User?> getCurrentUser() async {
    return await getUserByEmail(authService.userEmail);
  }
}

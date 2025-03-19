import 'package:kasa_w_grupie/models/friend.dart';

class User {
  User({required this.name, required this.id, required this.email});
  User.fromJson(Map<String, Object> json) {
    name = json['name']! as String;
    id = json['id']! as String;
    email = json['email']! as String;
  }

  late final String name;
  late final String email;
  late final String id;

  Map<String, Object> toJson() {
    return {
      'name': name,
      'id': id,
      'email': email,
    };
  }

  List<Friend> getFriends() {
    return [
      Friend(id: "1", name: "Alice Johnson", email: "alice@example.com"),
      Friend(id: "2", name: "Bob Smith", email: "bob@example.com"),
      Friend(id: "3", name: "Charlie Brown", email: "charlie@example.com"),
      Friend(id: "4", name: "Alice Johnson", email: "alice@example.com"),
      Friend(id: "5", name: "Bob Smith", email: "bob@example.com"),
      Friend(id: "6", name: "Charlie Brown", email: "charlie@example.com"),
    ];
  }
}

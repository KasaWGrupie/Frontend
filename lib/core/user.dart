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
}

class User {
  User({required this.name, required this.id, required this.email});
  User.fromJson(Map<String, dynamic> json) {
    name = json['name']! as String;
    id = json['id']! as int;
    email = json['email']! as String;
  }

  late final String name;
  late final String email;
  String get pictureUrl {
    return "https://i.kym-cdn.com/entries/icons/original/000/044/122/avatarguystaring.jpg";
  }

  late final int id;

  Map<String, Object> toJson() {
    return {
      'name': name,
      'id': id,
      'email': email,
    };
  }
}

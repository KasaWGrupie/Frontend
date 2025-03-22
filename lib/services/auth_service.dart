import 'package:kasa_w_grupie/models/user.dart';

enum SignInResult {
  invalidEmail,
  userDisabled,
  userNotFound,
  wrongPassword,
  success,
}

abstract class AuthService {
  bool get isSignedIn;

  Stream<bool> get isSignedInStream;

  String get userEmail;

  Future<String> userName();

  User? get currentUser;

  Future<SignInResult> signInWithEmail(String email, String password);

  // Returns error message in case of error, null otherwise

  Future<String?> signUpWithEmail(
    String email,
    String password,
    String name,
  );

  Future<void> signOut();
}

class AuthServiceMock implements AuthService {
  final Map<String, User> _users = {
    "test@test.com": User(name: "test", id: "0", email: "test@test.com")
  };
  User? _currentUser;
  bool _isSignedIn = false;

  @override
  bool get isSignedIn => _isSignedIn;

  @override
  Stream<bool> get isSignedInStream async* {
    yield _isSignedIn;
  }

  @override
  String get userEmail {
    if (_currentUser != null) {
      return _currentUser!.email;
    }
    return '';
  }

  @override
  Future<String> userName() async {
    if (_currentUser != null) {
      return _currentUser!.name;
    }
    return '';
  }

  @override
  User? get currentUser => _currentUser;

  @override
  Future<SignInResult> signInWithEmail(String email, String password) async {
    // Simulate a basic email-password match for demo
    final user = _users[email];

    if (user == null) {
      return SignInResult.userNotFound;
    }

    // For simplicity, let's assume the password is always correct
    _currentUser = user;
    _isSignedIn = true;
    return SignInResult.success;
  }

  @override
  Future<String?> signUpWithEmail(
      String email, String password, String name) async {
    // Check if the email is already used
    if (_users.containsKey(email)) {
      return 'Email already in use';
    }

    // Create a new user and add to the "database"
    final newUser = User(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        email: email);
    _users[email] = newUser;

    return null;
  }

  @override
  Future<void> signOut() async {
    _currentUser = null;
    _isSignedIn = false;
  }
}

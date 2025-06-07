import 'package:firebase_auth/firebase_auth.dart';
import 'package:kasa_w_grupie/models/user.dart' as u;
import 'package:kasa_w_grupie/services/users_service.dart';

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

  int get userId;

  Future<u.User?> currentUser();

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
  final Map<String, u.User> _users = {};
  u.User? _currentUser;
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
    final newUser = u.User(
        id: DateTime.now().millisecondsSinceEpoch, name: name, email: email);
    _users[email] = newUser;

    return null;
  }

  @override
  Future<void> signOut() async {
    _currentUser = null;
    _isSignedIn = false;
  }

  @override
  // TODO: implement userId
  int get userId => _currentUser!.id;

  @override
  Future<u.User?> currentUser() async {
    return _currentUser;
  }
}

class FirebaseAuthService implements AuthService {
  const FirebaseAuthService({
    required this.userService,
    required this.firebaseAuth,
  });

  final FirebaseAuth firebaseAuth;
  final UsersService userService;
  @override
  bool get isSignedIn => firebaseAuth.currentUser != null;

  @override
  Stream<bool> get isSignedInStream =>
      firebaseAuth.userChanges().map((user) => user != null);

  @override
  String get userEmail => firebaseAuth.currentUser!.email!;

  @override
  //TODO CHANGEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEE
  Future<String> userName() async {
    return userService.getUser(0).then((value) => value!.name);
  }

  @override
  Future<SignInResult> signInWithEmail(String email, String password) async {
    try {
      if (isSignedIn) {
        await firebaseAuth.signOut();
      }

      await firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      return SignInResult.success;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'invalid-email':
          return SignInResult.invalidEmail;
        case 'user-disabled':
          return SignInResult.userDisabled;
        case 'user-not-found' || 'invalid-credential':
          return SignInResult.userNotFound;
        case 'wrong-password':
          return SignInResult.wrongPassword;
        default:
          rethrow;
      }
    }
  }

  @override
  Future<String?> signUpWithEmail(
    String email,
    String password,
    String name,
  ) async {
    try {
      if (isSignedIn) {
        await firebaseAuth.signOut();
      }

      final credential = await firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (credential.user == null) {
        return 'Error occurred';
      }

      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (err) {
      return 'Error occurred';
    }
  }

  @override
  Future<void> signOut() => firebaseAuth.signOut();

  @override
  // TODO CHANGEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEE
  int get userId => 0;
  @override
  Future<u.User?> currentUser() {
    return userService.getUser(0);
  }
}

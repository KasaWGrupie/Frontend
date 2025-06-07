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
  FirebaseAuthService({
    required this.userService,
    required this.firebaseAuth,
  });

  final FirebaseAuth firebaseAuth;
  final UsersService userService;

  u.User? _cachedUser;

  @override
  bool get isSignedIn => firebaseAuth.currentUser != null;

  @override
  Stream<bool> get isSignedInStream =>
      firebaseAuth.userChanges().map((user) => user != null);

  @override
  String get userEmail => firebaseAuth.currentUser?.email ?? '';

  @override
  Future<String> userName() async {
    final user = await currentUser();
    return user?.name ?? '';
  }

  @override
  int get userId {
    if (_cachedUser != null) return _cachedUser!.id;
    throw Exception("User not loaded yet.");
  }

  @override
  Future<u.User?> currentUser() async {
    if (_cachedUser != null) return _cachedUser;

    final email = firebaseAuth.currentUser?.email;
    if (email == null) return null;

    _cachedUser = await userService.getUserByEmail(email);
    return _cachedUser;
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

      // After signing in, retrieve and cache backend user
      _cachedUser = await userService.getUserByEmail(email);
      if (_cachedUser == null) return SignInResult.userNotFound;

      return SignInResult.success;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'invalid-email':
          return SignInResult.invalidEmail;
        case 'user-disabled':
          return SignInResult.userDisabled;
        case 'user-not-found':
        case 'invalid-credential':
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
        return 'Firebase auth failed';
      }
      final user = credential.user!;
      final token = await user.getIdToken();

      if (token != null) {
        await userService.createUser(
          name: name,
          email: user.email!,
          profilePicture: null,
          idToken: token,
        );
      }

      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (_) {
      return 'Unexpected error';
    }
  }

  @override
  Future<void> signOut() async {
    _cachedUser = null;
    await firebaseAuth.signOut();
  }
}

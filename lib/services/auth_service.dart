import 'package:firebase_auth/firebase_auth.dart';

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

  Future<String> userIdToken();

  String get userEmail;

  Future<SignInResult> signInWithEmail(String email, String password);

  // Returns error message in case of error, null otherwise
  Future<String?> signUpWithEmail(
    String email,
    String password,
    String name,
  );

  Future<void> signOut();
}

class FirebaseAuthService implements AuthService {
  FirebaseAuthService({
    required this.firebaseAuth,
  });

  final FirebaseAuth firebaseAuth;

  @override
  bool get isSignedIn => firebaseAuth.currentUser != null;

  @override
  Stream<bool> get isSignedInStream =>
      firebaseAuth.userChanges().map((user) => user != null);

  @override
  String get userEmail => firebaseAuth.currentUser?.email ?? '';

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

  String? _cachedToken;

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

      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (_) {
      return 'Unexpected error';
    }
  }

  @override
  Future<void> signOut() async {
    _cachedToken = null; // Clear cached token on sign out
    await firebaseAuth.signOut();
  }

  @override
  Future<String> userIdToken() async {
    if (_cachedToken != null) {
      return _cachedToken!;
    }
    final user = firebaseAuth.currentUser;
    if (user == null) {
      throw Exception("User not signed in");
    }
    _cachedToken = await user.getIdToken();
    if (_cachedToken == null) {
      throw Exception("Couldn't retrieve user ID token");
    }
    return _cachedToken!;
  }
}

import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kasa_w_grupie/services/auth_service.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit({required this.authService}) : super(authService.stateFromAuth) {
    _sub = authService.isSignedInStream.listen((isSignedIn) {
      emit(authService.stateFromAuth);
    });
  }

  bool isSignedIn() => state is SignedInState;

  final AuthService authService;
  StreamSubscription<bool>? _sub;

  Future<void> signInWithEmail(String email, String password) async {
    emit(SigningInState());
    await Future<void>.delayed(const Duration(seconds: 1));

    try {
      final result = await authService.signInWithEmail(email, password);

      switch (result) {
        case SignInResult.invalidEmail:
          emit(SignedOutState(error: 'This email address is invalid.'));
        case SignInResult.userDisabled:
          emit(SignedOutState(error: 'This user has been banned.'));
        case SignInResult.userNotFound:
          emit(SignedOutState(error: 'User not found'));
        case SignInResult.wrongPassword:
          emit(SignedOutState(error: 'Invalid credentials.'));
        case SignInResult.success:
          emit(SignedInState(email: email));
      }
    } catch (err) {
      emit(SignedOutState(error: 'Unexpected error: $err'));
    }
  }

  Future<String> get userName async => authService.userName();

  int get userUid => authService.userId;

  Future<void> signOut() async {
    await authService.signOut();

    emit(SignedOutState());
  }

  Future<String?> trySignUp(String email, String password, String name) =>
      authService.signUpWithEmail(email, password, name);

  void resetError() {
    if (state is SignedOutState) {
      emit(SignedOutState());
    }
  }

  @override
  Future<void> close() async {
    await _sub?.cancel();
    return super.close();
  }
}

extension on AuthService {
  AuthState get stateFromAuth =>
      isSignedIn ? SignedInState(email: userEmail) : SignedOutState();
}

sealed class AuthState with EquatableMixin {}

class SignedInState extends AuthState {
  SignedInState({required this.email});

  final String email;

  @override
  List<Object?> get props => [email];
}

class SigningInState extends AuthState {
  @override
  List<Object?> get props => [];
}

class SignedOutState extends AuthState {
  SignedOutState({this.error});

  final String? error;

  @override
  List<Object?> get props => [error];
}

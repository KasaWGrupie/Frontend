import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kasa_w_grupie/services/auth_service.dart';
import 'package:kasa_w_grupie/services/users_service.dart';

class RegisterCubit extends Cubit<RegisterState> {
  RegisterCubit({required this.authService, required this.usersService})
      : super(const RegisterState.initial());

  final AuthService authService;
  final UsersService usersService;
  File? profilePicture; // Added field to store profile picture

  Future<void> registerWithEmail(
    String email,
    String password,
    String name,
  ) async {
    emit(const RegisterState.loading());

    try {
      final result = await authService.signUpWithEmail(email, password, name);
      if (result != null) {
        emit(RegisterState.error(result));
        return;
      }
      final loginResult = await authService.signInWithEmail(email, password);

      if (loginResult != SignInResult.success) {
        emit(RegisterState.error("Failed to log in after registration."));
        return;
      } else {
        await usersService.createUser(
          name: name,
          email: email,
          profilePicture:
              profilePicture, // Pass the profile picture to usersService
        );
        final user = await usersService.getCurrentUser();
        if (user == null) {
          emit(RegisterState.error('Failed to create user profile.'));
          return;
        }
        await authService.signOut(); // Sign out after registration
        emit(const RegisterState.success());
      }
    } catch (err) {
      emit(RegisterState.error('Unexpected error: $err'));
    }
  }
}

class RegisterState {
  const RegisterState._({
    this.error,
    this.isLoading = false,
    this.isSuccess = false,
  });

  const RegisterState.initial() : this._();

  const RegisterState.loading() : this._(isLoading: true);

  const RegisterState.success() : this._(isSuccess: true);

  const RegisterState.error(String error) : this._(error: error);

  final String? error;
  final bool isLoading;
  final bool isSuccess;
}

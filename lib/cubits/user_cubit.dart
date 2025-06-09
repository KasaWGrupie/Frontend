import 'package:bloc/bloc.dart';
import 'package:kasa_w_grupie/models/user.dart';
import 'package:kasa_w_grupie/services/users_service.dart';

abstract class UserState {}

class UserLoading extends UserState {}

class UserLoaded extends UserState {
  final User user;
  UserLoaded(this.user);
}

class UserError extends UserState {
  final String errorMessage;
  UserError(this.errorMessage);
}

class UserCubit extends Cubit<UserState> {
  final UsersService userService;

  UserCubit(this.userService) : super(UserLoading());

  // Fetch user by id
  Future<void> fetchUserById(int userId) async {
    try {
      emit(UserLoading());
      final user = await userService.getUser(userId);
      if (user != null) {
        emit(UserLoaded(user));
      } else {
        emit(UserError("User not found"));
      }
    } catch (e) {
      emit(UserError("Failed to load user: $e"));
    }
  }
}

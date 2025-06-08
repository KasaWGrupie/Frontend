import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kasa_w_grupie/services/group_service.dart';
import 'package:kasa_w_grupie/models/group.dart';

class AddGroupCubit extends Cubit<AddGroupState> {
  final GroupService groupService;

  AddGroupCubit({required this.groupService})
      : super(const AddGroupState.initial());

  Future<void> addGroup({
    required String name,
    String? description,
    required CurrencyEnum currency,
    required int adminId,
    required List<int> members,
    required String invitationCode,
  }) async {
    emit(const AddGroupState.loading());

    try {
      final newGroup = NewGroup(
        name: name,
        description: description,
        currency: currency,
        membersId: members,
        invitationCode: invitationCode,
        picture: null,
        adminId: adminId,
      );

      final result = await groupService.addGroup(newGroup);

      if (result != null) {
        emit(AddGroupState.error(result));
      } else {
        emit(const AddGroupState.success());
      }
    } catch (err) {
      emit(AddGroupState.error('Unexpected error: $err'));
    }
  }
}

class AddGroupState {
  const AddGroupState._({
    this.error,
    this.isLoading = false,
    this.isSuccess = false,
  });

  const AddGroupState.initial() : this._();

  const AddGroupState.loading() : this._(isLoading: true);

  const AddGroupState.success() : this._(isSuccess: true);

  const AddGroupState.error(String error) : this._(error: error);

  final String? error;
  final bool isLoading;
  final bool isSuccess;
}

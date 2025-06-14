import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kasa_w_grupie/models/friend.dart';
import 'package:kasa_w_grupie/models/group.dart';
import 'package:kasa_w_grupie/models/user.dart';
import 'package:kasa_w_grupie/services/friends_service.dart';
import 'package:kasa_w_grupie/services/group_service.dart';
import 'package:kasa_w_grupie/services/users_service.dart';

class EditGroupCubit extends Cubit<EditGroupState> {
  final GroupService groupService;
  final FriendsService friendsService;
  final UsersService usersService;
  final int groupId;

  EditGroupCubit({
    required this.groupService,
    required this.groupId,
    required this.friendsService,
    required this.usersService,
  }) : super(EditGroupState.initial());

  Future<void> loadGroup() async {
    try {
      final group = await groupService.getGroupById(groupId);
      final friends = await friendsService.getFriends();
      final groupMembers = await groupService.getUsersForGroup(groupId);
      final currentUserId =
          await usersService.getCurrentUser().then((user) => user!.id);

      final membersSet = group.membersId.toSet();

      final Set<int> uniqueUserIds = {
        ...friends.map((f) => f.id),
        ...groupMembers.map((m) => m.id),
      };

      // Create Friend objects for all users (excluding logged-in user)
      List<Friend> allUsers = uniqueUserIds
          .where((userId) => userId != currentUserId)
          .map((userId) {
        User? user = friends.firstWhere(
          (f) => f.id == userId,
          orElse: () => groupMembers.firstWhere((m) => m.id == userId),
        );

        return Friend(
          id: user.id,
          name: user.name,
          email: user.email,
          isSelected: membersSet.contains(user.id),
        );
      }).toList();

      emit(EditGroupLoaded(group: group, members: allUsers));
    } catch (e) {
      emit(EditGroupError('Failed to load group: $e'));
    }
  }

  Future<void> updateGroup({
    required String name,
    required String? description,
    required List<int> members,
    bool? isActive,
  }) async {
    if (state is! EditGroupLoaded) return;

    final currentState = state as EditGroupLoaded;
    final oldGroup = currentState.group;

    final updatedGroup = oldGroup.copyWith(
      name: name,
      description: description,
      membersId: members,
    );

    emit(EditGroupState.saving());

    try {
      final updateResult = await groupService.updateGroup(updatedGroup);

      if (updateResult != null) {
        emit(EditGroupState.error(updateResult));
        return;
      }

      if (isActive != null) {
        final statusResult =
            await groupService.updateGroupStatus(updatedGroup.id, isActive);

        if (statusResult != null) {
          emit(EditGroupState.error(statusResult));
          return;
        }
      }

      emit(EditGroupState.success());
    } catch (e) {
      emit(EditGroupState.error('Failed to update group: $e'));
    }
  }
}

abstract class EditGroupState {
  const EditGroupState();

  factory EditGroupState.initial() => EditGroupInitial();
  factory EditGroupState.loading() => EditGroupLoading();
  factory EditGroupState.loaded(
          {required Group group, required List<Friend> members}) =>
      EditGroupLoaded(group: group, members: members);
  factory EditGroupState.saving() => EditGroupSaving();
  factory EditGroupState.success() => EditGroupSuccess();
  factory EditGroupState.error(String message) => EditGroupError(message);
}

class EditGroupInitial extends EditGroupState {}

class EditGroupLoading extends EditGroupState {}

class EditGroupLoaded extends EditGroupState {
  final Group group;
  final List<Friend> members;

  EditGroupLoaded({required this.group, required this.members});
}

class EditGroupStatusUpdated extends EditGroupState {
  final Group group;
  EditGroupStatusUpdated(this.group);
}

class EditGroupSaving extends EditGroupState {}

class EditGroupSuccess extends EditGroupState {}

class EditGroupError extends EditGroupState {
  final String message;
  EditGroupError(this.message);
}

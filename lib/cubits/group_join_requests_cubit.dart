import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kasa_w_grupie/models/group_join_request.dart';
import 'package:kasa_w_grupie/services/group_service.dart';

sealed class GroupJoinRequestsState {}

class GroupJoinRequestsLoading extends GroupJoinRequestsState {}

class GroupJoinRequestsLoaded extends GroupJoinRequestsState {
  final List<GroupJoinRequest> requests;
  GroupJoinRequestsLoaded(this.requests);
}

class GroupJoinRequestsError extends GroupJoinRequestsState {
  final String message;
  GroupJoinRequestsError(this.message);
}

class GroupJoinRequestsCubit extends Cubit<GroupJoinRequestsState> {
  final GroupService groupService;
  final int groupId;

  GroupJoinRequestsCubit({required this.groupService, required this.groupId})
      : super(GroupJoinRequestsLoading());

  Future<void> fetchRequests() async {
    try {
      final requests = await groupService.getJoinRequests(groupId);
      emit(GroupJoinRequestsLoaded(requests));
    } catch (e) {
      emit(GroupJoinRequestsError('Failed to load join requests'));
    }
  }

  Future<void> respondToRequest(int requestId, bool accept) async {
    try {
      await groupService.respondToJoinRequest(groupId, requestId, accept);
      fetchRequests();
    } catch (e) {
      emit(GroupJoinRequestsError('Failed to update request'));
    }
  }
}

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kasa_w_grupie/models/group.dart';
import 'package:kasa_w_grupie/services/group_service.dart';

class GroupsCubit extends Cubit<List<Group>?> {
  GroupsCubit(this._groupService) : super(null);

  final GroupService _groupService;

  Future<void> fetch() async {
    final groups = await _groupService.getGroupsForUser();
    emit(groups);
  }

  Future<bool> joinGroupByInvitationCode(String code) async {
    final error = await _groupService.joinGroupByCode(code);
    return error == null;
  }
}

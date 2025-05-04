import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kasa_w_grupie/cubits/group_cubit.dart';
import 'package:kasa_w_grupie/screens/base_screen.dart';
import 'package:kasa_w_grupie/screens/group_screen/expenses_screen.dart';
import 'package:kasa_w_grupie/screens/group_screen/members_screen.dart';
import 'package:kasa_w_grupie/screens/group_screen/settlements_screen.dart';
import 'package:kasa_w_grupie/services/group_service.dart';
import 'package:kasa_w_grupie/services/users_service.dart';

class GroupScreen extends StatelessWidget {
  const GroupScreen({required this.groupId, super.key});

  final String groupId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => GroupCubit(
        groupId: groupId,
        groupService: context.read<GroupService>(),
        usersService: context.read<UsersService>(),
      )..fetch(),
      child: BlocBuilder<GroupCubit, GroupState>(
        builder: (buildContext, state) => switch (state) {
          GroupLoading() => BaseScreen(
              title: 'Group details',
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          GroupError(message: final m) => BaseScreen(
              title: 'Error',
              child: Center(
                child: Text(
                  m,
                ),
              ),
            ),
          GroupLoaded() => _loaded(state)
        },
      ),
    );
  }

  Widget _loaded(GroupLoaded state) {
    return DefaultTabController(
      length: 3,
      child: BaseScreen(
        title: state.group.name,
        appBarBottom: const TabBar(
          tabs: [
            Tab(text: 'Expenses'),
            Tab(text: 'Members'),
            Tab(text: 'Settlements'),
          ],
        ),
        child: TabBarView(
          children: [
            MembersScreen(loadedState: state),
            SettlementsScreen(loadedState: state)
          ],
        ),
      ),
    );
  }
}

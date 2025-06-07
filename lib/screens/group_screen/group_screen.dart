import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:kasa_w_grupie/cubits/group_cubit.dart';
import 'package:kasa_w_grupie/screens/base_screen.dart';
import 'package:kasa_w_grupie/screens/group_screen/expenses_screen.dart';
import 'package:kasa_w_grupie/screens/group_screen/members_screen.dart';
import 'package:kasa_w_grupie/screens/group_screen/settlements_screen.dart';
import 'package:kasa_w_grupie/services/auth_service.dart';
import 'package:kasa_w_grupie/services/group_service.dart';
import 'package:kasa_w_grupie/services/users_service.dart';

class GroupScreen extends StatelessWidget {
  const GroupScreen({required this.groupId, super.key});

  final int groupId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => GroupCubit(
        groupId: groupId,
        groupService: context.read<GroupService>(),
        usersService: context.read<UsersService>(),
        authService: context.read<AuthService>(),
      )..fetch(),
      child: BlocBuilder<GroupCubit, GroupState>(
        builder: (buildContext, state) => switch (state) {
          GroupLoading() => BaseScreen(
              title: 'Group details',
              child: const Center(
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
          GroupLoaded() => _loaded(state, context),
        },
      ),
    );
  }

  Widget _loaded(GroupLoaded state, BuildContext context) {
    final group = state.group;
    final currentUserId = state.currentUserId;

    return DefaultTabController(
      length: 3,
      child: BaseScreen(
        title: group.name,
        appBarBottom: const TabBar(
          tabs: [
            Tab(text: 'Expenses'),
            Tab(text: 'Members'),
            Tab(text: 'Settlements'),
          ],
        ),
        appBarActions: currentUserId == group.adminId
            ? [
                IconButton(
                  icon: const Icon(Icons.settings),
                  onPressed: () {
                    context.go('/editGroup/$groupId');
                  },
                ),
              ]
            : null,
        child: TabBarView(
          children: [
            ExpensesScreen(loadedState: state),
            MembersScreen(loadedState: state),
            SettlementsScreen(loadedState: state),
          ],
        ),
      ),
    );
  }
}

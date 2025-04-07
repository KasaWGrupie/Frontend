import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:kasa_w_grupie/cubits/groups_cubit.dart';
import 'package:kasa_w_grupie/models/group.dart';
import 'package:kasa_w_grupie/screens/base_screen.dart';
import 'package:kasa_w_grupie/screens/groups_screen/group_tile.dart';
import 'package:kasa_w_grupie/services/group_service.dart';

class GroupsScreen extends StatelessWidget {
  const GroupsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => GroupsCubit(context.read<GroupsService>())..fetch(),
      child: BaseScreen(
        floatingActionButton: FloatingActionButton(
          onPressed: () => context.go('/addGroup'),
          child: const Icon(Icons.add),
        ),
        title: 'Groups',
        child: BlocBuilder<GroupsCubit, List<Group>?>(
          builder: (context, state) {
            if (state == null) {
              return Center(
                child: CircularProgressIndicator(),
              );
            } else {
              return RefreshIndicator(
                onRefresh: () => context.read<GroupsCubit>().fetch(),
                child: ListView.builder(
                  itemBuilder: (buildContext, index) => state.length > index
                      ? GroupTile(
                          groupName: state[index].name,
                          groupId: state[index].id,
                          //imageUrl: state[index].imageUrl,
                        )
                      : null,
                ),
              );
            }
          },
        ),
      ),
    );
  }
}

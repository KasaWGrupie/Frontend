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
      create: (context) => GroupsCubit(context.read<GroupService>())..fetch(),
      child: _GroupsScreenContent(),
    );
  }
}

class _GroupsScreenContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            heroTag: 'joinGroup',
            onPressed: () async {
              final code = await showDialog<String>(
                context: context,
                builder: (context) {
                  final controller = TextEditingController();
                  return AlertDialog(
                    title: const Text('Join Group'),
                    content: TextField(
                      controller: controller,
                      decoration: const InputDecoration(
                        labelText: 'Enter invitation code',
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () =>
                            Navigator.of(context).pop(controller.text.trim()),
                        child: const Text('Join'),
                      ),
                    ],
                  );
                },
              );

              if (code != null && code.isNotEmpty && context.mounted) {
                final success = await context
                    .read<GroupsCubit>()
                    .joinGroupByInvitationCode(code);
                if (success && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text(
                            'Successfully send request to join the group!')),
                  );
                } else if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Invalid or expired code.')),
                  );
                }
              }
            },
            child: const Icon(Icons.link),
          ),
          const SizedBox(height: 12),
          FloatingActionButton(
            heroTag: 'addGroup',
            onPressed: () => context.go('/addGroup'),
            child: const Icon(Icons.add),
          ),
        ],
      ),
      title: 'Groups',
      child: BlocBuilder<GroupsCubit, List<Group>?>(
        builder: (context, state) {
          if (state == null) {
            return const Center(
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
    );
  }
}

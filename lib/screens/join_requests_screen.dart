import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kasa_w_grupie/cubits/group_join_requests_cubit.dart';

class GroupJoinRequestsScreen extends StatelessWidget {
  final String groupId;

  const GroupJoinRequestsScreen({super.key, required this.groupId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Join Requests')),
      body: BlocBuilder<GroupJoinRequestsCubit, GroupJoinRequestsState>(
        builder: (context, state) {
          if (state is GroupJoinRequestsLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is GroupJoinRequestsError) {
            return Center(child: Text(state.message));
          } else if (state is GroupJoinRequestsLoaded) {
            if (state.requests.isEmpty) {
              return const Center(child: Text('No join requests.'));
            }

            return ListView.builder(
              itemCount: state.requests.length,
              itemBuilder: (context, index) {
                final req = state.requests[index];
                return ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.person)),
                  title: Text(req.name),
                  subtitle: Text(req.email),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: Colors.green,
                        child: IconButton(
                          icon: const Icon(Icons.check, color: Colors.white),
                          onPressed: () => context
                              .read<GroupJoinRequestsCubit>()
                              .respondToRequest(req.id, true),
                        ),
                      ),
                      const SizedBox(width: 8),
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: Colors.red,
                        child: IconButton(
                          icon: const Icon(Icons.close, color: Colors.white),
                          onPressed: () => context
                              .read<GroupJoinRequestsCubit>()
                              .respondToRequest(req.id, false),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          }
          return const SizedBox();
        },
      ),
    );
  }
}

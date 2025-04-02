import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:kasa_w_grupie/cubits/edit_group_cubit.dart';
import 'package:kasa_w_grupie/screens/base_screen.dart';
import 'package:kasa_w_grupie/screens/add_group_screen/widgets/friends_list.dart';
import 'package:kasa_w_grupie/screens/add_group_screen/widgets/group_photo.dart';
import 'package:kasa_w_grupie/models/friend.dart';

class EditGroupScreen extends StatefulWidget {
  final String groupId;

  const EditGroupScreen({super.key, required this.groupId});

  @override
  State<EditGroupScreen> createState() => _EditGroupScreenState();
}

class _EditGroupScreenState extends State<EditGroupScreen> {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();

  late List<Friend> friends;
  bool isSelectingFriends = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<EditGroupCubit, EditGroupState>(
      listener: (context, state) {
        if (state is EditGroupSuccess) {
          context.pop();
        }
      },
      child: BaseScreen(
        title: 'Edit Group',
        child: BlocBuilder<EditGroupCubit, EditGroupState>(
          builder: (context, state) {
            if (state is EditGroupLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is EditGroupError) {
              return Center(
                  child: Text(state.message,
                      style: const TextStyle(color: Colors.red)));
            } else if (state is EditGroupLoaded) {
              final group = state.group;
              friends = state.members;

              nameController.text = group.name;
              descriptionController.text = group.description ?? '';

              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Form(
                    key: _formKey,
                    child: ListView(
                      children: [
                        // Group Photo
                        const GroupPhotoWithAddButton(),
                        const SizedBox(height: 16),

                        // Group Name
                        TextFormField(
                          controller: nameController,
                          decoration: InputDecoration(
                            labelText: 'Group Name',
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8)),
                          ),
                          validator: (value) => value == null || value.isEmpty
                              ? 'Please enter a group name'
                              : null,
                        ),
                        const SizedBox(height: 16),

                        // Group Description
                        TextFormField(
                          controller: descriptionController,
                          decoration: InputDecoration(
                            labelText: 'Group Description (optional)',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Friend Selector
                        FriendSelector(
                          friends: friends,
                          isSelectingFriends: isSelectingFriends,
                          onExpansionChanged: (expanded) {
                            setState(() {
                              isSelectingFriends = expanded;
                            });
                          },
                          onFriendToggle: (friend) {
                            setState(() {
                              friend.isSelected = !friend.isSelected;
                            });
                          },
                        ),

                        const SizedBox(height: 16),

                        // Save Changes Button
                        ElevatedButton(
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              List<String> selectedMembersIds = friends
                                  .where((friend) => friend.isSelected)
                                  .map((friend) => friend.id)
                                  .toList();

                              await context.read<EditGroupCubit>().updateGroup(
                                    name: nameController.text,
                                    description: descriptionController.text,
                                    members: selectedMembersIds,
                                  );
                            }
                          },
                          child: const Text('Save Changes'),
                        ),
                        if (state is EditGroupSaving) ...[
                          const SizedBox(height: 16),
                          const Center(child: CircularProgressIndicator()),
                        ],
                      ],
                    ),
                  ),
                ),
              );
            }
            return const Center(child: Text("Unknown State"));
          },
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:kasa_w_grupie/cubits/edit_group_cubit.dart';
import 'package:kasa_w_grupie/screens/add_group_screen/widgets/invitation_code_tile.dart';
import 'package:kasa_w_grupie/screens/base_screen.dart';
import 'package:kasa_w_grupie/screens/add_group_screen/widgets/friends_list.dart';
import 'package:kasa_w_grupie/screens/add_group_screen/widgets/group_photo.dart';
import 'package:kasa_w_grupie/models/friend.dart';
import 'package:kasa_w_grupie/screens/edit_group_screen/widgets/read_only_currency_tile.dart';

class EditGroupScreen extends StatefulWidget {
  final String groupId;

  const EditGroupScreen({super.key, required this.groupId});

  @override
  State<EditGroupScreen> createState() => EditGroupScreenState();
}

class EditGroupScreenState extends State<EditGroupScreen> {
  final formKey = GlobalKey<FormState>();
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
          context.go('/groups');
        }
      },
      child: BaseScreen(
        title: 'Edit Group',
        child: BlocBuilder<EditGroupCubit, EditGroupState>(
          builder: (context, state) {
            if (state is EditGroupInitial || state is EditGroupLoading) {
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
                    key: formKey,
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

                        // Invitation Code (Read-only)
                        InvitationCodeField(
                          controller:
                              TextEditingController(text: group.invitationCode),
                          onCopyPressed: () {
                            Clipboard.setData(
                                ClipboardData(text: group.invitationCode));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Copied!')),
                            );
                          },
                        ),
                        const Text(
                          '*Invitation code can only be copied',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        const SizedBox(height: 8),

                        // Currency tile
                        ReadOnlyCurrencyTile(
                            currencyLabel: group.currency.name.toUpperCase()),
                        const Text(
                          '*Currency cannot be changed after group creation',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        const SizedBox(height: 8),

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
                            if (formKey.currentState!.validate()) {
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

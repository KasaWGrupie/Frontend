import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:kasa_w_grupie/cubits/add_group_cubit.dart';
import 'package:kasa_w_grupie/models/friend.dart';
import 'package:kasa_w_grupie/models/group.dart';
import 'package:kasa_w_grupie/screens/base_screen.dart';
import 'package:flutter/services.dart';
import 'package:kasa_w_grupie/models/user.dart';
import 'package:kasa_w_grupie/screens/add_group_screen/widgets/friends_list.dart';
import 'package:kasa_w_grupie/screens/add_group_screen/widgets/invitation_code_tile.dart';
import 'package:kasa_w_grupie/services/auth_service.dart';
import 'package:kasa_w_grupie/screens/add_group_screen/widgets/group_photo.dart';
import 'package:kasa_w_grupie/screens/add_group_screen/widgets/currency_list.dart';
import 'dart:math';

import 'package:kasa_w_grupie/services/friends_service.dart';
import 'package:kasa_w_grupie/services/users_service.dart';

class CreateGroupScreen extends StatefulWidget {
  const CreateGroupScreen({super.key});

  @override
  State<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final invitationCodeController = TextEditingController();
  final membersController = TextEditingController();

  CurrencyEnum selectedCurrency = CurrencyEnum.eur;

  late final User currentUser;
  bool isSelectingFriends = false;

  late final dynamic _getFriendsFuture;

  Future<List<Friend>> getFriends() async {
    final usersService = context.read<UsersService>();
    final friendService = context.read<FriendsService>();
    currentUser = (await usersService.getCurrentUser())!;
    return parseUsersToFriends(await friendService.getFriends());
  }

  @override
  void initState() {
    super.initState();
    _getFriendsFuture = getFriends();
    // Fetch current user from AuthService
    invitationCodeController.text = generateInvitationCode();
  }

  // Function converting list of Users to list of Friends
  List<Friend> parseUsersToFriends(List<User> list) {
    return list.map((user) {
      return Friend(
        id: user.id,
        name: user.name,
        email: user.email,
        pictureUrl: user.pictureUrl,
      );
    }).toList();
  }

  // Function generating invitation code - mock function, to be changed
  String generateInvitationCode({int length = 8}) {
    const chars =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    Random rand = Random();
    return List.generate(length, (index) => chars[rand.nextInt(chars.length)])
        .join();
  }

  // Helper funcion for copying invitation code
  void copyToClipboard(String code) {
    Clipboard.setData(ClipboardData(text: code));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Invitation code copied to clipboard!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _getFriendsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasData) {
          List<Friend> friends = snapshot.data! as List<Friend>;
          return BlocProvider(
            create: (context) => AddGroupCubit(
                groupService: context.read<AddGroupCubit>().groupService),
            child: BlocListener<AddGroupCubit, AddGroupState>(
              listener: (context, state) {
                if (state.isSuccess) {
                  context.go('/groups');
                }
              },
              child: BaseScreen(
                title: 'Create Group',
                child: BlocBuilder<AddGroupCubit, AddGroupState>(
                  builder: (context, state) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Form(
                          key: _formKey,
                          child: ListView(
                            children: [
                              // Group photo field
                              GroupPhotoWithAddButton(
                                cubit: context.read(),
                              ),
                              const SizedBox(height: 16),

                              // Group name field
                              TextFormField(
                                controller: nameController,
                                decoration: InputDecoration(
                                  labelText: 'Group Name',
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8)),
                                ),
                                validator: (value) =>
                                    value == null || value.isEmpty
                                        ? 'Please enter a group name'
                                        : null,
                              ),
                              const SizedBox(height: 16),

                              // Group description field
                              TextFormField(
                                controller: descriptionController,
                                decoration: InputDecoration(
                                  labelText: 'Group Description (optional)',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide:
                                        BorderSide(color: Colors.grey.shade400),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),

                              // Currency field
                              CurrencySelector(
                                selectedCurrency: selectedCurrency,
                                onCurrencySelected: (currency) {
                                  setState(() {
                                    selectedCurrency = currency;
                                  });
                                },
                                isSelectingFriends: isSelectingFriends,
                                onExpansionChanged: (expanded) {
                                  setState(() {
                                    isSelectingFriends = expanded;
                                  });
                                },
                              ),
                              const SizedBox(height: 16),

                              // Add members field
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

                              // Copy invitation code field
                              InvitationCodeField(
                                controller: invitationCodeController,
                                onCopyPressed: () {
                                  copyToClipboard(
                                      invitationCodeController.text);
                                },
                              ),

                              const SizedBox(height: 16),

                              // Create group button
                              ElevatedButton(
                                onPressed: () async {
                                  if (_formKey.currentState!.validate()) {
                                    List<int> selectedMembersIds = friends
                                        .where((friend) => friend.isSelected)
                                        .map((friend) => friend.id)
                                        .toList();
                                    await context
                                        .read<AddGroupCubit>()
                                        .addGroup(
                                          name: nameController.text,
                                          description:
                                              descriptionController.text,
                                          currency: selectedCurrency,
                                          adminId: currentUser.id,
                                          members: selectedMembersIds,
                                          invitationCode:
                                              invitationCodeController.text,
                                        );
                                  }
                                },
                                child: const Text('Create Group'),
                              ),
                              const SizedBox(height: 16),
                              if (state.error != null) ...[
                                Text(state.error!,
                                    style: const TextStyle(color: Colors.red)),
                                const SizedBox(height: 16),
                              ] else if (state.isLoading) ...[
                                Center(
                                  child: const CircularProgressIndicator(),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          );
        } else {
          return const Center(child: Text('An error occurred.'));
        }
      },
    );
  }
}

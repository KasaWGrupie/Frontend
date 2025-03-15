import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:kasa_w_grupie/features/add_group/add_group_cubit.dart';
import 'package:kasa_w_grupie/core/group.dart';
import 'package:kasa_w_grupie/core/widgets/base_screen.dart';

import 'dart:math';
import 'package:flutter/services.dart';

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

  @override
  void initState() {
    super.initState();
    invitationCodeController.text = generateInvitationCode();
  }

  // Function simulating generating invitation code - to be changed
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
    return BlocProvider(
      create: (context) => AddGroupCubit(
          groupService: context.read<AddGroupCubit>().groupService),
      child: BlocListener<AddGroupCubit, AddGroupState>(
        listener: (context, state) {
          if (state.isSuccess) {
            context.pop();
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
                        // Group name field
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

                        // Group description field
                        TextFormField(
                          controller: descriptionController,
                          decoration: InputDecoration(
                            labelText: 'Group Description (optional)',
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Currency field
                        DropdownButtonFormField<CurrencyEnum>(
                          value: selectedCurrency,
                          decoration: InputDecoration(
                            labelText: 'Currency',
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8)),
                          ),
                          items: CurrencyEnum.values.map((currency) {
                            return DropdownMenuItem<CurrencyEnum>(
                              value: currency,
                              child: Text(currency.name.toUpperCase()),
                            );
                          }).toList(),
                          onChanged: (CurrencyEnum? value) {
                            if (value != null) {
                              setState(() => selectedCurrency = value);
                            }
                          },
                          validator: (value) =>
                              value == null ? 'Please select a currency' : null,
                        ),
                        const SizedBox(height: 16),

                        // Add members field
                        TextFormField(
                          controller: membersController,
                          decoration: InputDecoration(
                            labelText: 'Members',
                            hintText: 'Enter member emails (comma separated)',
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8)),
                          ),
                          validator: (value) => value == null || value.isEmpty
                              ? 'Please enter member emails'
                              : null,
                        ),
                        const SizedBox(height: 16),

                        // Copy invitation code field
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: invitationCodeController,
                                decoration: InputDecoration(
                                  labelText: 'Invitation Code',
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8)),
                                ),
                                readOnly: true,
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.copy),
                              onPressed: () => copyToClipboard(
                                  invitationCodeController.text),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Create group button
                        ElevatedButton(
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              await context.read<AddGroupCubit>().addGroup(
                                    name: nameController.text,
                                    description: descriptionController.text,
                                    currency: selectedCurrency,
                                    members: membersController.text
                                        .split(',')
                                        .map((e) => e.trim())
                                        .toList(),
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
                          const CircularProgressIndicator(),
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
  }
}

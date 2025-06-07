import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kasa_w_grupie/cubits/group_cubit.dart';
import 'package:kasa_w_grupie/models/expense.dart';
import 'package:kasa_w_grupie/models/new_expense.dart';
import 'package:kasa_w_grupie/models/user.dart';
import 'package:kasa_w_grupie/screens/add_expense_screen/expense_split_dialog.dart';
import 'package:kasa_w_grupie/screens/add_expense_screen/manual_expense_screen.dart';
import 'package:kasa_w_grupie/services/expense_service.dart';

class AddExpenseScreen extends StatefulWidget {
  final ExpenseService expenseService;

  const AddExpenseScreen({
    super.key,
    required this.expenseService,
  });

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  bool _expenseAdded = false;

  // Simplified state - removing duplicated state that's managed in child component
  final Map<String, bool> _participatingMembers = {};

  @override
  void initState() {
    super.initState();
    final groupCubit = context.read<GroupCubit>();
    groupCubit.fetch(); // Ensure the group data is loaded
  }

  // Handle navigation after successful form submission
  void _onExpenseAdded() {
    setState(() {
      _expenseAdded = true; // Set the flag to true
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_expenseAdded) {
      // If the expense was added, navigate back to the group screen
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pop();
      });
    }
    return BlocBuilder<GroupCubit, GroupState>(
      builder: (context, state) {
        if (state is GroupLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (state is GroupLoaded) {
          final members = state.members;

          // Initialize participating members if not already done
          if (_participatingMembers.isEmpty) {
            for (var member in members) {
              _participatingMembers[member.id] = true; // Default to true
            }
          }

          return Scaffold(
            appBar: AppBar(
              title: const Text('Add Expense'),
            ),
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Expense Name',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a name for the expense';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    ManualExpenseScreen(
                      formKey: _formKey,
                      expenseService: widget.expenseService,
                      nameController: _nameController,
                      groupState: state,
                      onExpenseAdded: _onExpenseAdded,
                    ),
                  ],
                ),
              ),
            ),
          );
        } else if (state is GroupError) {
          return Scaffold(
            body: Center(child: Text(state.message)),
          );
        } else {
          return const Scaffold(
            body: Center(child: Text('Unexpected error occurred')),
          );
        }
      },
    );
  }
}

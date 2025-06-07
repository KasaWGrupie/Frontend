import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kasa_w_grupie/cubits/group_cubit.dart';
import 'package:kasa_w_grupie/models/expense.dart';
import 'package:kasa_w_grupie/models/new_expense.dart';
import 'package:kasa_w_grupie/models/user.dart';
import 'package:kasa_w_grupie/screens/add_expense_screen/expense_split_dialog.dart';
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
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  String? error;
  String? _selectedPayer;
  SplitType _selectedSplitType = SplitType.equal;
  final Map<String, bool> _participatingMembers =
      {}; // Tracks participation for "Equal" split
  ExpenseSplit? _splitDetails;
  bool _isLoading = false;
  bool _isSubmitted = false;

  @override
  void initState() {
    super.initState();
    final groupCubit = context.read<GroupCubit>();
    groupCubit.fetch(); // Ensure the group data is loaded
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    final groupCubit = context.read<GroupCubit>();
    if (groupCubit.state is! GroupLoaded) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Group data is not loaded')),
      );
      setState(() {
        _isLoading = false;
      });
      return;
    }
    if (_splitDetails == null) {
      return;
    }

    final group = (groupCubit.state as GroupLoaded).group;

    final newExpense = NewExpense(
      groupId: group.id,
      name: _nameController.text,
      amount: double.tryParse(_amountController.text),
      date: DateTime.now(),
      payer: _selectedPayer,
      description: _descriptionController.text,
      split: _splitDetails,
    );

    final result = await widget.expenseService.addExpense(newExpense);

    setState(() {
      _isLoading = false;
    });

    if (result == null) {
      setState(() {
        _isSubmitted = true;
      });
    } else {
      setState(() {
        error = result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isSubmitted) {
      Navigator.of(context).pop();
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
                    TextFormField(
                      controller: _amountController,
                      decoration: const InputDecoration(
                        labelText: 'Amount',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter an amount';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Please enter a valid number';
                        }
                        return null;
                      },
                      onChanged: (value) {
                        setState(() {
                          _splitDetails = null;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _selectedPayer,
                      decoration: const InputDecoration(
                        labelText: 'Payer',
                        border: OutlineInputBorder(),
                      ),
                      items: members.map((User member) {
                        return DropdownMenuItem(
                          value: member.id,
                          child: Row(
                            children: [
                              CircleAvatar(
                                backgroundImage:
                                    NetworkImage(member.pictureUrl),
                                radius: 16,
                              ),
                              const SizedBox(width: 8),
                              Text(member.name),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedPayer = value;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    if (error != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: Text(
                          error!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    const SizedBox(height: 16),
                    TextButton(
                        onPressed: () async {
                          _splitDetails = await showDialog(
                            context: context,
                            builder: (context) {
                              return ExpenseSplitDialog(
                                totalAmount:
                                    double.tryParse(_amountController.text) ??
                                        0.0,
                                groupInfo: state,
                              );
                            },
                          ) as ExpenseSplit?;
                        },
                        child: const Text('Split Expense')),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _submitForm,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator()
                          : const Text('Add Expense'),
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

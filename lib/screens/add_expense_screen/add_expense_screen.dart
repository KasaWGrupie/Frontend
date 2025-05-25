import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kasa_w_grupie/cubits/group_cubit.dart';
import 'package:kasa_w_grupie/models/expense.dart';
import 'package:kasa_w_grupie/models/user.dart';
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

  String? _selectedPayer;
  SplitType _selectedSplitType = SplitType.equal;
  Map<String, double> _splitDetails = {};
  final Map<String, bool> _participatingMembers =
      {}; // Tracks participation for "Equal" split

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final groupCubit = context.read<GroupCubit>();
    groupCubit.fetch(); // Ensure the group data is loaded
  }

  void _initializeSplitDetails(List<User> members) {
    if (_selectedSplitType == SplitType.byAmount) {
      final totalAmount = double.tryParse(_amountController.text) ?? 0.0;
      final defaultAmount = totalAmount / members.length;
      _splitDetails = {
        for (var member in members) member.id: defaultAmount,
      };
    } else if (_selectedSplitType == SplitType.byPercentage) {
      final defaultPercentage = 100.0 / members.length;
      _splitDetails = {
        for (var member in members) member.id: defaultPercentage,
      };
    }
  }

  bool _validateSplitDetails() {
    if (_selectedSplitType == SplitType.equal) {
      // Check if at least one participant is selected
      if (_participatingMembers.values.where((value) => value).isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('At least one participant must be selected.')),
        );
        return false;
      }
    } else if (_selectedSplitType == SplitType.byAmount) {
      // Check if amounts sum up to the total amount
      final totalAmount = double.tryParse(_amountController.text) ?? 0.0;
      final sum = _splitDetails.values.fold(0.0, (a, b) => a + b);
      if (sum != totalAmount) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('The amounts must sum up to $totalAmount.')),
        );
        return false;
      }
    } else if (_selectedSplitType == SplitType.byPercentage) {
      // Check if percentages sum up to 100
      final sum = _splitDetails.values.fold(0.0, (a, b) => a + b);
      if (sum != 100.0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('The percentages must sum up to 100%.')),
        );
        return false;
      }
    }
    return true;
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_validateSplitDetails()) return;

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

    final group = (groupCubit.state as GroupLoaded).group;

    // Build the ExpenseSplit based on the selected split type
    final expenseSplit = _buildExpenseSplit();

    final newExpense = NewExpense(
      groupId: group.id,
      name: _nameController.text,
      amount: double.tryParse(_amountController.text),
      date: DateTime.now(),
      payer: _selectedPayer,
      description: _descriptionController.text,
      split: expenseSplit,
    );

    final result = await widget.expenseService.addExpense(newExpense);

    setState(() {
      _isLoading = false;
    });

    if (result == null) {
      Navigator.pop(context); // Close the form on success
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result)),
      );
    }
  }

  ExpenseSplit _buildExpenseSplit() {
    final participants = _participatingMembers.entries
        .where((entry) => entry.value)
        .map((entry) => entry.key)
        .toList();

    switch (_selectedSplitType) {
      case SplitType.equal:
        return ExpenseSplit.equal(participants: participants);
      case SplitType.byAmount:
        return ExpenseSplit.byAmount(_splitDetails, participants: participants);
      case SplitType.byPercentage:
        return ExpenseSplit.byPercentage(_splitDetails,
            participants: participants);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GroupCubit, GroupState>(
      builder: (context, state) {
        if (state is GroupLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (state is GroupLoaded) {
          final group = state.group;
          final members = state.members;

          // Initialize participating members if not already done
          if (_participatingMembers.isEmpty) {
            for (var member in members) {
              _participatingMembers[member.id] = true; // Default to true
            }
          }

          // Initialize split details when the split type changes
          if (_splitDetails.isEmpty) {
            _initializeSplitDetails(members);
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
                          _splitDetails.clear(); // Recalculate split details
                          _initializeSplitDetails(members);
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
                    DropdownButtonFormField<SplitType>(
                      value: _selectedSplitType,
                      decoration: const InputDecoration(
                        labelText: 'Split Type',
                        border: OutlineInputBorder(),
                      ),
                      items: SplitType.values.map((type) {
                        return DropdownMenuItem(
                          value: type,
                          child: Text(type.toString().split('.').last),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedSplitType = value!;
                          _splitDetails.clear(); // Reset split details
                          _initializeSplitDetails(members);
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    if (_selectedSplitType == SplitType.equal)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Participating Members',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          ...members.map((User member) {
                            return CheckboxListTile(
                              title: Row(
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
                              value: _participatingMembers[member.id],
                              onChanged: (value) {
                                setState(() {
                                  _participatingMembers[member.id] = value!;
                                });
                              },
                            );
                          }).toList(),
                        ],
                      ),
                    if (_selectedSplitType != SplitType.equal)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Split Details',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          ...members.map((User member) {
                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 8.0),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    backgroundImage:
                                        NetworkImage(member.pictureUrl),
                                    radius: 16,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(member.name),
                                  ),
                                  Expanded(
                                    child: TextFormField(
                                      initialValue:
                                          _splitDetails[member.id]?.toString(),
                                      keyboardType: TextInputType.number,
                                      decoration: InputDecoration(
                                        labelText: _selectedSplitType ==
                                                SplitType.byAmount
                                            ? 'Amount'
                                            : 'Percentage',
                                        border: const OutlineInputBorder(),
                                      ),
                                      onChanged: (value) {
                                        setState(() {
                                          _splitDetails[member.id] =
                                              double.tryParse(value) ?? 0.0;
                                        });
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ],
                      ),
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

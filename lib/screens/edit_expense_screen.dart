import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kasa_w_grupie/cubits/edit_expense_cubit.dart';
import 'package:kasa_w_grupie/cubits/group_cubit.dart';
import 'package:kasa_w_grupie/models/expense.dart';
import 'package:kasa_w_grupie/models/user.dart';
import 'package:kasa_w_grupie/services/expense_service.dart';

class EditExpenseScreen extends StatefulWidget {
  final ExpenseService expenseService;
  final Expense expense;

  const EditExpenseScreen({
    super.key,
    required this.expenseService,
    required this.expense,
  });

  @override
  State<EditExpenseScreen> createState() => _EditExpenseScreenState();
}

class _EditExpenseScreenState extends State<EditExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _amountController;
  late final TextEditingController _descriptionController;
  String? _selectedPayer;
  SplitType _selectedSplitType = SplitType.equal;
  Map<String, double> _splitDetails = {};
  final Map<String, bool> _participatingMembers = {};

  @override
  void initState() {
    super.initState();
    final expense = widget.expense;
    _nameController = TextEditingController(text: expense.name);
    _amountController = TextEditingController(text: expense.amount.toString());
    _descriptionController = TextEditingController(text: expense.description);
    _selectedPayer = expense.payer;
    _selectedSplitType = expense.split.type;
    _splitDetails = Map<String, double>.from(expense.split.details ?? {});
    for (var participant in expense.split.participants) {
      _participatingMembers[participant] = true;
    }
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

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => EditExpenseCubit(
        expenseService: widget.expenseService,
        initialExpense: widget.expense,
      ),
      child: BlocBuilder<GroupCubit, GroupState>(
        builder: (context, groupState) {
          if (groupState is GroupLoading) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          } else if (groupState is GroupLoaded) {
            final members = groupState.members;

            return BlocBuilder<EditExpenseCubit, Expense>(
              builder: (context, expense) {
                return Scaffold(
                  appBar: AppBar(
                    title: const Text('Edit Expense'),
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
                            onChanged: (value) => context
                                .read<EditExpenseCubit>()
                                .updateName(value),
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
                                _splitDetails.clear();
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
                            onChanged: (value) => context
                                .read<EditExpenseCubit>()
                                .updateDescription(value),
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

                                // Initialize participating members for all group members
                                if (_participatingMembers.isEmpty) {
                                  for (var member in members) {
                                    _participatingMembers[member.id] = true;
                                  }
                                }

                                if (_selectedSplitType == SplitType.byAmount ||
                                    _selectedSplitType ==
                                        SplitType.byPercentage) {
                                  final defaultValue =
                                      _selectedSplitType == SplitType.byAmount
                                          ? (double.tryParse(
                                                  _amountController.text) ??
                                              0.0) / members.length
                                          : 100.0 / members.length;

                                  _splitDetails.clear();
                                  for (var member in members) {
                                    _splitDetails[member.id] = defaultValue;
                                  }
                                } else {
                                  _splitDetails.clear();
                                }
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
                                    value: _participatingMembers[member.id] ??
                                        false,
                                    onChanged: (value) {
                                      setState(() {
                                        _participatingMembers[member.id] =
                                            value!;
                                      });
                                    },
                                  );
                                }),
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
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 8.0),
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
                                                _splitDetails[member.id]
                                                        ?.toString() ??
                                                    '',
                                            keyboardType: TextInputType.number,
                                            decoration: InputDecoration(
                                              labelText: _selectedSplitType ==
                                                      SplitType.byAmount
                                                  ? 'Amount'
                                                  : 'Percentage',
                                              border:
                                                  const OutlineInputBorder(),
                                            ),
                                            onChanged: (value) {
                                              setState(() {
                                                _splitDetails[member.id] =
                                                    double.tryParse(value) ??
                                                        0.0;
                                              });
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }),
                              ],
                            ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () async {
                              final result = await context
                                  .read<EditExpenseCubit>()
                                  .saveChanges();
                              if (result == null) {
                                Navigator.of(context).pop();
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(result)),
                                );
                              }
                            },
                            child: const Text('Save Changes'),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          } else if (groupState is GroupError) {
            return Scaffold(
              body: Center(child: Text(groupState.message)),
            );
          } else {
            return const Scaffold(
              body: Center(child: Text('Unexpected error occurred')),
            );
          }
        },
      ),
    );
  }
}

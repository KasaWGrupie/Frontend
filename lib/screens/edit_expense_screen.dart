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
  String? _error;
  bool _isLoading = false;

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
                          // Header Card
                          Card(
                            margin: const EdgeInsets.only(bottom: 16),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Edit Expense Details',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  const Text(
                                    'Update the expense details and split method.',
                                    style: TextStyle(
                                        fontSize: 12, color: Colors.grey),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 8),

                          // Name field
                          TextFormField(
                            controller: _nameController,
                            decoration: const InputDecoration(
                              labelText: 'Expense Name',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.label),
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

                          // Amount field
                          TextFormField(
                            controller: _amountController,
                            decoration: const InputDecoration(
                              labelText: 'Amount',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.attach_money),
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

                          // Payer dropdown
                          DropdownButtonFormField<String>(
                            value: _selectedPayer,
                            decoration: const InputDecoration(
                              labelText: 'Payer',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.person),
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

                          // Description field
                          TextFormField(
                            controller: _descriptionController,
                            decoration: const InputDecoration(
                              labelText: 'Description',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.description),
                              hintText: 'Optional notes about this expense',
                            ),
                            maxLines: 2,
                            onChanged: (value) => context
                                .read<EditExpenseCubit>()
                                .updateDescription(value),
                          ),
                          const SizedBox(height: 16),

                          // Split type selection
                          Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Split Method',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  DropdownButtonFormField<SplitType>(
                                    value: _selectedSplitType,
                                    decoration: const InputDecoration(
                                      labelText: 'Split Type',
                                      border: OutlineInputBorder(),
                                      prefixIcon: Icon(Icons.pie_chart),
                                    ),
                                    items: SplitType.values.map((type) {
                                      return DropdownMenuItem(
                                        value: type,
                                        child: Text(
                                            type.toString().split('.').last),
                                      );
                                    }).toList(),
                                    onChanged: (value) {
                                      setState(() {
                                        _selectedSplitType = value!;

                                        // Initialize participating members for all group members
                                        if (_participatingMembers.isEmpty) {
                                          for (var member in members) {
                                            _participatingMembers[member.id] =
                                                true;
                                          }
                                        }

                                        if (_selectedSplitType ==
                                                SplitType.byAmount ||
                                            _selectedSplitType ==
                                                SplitType.byPercentage) {
                                          final defaultValue =
                                              _selectedSplitType ==
                                                      SplitType.byAmount
                                                  ? (double.tryParse(
                                                              _amountController
                                                                  .text) ??
                                                          0.0) /
                                                      members.length
                                                  : 100.0 / members.length;

                                          _splitDetails.clear();
                                          for (var member in members) {
                                            _splitDetails[member.id] =
                                                defaultValue;
                                          }
                                        } else {
                                          _splitDetails.clear();
                                        }
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 8),

                          // Split details based on selected type
                          if (_selectedSplitType == SplitType.equal)
                            Card(
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Participating Members',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    const Text(
                                      'Select who is sharing this expense equally',
                                      style: TextStyle(
                                          fontSize: 12, color: Colors.grey),
                                    ),
                                    const SizedBox(height: 8),
                                    ...members.map((User member) {
                                      return CheckboxListTile(
                                        title: Row(
                                          children: [
                                            CircleAvatar(
                                              backgroundImage: NetworkImage(
                                                  member.pictureUrl),
                                              radius: 16,
                                            ),
                                            const SizedBox(width: 8),
                                            Text(member.name),
                                          ],
                                        ),
                                        value:
                                            _participatingMembers[member.id] ??
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
                              ),
                            ),
                          if (_selectedSplitType != SplitType.equal)
                            Card(
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _selectedSplitType == SplitType.byAmount
                                          ? 'Split by Amount'
                                          : 'Split by Percentage',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      _selectedSplitType == SplitType.byAmount
                                          ? 'Specify how much each person pays'
                                          : 'Specify percentage each person contributes',
                                      style: const TextStyle(
                                          fontSize: 12, color: Colors.grey),
                                    ),
                                    const SizedBox(height: 16),
                                    ...members.map((User member) {
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 8.0),
                                        child: Row(
                                          children: [
                                            CircleAvatar(
                                              backgroundImage: NetworkImage(
                                                  member.pictureUrl),
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
                                                keyboardType:
                                                    TextInputType.number,
                                                decoration: InputDecoration(
                                                  labelText:
                                                      _selectedSplitType ==
                                                              SplitType.byAmount
                                                          ? 'Amount'
                                                          : 'Percentage',
                                                  border:
                                                      const OutlineInputBorder(),
                                                  suffixText:
                                                      _selectedSplitType ==
                                                              SplitType
                                                                  .byPercentage
                                                          ? '%'
                                                          : null,
                                                ),
                                                onChanged: (value) {
                                                  setState(() {
                                                    _splitDetails[member.id] =
                                                        double.tryParse(
                                                                value) ??
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
                              ),
                            ),

                          const SizedBox(height: 16),

                          // Error display
                          if (_error != null)
                            Container(
                              padding: const EdgeInsets.all(8.0),
                              decoration: BoxDecoration(
                                color: Colors.red.shade50,
                                border: Border.all(color: Colors.red.shade200),
                                borderRadius: BorderRadius.circular(4.0),
                              ),
                              child: Text(
                                _error!,
                                style: const TextStyle(color: Colors.red),
                              ),
                            ),

                          const SizedBox(height: 16),

                          // Save button
                          ElevatedButton(
                            onPressed: _isLoading
                                ? null
                                : () async {
                                    setState(() {
                                      _isLoading = true;
                                      _error = null;
                                    });

                                    // Validate form
                                    if (!_formKey.currentState!.validate()) {
                                      setState(() {
                                        _isLoading = false;
                                      });
                                      return;
                                    }

                                    // Update the expense using the cubit
                                    final result = await context
                                        .read<EditExpenseCubit>()
                                        .saveChanges();

                                    // Handle result
                                    if (result == null) {
                                      // Success - Navigate back
                                      Navigator.of(context).pop();
                                    } else {
                                      setState(() {
                                        _error = result;
                                        _isLoading = false;
                                      });
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              backgroundColor: Theme.of(context).primaryColor,
                              foregroundColor: Colors.white,
                            ),
                            child: _isLoading
                                ? const CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white),
                                  )
                                : const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.save),
                                      SizedBox(width: 8),
                                      Text('Save Changes'),
                                    ],
                                  ),
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

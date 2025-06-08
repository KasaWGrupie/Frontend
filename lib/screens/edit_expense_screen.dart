import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kasa_w_grupie/cubits/edit_expense_cubit.dart';
import 'package:kasa_w_grupie/cubits/group_cubit.dart';
import 'package:kasa_w_grupie/models/expense.dart';
import 'package:kasa_w_grupie/models/user.dart';
import 'package:kasa_w_grupie/screens/add_expense_screen/expense_split_dialog.dart';
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
  int? _selectedPayer;
  SplitType _selectedSplitType = SplitType.equal;
  String? _error;
  bool _isLoading = false;
  ExpenseSplit? _currentSplit;

  @override
  void initState() {
    super.initState();
    final expense = widget.expense;
    _nameController = TextEditingController(text: expense.name);
    _amountController = TextEditingController(text: expense.amount.toString());
    _descriptionController = TextEditingController(text: expense.description);
    _selectedPayer = expense.payer;
    _selectedSplitType = expense.split.type;
    _currentSplit = expense.split;
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
                              if (value.isNotEmpty) {
                                final newAmount = double.tryParse(value) ?? 0.0;
                                context
                                    .read<EditExpenseCubit>()
                                    .updateAmount(newAmount);

                                // Reset split details if amount changes
                                setState(() {
                                  _currentSplit = null;
                                });
                              }
                            },
                          ),
                          const SizedBox(height: 16),

                          // Payer dropdown
                          DropdownButtonFormField<int>(
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
                              context
                                  .read<EditExpenseCubit>()
                                  .updatePayer(value!);
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

                          // Split expense button with current split info
                          Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Expense Split Details',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  const Text(
                                    'Configure how this expense is split between group members',
                                    style: TextStyle(
                                        fontSize: 12, color: Colors.grey),
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          'Current split type: ${_currentSplit?.type.toString().split('.').last ?? expense.split.type.toString().split('.').last}',
                                          style: const TextStyle(fontSize: 14),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 16),
                                      backgroundColor: _currentSplit != null
                                          ? Colors.green.shade50
                                          : null,
                                    ),
                                    onPressed: () async {
                                      final totalAmount = double.tryParse(
                                              _amountController.text) ??
                                          0.0;

                                      // Show split dialog
                                      final details = await showDialog(
                                        context: context,
                                        builder: (context) {
                                          return ExpenseSplitDialog(
                                            totalAmount: totalAmount,
                                            groupInfo: groupState,
                                          );
                                        },
                                      ) as ExpenseSplit?; // Update state with new split details
                                      if (details != null) {
                                        setState(() {
                                          _currentSplit = details;
                                          _selectedSplitType = details.type;

                                          // Update expense cubit
                                          context
                                              .read<EditExpenseCubit>()
                                              .updateSplit(details);
                                        });
                                      }
                                    },
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          _currentSplit != null
                                              ? Icons.check_circle
                                              : Icons.group_add,
                                          color: _currentSplit != null
                                              ? Colors.green
                                              : null,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          _currentSplit != null
                                              ? 'Split Configured'
                                              : 'Configure Split',
                                          style: TextStyle(
                                            color: _currentSplit != null
                                                ? Colors.green
                                                : null,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
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

                                    // Ensure split is configured
                                    if (_currentSplit == null &&
                                        expense.split.type !=
                                            _selectedSplitType) {
                                      setState(() {
                                        _error =
                                            "Please configure the expense split details";
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

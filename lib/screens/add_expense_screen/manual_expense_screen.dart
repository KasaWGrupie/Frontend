import 'package:flutter/material.dart';
import 'package:kasa_w_grupie/cubits/group_cubit.dart';
import 'package:kasa_w_grupie/models/expense.dart';
import 'package:kasa_w_grupie/models/new_expense.dart';
import 'package:kasa_w_grupie/models/user.dart';
import 'package:kasa_w_grupie/screens/add_expense_screen/expense_split_dialog.dart';
import 'package:kasa_w_grupie/services/expense_service.dart';

class ManualExpenseScreen extends StatefulWidget {
  const ManualExpenseScreen(
      {super.key,
      required formKey,
      required this.expenseService,
      required nameController,
      required this.groupState,
      required this.onExpenseAdded})
      : _formKey = formKey,
        _nameController = nameController;
  final GlobalKey<FormState> _formKey;
  final TextEditingController _nameController;
  final ExpenseService expenseService;
  final GroupLoaded groupState;
  final VoidCallback onExpenseAdded;

  @override
  State<ManualExpenseScreen> createState() => _ManualExpenseScreenState();
}

class _ManualExpenseScreenState extends State<ManualExpenseScreen> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  String? error;
  String? _selectedPayer;
  final Map<String, bool> _participatingMembers =
      {}; // Tracks participation for "Equal" split
  ExpenseSplit? _splitDetails;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Initialize state here if needed
  }

  Future<void> _submitForm() async {
    if (!widget._formKey.currentState!.validate()) return;

    if (_splitDetails == null) {
      setState(() {
        error = "Please configure expense split details";
      });
      return;
    }

    setState(() {
      _isLoading = true;
      error = null;
    });

    final group = widget.groupState.group;

    final newExpense = NewExpense(
      groupId: group.id,
      name: widget._nameController.text,
      amount: double.tryParse(_amountController.text),
      date: DateTime.now(),
      payer: _selectedPayer,
      description: _descriptionController.text,
      split: _splitDetails,
    );

    final result = await widget.expenseService.addExpense(newExpense);

    if (result == null) {
      // Success - call the callback to navigate
      widget.onExpenseAdded();
    } else {
      setState(() {
        error = result;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final members = widget.groupState.members;

    // Initialize participating members if not already done
    if (_participatingMembers.isEmpty) {
      for (var member in members) {
        _participatingMembers[member.id] = true; // Default to true
      }
    }

    return Column(
      children: [
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
                    backgroundImage: NetworkImage(member.pictureUrl),
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
        if (_amountController.text.isNotEmpty)
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            onPressed: () async {
              final details = await showDialog(
                context: context,
                builder: (context) {
                  return ExpenseSplitDialog(
                    totalAmount: double.tryParse(_amountController.text) ?? 0.0,
                    groupInfo: widget.groupState,
                  );
                },
              ) as ExpenseSplit?;

              setState(() {
                _splitDetails = details;
              });
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Split Expense'),
                if (_splitDetails != null)
                  const Icon(Icons.check, color: Colors.green),
              ],
            ),
          ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: _isLoading ? null : _submitForm,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          child: Center(
            child: _isLoading
                ? const CircularProgressIndicator()
                : const Text('Add Expense'),
          ),
        ),
      ],
    );
  }
}

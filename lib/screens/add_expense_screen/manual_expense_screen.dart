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
    // Initialize with the first group member as default payer
    if (widget.groupState.members.isNotEmpty) {
      _selectedPayer = widget.groupState.members.first.id;
    }
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
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Expense Details',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Enter amount, payer, and other details for this expense.',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 8),

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
              _splitDetails = null;
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
        ),
        const SizedBox(height: 16),

        // Error display
        if (error != null)
          Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              border: Border.all(color: Colors.red.shade200),
              borderRadius: BorderRadius.circular(4.0),
            ),
            child: Text(
              error!,
              style: const TextStyle(color: Colors.red),
            ),
          ),

        const SizedBox(height: 16),

        // Split expense button
        if (_amountController.text.isNotEmpty)
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor:
                  _splitDetails != null ? Colors.green.shade50 : null,
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
                Icon(
                  _splitDetails != null ? Icons.check_circle : Icons.group_add,
                  color: _splitDetails != null ? Colors.green : null,
                ),
                const SizedBox(width: 8),
                Text(
                  _splitDetails != null
                      ? 'Split Configured'
                      : 'Configure Split',
                  style: TextStyle(
                    color: _splitDetails != null ? Colors.green : null,
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: 16),

        // Add expense button
        ElevatedButton(
          onPressed: _isLoading ? null : _submitForm,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            backgroundColor: Theme.of(context).primaryColor,
            foregroundColor: Colors.white,
          ),
          child: _isLoading
              ? const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                )
              : const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.save),
                    SizedBox(width: 8),
                    Text('Add Expense'),
                  ],
                ),
        ),
      ],
    );
  }
}

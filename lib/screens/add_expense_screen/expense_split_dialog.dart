import 'package:flutter/material.dart';
import 'package:kasa_w_grupie/cubits/group_cubit.dart';
import 'package:kasa_w_grupie/models/expense.dart';
import 'package:kasa_w_grupie/models/user.dart';

class ExpenseSplitDialog extends StatefulWidget {
  const ExpenseSplitDialog({
    required this.groupInfo,
    required this.totalAmount,
    super.key,
  });
  final double totalAmount;
  final GroupLoaded groupInfo;

  @override
  State<ExpenseSplitDialog> createState() => _ExpenseSplitDialogState();
}

class _ExpenseSplitDialogState extends State<ExpenseSplitDialog> {
  String? _selectedPayer;
  SplitType _selectedSplitType = SplitType.equal;
  Map<String, double> _splitDetails = {};
  final Map<String, bool> _participatingMembers =
      {}; // Tracks participation for "Equal" split

  String? _errorMessage;

  void _initializeSplitDetails(List<User> members) {
    if (_selectedSplitType == SplitType.byAmount) {
      final totalAmount = widget.totalAmount;
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
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DropdownButtonFormField<SplitType>(
              value: _selectedSplitType,
              decoration: const InputDecoration(
                labelText: 'Split Type',
                border: OutlineInputBorder(),
              ),
              items: SplitType.values.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(type.toString()),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedSplitType = value!;
                  _splitDetails.clear(); // Reset split details
                  _initializeSplitDetails(widget.groupInfo.members);
                  _participatingMembers.clear();
                  for (var member in widget.groupInfo.members) {
                    _participatingMembers[member.id] = true; // Default to true
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
                  ...widget.groupInfo.members.map((User member) {
                    return CheckboxListTile(
                      title: Row(
                        children: [
                          CircleAvatar(
                            backgroundImage: NetworkImage(member.pictureUrl),
                            radius: 16,
                          ),
                          const SizedBox(width: 8),
                          Text(member.name),
                        ],
                      ),
                      value: _participatingMembers[member.id] ?? false,
                      onChanged: (value) {
                        setState(() {
                          if (_participatingMembers[member.id] == null) {
                            _participatingMembers[member.id] = value ?? true;
                          } else {
                            _participatingMembers[member.id] = value!;
                          }
                        });
                      },
                    );
                  }),
                ],
              ),
            if (_selectedSplitType != SplitType.equal)
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text(
                  'Split Details',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ...widget.groupInfo.members.map((User member) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundImage: NetworkImage(member.pictureUrl),
                          radius: 16,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(member.name),
                        ),
                        Expanded(
                          child: TextFormField(
                            initialValue: _splitDetails[member.id]?.toString(),
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText:
                                  _selectedSplitType == SplitType.byAmount
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
                        )
                      ],
                    ),
                  );
                })
              ]),
            // Show error message if present
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                child: Container(
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    border: Border.all(color: Colors.red.shade200),
                    borderRadius: BorderRadius.circular(4.0),
                  ),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _submitForm,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
              ),
              child: const Text("Submit Split Details"),
            ),
          ],
        ),
      ),
    );
  }

  bool _validateSplitDetails() {
    if (_selectedSplitType == SplitType.equal) {
      // Check if at least one participant is selected
      if (_participatingMembers.values.where((value) => value).isEmpty) {
        setState(() {
          _errorMessage = 'At least one participant must be selected.';
        });
        return false;
      }
    } else if (_selectedSplitType == SplitType.byAmount) {
      // Check if amounts sum up to the total amount
      final sum = _splitDetails.values.fold(0.0, (a, b) => a + b);
      if (sum != widget.totalAmount) {
        setState(() {
          _errorMessage = 'The amounts must sum up to ${widget.totalAmount}.';
        });
        return false;
      }
    } else if (_selectedSplitType == SplitType.byPercentage) {
      // Check if percentages sum up to 100
      final sum = _splitDetails.values.fold(0.0, (a, b) => a + b);
      if (sum != 100.0) {
        setState(() {
          _errorMessage = 'The percentages must sum up to 100%.';
        });
        return false;
      }
    }
    setState(() {
      _errorMessage = null; // Clear any previous error
    });
    return true;
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

  void _submitForm() async {
    if (!_validateSplitDetails()) return;

    final expenseSplit = _buildExpenseSplit();

    Navigator.of(context).pop(expenseSplit);
  }
}

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
  SplitType _selectedSplitType = SplitType.equal;
  Map<int, double> _splitDetails = {};
  final Map<int, bool> _participatingMembers =
      {}; // Tracks participation for "Equal" split

  String? _errorMessage;

  @override
  void initState() {
    super.initState();

    // Initialize participating members and split details
    for (var member in widget.groupInfo.members) {
      _participatingMembers[member.id] = true;
    }

    _initializeSplitDetails(widget.groupInfo.members);
  }

  void _initializeSplitDetails(List<User> members) {
    // Initialize with default values appropriate for the selected split type
    if (_splitDetails.isEmpty || _selectedSplitType == SplitType.equal) {
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

    // Ensure all members have an entry in the split details
    if (_selectedSplitType != SplitType.equal) {
      for (var member in members) {
        if (!_splitDetails.containsKey(member.id)) {
          _splitDetails[member.id] =
              _selectedSplitType == SplitType.byAmount ? 0.0 : 0.0;
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 24.0),
        child: SingleChildScrollView(
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
                  // When switching between split types, we need to properly convert values
                  final newSplitType = value!;
                  final oldSplitType = _selectedSplitType;

                  setState(() {
                    _selectedSplitType = newSplitType;
                    _errorMessage = null; // Clear error messages

                    // Convert existing values instead of clearing them if we have values
                    // and we're switching between amount and percentage
                    if (_splitDetails.isNotEmpty &&
                        ((oldSplitType == SplitType.byAmount &&
                                newSplitType == SplitType.byPercentage) ||
                            (oldSplitType == SplitType.byPercentage &&
                                newSplitType == SplitType.byAmount))) {
                      // Store the old split details temporarily
                      final oldSplitDetails =
                          Map<int, double>.from(_splitDetails);
                      final totalAmount = widget.totalAmount;

                      // Convert from amount to percentage
                      if (oldSplitType == SplitType.byAmount &&
                          newSplitType == SplitType.byPercentage) {
                        for (var entry in oldSplitDetails.entries) {
                          // Convert each amount to its percentage of the total
                          _splitDetails[entry.key] =
                              (entry.value / totalAmount) * 100.0;
                        }
                      }
                      // Convert from percentage to amount
                      else if (oldSplitType == SplitType.byPercentage &&
                          newSplitType == SplitType.byAmount) {
                        for (var entry in oldSplitDetails.entries) {
                          // Convert each percentage to its amount
                          _splitDetails[entry.key] =
                              (entry.value / 100.0) * totalAmount;
                        }
                      }
                    } else {
                      // If switching to equal or from equal, or if no split details exist yet,
                      // just initialize with default values
                      _splitDetails.clear();
                      _initializeSplitDetails(widget.groupInfo.members);
                    }

                    // Always reinitialize participating members
                    // when switching to equal split type
                    if (newSplitType == SplitType.equal) {
                      _participatingMembers.clear();
                      for (var member in widget.groupInfo.members) {
                        _participatingMembers[member.id] =
                            true; // Default to true
                      }
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
                  Text(
                    _selectedSplitType == SplitType.byAmount
                        ? 'Specify how much each person pays'
                        : 'Specify percentage each person contributes',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 12),
                  // Display running total
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            _selectedSplitType == SplitType.byAmount
                                ? 'Current total: ${_splitDetails.values.fold(0.0, (a, b) => a + b).toStringAsFixed(2)} / ${widget.totalAmount.toStringAsFixed(2)}'
                                : 'Current total: ${_splitDetails.values.fold(0.0, (a, b) => a + b).toStringAsFixed(1)}% / 100.0%',
                            style: TextStyle(
                              fontSize: 14,
                              color: _validateCurrentTotal()
                                  ? Colors.green
                                  : Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
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
                            // Using a stateful widget key based on split type to force rebuild
                            // when the split type changes
                            child: TextFormField(
                              key: ValueKey(
                                  '${_selectedSplitType}_${member.id}'),
                              initialValue: _splitDetails[member.id]
                                  ?.toStringAsFixed(
                                      _selectedSplitType == SplitType.byAmount
                                          ? 2
                                          : 1),
                              keyboardType: TextInputType.numberWithOptions(
                                  decimal: true),
                              decoration: InputDecoration(
                                labelText:
                                    _selectedSplitType == SplitType.byAmount
                                        ? 'Amount'
                                        : 'Percentage',
                                border: const OutlineInputBorder(),
                                suffixText:
                                    _selectedSplitType == SplitType.byPercentage
                                        ? '%'
                                        : widget.groupInfo.group.currency.name,
                              ),
                              onChanged: (value) {
                                setState(() {
                                  _splitDetails[member.id] =
                                      double.tryParse(value) ?? 0.0;

                                  // Clear error message if values are now correct
                                  if (_validateCurrentTotal()) {
                                    _errorMessage = null;
                                  }
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
      ),
    );
  }

  bool _validateCurrentTotal() {
    if (_selectedSplitType == SplitType.byAmount) {
      final sum = _splitDetails.values.fold(0.0, (a, b) => a + b);
      // Use a small epsilon for floating-point comparison
      return (sum - widget.totalAmount).abs() < 0.01;
    } else if (_selectedSplitType == SplitType.byPercentage) {
      final sum = _splitDetails.values.fold(0.0, (a, b) => a + b);
      // Use a small epsilon for floating-point comparison
      return (sum - 100.0).abs() < 0.01;
    }
    return true;
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
      if ((sum - widget.totalAmount).abs() >= 0.01) {
        setState(() {
          _errorMessage =
              'The amounts must sum up to ${widget.totalAmount.toStringAsFixed(2)}.';
        });
        return false;
      }
    } else if (_selectedSplitType == SplitType.byPercentage) {
      // Check if percentages sum up to 100
      final sum = _splitDetails.values.fold(0.0, (a, b) => a + b);
      if ((sum - 100.0).abs() >= 0.01) {
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

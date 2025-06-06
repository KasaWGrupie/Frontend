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
      child: Column(children: [
        DropdownButtonFormField<String>(
          value: _selectedPayer,
          decoration: const InputDecoration(
            labelText: 'Payer',
            border: OutlineInputBorder(),
          ),
          items: widget.groupInfo.members.map((User member) {
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
                  value: _participatingMembers[member.id],
                  onChanged: (value) {
                    setState(() {
                      _participatingMembers[member.id] = value!;
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
                          labelText: _selectedSplitType == SplitType.byAmount
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
        ElevatedButton(
          onPressed: _submitForm,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          child: _isLoading
              ? const CircularProgressIndicator()
              : const Text('Add Expense'),
        ),
      ]),
    );
  }
}

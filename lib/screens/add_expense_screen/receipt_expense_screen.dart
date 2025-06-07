import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kasa_w_grupie/cubits/group_cubit.dart';
import 'package:kasa_w_grupie/models/expense.dart';
import 'package:kasa_w_grupie/models/new_expense.dart';
import 'package:kasa_w_grupie/models/receipt.dart';
import 'package:kasa_w_grupie/models/user.dart';
import 'package:kasa_w_grupie/screens/add_expense_screen/expense_split_dialog.dart';
import 'package:kasa_w_grupie/services/expense_service.dart';
import 'package:kasa_w_grupie/services/receipt_service.dart';

class ReceiptExpenseScreen extends StatefulWidget {
  const ReceiptExpenseScreen({
    super.key,
    required GlobalKey<FormState> formKey,
    required this.expenseService,
    required TextEditingController nameController,
    required this.groupState,
    required this.onExpenseAdded,
  })  : _formKey = formKey,
        _nameController = nameController;

  final GlobalKey<FormState> _formKey;
  final TextEditingController _nameController;
  final ExpenseService expenseService;
  final GroupLoaded groupState;
  final VoidCallback onExpenseAdded;

  @override
  State<ReceiptExpenseScreen> createState() => _ReceiptExpenseScreenState();
}

class _ReceiptExpenseScreenState extends State<ReceiptExpenseScreen> {
  final ImagePicker _imagePicker = ImagePicker();
  final TextEditingController _descriptionController = TextEditingController();

  String? error;
  String? _selectedPayer;

  // Receipt state
  XFile? _selectedImage;
  bool _processingReceipt = false;
  ReceiptParseResult? _receiptResult; // Keep track of each item's split details
  final Map<int, ExpenseSplit> _itemSplits = {};

  bool _isLoading = false;

  // Receipt service for parsing the receipt image
  final ReceiptService _receiptService = MockReceiptParserService();

  @override
  void initState() {
    super.initState();
    // Set default payer to first group member
    if (widget.groupState.members.isNotEmpty) {
      _selectedPayer = widget.groupState.members.first.id;
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _imagePicker.pickImage(source: source);

      if (image != null) {
        setState(() {
          _selectedImage = image;
          _processingReceipt = true;
          error = null;
        });

        try {
          final result = await _receiptService.parseReceipt(image);

          setState(() {
            _receiptResult = result;
            _processingReceipt = false;

            // Set the expense name if not already set
            if (widget._nameController.text.isEmpty &&
                result.storeName != null) {
              widget._nameController.text = result.storeName!;
            }

            // No need to initialize individual payers since we're using one payer for all items
          });
        } catch (e) {
          setState(() {
            _processingReceipt = false;
            error = "Failed to process receipt: ${e.toString()}";
          });
        }
      }
    } catch (e) {
      setState(() {
        error = "Failed to select image: ${e.toString()}";
      });
    }
  }

  Future<void> _configureItemSplit(int itemIndex) async {
    final item = _receiptResult!.items[itemIndex];

    final details = await showDialog(
      context: context,
      builder: (context) {
        return ExpenseSplitDialog(
          totalAmount: item.amount,
          groupInfo: widget.groupState,
        );
      },
    ) as ExpenseSplit?;

    if (details != null) {
      setState(() {
        _itemSplits[itemIndex] = details;
      });
    }
  }

  Future<void> _submitForm() async {
    if (!widget._formKey.currentState!.validate()) return;

    if (_receiptResult == null) {
      setState(() {
        error = "Please select and process a receipt image";
      });
      return;
    }

    // Check if all items have been split
    final unsplitItems = _receiptResult!.items
        .asMap()
        .entries
        .where((entry) => !_itemSplits.containsKey(entry.key))
        .map((entry) => entry.value.name)
        .toList();

    if (unsplitItems.isNotEmpty) {
      setState(() {
        error = "Please split the following items: ${unsplitItems.join(', ')}";
      });
      return;
    }

    setState(() {
      _isLoading = true;
      error = null;
    });

    final group = widget.groupState.group;

    // Create an expense for each receipt item
    bool allSuccess = true;
    String? firstError;

    for (int i = 0; i < _receiptResult!.items.length; i++) {
      final item = _receiptResult!.items[i];
      final split = _itemSplits[i]!;
      final payerId = _selectedPayer;

      final itemName = item.name;
      final expenseName = widget._nameController.text.isNotEmpty
          ? "${widget._nameController.text} - $itemName"
          : itemName;

      final newExpense = NewExpense(
        groupId: group.id,
        name: expenseName,
        amount: item.amount,
        date: _receiptResult!.date ?? DateTime.now(),
        payer: payerId,
        description: _descriptionController.text,
        split: split,
      );

      final result = await widget.expenseService.addExpense(newExpense);

      if (result != null) {
        allSuccess = false;
        firstError = result;
        break;
      }
    }

    if (allSuccess) {
      widget.onExpenseAdded();
    } else {
      setState(() {
        error = firstError;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final members = widget.groupState.members;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Receipt image selection
        if (_selectedImage == null)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                onPressed: () => _pickImage(ImageSource.camera),
                icon: const Icon(Icons.camera_alt),
                label: const Text('Take Photo'),
              ),
              ElevatedButton.icon(
                onPressed: () => _pickImage(ImageSource.gallery),
                icon: const Icon(Icons.photo_library),
                label: const Text('Choose from Gallery'),
              ),
            ],
          )
        else if (_processingReceipt)
          const Center(
            child: Column(
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Processing receipt...'),
              ],
            ),
          )
        else if (_receiptResult != null)
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Receipt summary
              Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_receiptResult!.storeName != null)
                        Text(
                          _receiptResult!.storeName!,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      if (_receiptResult!.date != null)
                        Text(
                          'Date: ${_receiptResult!.date!.toLocal().toString().split(' ')[0]}',
                          style: const TextStyle(color: Colors.grey),
                        ),
                      const SizedBox(height: 8),
                      Text(
                        'Total: ${_receiptResult!.totalAmount.toStringAsFixed(2)} ${widget.groupState.group.currency.name.toUpperCase()}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Payer dropdown for all receipt items
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

              // Description field
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),

              // Receipt items list
              const Text(
                'Receipt Items',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Each item will be added as a separate expense. Click "Split" to configure how each item is shared.',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 12),

              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _receiptResult!.items.length,
                itemBuilder: (context, index) {
                  final item = _receiptResult!.items[index];
                  final hasSplit = _itemSplits.containsKey(index);

                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.name,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  '${item.amount.toStringAsFixed(2)} ${widget.groupState.group.currency.name.toUpperCase()}',
                                  style: const TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            flex: 1,
                            child: ElevatedButton(
                              onPressed: () => _configureItemSplit(index),
                              style: ElevatedButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8),
                                backgroundColor:
                                    hasSplit ? Colors.green.shade50 : null,
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    hasSplit
                                        ? Icons.check_circle
                                        : Icons.group_add,
                                    color: hasSplit ? Colors.green : null,
                                    size: 20,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    hasSplit ? 'Split Set' : 'Split',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: hasSplit ? Colors.green : null,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 16),

              // Retake photo button
              OutlinedButton.icon(
                onPressed: () {
                  setState(() {
                    _selectedImage = null;
                    _receiptResult = null;
                    _processingReceipt = false;
                    _itemSplits.clear();
                  });
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Select Different Receipt'),
              ),
            ],
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

        // Submit button
        if (_receiptResult != null)
          ElevatedButton(
            onPressed: _isLoading ? null : _submitForm,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: _isLoading
                ? const CircularProgressIndicator()
                : const Text('Submit All Items'),
          ),
      ],
    );
  }
}

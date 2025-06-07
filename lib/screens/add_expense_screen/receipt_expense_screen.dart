import 'package:flutter/material.dart';

class ReceiptExpenseScreen extends StatefulWidget {
  const ReceiptExpenseScreen({super.key});

  @override
  State<ReceiptExpenseScreen> createState() => _ReceiptExpenseScreenState();
}

class _ReceiptExpenseScreenState extends State<ReceiptExpenseScreen> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

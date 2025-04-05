import 'package:flutter/material.dart';

class ReadOnlyCurrencyTile extends StatelessWidget {
  final String currencyLabel;

  const ReadOnlyCurrencyTile({
    super.key,
    required this.currencyLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade400),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Icons.attach_money),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              ' $currencyLabel',
              style: const TextStyle(fontSize: 16),
            ),
          ),
          const Icon(Icons.lock, size: 20, color: Colors.grey),
        ],
      ),
    );
  }
}

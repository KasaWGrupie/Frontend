import 'package:flutter/material.dart';

class ShowTransferDetailsButton extends StatelessWidget {
  const ShowTransferDetailsButton({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Transfer Details'),
            content:
                const Text('This feature will be implemented in the future'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
        );
      },
      child: Row(
        children: [
          const Icon(Icons.info_outline, size: 18, color: Colors.grey),
          const SizedBox(width: 6),
          Text(
            'Show transfer data',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 14,
              decoration: TextDecoration.underline,
            ),
          ),
        ],
      ),
    );
  }
}

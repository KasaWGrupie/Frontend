import 'package:flutter/material.dart';

class ShowTransferDetailsButton extends StatelessWidget {
  const ShowTransferDetailsButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.info_outline, size: 18, color: Colors.grey),
        const SizedBox(width: 6),
        Text(
          'Please verify payment details manually',
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 14,
            decoration: TextDecoration.underline,
          ),
        ),
      ],
    );
  }
}

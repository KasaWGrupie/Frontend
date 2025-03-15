import 'package:flutter/material.dart';

class InvitationCodeField extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onCopyPressed;

  const InvitationCodeField({
    super.key,
    required this.controller,
    required this.onCopyPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            controller: controller,
            decoration: InputDecoration(
              labelText: 'Invitation Code',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12),
            ),
            style: const TextStyle(textBaseline: TextBaseline.alphabetic),
            textAlign: TextAlign.center,
            readOnly: true,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.copy),
          onPressed: onCopyPressed,
        ),
      ],
    );
  }
}

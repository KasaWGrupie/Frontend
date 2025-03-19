import 'package:flutter/material.dart';

class FriendSelectionTile extends StatelessWidget {
  final String name;
  final String email;
  final bool isSelected;
  final VoidCallback onToggle;

  const FriendSelectionTile({
    super.key,
    required this.name,
    required this.email,
    required this.isSelected,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.grey.shade300,
        child: Icon(Icons.person, color: Colors.white),
      ),
      title: Text(name, style: TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(email),
      trailing: Checkbox(
        value: isSelected,
        onChanged: (value) => onToggle(),
      ),
      onTap: onToggle,
    );
  }
}

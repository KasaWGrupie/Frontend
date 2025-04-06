import 'package:flutter/material.dart';

class FriendBalanceCard extends StatelessWidget {
  final String friendName;
  final String friendEmail;

  const FriendBalanceCard({
    super.key,
    required this.friendName,
    required this.friendEmail,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: CircleAvatar(
          radius: 30,
          child: Icon(Icons.person, size: 30, color: Colors.white),
        ),
        title: Text(
          friendName,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        subtitle: Text(
          friendEmail,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.grey,
              ),
        ),
      ),
    );
  }
}

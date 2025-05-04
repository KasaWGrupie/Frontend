import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class GroupTile extends StatelessWidget {
  const GroupTile({
    required this.groupName,
    required this.groupId,
    super.key,
    this.imageUrl,
  });

  final String groupName;
  final String groupId;
  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        //TODO change later to right route
        context.go('/editGroup/0');
      },
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                child: CircleAvatar(
                  radius: 30,
                  backgroundImage:
                      imageUrl != null ? NetworkImage(imageUrl!) : null,
                  child: imageUrl == null ? const Icon(Icons.group) : null,
                ),
              ),
              Expanded(
                child: Text(
                  groupName,
                  style: Theme.of(context).textTheme.labelLarge,
                ),
              ),
              const Padding(
                padding: EdgeInsets.fromLTRB(8, 0, 8, 0),
                child: Icon(Icons.chevron_right),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

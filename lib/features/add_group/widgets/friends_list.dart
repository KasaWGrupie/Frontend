import 'package:flutter/material.dart';
import 'package:kasa_w_grupie/features/add_group/models/friend.dart';
import 'package:kasa_w_grupie/features/add_group/widgets/friend_selection_tile.dart';

class FriendSelector extends StatelessWidget {
  final List<Friend> friends;
  final bool isSelectingFriends;
  final ValueChanged<bool> onExpansionChanged;
  final ValueChanged<Friend> onFriendToggle;

  const FriendSelector({
    super.key,
    required this.friends,
    required this.isSelectingFriends,
    required this.onExpansionChanged,
    required this.onFriendToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade400),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ExpansionTile(
        title: const Text("Select Friends"),
        leading: const Icon(Icons.person_add),
        trailing: Icon(
          isSelectingFriends ? Icons.arrow_drop_up : Icons.arrow_drop_down,
        ),
        onExpansionChanged: onExpansionChanged,
        children: [
          Container(
            constraints: BoxConstraints(
              maxHeight: 200,
            ),
            child: ListView(
              shrinkWrap: true,
              children: friends.map((friend) {
                return FriendSelectionTile(
                  name: friend.name,
                  email: friend.email,
                  isSelected: friend.isSelected,
                  onToggle: () {
                    onFriendToggle(friend);
                  },
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

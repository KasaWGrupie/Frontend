import 'package:flutter/material.dart';
import 'package:kasa_w_grupie/screens/friends_details_screen/widgets/settle_between_groups_modal.dart';

class SettleBetweenGroupsButton extends StatelessWidget {
  final List<Map<String, dynamic>> groupBalances;
  final int friendId;

  const SettleBetweenGroupsButton({
    super.key,
    required this.groupBalances,
    required this.friendId,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: ElevatedButton(
        onPressed: () =>
            showSettleBetweenGroupsModal(context, groupBalances, friendId),
        style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(vertical: 12)),
        child: Text("Settle"),
      ),
    );
  }
}

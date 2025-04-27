import 'package:flutter/material.dart';
import 'package:kasa_w_grupie/screens/base_screen.dart';

class GroupScreen extends StatelessWidget {
  const GroupScreen(this.groupId, {super.key});

  final String groupId;

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      title: "Group",
      child: Center(
        child: Text(
          "Group ID: $groupId",
        ),
      ),
    );
  }
}

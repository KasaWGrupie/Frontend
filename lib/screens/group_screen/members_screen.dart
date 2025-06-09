import 'package:flutter/material.dart';
import 'package:kasa_w_grupie/cubits/group_cubit.dart';
import 'package:kasa_w_grupie/models/user.dart';

class MembersScreen extends StatelessWidget {
  const MembersScreen({super.key, required this.loadedState});

  final GroupLoaded loadedState;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: ListView.builder(
          itemBuilder: (buildContext, index) {
            final members = loadedState.members;
            if (index >= members.length) {
              return null;
            }
            return MemberTile(
              user: members[index],
              balances: loadedState.balances,
              currency: loadedState.group.currency.name.toUpperCase(),
            );
          },
        ),
      ),
    );
  }
}

class MemberTile extends StatelessWidget {
  const MemberTile({
    required this.user,
    required this.balances,
    required this.currency,
    super.key,
  });

  final User user;
  final Map<int, double>? balances;
  final String currency;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          radius: 20,
          backgroundColor: Colors.grey.shade300,
          backgroundImage:
              user.pictureUrl.isNotEmpty ? NetworkImage(user.pictureUrl) : null,
          child: user.pictureUrl.isEmpty
              ? const Icon(
                  Icons.person,
                  size: 20,
                  color: Colors.white,
                )
              : null,
        ),
        title: Text(user.name),
        trailing: Text(
          "${balances?[user.id]?.toStringAsFixed(2) ?? "0.00"} $currency",
        ),
      ),
    );
  }
}

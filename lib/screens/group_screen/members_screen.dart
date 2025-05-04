import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kasa_w_grupie/cubits/group_cubit.dart';
import 'package:kasa_w_grupie/models/user.dart';

class MembersScreen extends StatelessWidget {
  const MembersScreen({super.key, required this.loadedState});

  final GroupLoaded loadedState;

  @override
  Widget build(BuildContext context) {
    final groupCubit = BlocProvider.of<GroupCubit>(context);
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
  final Map<String, double>? balances;
  final String currency;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const CircleAvatar(
          radius: 20,
          // TODO: Replace with user image
          child: FlutterLogo(
            size: 30,
          ),
        ),
        title: Text(user.name),
        trailing: Text(
          "${balances?[user.id]?.toStringAsFixed(2) ?? "0.00"} $currency",
        ),
      ),
    );
  }
}

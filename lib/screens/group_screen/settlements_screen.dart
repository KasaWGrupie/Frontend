import 'package:flutter/material.dart';
import 'package:kasa_w_grupie/cubits/group_cubit.dart';
import 'package:kasa_w_grupie/models/group.dart';
import 'package:kasa_w_grupie/models/user.dart';
import 'package:kasa_w_grupie/services/users_service.dart';
import 'package:provider/provider.dart';

class SettlementsScreen extends StatelessWidget {
  const SettlementsScreen({super.key, required this.loadedState});

  final GroupLoaded loadedState;

  @override
  Widget build(BuildContext context) {
    final settlements = loadedState.settlements;

    return Padding(
      padding: const EdgeInsets.all(10),
      child: settlements.isEmpty
          ? const Center(
              child: Text(
                'Everybody is settled!',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          : ListView.builder(
              itemCount: settlements.length,
              itemBuilder: (buildContext, index) {
                final settlement = settlements[index];
                final from = loadedState.members
                    .firstWhere((u) => u.id == settlement.from);
                final to = loadedState.members
                    .firstWhere((u) => u.id == settlement.to);
                return FutureBuilder(
                    future: Provider.of<UsersService>(context)
                        .getCurrentUser()
                        .then((user) => user!.id),
                    builder: (context, asyncSnapshot) {
                      return SettlementTile(
                        from: from,
                        to: to,
                        amount: settlement.amount,
                        currency: loadedState.group.currency,
                        groupId: loadedState.group.id,
                        userId: asyncSnapshot.data ?? -1,
                      );
                    });
              },
            ),
    );
  }
}

class SettlementTile extends StatelessWidget {
  const SettlementTile({
    super.key,
    required this.from,
    required this.to,
    required this.amount,
    required this.currency,
    required this.groupId,
    required this.userId,
  });

  final User from;
  final User to;
  final double amount;
  final CurrencyEnum currency;
  final int groupId;
  final int userId;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${from.name} owes ${to.name} ${amount.toStringAsFixed(2)} ${currency.name.toUpperCase()}',
            ),
            if (userId == from.id)
              ElevatedButton(
                onPressed: () async {
                  // await RepositoryProvider.of<GroupService>(context)
                  //     .settle(from.id, to.id, amount, groupId);
                  // await BlocProvider.of<GroupCubit>(context).fetch();
                },
                child: const Text('Settle'),
              ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kasa_w_grupie/models/group.dart';
import 'package:kasa_w_grupie/models/money_requests.dart';
import 'package:kasa_w_grupie/models/money_transfer.dart';
import 'package:kasa_w_grupie/models/user.dart';
import 'package:kasa_w_grupie/screens/settlements_screen/widgets/settlement_item.dart';
import 'package:kasa_w_grupie/screens/settlements_screen/widgets/settlements_tile.dart';
import 'package:kasa_w_grupie/services/auth_service.dart';
import 'package:kasa_w_grupie/services/group_service.dart';
import 'package:kasa_w_grupie/services/money_transactions_service.dart';

class SettlementsTab extends StatelessWidget {
  const SettlementsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final moneyTransactionService = context.read<MoneyTransactionService>();
    final groupService = context.read<GroupService>();
    final authService = context.read<AuthService>();

    return FutureBuilder(
      future: Future.wait([
        moneyTransactionService.getRejectedMoneyRequestsForUser(),
        moneyTransactionService.getMoneyTransfersForUser(),
        groupService.getGroupsForUser(),
        authService.currentUser(),
      ]),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }

        // Get data from the snapshot
        final rejectedRequests = snapshot.data![0] as List<MoneyRequest>;
        final moneyTransfers = snapshot.data![1] as List<MoneyTransfer>;
        final groups = snapshot.data![2] as List<Group>;
        final user = snapshot.data![3] as User;

        // Convert to unified model
        final List<SettlementItem> allSettlements = [
          ...rejectedRequests
              .where((req) => req.finalizedAt != null)
              .map((req) => SettlementItem.fromMoneyRequest(req)),
          ...moneyTransfers
              .where((transfer) => transfer.finalizedAt != null)
              .map((transfer) => SettlementItem.fromMoneyTransfer(transfer)),
        ];

        // Sort by date
        allSettlements.sort((a, b) => b.finalizedAt.compareTo(a.finalizedAt));

        if (allSettlements.isEmpty) {
          return const Center(child: Text('No settlements.'));
        }

        // Show rejected money requests and money transfers
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView.separated(
            itemCount: allSettlements.length,
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) {
              final settlement = allSettlements[index];
              return SettlementTile(
                settlement: settlement,
                groups: groups,
                currentUser: user,
              );
            },
          ),
        );
      },
    );
  }
}

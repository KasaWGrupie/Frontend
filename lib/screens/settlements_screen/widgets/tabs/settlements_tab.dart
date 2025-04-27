import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kasa_w_grupie/models/group.dart';
import 'package:kasa_w_grupie/models/money_requests.dart';
import 'package:kasa_w_grupie/models/user.dart';
import 'package:kasa_w_grupie/screens/settlements_screen/widgets/settlements_tile.dart';
import 'package:kasa_w_grupie/services/auth_service.dart';
import 'package:kasa_w_grupie/services/group_service.dart';
import 'package:kasa_w_grupie/services/money_requests_service.dart';

class SettlementsTab extends StatelessWidget {
  const SettlementsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final moneyRequestService = context.read<MoneyRequestService>();
    final groupService = context.read<GroupService>();
    final authService = context.read<AuthService>();

    return FutureBuilder(
      future: Future.wait([
        moneyRequestService.getSettlementsForUser(),
        groupService.getGroupsForUser(),
        authService.currentUser(),
      ]),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }

        final settlements = snapshot.data![0] as List<MoneyRequest>;
        settlements.sort((a, b) => b.finalizedAt!.compareTo(a.finalizedAt!));
        final groups = snapshot.data![1] as List<Group>;
        final user = snapshot.data![2] as User;

        if (settlements.isEmpty) {
          return const Center(child: Text('No settlements.'));
        }

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView.separated(
            itemCount: settlements.length,
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) {
              final settlement = settlements[index];
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

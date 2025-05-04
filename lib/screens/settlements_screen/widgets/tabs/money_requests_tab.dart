import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kasa_w_grupie/screens/settlements_screen/widgets/money_request_tile.dart';
import 'package:kasa_w_grupie/services/money_transactions_service.dart';

class MoneyRequestsTab extends StatelessWidget {
  const MoneyRequestsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final moneyRequestService = context.read<MoneyTransactionService>();

    return FutureBuilder(
      future: moneyRequestService.getMoneyRequestsForUser(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }

        // Get data from the snapshot
        final moneyRequests = snapshot.data ?? [];

        if (moneyRequests.isEmpty) {
          return const Center(child: Text('No money requests.'));
        }

        // Show list of money requests
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView.separated(
            itemCount: moneyRequests.length,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              return MoneyRequestTile(request: moneyRequests[index]);
            },
          ),
        );
      },
    );
  }
}

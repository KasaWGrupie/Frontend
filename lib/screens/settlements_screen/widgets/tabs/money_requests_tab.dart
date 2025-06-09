import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kasa_w_grupie/cubits/settlements_cubit.dart';
import 'package:kasa_w_grupie/screens/settlements_screen/widgets/money_request_tile.dart';

class MoneyRequestsTab extends StatelessWidget {
  const MoneyRequestsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettlementsCubit, SettlementsState>(
      builder: (context, state) {
        if (state is SettlementsLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is SettlementsError) {
          return Center(child: Text(state.message));
        } else if (state is SettlementsLoaded) {
          final moneyRequests = state.moneyRequests;

          if (moneyRequests.isEmpty) {
            return const Center(child: Text('No money requests.'));
          }

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
        }

        // Default case if no state matches
        return const SizedBox();
      },
    );
  }
}

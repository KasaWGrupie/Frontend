import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kasa_w_grupie/cubits/settlements_cubit.dart';
import 'package:kasa_w_grupie/screens/settlements_screen/widgets/settlements_tile.dart';

class SettlementsTab extends StatelessWidget {
  const SettlementsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettlementsCubit, SettlementsState>(
      builder: (context, state) {
        if (state is SettlementsLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is SettlementsError) {
          return Center(child: Text(state.message));
        } else if (state is SettlementsLoaded) {
          final settlements = state.settlements;
          final groups = state.groups;
          final user = state.user;

          if (settlements.isEmpty) {
            return const Center(child: Text('No settlements.'));
          }

          // Show rejected money requests and money transfers
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
        }

        // Default case if no state matches
        return const SizedBox();
      },
    );
  }
}

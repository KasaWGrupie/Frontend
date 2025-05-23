import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kasa_w_grupie/screens/base_screen.dart';
import 'package:kasa_w_grupie/screens/settlements_screen/widgets/tabs/money_requests_tab.dart';
import 'package:kasa_w_grupie/screens/settlements_screen/widgets/tabs/settlements_tab.dart';
import 'package:kasa_w_grupie/services/auth_service.dart';
import 'package:kasa_w_grupie/services/group_service.dart';
import 'package:kasa_w_grupie/services/money_transactions_service.dart';
import 'package:kasa_w_grupie/cubits/settlements_cubit.dart';

class SettlementsScreen extends StatelessWidget {
  const SettlementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SettlementsCubit(
        moneyTransactionService: context.read<MoneyTransactionService>(),
        groupService: context.read<GroupService>(),
        authService: context.read<AuthService>(),
      )..loadData(),
      child: DefaultTabController(
        length: 2,
        child: BaseScreen(
          title: 'Your Settlements',
          appBarBottom: const TabBar(
            tabs: [
              Tab(text: 'Settlements History'),
              Tab(text: 'Money Requests'),
            ],
          ),
          child: const TabBarView(
            children: [
              SettlementsTab(),
              MoneyRequestsTab(),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:kasa_w_grupie/screens/base_screen.dart';
import 'package:kasa_w_grupie/screens/settlements_screen/widgets/tabs/money_requests_tab.dart';
import 'package:kasa_w_grupie/screens/settlements_screen/widgets/tabs/settlements_tab.dart';

class SettlementsScreen extends StatelessWidget {
  const SettlementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
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
    );
  }
}

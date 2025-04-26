import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kasa_w_grupie/models/group.dart';
import 'package:kasa_w_grupie/models/money_requests.dart';
import 'package:kasa_w_grupie/models/user.dart';
import 'package:kasa_w_grupie/services/auth_service.dart';
import 'package:kasa_w_grupie/services/group_service.dart';
import 'package:kasa_w_grupie/services/money_requests_service.dart';
import 'package:kasa_w_grupie/services/users_service.dart';

class SettlementsTab extends StatelessWidget {
  const SettlementsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final moneyRequestService = context.read<MoneyRequestService>();
    final groupService = context.read<GroupService>();
    final authService = context.read<AuthService>();
    final userService = context.read<UsersService>();

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
              final group = groups.firstWhere(
                (g) => g.id == settlement.groups.first,
                // TODO delete after backend integration
                orElse: () => Group(
                  id: 'unknown',
                  name: 'Unknown Group',
                  currency: CurrencyEnum.eur,
                  status: GroupStatus.active,
                  adminId: '',
                  membersId: [],
                  invitationCode: '',
                ),
              );

              final isSender = settlement.senderId == user.id;
              final amount = settlement.moneyValue;

              return FutureBuilder<List<User?>>(
                future: Future.wait([
                  userService.getUser(settlement.senderId),
                  userService.getUser(settlement.recipientId),
                ]),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final senderUser = snapshot.data![0];
                  final recipientUser = snapshot.data![1];

                  if (senderUser == null || recipientUser == null) {
                    return const Text("Error loading user data");
                  }

                  final text = isSender
                      ? 'You sent money to ${recipientUser.name}'
                      : '${senderUser.name} sent you money';

                  return Row(
                    children: [
                      const CircleAvatar(
                        radius: 24,
                        child: Icon(Icons.person),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              group.name,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              text,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        (isSender ? '-' : '+') +
                            getFormattedAmount(group.currency, amount),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isSender ? Colors.red : Colors.green,
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        );
      },
    );
  }

  // Function to display group currency
  String getFormattedAmount(CurrencyEnum currency, double amount) {
    switch (currency) {
      case CurrencyEnum.pln:
        return 'PLN ${amount.toStringAsFixed(2)}';
      case CurrencyEnum.usd:
        return '\$${amount.toStringAsFixed(2)}';
      case CurrencyEnum.eur:
        return '€${amount.toStringAsFixed(2)}';
      default:
        return '\$${amount.toStringAsFixed(2)}';
    }
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kasa_w_grupie/models/group.dart';
import 'package:kasa_w_grupie/models/user.dart';
import 'package:kasa_w_grupie/screens/friends_details_screen/utils/currency_formater.dart';
import 'package:kasa_w_grupie/screens/settlements_screen/widgets/settlement_item.dart';
import 'package:kasa_w_grupie/services/users_service.dart';

class SettlementTile extends StatelessWidget {
  final SettlementItem settlement;
  final List<Group> groups;
  final User currentUser;

  const SettlementTile({
    super.key,
    required this.settlement,
    required this.groups,
    required this.currentUser,
  });

  @override
  Widget build(BuildContext context) {
    final userService = context.read<UsersService>();

    // Fetch all groups that are connected to the money transfers/request
    final matchedGroups = settlement.groupIds.map((groupId) {
      return groups.firstWhere(
        (g) => g.id == groupId,
        // TODO delete after backend integration
        orElse: () => Group(
          id: 0,
          name: 'Unknown Group',
          currency: CurrencyEnum.eur,
          status: GroupStatus.active,
          adminId: -1,
          membersId: [],
          invitationCode: '',
        ),
      );
    }).toList();

    // Concatenate group names for the money transfer/request
    final groupNames = matchedGroups.map((g) => g.name).join(', ');

    // TODO change after backend integration
    final group = groups.firstWhere(
      (g) => g.id == settlement.groupIds.first,
      orElse: () => Group(
        id: 0,
        name: 'Unknown Group',
        currency: CurrencyEnum.eur,
        status: GroupStatus.active,
        adminId: -1,
        membersId: [],
        invitationCode: '',
      ),
    );

    final groupCurrency = group.currency;

    final isSender = settlement.senderId == currentUser.id;
    final amount = settlement.amount;

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

        // Prepare corresponding information about money transfer/request
        String text;
        if (settlement.isRejected && isSender) {
          text = '${recipientUser.name} rejected your money request';
        } else if (settlement.isTransfer) {
          text = isSender
              ? 'You sent money to ${recipientUser.name}'
              : '${senderUser.name} sent you money';
        } else {
          text = isSender
              ? 'You sent money to ${recipientUser.name}'
              : '${senderUser.name} sent you money';
        }

        return Row(
          children: [
            // User avatar
            const CircleAvatar(
              radius: 24,
              child: Icon(Icons.person),
            ),
            const SizedBox(width: 16),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Show date of transfer/request and name of group it was connected to
                  Text(
                    "${formatDate(settlement.finalizedAt)} \t$groupNames",
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 4),

                  // Show corresponding information about money transfer/request
                  Text(
                    text,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),

            // Format the money amount based on who owes whom
            Text(
              settlement.isRejected
                  ? formatCurrency(amount, groupCurrency)
                  : (isSender ? '-' : '+') +
                      formatCurrency(amount, groupCurrency),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: settlement.isRejected
                    ? Colors.grey
                    : (isSender ? Colors.red : Colors.green),
              ),
            ),
          ],
        );
      },
    );
  }

  // Helper function for formating date
  String formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

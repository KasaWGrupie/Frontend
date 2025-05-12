import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kasa_w_grupie/models/money_requests.dart';
import 'package:kasa_w_grupie/screens/friends_details_screen/utils/currency_formater.dart';
import 'package:kasa_w_grupie/screens/settlements_screen/widgets/money_request_buttons.dart';
import 'package:kasa_w_grupie/screens/settlements_screen/widgets/transfer_details_button.dart';
import 'package:kasa_w_grupie/services/users_service.dart';

class MoneyRequestTile extends StatelessWidget {
  final MoneyRequest request;

  const MoneyRequestTile({super.key, required this.request});

  @override
  Widget build(BuildContext context) {
    final userService = context.read<UsersService>();

    return FutureBuilder(
      future: userService.getUser(request.senderId),
      builder: (context, userSnapshot) {
        if (!userSnapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final senderUser = userSnapshot.data;

        if (senderUser == null) {
          return const Text("Error loading user data");
        }

        return Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text.rich(
                  TextSpan(
                    text: 'User ',
                    style: const TextStyle(fontSize: 16),
                    children: [
                      TextSpan(
                        text: senderUser.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const TextSpan(
                        text: ' sent you a request for ',
                        style: TextStyle(fontSize: 16),
                      ),
                      TextSpan(
                        text: formatCurrency(
                            request.moneyValue, request.currency),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                ShowTransferDetailsButton(),
                const SizedBox(height: 16),
                MoneyRequestsButton(
                  request: request,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kasa_w_grupie/cubits/settlements_cubit.dart';
import 'package:kasa_w_grupie/models/money_requests.dart';

class MoneyRequestsButton extends StatelessWidget {
  final MoneyRequest request;
  const MoneyRequestsButton({
    super.key,
    required this.request,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 10),
              backgroundColor: Colors.green.shade600,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () => showConfirmationDialog(
              context,
              "Mark as Paid",
              () {
                context.read<SettlementsCubit>().markRequestAsPaid(request);
              },
            ),
            child: const Text(
              'Mark as Paid',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 10),
              side: BorderSide(color: Colors.grey.shade400),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () => showConfirmationDialog(
              context,
              "Reject Request",
              () {
                context.read<SettlementsCubit>().rejectRequest(request);
              },
            ),
            child: const Text(
              'Reject',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void showConfirmationDialog(
      BuildContext context, String title, VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: const Text('Are you sure?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              onConfirm();
            },
            child: const Text('Yes'),
          ),
        ],
      ),
    );
  }
}

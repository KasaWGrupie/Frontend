import 'package:flutter/material.dart';

class SettleUpView extends StatelessWidget {
  const SettleUpView({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_circle_outline,
              size: 48, color: Colors.green.shade400),
          SizedBox(height: 12),
          Text("You are settled up",
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600)),
        ],
      ),
    );
  }
}

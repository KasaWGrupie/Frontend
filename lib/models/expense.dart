import 'package:firebase_auth/firebase_auth.dart';

class Expense {
  Expense({
    required this.id,
    required this.pictureUrl,
    required this.date,
    required this.amount,
    required this.payer,
    required this.split,
  });

  int id;
  String pictureUrl;
  DateTime date;
  double amount;
  String payer;
  ExpenseSplit split;
}

class ExpenseSplit {}

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:kasa_w_grupie/config/api_config.dart';
import 'package:kasa_w_grupie/models/expense.dart';
import 'package:kasa_w_grupie/models/new_expense.dart';
import 'package:kasa_w_grupie/services/auth_service.dart';

abstract class ExpenseService {
  Future<String?> addExpense(NewExpense expense);
  Future<String?> updateExpense(Expense expense);
  Future<Expense?> getExpenseById(String expenseId);
}

class ExpenseServiceApi implements ExpenseService {
  final AuthService authService;

  ExpenseServiceApi({required this.authService});

  Future<Map<String, String>> _getAuthHeaders() async {
    final idToken = await authService.userIdToken();
    return {
      'Authorization': 'Bearer $idToken',
      'Accept': '*/*',
      // 'Content-Type': 'application/json',
    };
  }

  @override
  Future<String?> addExpense(NewExpense expense) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/expense');
    final headers = await _getAuthHeaders();
    final request = http.MultipartRequest('POST', url)..headers.addAll(headers);

    try {
      final requestBody = jsonEncode(expense.toJson());
      request.fields['dto'] = requestBody;

      if (expense.picture != null) {
        request.files.add(http.MultipartFile.fromBytes(
          'expensePicture',
          expense.picture!.readAsBytesSync(),
          filename: 'expense_picture.jpg',
          contentType: MediaType('image', 'jpeg'),
        ));
      }
      final response = await http.Response.fromStream(await request.send());

      if (response.statusCode == 200 || response.statusCode == 201) {
        return null; // Success, no error message
      } else {
        return 'Failed to add expense: ${response.statusCode}';
      }
    } catch (e) {
      return 'Error adding expense: $e';
    }
  }

  @override
  Future<String?> updateExpense(Expense expense) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/expense');
    final headers = await _getAuthHeaders();

    try {
      // Convert expense to Map<String, dynamic>
      final Map<String, dynamic> expenseData = {
        'expenseId': expense.id,
        'paidBy': expense.payer,
        'expenseName': expense.name,
        'expensePictureUri': expense.pictureUrl,
        'description': expense.description ?? '',
        'amount': expense.amount,
        'date': expense.date.toUtc().toIso8601String(),
        'participants':
            _buildParticipantsFromSplit(expense.split, expense.amount),
        'divisionMethod': expense.split.type.toString().split('.').last,
      };

      final response = await http.put(
        url,
        headers: headers,
        body: jsonEncode(expenseData),
      );

      if (response.statusCode == 200) {
        return null;
      } else {
        return 'Failed to update expense: ${response.statusCode} ${response.body}';
      }
    } catch (e) {
      return 'Error updating expense: $e';
    }
  }

  @override
  Future<Expense?> getExpenseById(String expenseId) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/expense');
    final headers = await _getAuthHeaders();

    try {
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final expenseJson = jsonDecode(response.body);
        return Expense.fromJson(expenseJson);
      } else if (response.statusCode == 404) {
        return null;
      } else {
        throw Exception('Failed to fetch expense: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching expense: $e');
    }
  }

  // Helper method to build participants array from split details
  List<Map<String, dynamic>> _buildParticipantsFromSplit(
      ExpenseSplit split, double totalAmount) {
    List<Map<String, dynamic>> participants = [];

    if (split.type == SplitType.equal) {
      double equalShare = totalAmount / split.participants.length;

      for (var userId in split.participants) {
        participants.add({
          'userId': userId,
          'amount': equalShare,
        });
      }
    } else {
      // For byAmount and byPercentage
      final details = split.details;
      if (details != null) {
        for (var entry in details.entries) {
          double actualAmount;

          if (split.type == SplitType.byAmount) {
            actualAmount = entry.value;
          } else {
            // Convert percentage to actual amount
            actualAmount = (entry.value / 100.0) * totalAmount;
          }

          participants.add({
            'userId': entry.key,
            'amount': actualAmount,
          });
        }
      }
    }

    return participants;
  }
}

// Mock implementation remains unchanged
class MockExpenseService implements ExpenseService {
  @override
  Future<String?> addExpense(NewExpense expense) async {
    // Simulate a network call
    await Future.delayed(Duration(seconds: 1));
    return null;
  }

  @override
  Future<String?> updateExpense(Expense expense) async {
    // Simulate a network call
    await Future.delayed(Duration(seconds: 1));
    return null;
  }

  @override
  Future<Expense?> getExpenseById(String expenseId) async {
    // Simulate fetching an expense by ID
    return Expense(
      id: int.parse(expenseId),
      name: "Sample Expense",
      pictureUrl: "https://example.com/sample.jpg",
      date: DateTime.now(),
      amount: 100.0,
      payer: 6,
      split: ExpenseSplit.equal(participants: [6]),
      description: "Sample description",
    );
  }
}

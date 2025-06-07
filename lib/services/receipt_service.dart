import 'dart:math';

import 'package:image_picker/image_picker.dart';
import 'package:kasa_w_grupie/models/receipt.dart';

abstract class ReceiptService {
  /// Parses a receipt image and extracts items with their amounts
  ///
  /// [imageFile] - The image file from image picker
  /// Returns [ReceiptParseResult] containing parsed items and total amount
  /// Throws [ReceiptParseException] if parsing fails
  Future<ReceiptParseResult> parseReceipt(XFile imageFile);
}

class MockReceiptParserService implements ReceiptService {
  final Duration _processingDelay;

  const MockReceiptParserService({
    bool shouldSimulateError = false,
    Duration processingDelay = const Duration(seconds: 2),
  }) : _processingDelay = processingDelay;

  @override
  Future<ReceiptParseResult> parseReceipt(XFile imageFile) async {
    // Simulate processing time
    await Future.delayed(_processingDelay);

    // Mock parsed data - simulating different types of receipts
    return _generateMockReceipt();
  }

  ReceiptParseResult _generateMockReceipt() {
    final random = Random();
    final mockReceipts = [
      _createGroceryReceipt(),
      _createRestaurantReceipt(),
      _createRetailReceipt(),
    ];

    return mockReceipts[random.nextInt(mockReceipts.length)];
  }

  ReceiptParseResult _createGroceryReceipt() {
    final items = [
      const ReceiptItem(name: 'Organic Bananas', amount: 3.99),
      const ReceiptItem(name: 'Whole Milk', amount: 4.25),
      const ReceiptItem(name: 'Bread - Whole Wheat', amount: 2.89),
      const ReceiptItem(name: 'Eggs - Dozen', amount: 5.99),
      const ReceiptItem(name: 'Chicken Breast', amount: 12.45),
      const ReceiptItem(name: 'Broccoli', amount: 2.75),
    ];

    final total = items.fold(0.0, (sum, item) => sum + item.amount);

    return ReceiptParseResult(
      items: items,
      totalAmount: total,
      // storeName: 'Fresh Market Grocery',
      // date: DateTime.now().subtract(Duration(hours: Random().nextInt(48))),
    );
  }

  ReceiptParseResult _createRestaurantReceipt() {
    final items = [
      const ReceiptItem(name: 'Caesar Salad', amount: 12.95),
      const ReceiptItem(name: 'Grilled Salmon', amount: 24.50),
      const ReceiptItem(name: 'Pasta Carbonara', amount: 18.75),
      const ReceiptItem(name: 'Garlic Bread', amount: 6.50),
      const ReceiptItem(name: 'House Wine', amount: 8.00),
      const ReceiptItem(name: 'Tax', amount: 5.67),
      const ReceiptItem(name: 'Tip', amount: 15.27),
    ];

    final total = items.fold(0.0, (sum, item) => sum + item.amount);

    return ReceiptParseResult(
      items: items,
      totalAmount: total,
      storeName: 'Bella Vista Restaurant',
      date: DateTime.now().subtract(Duration(hours: Random().nextInt(24))),
    );
  }

  ReceiptParseResult _createRetailReceipt() {
    final items = [
      const ReceiptItem(name: 'Cotton T-Shirt', amount: 19.99),
      const ReceiptItem(name: 'Jeans - Blue', amount: 45.00),
      const ReceiptItem(name: 'Sneakers', amount: 79.95),
      const ReceiptItem(name: 'Sales Tax', amount: 11.60),
    ];

    final total = items.fold(0.0, (sum, item) => sum + item.amount);

    return ReceiptParseResult(
      items: items,
      totalAmount: total,
      storeName: 'Fashion Central',
      date: DateTime.now().subtract(Duration(hours: Random().nextInt(72))),
    );
  }
}

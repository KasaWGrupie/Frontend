class ReceiptItem {
  final String name;
  final double amount;

  const ReceiptItem({
    required this.name,
    required this.amount,
  });

  @override
  String toString() =>
      'ReceiptItem(name: $name, amount: \$${amount.toStringAsFixed(2)})';

  Map<String, dynamic> toJson() => {
        'name': name,
        'price': amount,
      };

  factory ReceiptItem.fromJson(Map<String, dynamic> json) => ReceiptItem(
        name: json['name'] as String,
        amount: (json['price'] as num).toDouble(),
      );
}

class ReceiptParseResult {
  final List<ReceiptItem> items;
  final double totalAmount;
  final String? storeName;
  final DateTime? date;

  const ReceiptParseResult({
    required this.items,
    required this.totalAmount,
    this.storeName,
    this.date,
  });

  @override
  String toString() {
    return 'ReceiptParseResult(\n'
        '  storeName: $storeName,\n'
        '  date: $date,\n'
        '  items: $items,\n'
        '  totalAmount: \$${totalAmount.toStringAsFixed(2)}\n'
        ')';
  }

  Map<String, dynamic> toJson() => {
        'products': items.map((item) => item.toJson()).toList(),
      };

  factory ReceiptParseResult.fromJson(Map<String, dynamic> json) =>
      ReceiptParseResult(
        items: (json['products'] as List)
            .map((item) => ReceiptItem.fromJson(item as Map<String, dynamic>))
            .toList(),
        totalAmount: _calculateTotal(json['products'] as List),
        storeName: null,
        date: null,
      );

  static double _calculateTotal(List products) {
    return products.fold(
        0.0, (sum, product) => sum + (product['price'] as num).toDouble());
  }
}

class Stock {
  final String id;
  final String variantName;
  final int purchasePrice;
  final int quantity;
  final String productId;
  final DateTime createdAt;
  final DateTime updatedAt;

  Stock({
    required this.id,
    required this.variantName,
    required this.purchasePrice,
    required this.quantity,
    required this.productId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Stock.fromJson(Map<String, dynamic> json) {
    return Stock(
      id: json['_id'] ?? '',
      variantName: json['variantName'] ?? '',
      purchasePrice: json['purchasePrice'] ?? 0,
      quantity: json['quantity'] ?? 0,
      productId: json['productId'] ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'variantName': variantName,
      'purchasePrice': purchasePrice,
      'quantity': quantity,
      'productId': productId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

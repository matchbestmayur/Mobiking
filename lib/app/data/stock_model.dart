class StockModel {
  final String id;
  final String variantName;
  final int purchasePrice;
  final int quantity;
  final String productId;

  StockModel({
    required this.id,
    required this.variantName,
    required this.purchasePrice,
    required this.quantity,
    required this.productId,
  });

  factory StockModel.fromJson(Map<String, dynamic> json) {
    return StockModel(
      id: json['_id'] ?? '',
      variantName: json['variantName'] ?? '',
      purchasePrice: json['purchasePrice'] ?? 0,
      quantity: json['quantity'] ?? 0,
      productId: json['productId'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    '_id': id,
    'variantName': variantName,
    'purchasePrice': purchasePrice,
    'quantity': quantity,
    'productId': productId,
  };
}

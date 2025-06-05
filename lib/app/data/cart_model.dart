class CartModel {
  final String productId;
  final int quantity;
  final double price;

  CartModel({
    required this.productId,
    this.quantity = 1,
    required this.price,
  });

  factory CartModel.fromJson(Map<String, dynamic> json) {
    return CartModel(
      productId: json['productId'],
      quantity: json['quantity'] ?? 1,
      price: (json['price'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'quantity': quantity,
      'price': price,
    };
  }
}

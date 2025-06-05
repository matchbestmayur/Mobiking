import 'cart_model.dart';

class OrderModel {
  final String? id;
  final String status;
  final String type;
  final bool abondonedOrder;
  final String orderId;
  final double orderAmount;
  final String address;
  final double deliveryCharge;
  final double discount;
  final double gst;
  final double subtotal;
  final String method;
  final String userId;
  final List<CartModel> items;

  OrderModel({
    this.id,
    required this.status,
    required this.type,
    required this.abondonedOrder,
    required this.orderId,
    required this.orderAmount,
    required this.address,
    required this.deliveryCharge,
    required this.discount,
    required this.gst,
    required this.subtotal,
    required this.method,
    required this.userId,
    required this.items,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['_id'],
      status: json['status'],
      type: json['type'],
      abondonedOrder: json['abondonedOrder'] ?? true,
      orderId: json['orderId'],
      orderAmount: (json['orderAmount'] ?? 0).toDouble(),
      address: json['address'],
      deliveryCharge: (json['deliveryCharge'] ?? 0).toDouble(),
      discount: (json['discount'] ?? 0).toDouble(),
      gst: (json['gst'] ?? 0).toDouble(),
      subtotal: (json['subtotal'] ?? 0).toDouble(),
      method: json['method'],
      userId: json['userId'],
      items: (json['items'] as List)
          .map((e) => CartModel.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'type': type,
      'abondonedOrder': abondonedOrder,
      'orderId': orderId,
      'orderAmount': orderAmount,
      'address': address,
      'deliveryCharge': deliveryCharge,
      'discount': discount,
      'gst': gst,
      'subtotal': subtotal,
      'method': method,
      'userId': userId,
      'items': items.map((e) => e.toJson()).toList(),
    };
  }
}

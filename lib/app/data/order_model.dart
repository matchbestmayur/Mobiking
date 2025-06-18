import 'package:mobiking/app/data/product_model.dart';

// Assuming SellingPrice and ProductModel are defined in product_model.dart
// class SellingPrice { ... }
// class ProductModel { ... }

class OrderItemProductModel {
  final String id;
  final String name;
  final String fullName;
  final String slug;
  final String description;
  final bool active;
  final bool newArrival;
  final bool liked;
  final bool bestSeller;
  final bool recommended;
  final List<SellingPrice> sellingPrice;
  final String categoryId; // This will store the _id of the category
  final List<String> images;
  final int totalStock;
  final List<String> stockIds;
  final List<String> orderIds;
  final List<String> groupIds;
  final Map<String, int> variants;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int? v; // "__v" field

  OrderItemProductModel({
    required this.id,
    required this.name,
    required this.fullName,
    required this.slug,
    required this.description,
    required this.active,
    required this.newArrival,
    required this.liked,
    required this.bestSeller,
    required this.recommended,
    required this.sellingPrice,
    required this.categoryId,
    required this.images,
    required this.totalStock,
    required this.stockIds,
    required this.orderIds,
    required this.groupIds,
    required this.variants,
    this.createdAt,
    this.updatedAt,
    this.v,
  });

  factory OrderItemProductModel.fromJson(Map<String, dynamic> json) {
    return OrderItemProductModel(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      fullName: json['fullName'] ?? '',
      slug: json['slug'] ?? '',
      description: json['description'] ?? '',
      active: json['active'] ?? false,
      newArrival: json['newArrival'] ?? false,
      liked: json['liked'] ?? false,
      bestSeller: json['bestSeller'] ?? false,
      recommended: json['recommended'] ?? false,
      sellingPrice: (json['sellingPrice'] as List<dynamic>?)
          ?.map((e) => SellingPrice.fromJson(e as Map<String, dynamic>))
          .toList() ??
          [],
      // Handle category which can be an object or just an ID string
      categoryId: (json['category'] is Map && json['category'] != null)
          ? json['category']['_id'] as String? ?? ''
          : (json['category'] is String ? json['category'] as String : ''),
      images: (json['images'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
          [],
      totalStock: json['totalStock'] ?? 0,
      stockIds: (json['stock'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList() ??
          [],
      orderIds: (json['orders'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList() ??
          [],
      groupIds: (json['groups'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList() ??
          [],
      variants: Map<String, int>.from(json['variants'] ?? {}),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
      v: json['__v'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'fullName': fullName,
      'slug': slug,
      'description': description,
      'active': active,
      'newArrival': newArrival,
      'liked': liked,
      'bestSeller': bestSeller,
      'recommended': recommended,
      'sellingPrice': sellingPrice.map((e) => e.toJson()).toList(),
      'category': categoryId, // Sending back just the ID
      'images': images,
      'totalStock': totalStock,
      'stock': stockIds,
      'orders': orderIds,
      'groups': groupIds,
      'variants': variants,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      '__v': v,
    };
  }
}

class OrderItemModel {
  final OrderItemProductModel productId; // This now uses the new model
  final String variantName;
  final int quantity;
  final double price; // Changed to double as prices often have decimals

  OrderItemModel({
    required this.productId,
    required this.variantName,
    required this.quantity,
    required this.price,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      productId: OrderItemProductModel.fromJson(json['productId'] as Map<String, dynamic>),
      variantName: json['variantName'] ?? '',
      quantity: json['quantity'] ?? 0,
      price: (json['price'] as num?)?.toDouble() ?? 0.0, // Safely parse to double
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId.toJson(),
      'variantName': variantName,
      'quantity': quantity,
      'price': price,
    };
  }
}


// You might need a simple User model for userId if you want to parse it fully
class OrderUserModel {
  final String id;
  final String email;
  final String phoneNo;
  // ... other fields if needed from userId object

  OrderUserModel({
    required this.id,
    required this.email,
    required this.phoneNo,
    // ...
  });

  factory OrderUserModel.fromJson(Map<String, dynamic> json) {
    return OrderUserModel(
      id: json['_id'] ?? '',
      email: json['email'] ?? '',
      phoneNo: json['phoneNo'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'email': email,
      'phoneNo': phoneNo,
    };
  }
}


class OrderModel {
  final String id;
  final String status;
  final String type;
  final bool isAppOrder;
  final bool abandonedOrder;
  final String orderId;
  final double orderAmount;
  final String name;
  final String email;
  final String phoneNo;
  final double deliveryCharge;
  final double discount;
  final double gst;
  final double subtotal;
  final String method;
  final OrderUserModel? userId;
  final List<OrderItemModel> items; // This is the crucial line for the List<OrderItemModel>
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int? v;

  OrderModel({
    required this.id,
    required this.status,
    required this.type,
    required this.isAppOrder,
    required this.abandonedOrder,
    required this.orderId,
    required this.orderAmount,
    required this.name,
    required this.email,
    required this.phoneNo,
    required this.deliveryCharge,
    required this.discount,
    required this.gst,
    required this.subtotal,
    required this.method,
    this.userId,
    required this.items, // Ensure it's required here
    this.createdAt,
    this.updatedAt,
    this.v,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    // Helper function to parse numeric values which might come as String or num
    double _parseNum(dynamic value) {
      if (value == null) return 0.0;
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0; // Fallback for unexpected types
    }

    return OrderModel(
      id: json['_id'] ?? '',
      status: json['status'] ?? '',
      type: json['type'] ?? '',
      isAppOrder: json['isAppOrder'] ?? false,
      abandonedOrder: json['abondonedOrder'] ?? false, // Keep original JSON key for parsing
      orderId: json['orderId'] ?? '',
      orderAmount: _parseNum(json['orderAmount']),
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phoneNo: json['phoneNo'] ?? '',
      deliveryCharge: _parseNum(json['deliveryCharge']),
      discount: _parseNum(json['discount']),
      gst: _parseNum(json['gst']), // Apply the helper here
      subtotal: _parseNum(json['subtotal']),
      method: json['method'] ?? '',
      userId: json['userId'] != null && json['userId'] is Map
          ? OrderUserModel.fromJson(json['userId'] as Map<String, dynamic>)
          : null,
      // This is the correct line for parsing the list of OrderItemModel
      items: (json['items'] as List<dynamic>?)
          ?.map((e) => OrderItemModel.fromJson(e as Map<String, dynamic>))
          .toList() ??
          [],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
      v: json['__v'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'status': status,
      'type': type,
      'isAppOrder': isAppOrder,
      'abondonedOrder': abandonedOrder,
      'orderId': orderId,
      'orderAmount': orderAmount,
      'name': name,
      'email': email,
      'phoneNo': phoneNo,
      'deliveryCharge': deliveryCharge,
      'discount': discount,
      'gst': gst,
      'subtotal': subtotal,
      'method': method,
      'userId': userId?.toJson(),
      'items': items.map((e) => e.toJson()).toList(),
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      '__v': v,
    };
  }
}
// And finally, a wrapper for the entire API response
class OrdersResponse {
  final int statusCode;
  final List<OrderModel> data;
  final String message;
  final bool success;

  OrdersResponse({
    required this.statusCode,
    required this.data,
    required this.message,
    required this.success,
  });

  factory OrdersResponse.fromJson(Map<String, dynamic> json) {
    return OrdersResponse(
      statusCode: json['statusCode'] ?? 0,
      data: (json['data'] as List<dynamic>?)
          ?.map((e) => OrderModel.fromJson(e as Map<String, dynamic>))
          .toList() ??
          [],
      message: json['message'] ?? '',
      success: json['success'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'statusCode': statusCode,
      'data': data.map((e) => e.toJson()).toList(),
      'message': message,
      'success': success,
    };
  }
}
// Path: lib/app/data/create_order_request_model.dart

import 'package:mobiking/app/data/product_model.dart'; // To reference ProductModel's ID if needed

// --- Request-specific Nested Models ---

// This represents the user reference *sent with the order*.
// Typically, you only send the user's ID, but if your backend expects email/phone for verification
// or to identify the user for the order, then include them.
class CreateUserReferenceRequestModel {
  final String id; // The user's _id
  final String email;
  final String phoneNo;

  CreateUserReferenceRequestModel({
    required this.id,
    required this.email,
    required this.phoneNo,
  });

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'email': email,
      'phoneNo': phoneNo,
    };
  }
}

// This represents an item in the order *request*.
// It should only contain information the backend needs to identify the product and quantity.
class CreateOrderItemRequestModel {
  final String productId; // Only the product's _id
  final String variantName;
  final int quantity;
  final double price; // Price at the time of order (critical for backend)

  CreateOrderItemRequestModel({
    required this.productId,
    required this.variantName,
    required this.quantity,
    required this.price,
  });

  Map<String, dynamic> toJson() {
    return {
      'productId': productId, // Sending just the product ID string
      'variantName': variantName,
      'quantity': quantity,
      'price': price,
    };
  }
}

// --- Main CreateOrderRequestModel ---
// This is the model for the payload you send when placing a new order.
class CreateOrderRequestModel {
  // These fields are provided by the client
  final CreateUserReferenceRequestModel userId; // Reference to the user placing the order
  final String cartId; // Reference to the cart
  final String name; // Recipient name (can be self or other)
  final String email; // Recipient email
  final String phoneNo; // Recipient phone
  final double orderAmount;
  final double discount;
  final double deliveryCharge;
  final double gst;
  final double subtotal;
  final String address; // Full shipping address string
  final String method; // Payment method (e.g., 'COD')
  final List<CreateOrderItemRequestModel> items; // List of order items for the request
  final String? addressId; // <--- NEW FIELD: The ID of the selected address
  final bool isAppOrder; // <--- NEW FIELD: Added for app identification

  CreateOrderRequestModel({
    required this.userId,
    required this.cartId,
    required this.name,
    required this.email,
    required this.phoneNo,
    required this.orderAmount,
    required this.discount,
    required this.deliveryCharge,
    required this.gst,
    required this.subtotal,
    required this.address,
    required this.method,
    required this.items,
    this.addressId, // <--- ADDED TO CONSTRUCTOR
    this.isAppOrder = true, // <--- ADDED TO CONSTRUCTOR with default true
  });

  Map<String, dynamic> toJson() {
    return {
      'userId': userId.toJson(),
      'cartId': cartId,
      'name': name,
      'email': email,
      'phoneNo': phoneNo,
      'orderAmount': orderAmount,
      'discount': discount,
      'deliveryCharge': deliveryCharge,
      'gst': gst,
      'subtotal': subtotal,
      'address': address,
      'method': method,
      'items': items.map((item) => item.toJson()).toList(),
      if (addressId != null) 'addressId': addressId,
      'isAppOrder': isAppOrder, // <--- ADDED TO JSON METHOD
    };
  }
}
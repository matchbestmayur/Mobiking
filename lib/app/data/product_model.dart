class SellingPrice {
  final int price;

  SellingPrice({required this.price});

  factory SellingPrice.fromJson(Map<String, dynamic> json) {
    return SellingPrice(price: json['price'] ?? 0);
  }

  Map<String, dynamic> toJson() => {'price': price};
}

class ProductModel {
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
  final String categoryId;
  final List<String> stockIds;
  final List<String> orderIds;
  final List<String> groupIds;
  final int totalStock;
  final Map<String, int> variants;
  final List<String> images;

  ProductModel({
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
    required this.stockIds,
    required this.orderIds,
    required this.groupIds,
    required this.totalStock,
    required this.variants,
        required this.images,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
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
      sellingPrice: (json['sellingPrice'] as List<dynamic>)
          .map((e) => SellingPrice.fromJson(e))
          .toList(),
      categoryId: json['category'] ?? '',
      images: List<String>.from(json['images'] ?? []),
      stockIds: List<String>.from((json['stock'] ?? []).map((e) => e.toString())),
      orderIds: List<String>.from((json['orders'] ?? []).map((e) => e.toString())),
      groupIds: List<String>.from((json['groups'] ?? []).map((e) => e.toString())),
      totalStock: json['totalStock'] ?? 0,
      variants: Map<String, int>.from(json['variants']?.map((key, value) => MapEntry(key, value as int)) ?? {}),
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
      'categoryId': categoryId,
            'images': images,
      'stockIds': stockIds,
      'orderIds': orderIds,
      'groupIds': groupIds,
      'totalStock': totalStock,
      'variants': variants,
    };
  }
}

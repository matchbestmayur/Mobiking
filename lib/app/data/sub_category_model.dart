import 'package:mobiking/app/data/product_model.dart';

import 'ParentCategory.dart'; // Assuming this file contains ParentCategory model

class SubCategory {
  final String id;
  final String name;
  final String slug;
  final int sequenceNo;
  final String? upperBanner;
  final String? lowerBanner;
  final bool active;
  final bool featured;
  final List<String> photos; // Changed to non-nullable list, always initialized
  final ParentCategory? parentCategory;
  final List<ProductModel> products; // Changed to non-nullable list, always initialized
  final DateTime createdAt;
  final DateTime updatedAt;
  final int v;
  final int? deliveryCharge;
  final int? minFreeDeliveryOrderAmount;
  final int? minOrderAmount;

  SubCategory({
    required this.id,
    required this.name,
    required this.slug,
    required this.sequenceNo,
    this.upperBanner,
    this.lowerBanner,
    required this.active,
    required this.featured,
    required this.photos, // No longer nullable in constructor, default to empty list in fromJson
    this.parentCategory,
    required this.products, // No longer nullable in constructor, default to empty list in fromJson
    required this.createdAt,
    required this.updatedAt,
    required this.v,
    this.deliveryCharge,
    this.minFreeDeliveryOrderAmount,
    this.minOrderAmount,
  });

  factory SubCategory.fromJson(Map<String, dynamic> json) {
    return SubCategory(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      slug: json['slug'] ?? '',
      sequenceNo: json['sequenceNo'] ?? 0,
      upperBanner: json['upperBanner'] as String?, // Explicitly cast to String?
      lowerBanner: json['lowerBanner'] as String?, // Explicitly cast to String?
      active: json['active'] ?? false,
      featured: json['featured'] ?? false,
      // Ensure photos is always a List<String>, defaulting to empty if null or not a list
      photos: (json['photos'] as List?)?.map((e) => e.toString()).toList() ?? <String>[],
      parentCategory: json['parentCategory'] != null
          ? ParentCategory.fromJson(json['parentCategory'] as Map<String, dynamic>)
          : null,
      // Ensure products is always a List<ProductModel>, defaulting to empty if null or not a list
      products: (json['products'] as List?)
          ?.map((e) => ProductModel.fromJson(e as Map<String, dynamic>))
          .toList() ?? <ProductModel>[],
      // Safely parse DateTime, providing a fallback (e.g., current time or a default epoch time)
      // if createdAt or updatedAt are null or invalid strings.
      createdAt: json['createdAt'] != null && json['createdAt'] is String
          ? DateTime.tryParse(json['createdAt']) ?? DateTime(2000) // Fallback to a default DateTime
          : DateTime(2000), // Fallback if not string or null
      updatedAt: json['updatedAt'] != null && json['updatedAt'] is String
          ? DateTime.tryParse(json['updatedAt']) ?? DateTime(2000) // Fallback to a default DateTime
          : DateTime(2000), // Fallback if not string or null
      v: json['__v'] ?? 0,
      deliveryCharge: json['deliveryCharge'] as int?, // Explicitly cast to int?
      minFreeDeliveryOrderAmount: json['minFreeDeliveryOrderAmount'] as int?, // Explicitly cast to int?
      minOrderAmount: json['minOrderAmount'] as int?, // Explicitly cast to int?
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'slug': slug,
      'sequenceNo': sequenceNo,
      'upperBanner': upperBanner,
      'lowerBanner': lowerBanner,
      'active': active,
      'featured': featured,
      'photos': photos,
      'parentCategory': parentCategory?.toJson(), // Use null-aware access for parentCategory
      'products': products.map((p) => p.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      '__v': v,
      'deliveryCharge': deliveryCharge,
      'minFreeDeliveryOrderAmount': minFreeDeliveryOrderAmount,
      'minOrderAmount': minOrderAmount,
    };
  }
}

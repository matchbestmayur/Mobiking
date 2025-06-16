import 'package:mobiking/app/data/product_model.dart';

import 'ParentCategory.dart';

class SubCategory {
  final String id;
  final String name;
  final String slug;
  final int sequenceNo;
  final String? upperBanner;
  final String? lowerBanner;
  final bool active;
  final bool featured;
  final List<String> photos;
  final ParentCategory? parentCategory;
  final List<ProductModel> products;
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
    required this.photos,
    this.parentCategory,
    required this.products,
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
      upperBanner: json['upperBanner'],
      lowerBanner: json['lowerBanner'],
      active: json['active'] ?? false,
      featured: json['featured'] ?? false,
      photos: json['photos'] != null
          ? List<String>.from(json['photos'])
          : <String>[],
      parentCategory: json['parentCategory'] != null
          ? ParentCategory.fromJson(json['parentCategory'])
          : null,
      products: json['products'] != null
          ? List<ProductModel>.from(
          json['products'].map((x) => ProductModel.fromJson(x)))
          : <ProductModel>[],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      v: json['__v'] ?? 0,
      deliveryCharge: json['deliveryCharge'],
      minFreeDeliveryOrderAmount: json['minFreeDeliveryOrderAmount'],
      minOrderAmount: json['minOrderAmount'],
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
      'parentCategory': parentCategory?.toJson(),
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
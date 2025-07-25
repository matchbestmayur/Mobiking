import 'package:mobiking/app/data/product_model.dart';

class GroupModel {
  final String id;
  final String name;
  final int sequenceNo;
  final String banner;
  final bool active;
  final bool isBannerVisible;
  final bool isSpecial;
  final List<ProductModel> products;
  final DateTime createdAt;
  final DateTime updatedAt;

  GroupModel({
    required this.id,
    required this.name,
    required this.sequenceNo,
    required this.banner,
    required this.active,
    required this.isBannerVisible,
    required this.isSpecial,
    required this.products,
    required this.createdAt,
    required this.updatedAt,
  });

  factory GroupModel.fromJson(Map<String, dynamic> json) => GroupModel(
    id: json['_id'] ?? '',
    name: json['name'] ?? '',
    sequenceNo: json['sequenceNo'] ?? 0,
    banner: json['banner'] ?? '',
    active: json['active'] ?? true,
    isBannerVisible: json['isBannerVisble'] ?? false, 
    isSpecial: json['isSpecial'] ?? false,
    products: (json['products'] as List<dynamic>? ?? [])
        .map((e) => ProductModel.fromJson(e as Map<String, dynamic>))
        .toList(),
    createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
    updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
  );


  Map<String, dynamic> toJson() => {
    '_id': id,
    'name': name,
    'sequenceNo': sequenceNo,
    'banner': banner,
    'active': active,
    'isBannerVisible': isBannerVisible,
    'isSpecial': isSpecial,
    'products': products.map((p) => p.toJson()).toList(),
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };
}

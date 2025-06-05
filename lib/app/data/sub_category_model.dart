class SubCategoryModel {
  final String id;
  final String name;
  final String slug;
  final int sequenceNo;
  final String upperBanner;
  final String lowerBanner;
  final bool active;
  final bool featured;
  final List<String> photos;
  final String parentCategory;
  final List<String> products;

  SubCategoryModel({
    required this.id,
    required this.name,
    required this.slug,
    required this.sequenceNo,
    required this.upperBanner,
    required this.lowerBanner,
    required this.active,
    required this.featured,
    required this.photos,
    required this.parentCategory,
    required this.products,
  });

  factory SubCategoryModel.fromJson(Map<String, dynamic> json) {
    return SubCategoryModel(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      slug: json['slug'] ?? '',
      sequenceNo: json['sequenceNo'] ?? 0,
      upperBanner: json['upperBanner'] ?? '',
      lowerBanner: json['lowerBanner'] ?? '',
      active: json['active'] ?? false,
      featured: json['featured'] ?? false,
      photos: (json['photos'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList() ?? [],
      parentCategory: json['parentCategory'] ?? '',
      products: (json['products'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() => {
    '_id': id,
    'name': name,
    'slug': slug,
    'sequenceNo': sequenceNo,
    'upperBanner': upperBanner,
    'lowerBanner': lowerBanner,
    'active': active,
    'featured': featured,
    'photos': photos,
    'parentCategory': parentCategory,
    'products': products,
  };
}

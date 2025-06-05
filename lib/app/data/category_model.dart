class CategoryModel {
  final String id;
  final String name;
  final String slug;
  final bool active;
  final List<String> subCategoryIds;

  CategoryModel({
    required this.id,
    required this.name,
    required this.slug,
    required this.active,
    required this.subCategoryIds,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    List<String> subCategoryIds = [];
    if (json['subCategories'] != null) {
      subCategoryIds = List<String>.from((json['subCategories'] as List).map((e) => e is String ? e : e['_id'] ?? ''));
      subCategoryIds.removeWhere((id) => id.isEmpty);
    }

    return CategoryModel(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      slug: json['slug'] ?? '',
      active: json['active'] ?? false,
      subCategoryIds: subCategoryIds,
    );
  }

  Map<String, dynamic> toJson() => {
    '_id': id,
    'name': name,
    'slug': slug,
    'active': active,
    'subCategories': subCategoryIds,
  };
}

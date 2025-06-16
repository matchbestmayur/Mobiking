class ParentCategory {
  final String id;
  final String name;
  final String image;
  final String slug;
  final bool active;
  final List<String> subCategories;

  ParentCategory({
    required this.id,
    required this.name,
    required this.image,
    required this.slug,
    required this.active,
    required this.subCategories,
  });

  factory ParentCategory.fromJson(Map<String, dynamic> json) {
    return ParentCategory(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      image: json['image'] ?? '',
      slug: json['slug'] ?? '',
      active: json['active'] ?? false,
      subCategories: json['subCategories'] != null
          ? List<String>.from(json['subCategories'])
          : <String>[],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'image': image,
      'slug': slug,
      'active': active,
      'subCategories': subCategories,
    };
  }
}

class GroupModel {
  final String id;
  final String name;
  final int sequenceNo;
  final String banner;
  final bool active;
  final bool isBannerVisible;
  final bool isSpecial;
  final List<String> productIds;
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
    required this.productIds,
    required this.createdAt,
    required this.updatedAt,
  });

  factory GroupModel.fromJson(Map<String, dynamic> json) {
    // Extract product IDs safely:
    List<String> ids = [];
    if (json['products'] != null) {
      ids = List<String>.from(
        (json['products'] as List).map((e) => e is String ? e : e['_id'] ?? ''),
      );
      ids.removeWhere((id) => id.isEmpty); // remove any empty ids
    }

    return GroupModel(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      sequenceNo: json['sequenceNo'] ?? 0,
      banner: json['banner'] ?? '',
      active: json['active'] ?? true,
      isBannerVisible: json['isBannerVisible'] ?? false,
      isSpecial: json['isSpecial'] ?? false,
      productIds: ids,
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'sequenceNo': sequenceNo,
      'banner': banner,
      'active': active,
      'isBannerVisible': isBannerVisible,
      'isSpecial': isSpecial,
      'products': productIds,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

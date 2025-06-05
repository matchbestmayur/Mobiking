// home_layout_model.dart
import 'group_model.dart';

class HomeLayoutModel {
  final String id;
  final bool active;
  final List<String> banners;
  final List<GroupModel> groups;

  HomeLayoutModel({
    required this.id,
    required this.active,
    required this.banners,
    required this.groups,
  });

  factory HomeLayoutModel.fromJson(Map<String, dynamic> json) {
    return HomeLayoutModel(
      id: json['_id'],
      active: json['active'],
      banners: List<String>.from(json['banners'] ?? []),
      groups: (json['groups'] as List).map((e) => GroupModel.fromJson(e)).toList(),
    );
  }
}

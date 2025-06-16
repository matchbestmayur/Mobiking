
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
    final groupsJson = json['groups'];
    List<GroupModel> groupsList = [];

    if (groupsJson != null && groupsJson is List) {
      groupsList = groupsJson
          .where((e) => e is Map<String, dynamic>)
          .map((e) => GroupModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } else {
      print("Warning: groups is null or not a List: $groupsJson");
    }

    final bannersJson = json['banners'];
    List<String> bannersList = [];
    if (bannersJson != null && bannersJson is List) {
      bannersList = List<String>.from(bannersJson);
    } else {
      print("Warning: banners is null or not a List: $bannersJson");
    }

    return HomeLayoutModel(
      id: json['_id'] ?? '',
      active: json['active'] ?? false,
      banners: bannersList,
      groups: groupsList,
    );
  }

}

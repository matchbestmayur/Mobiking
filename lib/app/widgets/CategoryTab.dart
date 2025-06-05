import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobiking/app/controllers/Home_controller.dart';
import 'package:mobiking/app/modules/home/home_screen.dart';

import '../controllers/category_controller.dart';
import '../data/product_model.dart';
import '../dummy/products_data.dart';
import '../modules/home/widgets/_buildSectionView.dart';

class TabControllerGetX extends GetxController {
  var selectedIndex = 0.obs;

  void updateIndex(int index) {
    selectedIndex.value = index;
  }
}

class CustomTabBarSection extends StatelessWidget {
  final CategoryController categoryController = Get.put(CategoryController());
  final TabControllerGetX tabController = Get.put(TabControllerGetX());

  // Use only 3 icons here for your tabs
  final List<IconData> tabIcons = [
    Icons.local_fire_department,
    Icons.headphones,
    Icons.watch,
  ];

  CustomTabBarSection({super.key});

  Widget _buildTabItem(IconData icon, String label, int index) {
    return Obx(() {
      final isSelected = tabController.selectedIndex.value == index;
      return GestureDetector(
        onTap: () => tabController.updateIndex(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white.withOpacity(0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 24,
                color: isSelected ? Colors.greenAccent : Colors.white,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                textAlign: TextAlign.center,
                style: GoogleFonts.fredoka(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: isSelected ? Colors.greenAccent : Colors.grey[400],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final categories = categoryController.categories;

      // Wait until categories are loaded & check length for 3 tabs
      if (categories.isEmpty || categories.length < tabIcons.length) {
        return const Center(child: CircularProgressIndicator());
      }

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(tabIcons.length, (index) {
              final label = categories[index].name;
              final icon = tabIcons[index];
              return _buildTabItem(icon, label, index);
            }),
          ),
        ),
      );
    });
  }
}
class CustomTabBarViewSection extends StatelessWidget {
  final TabControllerGetX controller = Get.find<TabControllerGetX>();
  final CategoryController categoryController = Get.find<CategoryController>();
  final HomeController homeController = Get.find<HomeController>();

  CustomTabBarViewSection({super.key});

  @override
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final categories = categoryController.categories;
      final selectedIndex = controller.selectedIndex.value;

      if (categories.isEmpty || selectedIndex >= categories.length) {
        return const Center(child: CircularProgressIndicator());
      }

      final selectedCategory = categories[selectedIndex];

      final homeData = homeController.homeData.value;
      if (homeData == null || homeData.groups.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }

      print("Categories: $categories");
      print("Selected Index: $selectedIndex");
      print("Selected Category ID: ${selectedCategory.id}");
      print("HomeData: ${homeData != null}");
      print("Groups: ${homeData?.groups.map((e) => e.id)}");


      return buildSectionView(
        products: dummyProducts,
        groups: homeData.groups,
        bannerImageUrl: homeData.banners.isNotEmpty ? homeData.banners.first : '',
      )
      ;
    });
  }
}







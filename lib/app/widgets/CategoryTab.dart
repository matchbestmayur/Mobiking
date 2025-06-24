import 'dart:convert';
import 'dart:async'; // Needed for Timer if you used it in TabControllerGetX (though it's not directly used now)

import 'package:flutter/material.dart';
import 'package:get/get.dart';
// If GoogleFonts is truly not used anywhere else, you can remove this import.
// For now, keeping it as it was in your original file.
import 'package:google_fonts/google_fonts.dart';

import 'package:mobiking/app/controllers/sub_category_controller.dart';
import 'package:mobiking/app/modules/home/home_screen.dart'; // Make sure this path is correct

import '../controllers/Home_controller.dart'; // Ensure correct path
import '../controllers/category_controller.dart'; // Ensure correct path
import '../controllers/tab_controller_getx.dart';
import '../data/Home_model.dart';
import '../data/product_model.dart'; // Assuming these models exist
import '../dummy/products_data.dart'; // Assuming this data exists
import '../modules/home/widgets/_buildSectionView.dart'; // Assuming this widget exists
import '../themes/app_theme.dart';


// CustomTabBarSection: Manages tab display and custom indicator animation.
class CustomTabBarSection extends StatefulWidget {
  const CustomTabBarSection({super.key});

  @override
  State<CustomTabBarSection> createState() => _CustomTabBarSectionState();
}

// _CustomTabBarSectionState: Manages the state for CustomTabBarSection,
// including GlobalKeys for measuring tab item positions for the custom indicator.
class _CustomTabBarSectionState extends State<CustomTabBarSection> with SingleTickerProviderStateMixin {
  // Use HomeController to access category data
  final HomeController homeController = Get.find<HomeController>(); // Get.find assuming HomeController is properly put
  final TabControllerGetX tabControllerGetX = Get.find<TabControllerGetX>(); // Get.find assuming TabControllerGetX is properly put

  // Predefined icons for the tabs.
  // Note: If you have more categories than icons, you'll need a fallback or dynamic icon selection.
  final List<IconData> tabIcons = const [
    /* Icons.local_fire_department, // For "Best Deals" or first category*/
    Icons.phone_android_rounded, // For "Bluetooth Headphones" or second category
    Icons.electric_bolt_sharp,   // For "Bluetooth Speaker4" or third category
    // Add more icons if you expect more categories
  ];

  // List to hold GlobalKeys for each tab's GestureDetector to enable measuring their positions.
  final List<GlobalKey> _tabItemGlobalKeys = [];

  // GlobalKey for the parent Container of the tabs to calculate indicator position relative to it.
  final GlobalKey _tabBarContainerGlobalKey = GlobalKey();

  double _indicatorX = 0.0;
  double _indicatorWidth = 0.0;

  @override
  void initState() {
    super.initState();

    // Initialize GlobalKeys for each tab item's GestureDetector, up to the number of icons.
    // This assumes you want to display tabs only for which you have icons.
    for (int i = 0; i < tabIcons.length; i++) {
      _tabItemGlobalKeys.add(GlobalKey());
    }

    // Listen to changes in selectedIndex from TabControllerGetX to update indicator position.
    ever(tabControllerGetX.selectedIndex, (_) {
      // Defer the update to ensure the layout is fully rendered after index change
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _updateIndicatorPosition();
      });
    });

    // Listen to changes in homeData from HomeController to update indicator after categories load.
    ever(homeController.homeData, (_) {
      // Defer the update to ensure categories and their layouts are fully rendered
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _updateIndicatorPosition();
      });
    });

    // Schedule a callback for after the first frame is rendered to calculate initial indicator position.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateIndicatorPosition();
    });
  }

  @override
  void dispose() {
    // No need to dispose controllers obtained via Get.find() as GetX manages their lifecycle.
    super.dispose();
  }

  // Calculates and updates the custom indicator's position and width.
  void _updateIndicatorPosition() {
    // Ensure the widget is mounted and necessary keys have contexts.
    if (!mounted || _tabItemGlobalKeys.isEmpty || _tabBarContainerGlobalKey.currentContext == null) {
      // If not ready, schedule another callback for the next frame.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _updateIndicatorPosition();
      });
      return;
    }

    final int selectedIndex = tabControllerGetX.selectedIndex.value;
    // Ensure selectedIndex is within valid bounds of the currently available tab items.
    if (selectedIndex < 0 || selectedIndex >= _tabItemGlobalKeys.length) {
      // If out of bounds (e.g., initial state before categories load), reset indicator or wait.
      setState(() {
        _indicatorX = 0.0;
        _indicatorWidth = 0.0;
      });
      return;
    }

    // Get the RenderBox for the currently selected tab item using its GlobalKey.
    final RenderBox? selectedTabRenderBox = _tabItemGlobalKeys[selectedIndex].currentContext?.findRenderObject() as RenderBox?;
    // Get the RenderBox for the parent container of all tabs using its GlobalKey.
    final RenderBox? parentRenderBox = _tabBarContainerGlobalKey.currentContext?.findRenderObject() as RenderBox?;

    if (selectedTabRenderBox == null || parentRenderBox == null) {
      // If render boxes are not yet available, defer the update.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _updateIndicatorPosition();
      });
      return;
    }

    final double selectedTabWidth = selectedTabRenderBox.size.width;
    // Calculate the selected tab's X position relative to the parent container's left edge.
    final double selectedTabLocalX = selectedTabRenderBox.localToGlobal(Offset.zero).dx - parentRenderBox.localToGlobal(Offset.zero).dx;

    const double indicatorLineDesiredWidth = 30.0; // Fixed width for the indicator line.
    // Calculate the new X position for the indicator to center it under the selected tab.
    final double newIndicatorX = selectedTabLocalX + (selectedTabWidth / 2) - (indicatorLineDesiredWidth / 2);

    // Update the state to animate the indicator.
    setState(() {
      _indicatorX = newIndicatorX;
      _indicatorWidth = indicatorLineDesiredWidth;
    });
  }

  // Builds an individual tab item widget.
  Widget _buildTabItem(IconData icon, String label, int index, TextTheme textTheme) {
    return GestureDetector(
      // Use ValueKey for efficient widget reconciliation when the list of tabs changes.
      key: ValueKey('tabItem_$label'),
      // Assign the GlobalKey to the inner Container for measuring its render box properties.
      // This GlobalKey is NOT for reconciliation, but for getting layout info.
      child: Container(
        key: _tabItemGlobalKeys[index], // This GlobalKey is for measurement only
        child: InkWell( // Use InkWell for a visual splash feedback on tap
          onTap: () {
            tabControllerGetX.updateIndex(index);
            // Trigger indicator update immediately on tap for snappier feedback.
            _updateIndicatorPosition();
          },
          child: Obx(() {
            final isSelected = tabControllerGetX.selectedIndex.value == index;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              child: Column(
                mainAxisSize: MainAxisSize.min, // Make column take minimum vertical space
                mainAxisAlignment: MainAxisAlignment.center, // Center contents horizontally
                crossAxisAlignment: CrossAxisAlignment.center, // Center contents vertically
                children: [
                  Icon(
                    icon,
                    size: 20,
                    color: isSelected ? AppColors.accentNeon : AppColors.white.withOpacity(0.7),
                  ),
                  const SizedBox(height: 2), // Small spacing between icon and text
                  Text(
                    label,
                    textAlign: TextAlign.center, // Center align text
                    style: textTheme.labelSmall?.copyWith(
                      fontSize: 11,
                      fontWeight: isSelected ? FontWeight.w800 : FontWeight.w300, // Bold when selected
                      color: isSelected ? AppColors.accentNeon : AppColors.white.withOpacity(0.7),
                      letterSpacing: -0.2, // Tighten letter spacing slightly
                    ),
                  ),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Obx(() {
      // Access the categories from HomeController's homeData
      final HomeLayoutModel? homeLayout = homeController.homeData.value;
      final List<CategoryModel> categories = homeLayout?.categories ?? [];

      // Show a loading indicator or empty state if categories are not yet loaded or insufficient.
      // We also check for `homeController.isLoading` to show progress when data is actively being fetched.
      // The condition `categories.length < tabIcons.length` ensures that we only try to build
      // tabs for which we have both data and a corresponding icon.
      if (homeController.isLoading.value || categories.isEmpty || categories.length < tabIcons.length) {
        return const SizedBox(
          height: 60, // Give some height for the indicator to show up
          child: Center(
            child: CircularProgressIndicator(color: AppColors.accentNeon),
          ),
        );
      }

      // Determine the number of tabs to show.
      // It's the minimum of available categories and pre-defined icons.
      final int numberOfTabsToShow = tabIcons.length; // Max tabs shown will be number of icons

      return Stack(
        children: [
          Container(
            key: _tabBarContainerGlobalKey, // Assign GlobalKey to the parent container for measurement
            padding: const EdgeInsets.only(top: 4, bottom: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround, // Distribute tabs evenly
              children: List.generate(numberOfTabsToShow, (index) {
                // Get category name for the label
                final label = categories[index].name;
                // Get the corresponding icon
                final icon = tabIcons[index];
                return Expanded(
                  child: _buildTabItem(icon, label, index, textTheme),
                );
              }),
            ),
          ),
          // The animated traveling indicator (positioned at the bottom)
          AnimatedPositioned(
            duration: const Duration(milliseconds: 250), // Smooth animation duration
            curve: Curves.easeOutCubic, // Animation curve
            left: _indicatorX, // X position for the indicator
            bottom: 0, // Position at the bottom of the Stack
            width: _indicatorWidth, // Width of the indicator
            height: 3, // Height of the indicator line
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.accentNeon, // Indicator color
                borderRadius: BorderRadius.circular(2), // Rounded corners for the indicator
              ),
            ),
          ),
        ],
      );
    });
  }
}

// CustomTabBarViewSection: Displays content based on the selected tab.
class CustomTabBarViewSection extends StatelessWidget {
  // Ensure Get.find is safe, ideally through Bindings
  final TabControllerGetX controller = Get.find<TabControllerGetX>();
  final HomeController homeController = Get.find<HomeController>();
  final SubCategoryController subCategoryController = Get.find<SubCategoryController>();

  CustomTabBarViewSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // Access categories and banners from HomeController's homeData
      final HomeLayoutModel? homeLayout = homeController.homeData.value;
      final List<CategoryModel> categories = homeLayout?.categories ?? [];
      final List<String> banners = homeLayout?.banners ?? []; // Get banners list
      final selectedIndex = controller.selectedIndex.value;

      // Check both homeController's loading state and data availability
      if (homeController.isLoading.value ||
          categories.isEmpty ||
          selectedIndex >= categories.length ||
          banners.isEmpty || // Added check for banners list
          selectedIndex >= banners.length // Ensure selectedIndex is valid for banners list
      ) {
        return const SizedBox(
          height: 300, // Provide a reasonable height for the loading indicator/empty state
          child: Center(
            child: CircularProgressIndicator(color: AppColors.accentNeon),
          ),
        );
      }

      final selectedCategory = categories[selectedIndex];
      final allGroups = homeLayout?.groups ?? [];

// 3. Filter the groups to include only those that contain products
//    belonging to the selected category.
      final updatedGroups = allGroups.where((group) {
        // Check if any product within this group has a category ID that matches
        // the ID of the currently selected category.
        return group.products.any((product) =>
        product.categoryId != null && product.categoryId == selectedCategory.id);
      }).toList();

      // --- FIX: Use banners list from homeLayout based on selectedIndex ---
      // Ensure selectedIndex is valid for banners list to prevent RangeError
      final String bannerImageUrl = (selectedIndex < banners.length)
          ? banners[selectedIndex]
          : selectedCategory.upperBanner ?? ''; // Fallback to category's banner if index out of bounds for main banners, or empty string

      print("Categories: $categories");
      print("Selected Index: $selectedIndex");
      print("Selected Category ID: ${selectedCategory.id}");
      print("HomeData: ${homeLayout != null}");
      print("Groups: ${allGroups.map((e) => e.id)}");
      print("Banner Image URL for Tab: $bannerImageUrl"); // Debug print

      return buildSectionView(
        groups: allGroups,
        bannerImageUrl: bannerImageUrl, // Pass the chosen banner URL
        categoryGridItems: subCategoryController.subCategories, // Keep existing subcategory logic
        subCategories: subCategoryController.subCategories,
      );
    });
  }
}

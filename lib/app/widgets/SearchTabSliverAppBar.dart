// lib/app/modules/Categories/SearchTabSliverAppBar.dart

import 'dart:async'; // Import for Timer
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart'; // Still needed if other parts of your app use it
import 'package:mobiking/app/controllers/sub_category_controller.dart';
import 'package:mobiking/app/modules/search/SearchPage.dart';
import 'package:mobiking/app/themes/app_theme.dart'; // Import your AppTheme

import '../controllers/tab_controller_getx.dart';
import 'CategoryTab.dart'; // Assumed location of TabControllerGetX and CustomTabBarSection

// Convert SearchTabSliverAppBar to a StatefulWidget to manage the Timer
class SearchTabSliverAppBar extends StatefulWidget {
  final TextEditingController? searchController;
  final void Function(String)? onSearchChanged;

  SearchTabSliverAppBar({
    Key? key,
    this.searchController,
    this.onSearchChanged,
  }) : super(key: key);

  @override
  _SearchTabSliverAppBarState createState() => _SearchTabSliverAppBarState();
}

class _SearchTabSliverAppBarState extends State<SearchTabSliverAppBar> {
  // List of hints to cycle through
  final List<String> _hintTexts = [
    'Search "20w bulb"',
    'Search "LED strip lights"',
    'Search "solar panel"',
    'Search "smart plug"',
    'Search "rechargeable battery"',
  ];

  // Observable for the current hint index
  late final RxInt _currentHintIndex;
  Timer? _hintTextTimer;

  @override
  void initState() {
    super.initState();
    _currentHintIndex = 0.obs; // Initialize RxInt here
    _startHintTextAnimation();

    // Ensure controllers are registered before usage
    if (!Get.isRegistered<TabControllerGetX>()) {
      Get.put(TabControllerGetX());
    }
    if (!Get.isRegistered<SubCategoryController>()) {
      Get.put(SubCategoryController());
    }
  }

  void _startHintTextAnimation() {
    _hintTextTimer?.cancel(); // Cancel any existing timer
    _hintTextTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      _currentHintIndex.value = (_currentHintIndex.value + 1) % _hintTexts.length;
    });
  }

  @override
  void dispose() {
    _hintTextTimer?.cancel(); // Cancel the timer when the widget is disposed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SliverPersistentHeader(
      pinned: true,
      delegate: _StickySearchAndTabBarDelegate(
        searchController: widget.searchController, // Access widget properties
        onSearchChanged: widget.onSearchChanged, // Access widget properties
        hintTexts: _hintTexts, // Pass the list of hints
        currentHintIndex: _currentHintIndex, // Pass the observable index
      ),
    );
  }
}

// Create sticky delegate
class _StickySearchAndTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TextEditingController? searchController;
  final void Function(String)? onSearchChanged;
  final List<String> hintTexts; // Now passed in
  final RxInt currentHintIndex; // Now passed in

  _StickySearchAndTabBarDelegate({
    required this.searchController,
    required this.onSearchChanged,
    required this.hintTexts,
    required this.currentHintIndex,
  });

  @override
  double get minExtent => 121; // Minimum height when collapsed
  @override
  double get maxExtent => 121; // Fixed height to prevent expansion

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    final TabControllerGetX tabController = Get.find<TabControllerGetX>();
    final SubCategoryController subCategoryController = Get.find<SubCategoryController>();

    // Retrieve the hint style from the AppTheme
    final TextStyle? appThemeHintStyle = Theme.of(context).inputDecorationTheme.hintStyle;

    return Obx(() {
      String? headerImageUrl;
      final int selectedIndex = tabController.selectedIndex.value;

      // Attempt to get the background image from the selected sub-category
      if (selectedIndex >= 0 && selectedIndex < subCategoryController.subCategories.length) {
        final currentSubCategory = subCategoryController.subCategories[selectedIndex];
        // Check currentSubCategory.upperBanner instead of products/images if that's where the header image is
        // Based on your original SubCategory dummy, it had 'upperBanner'
        if (currentSubCategory.upperBanner != null && currentSubCategory.upperBanner!.isNotEmpty) {
          headerImageUrl = currentSubCategory.upperBanner;
        }
      }

      return SafeArea(
        top: false, // You manage padding manually
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.darkPurple, // Default solid background color
            image: headerImageUrl != null
                ? DecorationImage(
              image: NetworkImage(headerImageUrl),
              fit: BoxFit.cover,
              colorFilter: ColorFilter.mode(
                Colors.black.withOpacity(0.4), // Darken the image
                BlendMode.darken,
              ),
            )
                : null, // If no image, just use the solid color
          ),
          child: Column(
            children: [
              // Search bar
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10), // Simpler way to set radius
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: TextField(
                      controller: searchController,
                      onChanged: onSearchChanged,
                      onTap: () {
                        Get.to(
                              () => const SearchPage(),
                          transition: Transition.rightToLeft,
                          duration: const Duration(milliseconds: 300),
                        );
                      },
                      readOnly: true,
                      // Apply the overall text style for entered text from AppTheme
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textDark) ??
                          GoogleFonts.poppins(fontSize: 15, color: AppColors.textDark),
                      cursorColor: AppColors.primaryGreen, // Changed to primaryGreen for consistency
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        // Use the hint property with AnimatedSwitcher for animated text
                        hint: Obx(() {
                          return AnimatedSwitcher(
                            duration: const Duration(milliseconds: 500),
                            transitionBuilder: (Widget child, Animation<double> animation) {
                              final offsetAnimation = Tween<Offset>(
                                begin: const Offset(0.0, 1.0), // Start from bottom
                                end: Offset.zero, // End at current position
                              ).animate(animation);

                              return ClipRect(
                                child: SlideTransition(
                                  position: offsetAnimation,
                                  child: FadeTransition(
                                    opacity: animation,
                                    child: child,
                                  ),
                                ),
                              );
                            },
                            child: Text(
                              hintTexts[currentHintIndex.value], // Use passed in data
                              key: ValueKey<int>(currentHintIndex.value), // Important for AnimatedSwitcher
                              // Apply the AppTheme's hint style
                              style: appThemeHintStyle,
                            ),
                          );
                        }),
                        prefixIcon: const Icon(Icons.search, color: AppColors.textMedium),
                        suffixIcon: const Icon(Icons.mic_none, color: AppColors.textMedium),
                        contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 4),

              // Tabs section
              Expanded( // Use Expanded to ensure CustomTabBarSection fills remaining space
                child: Container(
                  // Its background should be transparent so the parent Container's background (image or solid color) shows through.
                  color: Colors.transparent,
                  child: CustomTabBarSection(),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    // Rebuild if any of the passed-in properties change, or if it's a different delegate type.
    // Also, since currentHintIndex is an RxInt, the Obx in build will handle its changes.
    return oldDelegate.maxExtent != maxExtent ||
        oldDelegate.minExtent != minExtent ||
        (oldDelegate is _StickySearchAndTabBarDelegate &&
            (oldDelegate.searchController != searchController ||
                oldDelegate.onSearchChanged != onSearchChanged ||
                oldDelegate.hintTexts != hintTexts ||
                oldDelegate.currentHintIndex != currentHintIndex));
  }
}
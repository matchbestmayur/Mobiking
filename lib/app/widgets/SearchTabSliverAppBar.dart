import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobiking/app/widgets/CustomAppBar.dart';
import '../themes/app_theme.dart';
import 'CategoryTab.dart';

class SearchTabSliverAppBar extends StatelessWidget {
  final TextEditingController? searchController;
  final void Function(String)? onSearchChanged;

   SearchTabSliverAppBar({
    Key? key,
    this.searchController,
    this.onSearchChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SliverPersistentHeader(
      pinned: true,
      delegate: _StickySearchAndTabBarDelegate(
        searchController: searchController,
        onSearchChanged: onSearchChanged,
      ),
    );
  }
}

// Create sticky delegate
class _StickySearchAndTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TextEditingController? searchController;
  final void Function(String)? onSearchChanged;

  _StickySearchAndTabBarDelegate({
    required this.searchController,
    required this.onSearchChanged,
  });

  @override
  double get minExtent => 152; // Minimum height when collapsed
  @override
  double get maxExtent => 152; // Fixed height to prevent expansion

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {

    final tabController = Get.find<TabControllerGetX>();

    final List<Color> backgroundColors = [
      Colors.black,      // Index 0
      Colors.black,      // Index 1
      Colors.red,        // Index 2
      Colors.green       // Index 3
    ];

    return Obx(() {
      return SafeArea(
        top: false, // Prevents double padding, assuming your main app bar handles top inset
        child: Container(
          color: backgroundColors[tabController.selectedIndex.value],
          child: Column(
            children: [
              // Search bar
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 6,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: searchController,
                    onChanged: onSearchChanged,
                    style: GoogleFonts.poppins(fontSize: 14),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Search products, brands...',
                      hintStyle: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                      prefixIcon: Icon(Icons.search_rounded, color: Colors.grey.shade700),
                      contentPadding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // Tabs section
              Container(
                padding: const EdgeInsets.only(bottom: 8),
                color: backgroundColors[tabController.selectedIndex.value],
                child: CustomTabBarSection(),
              ),
            ],
          ),
        ),
      );
    });


  }

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) => false;
}

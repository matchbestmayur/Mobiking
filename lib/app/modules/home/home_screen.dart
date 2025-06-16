import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobiking/app/modules/home/widgets/FloatingCartButton.dart';

import '../../controllers/cart_controller.dart' show CartController;
import '../../controllers/category_controller.dart';
import '../../controllers/sub_category_controller.dart';
import '../../themes/app_theme.dart';
import '../../widgets/CustomBottomBar.dart';
import '../../widgets/CategoryTab.dart';
import '../../widgets/CustomAppBar.dart';
import '../../widgets/SearchTabSliverAppBar.dart' show SearchTabSliverAppBar;
import '../cart/cart_bottom_dialoge.dart';


class HomeScreen extends StatefulWidget {
  HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final CategoryController categoryController = Get.find<CategoryController>();
  final SubCategoryController subCategoryController = Get.find<SubCategoryController>();

  late ScrollController _scrollController;
  final RxBool _showScrollToTopButton = false.obs;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.offset >= 200 && !_showScrollToTopButton.value) {
      _showScrollToTopButton.value = true;
    } else if (_scrollController.offset < 200 && _showScrollToTopButton.value) {
      _showScrollToTopButton.value = false;
    }
  }

  void _scrollToTop() {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final tabController = Get.find<TabControllerGetX>();

    return Scaffold(
      // extendBodyBehindAppBar is usually set to false when AppBar is a sliver
      // if you don't want content to draw behind it.
      extendBodyBehindAppBar: false, // Changed to false as AppBar is now a sliver
      backgroundColor: AppColors.neutralBackground,
      appBar: null, // Removed direct appBar property
      body: Stack(
        children: [
          CustomScrollView(
            controller: _scrollController,
            slivers: [
              // --- CustomAppBar as a SliverToBoxAdapter ---
              SliverToBoxAdapter(
                child: CustomAppBar(), // Your custom app bar as a sliver
              ),

              // Search bar with added padding for a more professional look
              SearchTabSliverAppBar(
                onSearchChanged: (value) {
                  print('Search query: $value');
                },
              ),
              SliverToBoxAdapter(
                child: CustomTabBarViewSection(), // Assuming this widget exists
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12.0, 0.0, 24.0, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Mobiking",
                        textAlign: TextAlign.left,
                        style: GoogleFonts.poppins(
                          fontSize: 48,
                          fontWeight: FontWeight.w800,
                          color: Colors.grey,
                          letterSpacing: -2.0,
                          height: 1.0,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "Your Wholesale Partner",
                        textAlign: TextAlign.left,
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade700,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "Buy in bulk, save big. Get the best deals on mobile phones and accessories, delivered directly to your doorstep.",
                        textAlign: TextAlign.left,
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          color: Colors.grey.shade600,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 60),
                      Container(height: 800, color: Colors.blueGrey.withOpacity(0.1), child: Center(child: Text('Scrollable Content Area'))),
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // --- Scroll to Top Button (Top Center) ---
          Positioned(
            top: MediaQuery.of(context).padding.top + 120.0,
            left: 0,
            right: 0,
            child: Align(
              alignment: Alignment.topCenter,
              child: Obx(() => AnimatedOpacity(
                opacity: _showScrollToTopButton.value ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 300),
                child: _showScrollToTopButton.value
                    ? FloatingActionButton(
                  mini: true,
                  backgroundColor: AppColors.darkPurple,
                  onPressed: _scrollToTop,
                  child: const Icon(Icons.arrow_upward, color: Colors.white),
                )
                    : const SizedBox.shrink(),
              )),
            ),
          ),
        ],
      ),
    );
  }
}
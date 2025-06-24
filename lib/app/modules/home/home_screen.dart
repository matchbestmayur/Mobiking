import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
// Remove this if you're fully transitioning to AppTheme for text styles
import 'package:google_fonts/google_fonts.dart'; // Keep if used elsewhere or for specific cases
import 'package:mobiking/app/modules/home/widgets/FloatingCartButton.dart';

import '../../controllers/cart_controller.dart' show CartController;
import '../../controllers/category_controller.dart';
import '../../controllers/sub_category_controller.dart';
import '../../themes/app_theme.dart'; // Make sure this import is correct
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
    // Get the TextTheme from the current context
    final TextTheme textTheme = Theme.of(context).textTheme;

    // Assuming TabControllerGetX is defined somewhere (e.g., in your GetX bindings)
    // If not, you might need to manage tabs differently or provide a mock.
    // final tabController = Get.find<TabControllerGetX>();

    return Scaffold(
      extendBodyBehindAppBar: false,
      backgroundColor: AppColors.neutralBackground, // Use AppColors for background
      appBar: null,
      body: Stack(
        children: [
          CustomScrollView(
            controller: _scrollController,
            slivers: [
              SliverToBoxAdapter(
                child: CustomAppBar(),
              ),
              SearchTabSliverAppBar(
                onSearchChanged: (value) {
                  print('Search query: $value');
                },
              ),
              // Assuming CustomTabBarViewSection also handles its own text styling internally
              SliverToBoxAdapter(
                child: CustomTabBarViewSection(),
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
                        // Apply custom displayLarge style from AppTheme
                        style: textTheme.displayLarge?.copyWith(
                          color: AppColors.textLight, // Use AppColors for consistent grey
                          letterSpacing: -2.0,
                          height: 1.0,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "Your Wholesale Partner",
                        textAlign: TextAlign.left,
                        // Apply custom headlineMedium style from AppTheme
                        style: textTheme.headlineMedium?.copyWith(
                          color: AppColors.textLight, // Use AppColors for consistent grey
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "Buy in bulk, save big. Get the best deals on mobile phones and accessories, delivered directly to your doorstep.",
                        textAlign: TextAlign.left,
                        // Apply custom bodyLarge style from AppTheme
                        style: textTheme.bodyLarge?.copyWith(
                          color: AppColors.textLight, // Use AppColors for consistent grey
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 60),
                      Container(
                        height: 800,
                        color: AppColors.primaryPurple.withOpacity(0.1), // Use AppColors
                        child: Center(
                          child: Text(
                            'Scrollable Content Area',
                            style: textTheme.bodyMedium?.copyWith(color: AppColors.primaryPurple), // Use bodyMedium
                          ),
                        ),
                      ),
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
                  backgroundColor: AppColors.darkPurple, // Use AppColors
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

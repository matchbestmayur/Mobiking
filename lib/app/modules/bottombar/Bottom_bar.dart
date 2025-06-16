// lib/app/modules/main_container/main_container_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import for SystemChrome
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';


import 'package:mobiking/app/themes/app_theme.dart';

import 'package:mobiking/app/modules/cart/cart_bottom_dialoge.dart';
import 'package:mobiking/app/controllers/cart_controller.dart';
import 'package:mobiking/app/modules/home/widgets/FloatingCartButton.dart';

import '../../controllers/BottomNavController.dart';
import '../../widgets/CustomBottomBar.dart'; // Ensure this is imported



class MainContainerScreen extends StatefulWidget {
  const MainContainerScreen({super.key});

  @override
  State<MainContainerScreen> createState() => _MainContainerScreenState();
}

class _MainContainerScreenState extends State<MainContainerScreen> with WidgetsBindingObserver {
  final BottomNavController navController = Get.find<BottomNavController>();
  final CartController cartController = Get.find<CartController>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _setSystemUiMode();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    // Optional: Restore to default UI mode when the app is completely closed or this screen is removed.
    // However, for persistent global hiding, you might just leave it hidden.
    // SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Reapply UI mode if app comes back from background (important for Android)
    if (state == AppLifecycleState.resumed) {
      _setSystemUiMode();
    }
  }

  void _setSystemUiMode() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.leanBack);
    // Apply a transparent style so the hidden bars don't show a color when briefly visible
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        systemNavigationBarColor: Colors.transparent,
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light, // For dark content behind it
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppTheme.lightTheme,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: Obx(
              () => IndexedStack(
            index: navController.selectedIndex.value,
            children: navController.pages,
          ),
        ),
        bottomNavigationBar: const CustomBottomBar(),
        // --- Floating Action Button (Custom FloatingCartButton with conditional visibility) ---
        floatingActionButton: Obx(() {
          // Get the current selected index from the navigation controller
          final currentTabIndex = navController.selectedIndex.value;

          // Define the index of the Profile screen (adjust if your Profile tab is at a different index)
          // Assuming your tabs are (0: Home, 1: Categories, 2: My Orders, 3: Profile)
          const int profileTabIndex = 3;

          // If the current tab is the Profile screen, hide the Floating Action Button
          if (currentTabIndex == profileTabIndex) {
            return const SizedBox.shrink();
          }

          // Existing logic for showing the FloatingCartButton based on cart items
          final cartController = Get.find<CartController>();
          final totalItemsInCart = cartController.totalCartItemsCount;

          if (totalItemsInCart == 0) {
            return const SizedBox.shrink();
          }

          final List<String> imageUrls = cartController.cartItems.take(3).map((item) {
            final product = item['productId'];
            String? imageUrl;

            if (product is Map && product.containsKey('images')) {
              final imagesData = product['images'];

              if (imagesData is String) {
                imageUrl = imagesData;
              } else if (imagesData is List && imagesData.isNotEmpty) {
                final firstImageData = imagesData[0];
                if (firstImageData is String) {
                  imageUrl = firstImageData;
                } else if (firstImageData is Map && firstImageData.containsKey('url')) {
                  imageUrl = firstImageData['url'] as String?;
                }
              }
            }
            return imageUrl ?? 'https://placehold.co/50x50/cccccc/ffffff?text=No+Img';
          }).toList();

          return Container(
            height: 56,
            margin: const EdgeInsets.only(left: 25, right: 25,bottom: 70),
            child: FloatingCartButton(
              label: "View Cart",
              productImageUrls: imageUrls,
              itemCount: totalItemsInCart,
              onTap: () {
                showModalBottomSheet(
                  context: Get.context!,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) {
                    return FractionallySizedBox(
                      heightFactor: 0.8,
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Color(0xFF2C2C2E), // Your desired background color for the sheet content
                          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                        ),
                        child: const CartScreen(), // Assuming CartScreen is correct
                      ),
                    );
                  },
                );
              },
            ),
          );
        }),
        // IMPORTANT: Remove floatingActionButtonLocation when using Positioned directly inside floatingActionButton
         floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      ),
    );
  }
}
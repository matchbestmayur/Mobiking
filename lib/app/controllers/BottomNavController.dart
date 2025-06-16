import 'package:get/get.dart';
import 'package:flutter/material.dart';

import 'package:mobiking/app/modules/home/home_screen.dart';
import 'package:mobiking/app/modules/orders/order_screen.dart';
import 'package:mobiking/app/modules/profile/profile_screen.dart';
import 'package:mobiking/app/modules/Categories/Categories_screen.dart';

class BottomNavController extends GetxController {
  final RxInt selectedIndex = 0.obs;

  final List<Widget> pages = [
    HomeScreen(),
    CategorySectionScreen(),
    OrderHistoryScreen(),
    ProfileScreen(),
  ];

  void changePage(int index) {
    if (selectedIndex.value == index) {
      return;
    }
    selectedIndex.value = index;
    // IMPORTANT: No Get.to() or Get.offAll() calls here!
    // The MainContainerScreen with IndexedStack handles the display.
  }

  Widget getCurrentPage() {
    return pages[selectedIndex.value];
  }
}
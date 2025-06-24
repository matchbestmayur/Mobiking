// lib/app/controllers/BottomNavController.dart

import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Required for Brightness
import 'package:mobiking/app/controllers/system_ui_controller.dart'; // Import the SystemUiController

import 'package:mobiking/app/modules/home/home_screen.dart';
import 'package:mobiking/app/modules/orders/order_screen.dart';
import 'package:mobiking/app/modules/profile/profile_screen.dart';
import 'package:mobiking/app/modules/Categories/Categories_screen.dart';

class BottomNavController extends GetxController {
  final RxInt selectedIndex = 0.obs;

  // Get an instance of SystemUiController
  late final SystemUiController _systemUiController;

  @override
  void onInit() {
    super.onInit();
    _systemUiController = Get.find<SystemUiController>();
    // Set initial status bar brightness based on the initial selected index (0)
    _updateStatusBarBrightness(selectedIndex.value);
  }

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
    // Update status bar brightness based on the new index
    _updateStatusBarBrightness(index);
  }

  void _updateStatusBarBrightness(int index) {
    if (index == 0) { // Home Screen
      _systemUiController.setStatusBarBrightness(Brightness.light);
    } else { // Categories, Orders, Profile
      _systemUiController.setStatusBarBrightness(Brightness.dark);
    }
  }

  Widget getCurrentPage() {
    return pages[selectedIndex.value];
  }
}
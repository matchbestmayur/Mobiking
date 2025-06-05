import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class WishlistController extends GetxController {
  var wishlist = <String>[].obs;

  void addToWishlist(String productId) {
    wishlist.add(productId);
    Get.snackbar(
      'Wishlist',
      'Item added to wishlist',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF4CAF50), // green color
      colorText: Colors.white,
      margin: const EdgeInsets.all(12),
      duration: const Duration(seconds: 2),
    );
  }

  void removeFromWishlist(String productId) {
    wishlist.remove(productId);
    Get.snackbar(
      'Wishlist',
      'Item removed from wishlist',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFFF44336), // red color
      colorText:Colors.white,
      margin: const EdgeInsets.all(12),
      duration: const Duration(seconds: 2),
    );
  }
}

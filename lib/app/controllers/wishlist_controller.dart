import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../data/product_model.dart';
import '../services/wishlist_service.dart';

class WishlistController extends GetxController {
  final WishlistService _service = WishlistService();

  
  var wishlist = <ProductModel>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    
    loadWishlistFromLocal(); 
    
   
  }

  
  void loadWishlistFromLocal() {
    final box = _service.box;
    final userMap = box.read('user') as Map<String, dynamic>?; 

    if (userMap != null) {
      final List<dynamic>? wishlistData = userMap['wishlist']; 
      if (wishlistData != null) {
        wishlist.clear();
        wishlist.value = wishlistData
            .map((e) => ProductModel.fromJson(e as Map<String, dynamic>))
            .toList();
        print('Wishlist loaded locally with ${wishlist.length} items.');
      } else {
        wishlist.clear();
        print('No "wishlist" field found in user data or it is null locally.');
      }
    } else {
      wishlist.clear();
      print('No user data found locally for wishlist.');
    }
  }

  
  


  bool isProductInWishlist(String productId) {
    return wishlist.any((p) => p.id == productId);
  }

  Future<void> addToWishlist(String productId) async {
    if (isLoading.value) return;
    isLoading.value = true;

    if (isProductInWishlist(productId)) {
      _showSnackbar(
        'Already in Wishlist',
        'This product is already in your wishlist.',
        Colors.amber,
        Icons.info_outline,
      );
      isLoading.value = false;
      return;
    }

    final success = await _service.addToWishlist(productId); 
    if (success) {
      
      
      loadWishlistFromLocal();
      _showSnackbar(
        'Added to Wishlist',
        'Product has been added to your wishlist!',
        Colors.green,
        Icons.favorite,
      );
    } else {
      _showSnackbar(
        'Error',
        'Failed to add product to wishlist. Please try again.',
        Colors.red,
        Icons.error,
        duration: 3,
      );
      
      
      
      
      loadWishlistFromLocal();
    }
    isLoading.value = false;
  }

  Future<void> removeFromWishlist(String productId) async {
    if (isLoading.value) return;
    isLoading.value = true;

    final success = await _service.removeFromWishlist(productId); 
    if (success) {
      
      
      loadWishlistFromLocal();
      _showSnackbar(
        'Removed from Wishlist',
        'Product has been removed from your wishlist.',
        Colors.blueGrey,
        Icons.favorite_border,
      );
    } else {
      _showSnackbar(
        'Error',
        'Failed to remove product from wishlist. Please try again.',
        Colors.red,
        Icons.error,
        duration: 3,
      );
      
      
      
      loadWishlistFromLocal();
    }
    isLoading.value = false;
  }

  void _showSnackbar(
      String title,
      String message,
      Color backgroundColor,
      IconData iconData, {
        int duration = 2,
      }) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: backgroundColor.withOpacity(0.8),
      colorText: Colors.white,
      icon: Icon(iconData, color: Colors.white),
      margin: const EdgeInsets.all(10),
      borderRadius: 10,
      animationDuration: const Duration(milliseconds: 300),
      duration: Duration(seconds: duration),
    );
  }
}
// lib/widgets/favorite_toggle_button.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../../../controllers/wishlist_controller.dart';
import '../../../services/Sound_Service.dart';
import '../../../themes/app_theme.dart';



class FavoriteToggleButton extends StatelessWidget {
  final String productId; // The unique ID of the product
  final double iconSize;
  final double padding;
  final double containerOpacity;
  final Function(bool isFavorite)? onChanged; // Optional callback for when the favorite status changes

  const FavoriteToggleButton({
    Key? key,
    required this.productId,
    this.iconSize = 18,
    this.padding = 4,
    this.containerOpacity = 0.8,
    this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Get instances of your controllers/services
    final WishlistController wishlistController = Get.find<WishlistController>();
    final SoundService soundService = Get.find<SoundService>(); // <--- GET SOUND SERVICE INSTANCE

    // Obx makes the widget rebuild when the observable `wishlist` changes
    return Obx(() {
      // Check if the current product is in the wishlist
      final bool isFavorite = wishlistController.wishlist.any((p) => p.id == productId);

      return GestureDetector(
        onTap: () {
          soundService.playPopSound(); // <--- ADD THIS LINE TO PLAY SOUND

          // Toggle favorite status and show a SnackBar
          if (isFavorite) {
            wishlistController.removeFromWishlist(productId);
            Get.snackbar(
              'Wishlist',
              'Removed from wishlist!',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: AppColors.textDark.withOpacity(0.8),
              colorText: AppColors.white,
              duration: const Duration(seconds: 1),
            );
          } else {
            // In a real app, you might pass the whole product model to addToWishlist
            // For this example, we're just adding the ID.
            // If WishlistController.addToWishlist requires a ProductModel,
            // you'd need to fetch or pass the ProductModel here.
            // Example: wishlistController.addToWishlist(product);
            wishlistController.addToWishlist(productId); // Assuming this takes a String productId
            Get.snackbar(
              'Wishlist',
              'Added to wishlist!',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: AppColors.textDark.withOpacity(0.8),
              colorText: AppColors.white,
              duration: const Duration(seconds: 1),
            );
          }
          // Call the optional onChanged callback
          onChanged?.call(!isFavorite);
        },
        child: Container(
          padding: EdgeInsets.all(padding),
          decoration: BoxDecoration(
            color: AppColors.white.withOpacity(containerOpacity),
            shape: BoxShape.circle,
          ),
          child: Icon(
            // Change icon based on favorite status
            isFavorite ? Icons.favorite : Icons.favorite_border,
            // Change color based on favorite status
            color: isFavorite ? AppColors.danger : AppColors.textMedium,
            size: iconSize,
          ),
        ),
      );
    });
  }
}
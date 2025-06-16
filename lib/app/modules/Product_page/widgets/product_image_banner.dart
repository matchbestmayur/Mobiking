import 'package:flutter/material.dart';

class ProductImageBanner extends StatefulWidget {
  final List<String> imageUrls;
  final String badgeText;
  final VoidCallback? onBack;
  final VoidCallback? onFavorite; // Callback when favorite button is tapped
  final bool isFavorite; // New: indicates if the product is currently favorited

  const ProductImageBanner({
    super.key,
    required this.imageUrls,
    required this.badgeText,
    this.onBack,
    this.onFavorite,
    this.isFavorite = false, // Default to not favorited
  });

  @override
  State<ProductImageBanner> createState() => _ProductImageBannerState();
}

class _ProductImageBannerState extends State<ProductImageBanner> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return SizedBox( // Wrapped in SizedBox to give it a defined height, as Stack doesn't inherently
      height: 300, // Explicit height for the banner
      width: double.infinity,
      child: Stack(
        children: [
          // Image slider
          PageView.builder(
            itemCount: widget.imageUrls.length,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemBuilder: (_, index) {
              return Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  image: DecorationImage(
                    image: NetworkImage(widget.imageUrls[index]),
                    fit: BoxFit.cover,
                  ),
                ),
              );
            },
          ),

          // Share button
          Positioned(
            bottom: 12,
            right: 12,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.ios_share, color: Colors.black),
                onPressed: () {
                  // TODO: Add sharing logic
                  print('Share button tapped');
                },
              ),
            ),
          ),

          // Favorite button (Dynamic)
          Positioned(
            top: 12,
            right: 20,
            child: GestureDetector(
              onTap: widget.onFavorite, // Use the provided callback
              child: CircleAvatar(
                radius: 15,
                backgroundColor: Colors.black.withOpacity(0.6), // Slightly transparent background
                child: Icon(
                  widget.isFavorite // Dynamic icon based on isFavorite
                      ? Icons.favorite // Filled heart
                      : Icons.favorite_border_outlined, // Outline heart
                  size: 18, // Slightly larger icon for visibility
                  color: widget.isFavorite ? Colors.red.shade400 : Colors.white, // Red for favorited, white otherwise
                ),
              ),
            ),
          ),

          // Back button
          Positioned(
            top: 12,
            left: 20,
            child: GestureDetector(
              onTap: widget.onBack ?? () => Navigator.pop(context),
              child: CircleAvatar(
                radius: 15,
                backgroundColor: Colors.black.withOpacity(0.6), // Consistent background
                child: const Icon(Icons.arrow_back_ios_new, size: 18, color: Colors.white), // Larger icon
              ),
            ),
          ),

          // Badge
          Positioned(
            top: 12,
            left: 120, // Adjust position as needed, or calculate dynamically
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
              child: Text(
                widget.badgeText,
                style: const TextStyle(color: Colors.white, fontSize: 12), // Added font size
              ),
            ),
          ),

          // Dots indicator
          Positioned(
            bottom: 10,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                widget.imageUrls.length,
                    (index) => Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentIndex == index ? Colors.white : Colors.white.withOpacity(0.4),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
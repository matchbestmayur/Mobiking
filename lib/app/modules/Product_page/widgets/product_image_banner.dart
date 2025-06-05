import 'package:flutter/material.dart';

class ProductImageBanner extends StatefulWidget {
  final List<String> imageUrls;
  final String badgeText;
  final VoidCallback? onBack;
  final VoidCallback? onFavorite;

  const ProductImageBanner({
    super.key,
    required this.imageUrls,
    required this.badgeText,
    this.onBack,
    this.onFavorite,
  });

  @override
  State<ProductImageBanner> createState() => _ProductImageBannerState();
}

class _ProductImageBannerState extends State<ProductImageBanner> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Image slider
        SizedBox(
          height: 300,
          width: double.infinity,
          child: PageView.builder(
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

        // Favorite button
        Positioned(
          top: 12,
          right: 20,
          child: GestureDetector(
            onTap: widget.onFavorite,
            child: const CircleAvatar(
              child: Icon(Icons.favorite_border_outlined, size: 15, color: Colors.white),
              radius: 15,
              backgroundColor: Colors.black,
            ),
          ),
        ),

        // Back button
        Positioned(
          top: 12,
          left: 20,
          child: GestureDetector(
            onTap: widget.onBack ?? () => Navigator.pop(context),
            child: const CircleAvatar(
              child: Icon(Icons.arrow_back_ios_new, size: 15, color: Colors.white),
              radius: 15,
              backgroundColor: Colors.black,
            ),
          ),
        ),

        // Badge
        Positioned(
          top: 12,
          left: 120,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.7),
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            child: Text(
              widget.badgeText,
              style: const TextStyle(color: Colors.white),
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
    );
  }
}

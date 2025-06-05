import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:mobiking/app/modules/cart/cart_bottom_dialoge.dart';
import 'package:mobiking/app/modules/home/home_screen.dart';
import 'package:mobiking/app/modules/profile/profile_screen.dart';

import '../modules/Categories/Categories_screen.dart';

class CustomBottomBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTap;

  const CustomBottomBar({
    super.key,
    required this.selectedIndex,
    required this.onItemTap,
  });

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double itemWidth = screenWidth / 4;
    final double lineWidth = 40;

    final double leftOffset = (selectedIndex + 0.5) * itemWidth - (lineWidth / 2);

    // Map of index to SVG asset path
    final Map<int, String> iconPaths = {
      0: 'assets/svg/home.svg',
      1: 'assets/svg/category.svg',
      2: 'assets/svg/cart.svg',
      3: 'assets/svg/profile.svg',
    };

    return SizedBox(
      height: 60,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Top Indicator
          Positioned(
            top: 1,
            left: leftOffset,
            child: Container(
              width: lineWidth,
              height: 2,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Navigation Items
          Positioned.fill(
            top: 3,
            child: Container(
              color: Colors.white,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(4, (index) {
                  final String iconPath = iconPaths[index] ?? 'assets/icons/home.svg';

                  return GestureDetector(
                    onTap: () {
                      onItemTap(index); // update UI state
                      if (index == 0) {
                        Get.to(() => HomeScreen());
                      } else if (index == 2) {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (context) {
                            return FractionallySizedBox(
                              heightFactor: 0.6, // 60% of screen height
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                                ),
                                child: CartScreen(),
                              ),
                            );
                          },
                        );
                      } else if (index == 3) {
                        Get.to(() => ProfileScreen());
                      }else if (index == 1) {
                        Get.to(() => CategorySectionScreen());
                      }
                    },
                    child: SvgPicture.asset(
                      iconPath,
                      color: selectedIndex == index ? Colors.deepPurple : Colors.grey,
                      width: 24,
                      height: 24,
                    ),
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

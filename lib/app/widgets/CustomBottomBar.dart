import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobiking/app/themes/app_theme.dart';

import '../controllers/BottomNavController.dart';


class CustomBottomBar extends StatelessWidget {
  const CustomBottomBar({super.key});

  @override
  Widget build(BuildContext context) {
    final BottomNavController navController = Get.find<BottomNavController>();

    final List<Map<String, dynamic>> navItems = [
      {'icon': 'assets/svg/home.svg', 'label': 'Home'},
      {'icon': 'assets/svg/category.svg', 'label': 'Categories'},
      {'icon': 'assets/svg/order.svg', 'label': 'Orders'},
      {'icon': 'assets/svg/profile.svg', 'label': 'Profile'},
    ];

    return Obx(
          () => Container(
        height: 70,
        decoration: BoxDecoration(
          color: AppColors.primaryPurple,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 10,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(navItems.length, (index) {
            final bool isSelected = navController.selectedIndex.value == index;
            final String iconPath = navItems[index]['icon'];
            final String label = navItems[index]['label'];

            return Expanded(
              child: InkWell(
                onTap: () => navController.changePage(index),
                highlightColor: Colors.transparent,
                splashColor: AppColors.accentNeon.withOpacity(0.2),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedScale(
                        scale: isSelected ? 1.1 : 1.0,
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeInOut,
                        child: SvgPicture.asset(
                          iconPath,
                          color: isSelected ? AppColors.accentNeon : Colors.white70,
                          width: 26,
                          height: 26,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        label,
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                          color: isSelected ? AppColors.accentNeon : Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

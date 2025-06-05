import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobiking/app/themes/app_theme.dart';

import 'CategoryTab.dart';

class CustomAppBar extends StatelessWidget {
  CustomAppBar({super.key});

 final tabController = Get.find<TabControllerGetX>();

  @override
  Widget build(BuildContext context) {
    final List<Color> backgroundColors = [
      Colors.black,      // Index 0
      Colors.black,      // Index 1
      Colors.red,        // Index 2
      Colors.green       // Index 3
    ];

    return Obx(() {
      return Container(
        color: backgroundColors[tabController.selectedIndex.value],
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              const CircleAvatar(
                backgroundColor: Colors.deepPurple,
                child: Icon(Icons.storefront, color: Colors.white),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Mobiking Wholesale",
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 2),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}

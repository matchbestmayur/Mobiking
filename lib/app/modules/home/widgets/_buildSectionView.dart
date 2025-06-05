import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobiking/app/widgets/group_grid_section.dart';

import '../../../data/group_model.dart';
import '../../../data/product_model.dart';
import '../../../themes/app_theme.dart';
import '../../../widgets/buildProductList.dart';

Widget buildSectionView({
  required String bannerImageUrl,
  required List<GroupModel> groups,
  required List<ProductModel> products,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Container(
        height: 160,
        decoration: BoxDecoration(
          color: AppColors.darkPurple,
          image: DecorationImage(
            image: NetworkImage(bannerImageUrl),
            fit: BoxFit.fill,
            colorFilter: const ColorFilter.mode(
              Colors.black45,
              BlendMode.darken,
            ),
          ),
        ),
        alignment: Alignment.center,
      ),

      // Dynamically loop through each group
      ...groups.map((group) {
        final groupProducts = products
            .where((product) => product.groupIds == group.id)
            .toList(); // Filter products by groupId

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Group Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  group.name,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkPurple,
                  ),
                ),
              ),

              const SizedBox(height: 8),

              // Group Banner (optional visual divider)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child:group.banner.isNotEmpty
                      ? Image.network(
                    group.banner,
                    height: 100,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  )
                      : Container(
                    height: 100,
                    width: double.infinity,
                    color: AppColors.lightPurple, // or any fallback color
                    alignment: Alignment.center,
                    child: Text(
                      group.name,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),


              // Horizontal List of Products
            ],
          ),
        );
      }).toList(),

      SizedBox(
        height: 320,
        child: buildProductList(
          showBackground: false,
          title: '', // No need to show title again
          products: products,
        ),
      ),

      // Final bottom section (Optional Featured Section)
      Padding(
        padding: const EdgeInsets.all(16),
        child: Container(
          height: 120,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.center,
          child: Text(
            'Featured Banner',
            style: GoogleFonts.poppins(color: Colors.white, fontSize: 16),
          ),
        ),
      ),
    ],
  );
}

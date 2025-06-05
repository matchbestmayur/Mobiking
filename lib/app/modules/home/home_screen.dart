import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobiking/app/modules/home/widgets/FloatingCartButton.dart';
import 'package:mobiking/app/themes/app_theme.dart';
import '../../controllers/category_controller.dart';
import '../../widgets/Bottom_Bar.dart';
import '../../widgets/CategoryTab.dart';
import '../../widgets/CustomAppBar.dart';
import '../../widgets/ProductCardWidget.dart';
import '../../widgets/SearchTabSliverAppBar.dart';
import '../../widgets/SectionHeader.dart';
import '../../widgets/buildProductList.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}


class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final CategoryController categoryController = Get.find<CategoryController>();
  @override
  Widget build(BuildContext context) {

    final tabController = TabControllerGetX();

    final List<Color> backgroundColors = [
      Colors.black,        // Index 1
      Colors.red,
    ];


    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(

        statusBarColor: AppColors.darkPurple, // Must match your app bar
        statusBarIconBrightness: Brightness.light,
      ),
    );


    return Scaffold(
      backgroundColor: backgroundColors[tabController.selectedIndex.value],
      bottomNavigationBar: SafeArea(
        bottom: true,
        child: CustomBottomBar(
          selectedIndex: _selectedIndex,
          onItemTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
        ),
      ),
      body: CustomScrollView(
    slivers: [
    // Add spacing at the top
    const SliverToBoxAdapter(
    child: SizedBox(height: 20), // Adjust height as needed
        ),
        // Scrollable Header
         SliverToBoxAdapter(
        child: CustomAppBar(),
        ),
        // Pinned Search + TabBar
        SearchTabSliverAppBar(
        onSearchChanged: (value) {
        print('Search query: $value');
        },
        ),


        // Main content
         SliverToBoxAdapter(
        child: CustomTabBarViewSection(),
        ),

        ],
        ),
      floatingActionButton: FloatingCartButton(
        label: "Cart",
        productImageUrls: [
          'https://m.media-amazon.com/images/I/31x-Xz8TkbL._SX300_SY300_QL70_FMwebp_.jpg',
          'https://m.media-amazon.com/images/I/31x-Xz8TkbL._SX300_SY300_QL70_FMwebp_.jpg',
          'https://m.media-amazon.com/images/I/31x-Xz8TkbL._SX300_SY300_QL70_FMwebp_.jpg',
        ],
        itemCount: 3, // Replace with your cart count dynamically
        onTap: () {
          // Navigate to cart screen or perform action
          print('FAB tapped!');
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,


        );
  }

  BottomNavigationBarItem _buildNavItem(IconData iconData, int index) {
    return BottomNavigationBarItem(
      label: "",
      icon: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(iconData),
          const SizedBox(height: 4),
          Container(
            height: 3,
            width: 20,
            decoration: BoxDecoration(
              color: _selectedIndex == index ? Colors.deepPurple : Colors.transparent,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }
}
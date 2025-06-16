// lib/app/modules/search/search_page.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobiking/app/themes/app_theme.dart'; // Import your AppColors

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchPageController = TextEditingController();
  final RxList<String> _recentSearches = <String>[].obs; // Example for recent searches
  final RxList<String> _popularCategories = <String>[].obs; // Example for popular categories

  // Add an RxBool to manage the visibility of the clear button
  final RxBool _showClearButton = false.obs; // <--- NEW: Reactive boolean

  @override
  void initState() {
    super.initState();
    // Simulate loading recent searches and popular categories
    Future.delayed(const Duration(milliseconds: 300), () {
      _recentSearches.addAll(['Mobile A', 'Headphones', 'Charger']);
      _popularCategories.addAll(['Electronics', 'Accessories', 'Tablets', 'Laptops']);
    });

    // Add a listener to the TextEditingController to update the reactive variable
    _searchPageController.addListener(_onSearchPageControllerChanged); // <--- NEW: Listener
  }

  @override
  void dispose() {
    _searchPageController.removeListener(_onSearchPageControllerChanged); // <--- IMPORTANT: Remove listener
    _searchPageController.dispose();
    super.dispose();
  }

  // <--- NEW: Listener method
  void _onSearchPageControllerChanged() {
    _showClearButton.value = _searchPageController.text.isNotEmpty;
  }
  // --- End NEW ---


  void _onSearchInputChanged(String query) {
    // Implement your search logic here (e.g., call a search API)
    print('Search page query: $query');
    // You might update search results here, or debounced search.
  }

  void _addRecentSearch(String query) {
    if (query.trim().isNotEmpty && !_recentSearches.contains(query.trim())) {
      _recentSearches.insert(0, query.trim()); // Add to top
      if (_recentSearches.length > 5) _recentSearches.removeLast(); // Keep limited history
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutralBackground,
      appBar: AppBar(
        backgroundColor: AppColors.primaryPurple, // AppBar color from theme
        foregroundColor: Colors.white, // Back button and title color
        elevation: 0, // No shadow for a flat, modern look
        titleSpacing: 0, // Remove default title spacing
        title: Padding(
          padding: const EdgeInsets.only(right: 16.0), // Padding from the right edge
          child: Container(
            height: 44, // Slightly shorter for app bar integration
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12), // Pill shape
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: _searchPageController,
              autofocus: true, // Automatically focus on entering this page
              onChanged: _onSearchInputChanged,
              onSubmitted: (query) {
                _addRecentSearch(query); // Add to recent searches on submission
                // Trigger actual search result display
              },
              style: GoogleFonts.poppins(fontSize: 15, color: AppColors.textDark),
              cursorColor: AppColors.primaryPurple,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'Search in Mobiking...',
                hintStyle: GoogleFonts.poppins(
                  fontSize: 15,
                  color: AppColors.textLight,
                ),
                prefixIcon: Icon(Icons.search_rounded, color: AppColors.textLight),
                suffixIcon: Obx(() => _showClearButton.value // <--- NOW reacts to _showClearButton.value
                    ? IconButton(
                  icon: Icon(Icons.clear_rounded, color: AppColors.textLight),
                  onPressed: () {
                    _searchPageController.clear();
                    _onSearchInputChanged(''); // Clear results
                  },
                )
                    : const SizedBox.shrink()),
                contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Recent Searches Section
            Obx(() {
              if (_recentSearches.isEmpty) return const SizedBox.shrink();
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Recent Searches',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8.0, // Space between chips
                    runSpacing: 8.0, // Space between rows of chips
                    children: _recentSearches.map((search) => Chip(
                      onDeleted: () => _recentSearches.remove(search),
                      deleteIcon: Icon(Icons.close, size: 18, color: AppColors.textLight),
                      label: Text(search),
                      labelStyle: GoogleFonts.poppins(fontSize: 14, color: AppColors.textDark),
                      backgroundColor: Colors.white,
                      side: BorderSide(color: AppColors.lightPurple, width: 0.5),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    )).toList(),
                  ),
                  const SizedBox(height: 24),
                ],
              );
            }),

            // Popular Categories Section
            Obx(() {
              if (_popularCategories.isEmpty) return const SizedBox.shrink();
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Popular Categories',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 12),
                  GridView.builder(
                    shrinkWrap: true, // Essential for GridView in Column/ListView
                    physics: const NeverScrollableScrollPhysics(), // Prevents GridView from scrolling independently
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3, // 3 items per row
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 1.0, // Square items
                    ),
                    itemCount: _popularCategories.length,
                    itemBuilder: (context, index) {
                      final category = _popularCategories[index];
                      return GestureDetector(
                        onTap: () {
                          // Handle category tap, e.g., navigate to category products
                          print('Tapped category: $category');
                          _searchPageController.text = category;
                          _onSearchInputChanged(category);
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.lightPurple.withOpacity(0.5)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.category, size: 36, color: AppColors.primaryPurple), // Placeholder icon
                              const SizedBox(height: 8),
                              Text(
                                category,
                                textAlign: TextAlign.center,
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.textDark,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                ],
              );
            }),
            // Placeholder for search results
            // Obx(() {
            //   if (_searchResults.isEmpty && _searchPageController.text.isNotEmpty) {
            //     return Center(child: Text('No results found', style: GoogleFonts.poppins(color: AppColors.textLight)));
            //   } else if (_searchResults.isNotEmpty) {
            //     return ListView.builder(
            //       shrinkWrap: true,
            //       physics: NeverScrollableScrollPhysics(),
            //       itemCount: _searchResults.length,
            //       itemBuilder: (context, index) {
            //         final result = _searchResults[index];
            //         return ListTile(
            //           title: Text(result, style: GoogleFonts.poppins(color: AppColors.textDark)),
            //         );
            //       },
            //     );
            //   }
            //   return SizedBox.shrink();
            // }),
          ],
        ),
      ),
    );
  }
}
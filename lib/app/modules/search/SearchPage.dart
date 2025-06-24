// lib/app/modules/search/search_page.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobiking/app/themes/app_theme.dart'; // Import your AppColors

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchPageController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode(); // Add a FocusNode for controlled focusing

  final RxList<String> _recentSearches = <String>[].obs;
  final RxList<Map<String, dynamic>> _popularCategories = <Map<String, dynamic>>[].obs;
  final RxBool _showClearButton = false.obs;

  @override
  void initState() {
    super.initState();

    // Request focus AFTER the first frame is rendered
    // This allows the page to build before the keyboard animation starts.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _searchFocusNode.requestFocus();
    });

    // Simulate loading recent searches and popular categories
    // It's good that this is in a Future.delayed, so it doesn't block initState.
    // If this data were coming from a real API, ensure it's an async call.
    Future.delayed(const Duration(milliseconds: 300), () {
      _recentSearches.addAll(['Mobile A', 'Headphones', 'Charger', 'Power Bank', 'Screen Protector']);
      _popularCategories.addAll([
        {'name': 'All', 'icon': Icons.apps},
        {'name': 'Monsoon', 'icon': Icons.umbrella},
        {'name': 'Electronics', 'icon': Icons.headset},
        {'name': 'Beauty', 'icon': Icons.spa},
        {'name': 'Home', 'icon': Icons.home},
        {'name': 'Kitchen', 'icon': Icons.kitchen},
      ]);
    });

    _searchPageController.addListener(_onSearchPageControllerChanged);
  }

  @override
  void dispose() {
    _searchPageController.removeListener(_onSearchPageControllerChanged);
    _searchPageController.dispose();
    _searchFocusNode.dispose(); // Dispose the FocusNode
    super.dispose();
  }

  void _onSearchPageControllerChanged() {
    _showClearButton.value = _searchPageController.text.isNotEmpty;
  }

  void _onSearchInputChanged(String query) {
    debugPrint('Search page query: $query');
    // Implement your debounced search logic here if needed
  }

  void _addRecentSearch(String query) {
    final cleanQuery = query.trim();
    if (cleanQuery.isNotEmpty) {
      if (_recentSearches.contains(cleanQuery)) {
        _recentSearches.remove(cleanQuery); // Remove if exists to re-add at top
      }
      _recentSearches.insert(0, cleanQuery); // Add to top
      if (_recentSearches.length > 5) _recentSearches.removeLast(); // Keep limited history
    }
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.textDark,
        elevation: 0,
        toolbarHeight: 64,
        titleSpacing: 0,
        automaticallyImplyLeading: false,
        flexibleSpace: Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
          child: SafeArea(
            child: Row(
              children: [
                // Back button (added for better UX on a dedicated search page)
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textDark),
                  onPressed: () {
                    Get.back();
                  },
                ),
                const SizedBox(width: 8), // Spacing after back button
                Expanded(
                  child: Container(
                    height: 48,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.neutralBackground,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.lightPurple.withOpacity(0.5), width: 1),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.textDark.withOpacity(0.05),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _searchPageController,
                      focusNode: _searchFocusNode, // Assign the focus node
                      autofocus: false, // <-- REMOVED THIS CULPRIT!
                      onChanged: _onSearchInputChanged,
                      onSubmitted: (query) {
                        _addRecentSearch(query);
                        // Trigger actual search result display
                        FocusScope.of(context).unfocus(); // Dismiss keyboard
                      },
                      style: textTheme.bodyLarge?.copyWith(color: AppColors.textDark),
                      cursorColor: AppColors.primaryPurple,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Search for products...',
                        hintStyle: textTheme.bodyLarge?.copyWith(
                          color: AppColors.textLight,
                        ),
                        prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textLight),
                        suffixIcon: Obx(() => _showClearButton.value
                            ? IconButton(
                          icon: const Icon(Icons.clear_rounded, color: AppColors.textLight),
                          onPressed: () {
                            _searchPageController.clear();
                            _onSearchInputChanged('');
                          },
                        )
                            : IconButton(
                          icon: const Icon(Icons.mic_none_rounded, color: AppColors.textLight),
                          onPressed: () {
                            debugPrint('Microphone tapped');
                            // Implement voice search
                          },
                        )),
                        contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(top: 8.0, bottom: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Obx(() {
              if (_popularCategories.isEmpty) return const SizedBox.shrink();
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Text(
                      'Shop by Category',
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 90,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      itemCount: _popularCategories.length,
                      itemBuilder: (context, index) {
                        final category = _popularCategories[index];
                        return Padding(
                          padding: const EdgeInsets.only(right: 12.0),
                          child: GestureDetector(
                            onTap: () {
                              debugPrint('Tapped category: ${category['name']}');
                              _searchPageController.text = category['name'];
                              _onSearchInputChanged(category['name'] as String); // Cast to String
                              FocusScope.of(context).unfocus(); // Dismiss keyboard
                            },
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryPurple.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: AppColors.lightPurple.withOpacity(0.5)),
                                  ),
                                  child: Icon(category['icon'] as IconData,
                                      size: 30, color: AppColors.primaryPurple),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  category['name'] as String,
                                  textAlign: TextAlign.center,
                                  style: textTheme.labelMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textDark,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              );
            }),
            Obx(() {
              if (_recentSearches.isEmpty) return const SizedBox.shrink();
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      'Recent Searches',
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Wrap(
                      spacing: 8.0,
                      runSpacing: 8.0,
                      children: _recentSearches.map((search) => Chip(
                        onDeleted: () => _recentSearches.remove(search),
                        deleteIcon: const Icon(Icons.close, size: 18, color: AppColors.textLight),
                        label: Text(search),
                        labelStyle: textTheme.labelLarge?.copyWith(
                          color: AppColors.textDark,
                          fontWeight: FontWeight.w500,
                        ),
                        backgroundColor: AppColors.white,
                        side: BorderSide(color: AppColors.lightPurple.withOpacity(0.5), width: 1),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      )).toList(),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              );
            }),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Popular Products',
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 260,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                scrollDirection: Axis.horizontal,
                itemCount: 5,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  return Container(
                    width: 140,
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.textDark.withOpacity(0.06),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text('Product $index', style: textTheme.bodyMedium?.copyWith(color: AppColors.textLight)),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
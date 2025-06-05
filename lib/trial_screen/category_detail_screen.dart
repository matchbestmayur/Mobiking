/*
import 'package:flutter/material.dart';
import '../app/data/category_model.dart';
import '../app/data/sub_category_model.dart';
import '../app/services/category_service.dart';


class CategoryDetailScreen extends StatefulWidget {
  final String slug;

  const CategoryDetailScreen({super.key, required this.slug});

  @override
  State<CategoryDetailScreen> createState() => _CategoryDetailScreenState();
}

class _CategoryDetailScreenState extends State<CategoryDetailScreen> {
  late Future<Map<String, dynamic>> _future;

  @override
  void initState() {
    super.initState();
    _future = CategoryService.getCategoryDetails(widget.slug);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Category Details')),
        body: FutureBuilder<Map<String, dynamic>>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            final data = snapshot.data;
            if (data == null || data['category'] == null) {
              return const Center(child: Text('No category data found.'));
            }

            final category = data['category'] as CategoryModel;
            final subCategories = data['subCategories'] as List<SubCategoryModel>;

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(category.name, style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 10),
                category.photos.isNotEmpty
                    ? Image.network(category.photos.first)
                    : const SizedBox.shrink(),
                const SizedBox(height: 10),
                ...subCategories.map((subCat) => ListTile(
                  leading: Image(image: NetworkImage(subCat.photos.first)),
                  title: Text(subCat.name),
                  subtitle: Text('${subCat.products?.length ?? 0} Products'),
                )),
              ],
            );
          },
        )

    );
  }
}
*/

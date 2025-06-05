import 'package:get/get.dart';
import '../data/category_model.dart';
import '../services/category_service.dart';

class CategoryController extends GetxController {

  @override
  void onInit() {
    super.onInit();
    fetchCategories();
  }

  final CategoryService _service = CategoryService();

  var categories = <CategoryModel>[].obs;
  var selectedCategory = Rxn<CategoryModel>(); // for category details
  var isLoading = false.obs;

  // Fetch all categories
  Future<void> fetchCategories() async {
    try {
      isLoading.value = true;
      print('Fetching categories...');
      final List<CategoryModel> response = await _service.getCategories();
      print('Fetched categories count: ${response.length}');
      categories.assignAll(response);
    } catch (e) {
      Get.snackbar('Error', e.toString());
      print('Error in fetchCategories: $e');
    } finally {
      isLoading.value = false;
    }
  }


  Future<void> fetchCategoryDetails(String slug) async {
    try {
      isLoading.value = true;
      final response = await CategoryService.getCategoryDetails(slug);
      selectedCategory.value = response['category'] as CategoryModel;
      // OR if you want to be safe:
      // selectedCategory.value = CategoryModel.fromJson(response['category']);
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }
}

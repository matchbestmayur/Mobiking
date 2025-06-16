import 'package:get/get.dart';
import '../data/sub_category_model.dart';
import '../data/product_model.dart'; 
import '../services/sub_category_service.dart';

class SubCategoryController extends GetxController {
  final SubCategoryService _service = SubCategoryService();

  var subCategories = <SubCategory>[].obs;
  var allProducts = <ProductModel>[].obs;  
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadSubCategories();

    
    
    ever(subCategories, (_) {
      _updateAllProducts();
    });
  }

  Future<void> loadSubCategories() async {
    try {
      isLoading.value = true;
      final data = await _service.fetchSubCategories();
      print("Fetched data count: ${data.length}");

      subCategories.assignAll(data);
      _updateAllProducts(); 

      print("Subcategories fetched:");
      for (var sub in data) {
        print(" - ${sub.name} (${sub.id})");
      }
    } catch (e, stackTrace) {
      print('❌ Error fetching subcategories: $e');
      print(stackTrace);
      Get.snackbar('Error', 'Failed to fetch subcategories: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addSubCategory(SubCategory model) async {
    try {
      isLoading.value = true;
      final newItem = await _service.createSubCategory(model);
      subCategories.add(newItem);

      _updateAllProducts(); 
      print("Total products: ${allProducts.length}");

      print("✅ Subcategory added: ${newItem.name} (${newItem.id})");
    } catch (e) {
      Get.snackbar('Error', 'Failed to add subcategory: ${e.toString()}');
      print('❌ Error adding subcategory: $e');
    } finally {
      isLoading.value = false;
    }
  }

  
  void _updateAllProducts() {
    final combined = subCategories.expand((subCat) => subCat.products).toList();
    allProducts.assignAll(combined);
    print('🔄 Updated allProducts list with ${allProducts.length} products');
  }
}

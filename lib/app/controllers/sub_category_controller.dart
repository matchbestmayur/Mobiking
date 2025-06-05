import 'package:get/get.dart';
import '../data/sub_category_model.dart';
import '../services/sub_category_service.dart';

class SubCategoryController extends GetxController {
  final SubCategoryService _service = SubCategoryService();
  var subCategories = <SubCategoryModel>[].obs;
  var isLoading = false.obs;

  Future<void> loadSubCategories() async {
    try {
      isLoading.value = true;
      final data = await _service.fetchSubCategories();
      subCategories.assignAll(data);
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addSubCategory(SubCategoryModel model) async {
    try {
      isLoading.value = true;
      final newItem = await _service.createSubCategory(model);
      subCategories.add(newItem);
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }
}

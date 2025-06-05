import 'package:dio/dio.dart';

import '../data/sub_category_model.dart';


class SubCategoryService {
 /* final Dio _dio = Dio(BaseOptions(baseUrl: 'http://your-api-url.com'));*/

  Dio _dio;

  SubCategoryService() : _dio = Dio(BaseOptions(baseUrl: 'http://your-api-url.com'));

  // For testing purposes
  void overrideDio(Dio dio) {
    _dio = dio;
  }


  Future<List<SubCategoryModel>> fetchSubCategories() async {
    try {
      final response = await _dio.get('/subcategories');
      return (response.data as List)
          .map((e) => SubCategoryModel.fromJson(e))
          .toList();
    } catch (e) {
      throw Exception('Error fetching subcategories: $e');
    }
  }

  Future<SubCategoryModel> createSubCategory(SubCategoryModel model) async {
    try {
      final response = await _dio.post('/subcategories', data: model.toJson());
      return SubCategoryModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Error creating subcategory: $e');
    }
  }
}

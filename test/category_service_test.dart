import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';
import 'package:mobiking/app/services/category_service.dart';
import 'package:mockito/mockito.dart';
import 'mocks.mocks.dart';
import 'mocks.mocks.mocks.dart';

void main() {
  group('CategoryService', () {
    late MockDio mockDio;
    late CategoryService categoryService;

    setUp(() {
      mockDio = MockDio();
      categoryService = CategoryService();
      categoryService.overrideDio(mockDio); // Assuming you allow override for testing
    });

    test('returns categories from API', () async {
      final dummyData = [
        {
          "_id": "123",
          "name": "Electronics",
          "active": true,
          "subCategories": ["sub1", "sub2"]
        },
        {
          "_id": "124",
          "name": "Fashion",
          "active": true,
          "subCategories": []
        },
      ];

      when(mockDio.get('/categories')).thenAnswer(
            (_) async => Response(
          data: dummyData,
          statusCode: 200,
          requestOptions: RequestOptions(path: '/categories'),
        ),
      );

      final result = await categoryService.getCategories();

      expect(result.length, 2);
      expect(result[0].name, 'Electronics');
      expect(result[1].name, 'Fashion');
    });
  });
}

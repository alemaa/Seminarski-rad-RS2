import '../models/product.dart';
import 'base_provider.dart';

class ProductProvider extends BaseProvider<Product> {
  ProductProvider() : super('api/Products');

  @override
  Product fromJson(data) {
    return Product.fromJson(data);
  }

  Future<List<Product>> search({String? nameFTS, int? categoryId}) async {
    final filter = <String, dynamic>{};

    if (nameFTS != null && nameFTS.isNotEmpty) {
      filter['nameFTS'] = nameFTS;
    }

    if (categoryId != null) {
      filter['categoryId'] = categoryId;
    }

    final result = await get(filter: filter);
    return result.result;
  }
}

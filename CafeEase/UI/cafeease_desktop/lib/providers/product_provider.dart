import '../models/product.dart';
import 'base_provider.dart';

class ProductProvider extends BaseProvider<Product> {
  ProductProvider() : super('api/Products');

  @override
  Product fromJson(data) {
    return Product.fromJson(data);
  }
}

import '../models/product.dart';
import 'base_provider.dart';

class RecommendationProvider extends BaseProvider<Product> {
  RecommendationProvider() : super("Recommendations");

  @override
  Product fromJson(data) {
    return Product.fromJson(data as Map<String, dynamic>);
  }

  Future<void> train() async {
    await postCustom("Recommendations/train");
  }

  Future<void> clear() async {
    await deleteCustom("Recommendations/clear");
  }

  Future<List<Product>> getRecommended(int productId) async {
    final response = await getCustom("Recommendations/$productId/recommended");

    if (response == null) return [];

    final list = (response as List).cast<dynamic>();
    return list
        .map((e) => Product.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}

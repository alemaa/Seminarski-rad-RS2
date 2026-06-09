import 'base_provider.dart';
import '../models/recommended_product.dart';

class RecommendationProvider extends BaseProvider<RecommendedProduct> {
  RecommendationProvider() : super("Recommendations");

  @override
  RecommendedProduct fromJson(data) {
    return RecommendedProduct.fromJson(data as Map<String, dynamic>);
  }

  Future<List<RecommendedProduct>> getRecommended(int productId) async {
    final response = await getCustom("Recommendations/$productId/recommended");

    if (response == null) return [];

    final list = (response as List).cast<dynamic>();
    return list
        .map((e) => RecommendedProduct.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}

import '../models/promotion.dart';
import 'base_provider.dart';

class PromotionProvider extends BaseProvider<Promotion> {
  PromotionProvider() : super('api/Promotions');

  @override
  Promotion fromJson(data) => Promotion.fromJson(data);
}

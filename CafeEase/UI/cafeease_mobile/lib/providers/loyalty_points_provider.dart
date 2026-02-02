import '../models/loyalty_points.dart';
import 'base_provider.dart';

class LoyaltyPointsProvider extends BaseProvider<LoyaltyPoints> {
  LoyaltyPointsProvider() : super("api/LoyaltyPoints");

  @override
  LoyaltyPoints fromJson(data) {
    return LoyaltyPoints.fromJson(data);
  }
}

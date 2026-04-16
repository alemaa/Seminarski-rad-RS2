import '../models/cafe.dart';
import 'base_provider.dart';

class CafeProvider extends BaseProvider<Cafe> {
  CafeProvider() : super("api/Cafes");

  @override
  Cafe fromJson(data) => Cafe.fromJson(data);

  Future<List<Cafe>> getNearby(double latitude, double longitude) async {
    final data = await getCustom(
      "api/Cafes/nearby?latitude=$latitude&longitude=$longitude",
    );

    if (data == null) {
      return [];
    }

    return (data as List).map((e) => Cafe.fromJson(e)).toList();
  }
}

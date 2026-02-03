import '../models/city.dart';
import '../models/search_result.dart';
import 'base_provider.dart';

class CityProvider extends BaseProvider<City> {
  CityProvider() : super("api/Cities");

  @override
  City fromJson(data) => City.fromJson(data);

  Future<SearchResult<City>> getCities() async {
    return await get();
  }
}

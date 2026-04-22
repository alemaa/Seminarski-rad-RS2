import '../models/cafe.dart';
import 'base_provider.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class CafeProvider extends BaseProvider<Cafe> {
  CafeProvider() : super("api/Cafes");

  @override
  Cafe fromJson(data) => Cafe.fromJson(data);

  Future<Map<String, dynamic>> geocode(String address, String city) async {
    var uri = Uri.parse(
      '${BaseProvider.baseUrl}api/Cafes/geocode',
    ).replace(queryParameters: {'address': address, 'city': city});

    var headers = createHeaders();

    var response = await http.get(uri, headers: headers);

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }

    if (response.statusCode == 404) {
      throw Exception('Coordinates not found');
    }

    if (response.statusCode == 401) {
      throw Exception('Unauthorized');
    }

    throw Exception('Failed to load coordinates (${response.statusCode})');
  }
}

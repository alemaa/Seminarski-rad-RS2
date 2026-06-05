import '../models/user.dart';
import 'base_provider.dart';
import '../utils/util.dart';
import '../models/user_insert_request.dart';
import '../models/user_update_request.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class UserProvider extends BaseProvider<User> {
  UserProvider() : super("api/Users");

  @override
  User fromJson(data) => User.fromJson(data as Map<String, dynamic>);
  Future<User> getCurrentUser() async {
    final id = Authorization.userId;
    if (id == null) {
      throw Exception("Something went wrong after login. Please try again.");
    }
    return await getById(id);
  }

  Future<void> updateUserVoid(int id, UserUpdateRequest request) async {
    await updateVoid(id, request.toJson());
  }

  Future<User> createUser(UserInsertRequest request) async {
    final uri = Uri.parse('${BaseProvider.baseUrl}api/Users/register');

    final response = await http.post(
      uri,
      headers: createHeaders(),
      body: jsonEncode(request.toJson()),
    );

    isValidResponse(response);

    final data = jsonDecode(utf8.decode(response.bodyBytes));
    return fromJson(data);
  }

  Future<void> deleteUser(int id) async {
    await delete(id);
  }
}

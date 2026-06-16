import '../models/user.dart';
import 'base_provider.dart';
import '../models/user_insert_request.dart';
import '../models/user_update_request.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class UserProvider extends BaseProvider<User> {
  UserProvider() : super("api/Users");

  @override
  User fromJson(data) => User.fromJson(data as Map<String, dynamic>);

  Future<User> getCurrentUser() async {
    final data = await getCustom("api/Users/me");
    return User.fromJson(data);
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

  Future<void> changePassword(Map<String, dynamic> request) async {
    final uri = Uri.parse("${BaseProvider.baseUrl}api/Users/change-password");

    final response = await http.post(
      uri,
      headers: createHeaders(),
      body: jsonEncode(request),
    );

    isValidResponse(response);
  }

  Future<User> updateCurrentUser(UserUpdateRequest request) async {
    final uri = Uri.parse('${BaseProvider.baseUrl}api/Users/me');

    final response = await http.put(
      uri,
      headers: createHeaders(),
      body: jsonEncode(request.toJson()),
    );

    isValidResponse(response);

    return User.fromJson(
      jsonDecode(utf8.decode(response.bodyBytes)),
    );
  }

  Future<void> deleteCurrentUser() async {
    await deleteCustom('api/Users/me');
  }
}

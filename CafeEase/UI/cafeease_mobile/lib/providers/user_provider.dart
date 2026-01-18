import '../models/user.dart';
import 'base_provider.dart';
import '../utils/util.dart';
import '../models/user_insert_request.dart';
import '../models/user_update_request.dart';

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
    final response = await insert(request.toJson());
    return response;
  }

  Future<void> deleteUser(int id) async {
    await delete(id);
  }
}

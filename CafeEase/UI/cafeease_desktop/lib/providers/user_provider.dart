import 'package:cafeease_desktop/models/user.dart';

import 'base_provider.dart';

class UserProvider extends BaseProvider<User> {
  UserProvider() : super('api/Users');

  @override
  User fromJson(data) {
    return User.fromJson(data);
  }
}

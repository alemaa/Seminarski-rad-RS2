import 'package:json_annotation/json_annotation.dart';
import 'role.dart';

part 'user.g.dart';

@JsonSerializable()
class User {
  final int id;
  final String? firstName;
  final String? lastName;
  final String? username;
  final String? email;
  final int roleId;
  final Role? role;
  int? cityId;

  User({
    required this.id,
    this.firstName,
    this.lastName,
    this.username,
    this.email,
    required this.roleId,
    this.role,
    this.cityId,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  Map<String, dynamic> toJson() => _$UserToJson(this);
}

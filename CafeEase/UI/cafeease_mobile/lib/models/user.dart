import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

@JsonSerializable()
class User {
  int? id;
  String? firstName;
  String? lastName;
  String? username;
  String? email;
  int? roleId;
  int? cityId;

  User({
    this.id,
    this.firstName,
    this.lastName,
    this.username,
    this.email,
    this.roleId,
    this.cityId,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  Map<String, dynamic> toJson() => _$UserToJson(this);
}

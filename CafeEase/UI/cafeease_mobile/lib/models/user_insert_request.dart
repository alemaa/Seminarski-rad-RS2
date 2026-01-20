import 'package:json_annotation/json_annotation.dart';

part 'user_insert_request.g.dart';

@JsonSerializable()
class UserInsertRequest {
  String? firstName;
  String? lastName;
  String? email;
  String? username;
  String? password;
  String? passwordConfirmation;
  int? roleId;
  int? cityId;

  UserInsertRequest({
    this.firstName,
    this.lastName,
    this.email,
    this.username,
    this.password,
    this.passwordConfirmation,
    this.roleId,
    this.cityId
  });

  factory UserInsertRequest.fromJson(Map<String, dynamic> json) =>
      _$UserInsertRequestFromJson(json);

  Map<String, dynamic> toJson() => _$UserInsertRequestToJson(this);
}

import 'package:json_annotation/json_annotation.dart';
part 'user_update_request.g.dart';

@JsonSerializable()
class UserUpdateRequest {
  String? firstName;
  String? lastName;
  String? email;
  String? username;
  int? roleId;

  UserUpdateRequest(
      {this.firstName, this.lastName, this.email, this.username, this.roleId});

  factory UserUpdateRequest.fromJson(Map<String, dynamic> json) =>
      _$UserUpdateRequestFromJson(json);

  Map<String, dynamic> toJson() => _$UserUpdateRequestToJson(this);
}

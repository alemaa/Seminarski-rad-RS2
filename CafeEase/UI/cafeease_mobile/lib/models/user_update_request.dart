import 'package:json_annotation/json_annotation.dart';
part 'user_update_request.g.dart';

@JsonSerializable()
class UserUpdateRequest {
  String? firstName;
  String? lastName;
  String? email;
  String? username;
  int? roleId;
  int? cityId;

  UserUpdateRequest(
      {this.firstName, this.lastName, this.email, this.username, this.roleId,this.cityId});

  factory UserUpdateRequest.fromJson(Map<String, dynamic> json) =>
      _$UserUpdateRequestFromJson(json);

  Map<String, dynamic> toJson() => _$UserUpdateRequestToJson(this);
}

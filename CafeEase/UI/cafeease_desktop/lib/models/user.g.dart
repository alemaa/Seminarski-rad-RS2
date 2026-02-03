// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) => User(
  id: (json['id'] as num).toInt(),
  firstName: json['firstName'] as String?,
  lastName: json['lastName'] as String?,
  username: json['username'] as String?,
  email: json['email'] as String?,
  roleId: (json['roleId'] as num).toInt(),
  role: json['role'] == null
      ? null
      : Role.fromJson(json['role'] as Map<String, dynamic>),
  cityId: (json['cityId'] as num?)?.toInt(),
);

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
  'id': instance.id,
  'firstName': instance.firstName,
  'lastName': instance.lastName,
  'username': instance.username,
  'email': instance.email,
  'roleId': instance.roleId,
  'role': instance.role,
  'cityId': instance.cityId,
};

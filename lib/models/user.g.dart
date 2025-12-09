// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) => User(
  id: json['id'] as String,
  email: json['email'] as String,
  firstName: json['firstName'] as String?,
  lastName: json['lastName'] as String?,
  name: json['name'] as String?,
  phone: json['phone'] as String?,
  avatar: json['avatar'] as String?,
  language: json['language'] as String?,
  country: json['country'] as String?,
  role: json['role'] as String,
  phoneNumber: json['phoneNumber'] as String?,
  avatarUrl: json['avatarUrl'] as String?,
  preferredLanguage: json['preferredLanguage'] as String?,
  isActive: json['isActive'] as bool? ?? true,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
  'id': instance.id,
  'email': instance.email,
  'firstName': instance.firstName,
  'lastName': instance.lastName,
  'name': instance.name,
  'phone': instance.phone,
  'avatar': instance.avatar,
  'language': instance.language,
  'country': instance.country,
  'role': instance.role,
  'phoneNumber': instance.phoneNumber,
  'avatarUrl': instance.avatarUrl,
  'preferredLanguage': instance.preferredLanguage,
  'isActive': instance.isActive,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt?.toIso8601String(),
};

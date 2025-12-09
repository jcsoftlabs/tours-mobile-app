// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'site.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Site _$SiteFromJson(Map<String, dynamic> json) => Site(
  id: json['id'] as String,
  name: json['name'] as String,
  description: json['description'] as String,
  type: json['type'] as String,
  images: (json['images'] as List<dynamic>).map((e) => e as String).toList(),
  address: json['address'] as String,
  ville: json['ville'] as String?,
  departement: json['departement'] as String?,
  phone: json['phone'] as String?,
  email: json['email'] as String?,
  website: json['website'] as String?,
  latitude: (json['latitude'] as num).toDouble(),
  longitude: (json['longitude'] as num).toDouble(),
  amenities: (json['amenities'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  schedule: json['schedule'] as Map<String, dynamic>?,
  pricing: json['pricing'] as Map<String, dynamic>?,
  isActive: json['isActive'] as bool,
  partnerId: json['partnerId'] as String?,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$SiteToJson(Site instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'description': instance.description,
  'type': instance.type,
  'images': instance.images,
  'address': instance.address,
  'ville': instance.ville,
  'departement': instance.departement,
  'phone': instance.phone,
  'email': instance.email,
  'website': instance.website,
  'latitude': instance.latitude,
  'longitude': instance.longitude,
  'amenities': instance.amenities,
  'schedule': instance.schedule,
  'pricing': instance.pricing,
  'isActive': instance.isActive,
  'partnerId': instance.partnerId,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
};

SiteResponse _$SiteResponseFromJson(Map<String, dynamic> json) => SiteResponse(
  success: json['success'] as bool,
  message: json['message'] as String,
  data: (json['data'] as List<dynamic>)
      .map((e) => Site.fromJson(e as Map<String, dynamic>))
      .toList(),
  totalCount: (json['totalCount'] as num?)?.toInt(),
  currentPage: (json['currentPage'] as num?)?.toInt(),
  totalPages: (json['totalPages'] as num?)?.toInt(),
);

Map<String, dynamic> _$SiteResponseToJson(SiteResponse instance) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
      'data': instance.data,
      'totalCount': instance.totalCount,
      'currentPage': instance.currentPage,
      'totalPages': instance.totalPages,
    };

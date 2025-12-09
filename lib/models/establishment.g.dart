// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'establishment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Establishment _$EstablishmentFromJson(Map<String, dynamic> json) =>
    Establishment(
      id: json['id'] as String,
      name: json['name'] as String,
      type: json['type'] as String,
      categoryId: json['categoryId'] as String,
      address: json['address'] as String,
      ville: json['ville'] as String?,
      departement: json['departement'] as String?,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      phoneNumber: json['phoneNumber'] as String?,
      website: json['website'] as String?,
      email: json['email'] as String?,
      rating: (json['rating'] as num?)?.toDouble(),
      reviewCount: (json['reviewCount'] as num?)?.toInt(),
      description: json['description'] as String?,
      images: (json['images'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      openingHours: json['openingHours'] as Map<String, dynamic>?,
      amenities: (json['amenities'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      priceRange: json['priceRange'] as String?,
      isOpen: json['isOpen'] as bool?,
      distance: (json['distance'] as num?)?.toDouble(),
      reviews: (json['reviews'] as List<dynamic>?)
          ?.map((e) => Review.fromJson(e as Map<String, dynamic>))
          .toList(),
      promotions: (json['promotions'] as List<dynamic>?)
          ?.map((e) => Promotion.fromJson(e as Map<String, dynamic>))
          .toList(),
      isFavorite: json['isFavorite'] as bool? ?? false,
    );

Map<String, dynamic> _$EstablishmentToJson(Establishment instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'type': instance.type,
      'categoryId': instance.categoryId,
      'address': instance.address,
      'ville': instance.ville,
      'departement': instance.departement,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'phoneNumber': instance.phoneNumber,
      'website': instance.website,
      'email': instance.email,
      'rating': instance.rating,
      'reviewCount': instance.reviewCount,
      'description': instance.description,
      'images': instance.images,
      'openingHours': instance.openingHours,
      'amenities': instance.amenities,
      'priceRange': instance.priceRange,
      'isOpen': instance.isOpen,
      'distance': instance.distance,
      'reviews': instance.reviews,
      'promotions': instance.promotions,
      'isFavorite': instance.isFavorite,
    };

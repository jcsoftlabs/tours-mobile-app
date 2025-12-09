import 'package:json_annotation/json_annotation.dart';

part 'site.g.dart';

@JsonSerializable()
class Site {
  final String id;
  final String name;
  final String description;
  final String type;
  final List<String> images;
  final String address;
  final String? ville;
  final String? departement;
  final String? phone;
  final String? email;
  final String? website;
  final double latitude;
  final double longitude;
  final List<String> amenities;
  final Map<String, dynamic>? schedule;
  final Map<String, dynamic>? pricing;
  final bool isActive;
  final String? partnerId;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Site({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.images,
    required this.address,
    this.ville,
    this.departement,
    this.phone,
    this.email,
    this.website,
    required this.latitude,
    required this.longitude,
    required this.amenities,
    this.schedule,
    this.pricing,
    required this.isActive,
    this.partnerId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Site.fromJson(Map<String, dynamic> json) => _$SiteFromJson(json);

  Map<String, dynamic> toJson() => _$SiteToJson(this);

  Site copyWith({
    String? id,
    String? name,
    String? description,
    String? type,
    List<String>? images,
    String? address,
    String? ville,
    String? departement,
    String? phone,
    String? email,
    String? website,
    double? latitude,
    double? longitude,
    List<String>? amenities,
    Map<String, dynamic>? schedule,
    Map<String, dynamic>? pricing,
    bool? isActive,
    String? partnerId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Site(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      type: type ?? this.type,
      images: images ?? this.images,
      address: address ?? this.address,
      ville: ville ?? this.ville,
      departement: departement ?? this.departement,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      website: website ?? this.website,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      amenities: amenities ?? this.amenities,
      schedule: schedule ?? this.schedule,
      pricing: pricing ?? this.pricing,
      isActive: isActive ?? this.isActive,
      partnerId: partnerId ?? this.partnerId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

@JsonSerializable()
class SiteResponse {
  final bool success;
  final String message;
  final List<Site> data;
  final int? totalCount;
  final int? currentPage;
  final int? totalPages;

  const SiteResponse({
    required this.success,
    required this.message,
    required this.data,
    this.totalCount,
    this.currentPage,
    this.totalPages,
  });

  factory SiteResponse.fromJson(Map<String, dynamic> json) => _$SiteResponseFromJson(json);

  Map<String, dynamic> toJson() => _$SiteResponseToJson(this);
}
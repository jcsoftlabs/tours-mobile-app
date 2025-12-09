import 'package:json_annotation/json_annotation.dart';
import 'review.dart';
import 'promotion.dart';

part 'establishment.g.dart';

@JsonSerializable()
class Establishment {
  final String id;
  final String name;
  final String type;
  final String categoryId;
  final String address;
  final String? ville;
  final String? departement;
  final double latitude;
  final double longitude;
  final String? phoneNumber;
  final String? website;
  final String? email;
  final double? rating;
  final int? reviewCount;
  final String? description;
  final List<String>? images;
  final Map<String, dynamic>? openingHours;
  final List<String>? amenities;
  final String? priceRange; // €, €€, €€€
  final bool? isOpen;
  final double? distance;
  final List<Review>? reviews;
  final List<Promotion>? promotions;
  final bool isFavorite;

  const Establishment({
    required this.id,
    required this.name,
    required this.type,
    required this.categoryId,
    required this.address,
    this.ville,
    this.departement,
    required this.latitude,
    required this.longitude,
    this.phoneNumber,
    this.website,
    this.email,
    this.rating,
    this.reviewCount,
    this.description,
    this.images,
    this.openingHours,
    this.amenities,
    this.priceRange,
    this.isOpen,
    this.distance,
    this.reviews,
    this.promotions,
    this.isFavorite = false,
  });

  factory Establishment.fromJson(Map<String, dynamic> json) =>
      _$EstablishmentFromJson(json);

  Map<String, dynamic> toJson() => _$EstablishmentToJson(this);

  Establishment copyWith({
    String? id,
    String? name,
    String? type,
    String? categoryId,
    String? address,
    String? ville,
    String? departement,
    double? latitude,
    double? longitude,
    String? phoneNumber,
    String? website,
    String? email,
    double? rating,
    int? reviewCount,
    String? description,
    List<String>? images,
    Map<String, dynamic>? openingHours,
    List<String>? amenities,
    String? priceRange,
    bool? isOpen,
    double? distance,
    List<Review>? reviews,
    List<Promotion>? promotions,
    bool? isFavorite,
  }) {
    return Establishment(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      categoryId: categoryId ?? this.categoryId,
      address: address ?? this.address,
      ville: ville ?? this.ville,
      departement: departement ?? this.departement,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      website: website ?? this.website,
      email: email ?? this.email,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      description: description ?? this.description,
      images: images ?? this.images,
      openingHours: openingHours ?? this.openingHours,
      amenities: amenities ?? this.amenities,
      priceRange: priceRange ?? this.priceRange,
      isOpen: isOpen ?? this.isOpen,
      distance: distance ?? this.distance,
      reviews: reviews ?? this.reviews,
      promotions: promotions ?? this.promotions,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  List<Promotion> get activePromotions {
    return promotions?.where((promo) => promo.isValid).toList() ?? [];
  }

  String get formattedRating {
    if (rating == null) return 'N/A';
    return rating!.toStringAsFixed(1);
  }

  String get formattedDistance {
    if (distance == null) return '';
    if (distance! < 1) {
      return '${(distance! * 1000).toInt()}m';
    }
    return '${distance!.toStringAsFixed(1)}km';
  }

  /// Formate le prix pour un affichage convivial
  String get formattedPrice {
    if (priceRange == null || priceRange!.isEmpty) return '';
    
    // Pour les hôtels, afficher "À partir de X$/Jour"
    if (type.toUpperCase() == 'HOTEL') {
      // Convertir € en $ (approximation simple)
      final euroCount = priceRange!.replaceAll(RegExp(r'[^€]'), '').length;
      final priceEstimate = euroCount * 50; // €: 50$, €€: 100$, €€€: 150$, etc.
      return 'À partir de $priceEstimate\$/Jour';
    }
    
    // Pour les autres types, remplacer € par $
    return priceRange!.replaceAll('€', '\$');
  }
}

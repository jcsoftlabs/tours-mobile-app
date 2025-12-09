import '../models/establishment.dart';
import '../models/review.dart';
import '../models/promotion.dart';
import '../core/network/api_service.dart';
import '../core/constants/api_constants.dart';

class EstablishmentService {
  final ApiService _apiService = ApiService();

  /// Récupère les détails complets d'un établissement
  Future<Establishment> getEstablishmentDetails(String establishmentId) async {
    try {
      final response = await _apiService.get(
        ApiConstants.establishmentById(establishmentId),
      );

      if (response.statusCode == 200) {
        final json = response.data['data'] ?? response.data;
        return _convertToAppEstablishment(json);
      } else {
        throw Exception('Erreur HTTP: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur lors du chargement des détails: $e');
    }
  }

  /// Récupère les avis d'un établissement
  Future<List<Review>> getEstablishmentReviews(String establishmentId) async {
    try {
      final response = await _apiService.get(
        ApiConstants.reviewsByEstablishment(establishmentId),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'] ?? response.data;
        return data.map((json) => Review.fromJson(json)).toList();
      } else {
        throw Exception('Erreur HTTP: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur lors du chargement des avis: $e');
    }
  }

  /// Récupère les promotions actives d'un établissement
  Future<List<Promotion>> getActivePromotions(String establishmentId) async {
    try {
      final response = await _apiService.get(
        '${ApiConstants.establishmentById(establishmentId)}/promotions',
        queryParameters: {'active': 'true'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'] ?? response.data;
        return data.map((json) => Promotion.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      // Ne pas faire échouer si les promotions ne sont pas disponibles
      return [];
    }
  }

  /// Convertit un établissement du backend vers le modèle de l'app
  Establishment _convertToAppEstablishment(Map<String, dynamic> json) {
    print('DEBUG EstablishmentService: Converting establishment - type: ${json['type']}, name: ${json['name']}');
    // Récupérer les avis si disponibles
    List<Review>? reviews;
    if (json['reviews'] != null) {
      final reviewsData = json['reviews'] as List;
      reviews = reviewsData.map((reviewJson) {
        return Review(
          id: reviewJson['id']?.toString() ?? '',
          userId: reviewJson['userId']?.toString() ?? '',
          userName: reviewJson['user']?['firstName'] ?? 'Utilisateur',
          userAvatar: reviewJson['user']?['avatar'] ?? '',
          establishmentId: json['id']?.toString() ?? '',
          rating: _parsePrice(reviewJson['rating'])?.toInt() ?? 0,
          comment: reviewJson['comment'] ?? '',
          createdAt: DateTime.tryParse(reviewJson['createdAt'] ?? '') ?? DateTime.now(),
          images: _parseStringList(reviewJson['images']),
        );
      }).toList();
    }

    // Récupérer les promotions si disponibles
    List<Promotion>? promotions;
    if (json['promotions'] != null) {
      final promotionsData = json['promotions'] as List;
      promotions = promotionsData.map((promoJson) {
        return Promotion(
          id: promoJson['id']?.toString() ?? '',
          title: promoJson['title'] ?? '',
          description: promoJson['description'] ?? '',
          image: promoJson['image'],
          discount: _parsePrice(promoJson['discount'])?.toDouble(),
          discountType: promoJson['discountType'],
          startDate: DateTime.tryParse(promoJson['startDate'] ?? '') ?? DateTime.now(),
          endDate: DateTime.tryParse(promoJson['endDate'] ?? '') ?? DateTime.now().add(const Duration(days: 30)),
          isActive: _safeParseBool(promoJson['isActive']) ?? false,
        );
      }).toList();
    }

    return Establishment(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      type: json['type'] ?? '',
      categoryId: _mapTypeToCategory(json['type']),
      address: json['address'] ?? '',
      latitude: _parseCoordinate(json['latitude']),
      longitude: _parseCoordinate(json['longitude']),
      phoneNumber: json['phoneNumber'],
      website: json['website'],
      email: json['email'],
      rating: _parsePrice(json['rating'])?.toDouble(),
      reviewCount: _safeParseInt(json['reviewCount']),
      description: json['description'],
      images: _parseStringList(json['images']),
      openingHours: json['openingHours'] is Map ? Map<String, dynamic>.from(json['openingHours']) : null,
      amenities: _parseStringList(json['amenities']),
      priceRange: _mapPriceRange(_parsePrice(json['price'])),
      isOpen: _safeParseBool(json['isOpen']),
      distance: _parsePrice(json['distance'])?.toDouble(),
      reviews: reviews,
      promotions: promotions,
      isFavorite: _safeParseBool(json['isFavorite']) ?? false,
    );
  }

  /// Mappe le type d'établissement vers une catégorie
  String _mapTypeToCategory(String? type) {
    switch (type?.toUpperCase()) {
      case 'HOTEL':
        return 'hotels';
      case 'RESTAURANT':
      case 'BAR':
      case 'CAFE':
        return 'restaurants';
      case 'ATTRACTION':
      case 'MUSEUM':
      case 'PARK':
      case 'MONUMENT':
      case 'SHOP':
        return 'tourism';
      case 'EVENT':
        return 'events';
      default:
        return 'tourism';
    }
  }

  /// Parse les coordonnées depuis String ou num vers double
  double _parseCoordinate(dynamic coordinate) {
    if (coordinate == null) return 0.0;
    
    if (coordinate is String) {
      return double.tryParse(coordinate) ?? 0.0;
    } else if (coordinate is num) {
      return coordinate.toDouble();
    }
    
    return 0.0;
  }

  /// Parse le prix depuis String ou num vers num?
  num? _parsePrice(dynamic price) {
    if (price == null) return null;
    
    if (price is String) {
      return double.tryParse(price);
    } else if (price is num) {
      return price;
    }
    
    return null;
  }

  /// Parse un entier de façon sécurisée
  int? _safeParseInt(dynamic value) {
    if (value == null) return null;
    
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    if (value is num) return value.toInt();
    
    return null;
  }

  /// Parse une liste de chaînes de façon sécurisée
  List<String>? _parseStringList(dynamic value) {
    if (value == null) return null;
    
    if (value is List) {
      return value.map((e) => e?.toString() ?? '').where((s) => s.isNotEmpty).toList();
    }
    
    return null;
  }

  /// Parse un booléen de façon sécurisée
  bool? _safeParseBool(dynamic value) {
    if (value == null) return null;
    
    if (value is bool) return value;
    if (value is String) {
      final lowerValue = value.toLowerCase();
      if (lowerValue == 'true') return true;
      if (lowerValue == 'false') return false;
    }
    if (value is int) return value != 0;
    
    return null;
  }

  /// Mappe le prix vers une gamme de prix
  String? _mapPriceRange(num? price) {
    if (price == null) return null;
    
    if (price < 50) return '€';
    if (price < 100) return '€€';
    return '€€€';
  }

  /// Récupère tous les établissements
  Future<List<Establishment>> getEstablishments() async {
    try {
      final response = await _apiService.get(ApiConstants.establishments);
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'] ?? response.data;
        return data.map((json) => _convertToAppEstablishment(json)).toList();
      } else {
        throw Exception('Erreur HTTP: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur lors de la récupération des établissements: $e');
    }
  }

  /// Récupère un établissement par son ID (alias pour getEstablishmentDetails)
  Future<Establishment> getEstablishment(String id) async {
    return getEstablishmentDetails(id);
  }

  /// Récupère les établissements par catégorie
  Future<List<Establishment>> getEstablishmentsByCategory(String categoryId) async {
    try {
      print('DEBUG: Recherche par catégorie: $categoryId');
      
      // Temporairement, récupérons tous les établissements
      // et filtrons côté client en attendant que l'API backend supporte le filtrage
      final response = await _apiService.get(ApiConstants.establishments);
      
      print('DEBUG: Response status: ${response.statusCode}');
      print('DEBUG: Response data keys: ${response.data?.keys}');
      
      if (response.statusCode == 200) {
        final responseData = response.data;
        List<dynamic> allData = [];
        
        if (responseData['success'] == true) {
          allData = responseData['data'] ?? [];
        } else {
          final data = responseData['data'] ?? responseData;
          if (data is List) {
            allData = data;
          }
        }
        
        print('DEBUG: Nombre total d\'établissements: ${allData.length}');
        
        // Filtrage côté client par type (les types du backend sont en MAJUSCULES)
        final filteredData = allData.where((json) {
          final type = json['type']?.toString().toUpperCase();
          print('DEBUG: Type établissement: $type pour ${json['name']}');
          
          switch (categoryId) {
            case 'hotels':
              return type == 'HOTEL';
            case 'restaurants':
              return ['RESTAURANT', 'BAR', 'CAFE'].contains(type);
            case 'tourism':
              return ['ATTRACTION', 'MUSEUM', 'PARK', 'MONUMENT', 'SHOP'].contains(type);
            case 'events':
              return type == 'EVENT';
            default:
              return true; // Si catégorie inconnue, retourner tous
          }
        }).toList();
        
        print('DEBUG: Après filtrage pour $categoryId: ${filteredData.length} établissements');
        
        return filteredData.map((json) => _convertToAppEstablishment(json)).toList();
      } else {
        throw Exception('Erreur HTTP: ${response.statusCode} - ${response.data}');
      }
    } catch (e) {
      print('DEBUG: Erreur complète: $e');
      throw Exception('Erreur lors de la récupération des établissements par catégorie: $e');
    }
  }
}

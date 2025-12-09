import '../models/establishment.dart';
import '../core/network/api_service.dart';
import '../core/constants/api_constants.dart';

class SearchService {
  final ApiService _apiService = ApiService();

  Future<List<Establishment>> searchEstablishments({
    String? query,
    String? categoryId,
    double? latitude,
    double? longitude,
    double? radius,
    String? sortBy,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final queryParameters = <String, dynamic>{
        if (query != null && query.isNotEmpty) 'search': query,
        if (categoryId != null) 'category': categoryId,
        if (latitude != null) 'lat': latitude.toString(),
        if (longitude != null) 'lng': longitude.toString(),
        if (radius != null) 'radius': radius.toString(),
        if (sortBy != null) 'sortBy': sortBy,
        'page': page.toString(),
        'limit': limit.toString(),
      };

      final response = await _apiService.get(
        ApiConstants.establishments,
        queryParameters: queryParameters,
      );

      if (response.statusCode == 200) {
        // Le backend retourne {success: true, data: [...], count: X}
        final responseData = response.data;
        if (responseData['success'] == true) {
          final List<dynamic> data = responseData['data'] ?? [];
          return data.map((json) => _convertToAppEstablishment(json)).toList();
        } else {
          throw Exception('Réponse API non valide');
        }
      } else {
        throw Exception('Erreur HTTP: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur lors de la recherche: $e');
    }
  }

  Future<List<Establishment>> getEstablishmentsByCategory(String categoryId) async {
    return searchEstablishments(categoryId: categoryId);
  }

  Future<List<Establishment>> getNearbyEstablishments({
    required double latitude,
    required double longitude,
    double radius = 5.0,
  }) async {
    return searchEstablishments(
      latitude: latitude,
      longitude: longitude,
      radius: radius,
    );
  }

  /// Convertit un établissement du backend vers le modèle de l'app
  Establishment _convertToAppEstablishment(Map<String, dynamic> json) {
    // Convertir latitude/longitude de string vers double si nécessaire
    double lat = 0.0;
    double lng = 0.0;
    
    if (json['latitude'] is String) {
      lat = double.tryParse(json['latitude']) ?? 0.0;
    } else if (json['latitude'] is num) {
      lat = (json['latitude'] as num).toDouble();
    }
    
    if (json['longitude'] is String) {
      lng = double.tryParse(json['longitude']) ?? 0.0;
    } else if (json['longitude'] is num) {
      lng = (json['longitude'] as num).toDouble();
    }
    
    // Convertir price de string vers num si nécessaire
    num? price;
    if (json['price'] is String) {
      price = double.tryParse(json['price']);
    } else if (json['price'] is num) {
      price = json['price'] as num;
    }
    
    return Establishment(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      type: json['type'] ?? '',
      categoryId: _mapTypeToCategory(json['type']),
      address: json['address'] ?? '',
      latitude: lat,
      longitude: lng,
      phoneNumber: json['phone'], // Le backend utilise 'phone' au lieu de 'phoneNumber'
      website: json['website'],
      email: json['email'],
      rating: _parseNumeric(json['rating'])?.toDouble(),
      reviewCount: json['_count']?['reviews'] as int?, // Le backend utilise '_count.reviews'
      description: json['description'],
      images: (json['images'] as List?)?.cast<String>(),
      amenities: (json['amenities'] as List?)?.cast<String>(),
      priceRange: _mapPriceRange(price),
      isOpen: json['isOpen'] as bool?,
      distance: (json['distance'] as num?)?.toDouble(),
      isFavorite: json['isFavorite'] as bool? ?? false,
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

  /// Parse une valeur numérique depuis String ou num
  num? _parseNumeric(dynamic value) {
    if (value == null) return null;
    
    if (value is String) {
      return double.tryParse(value);
    } else if (value is num) {
      return value;
    }
    
    return null;
  }

  /// Mappe le prix vers une gamme de prix
  String? _mapPriceRange(num? price) {
    if (price == null) return null;
    
    if (price < 50) return '€';
    if (price < 100) return '€€';
    return '€€€';
  }
}


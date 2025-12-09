import '../models/establishment.dart';
import '../core/network/api_service.dart';
import '../core/constants/api_constants.dart';
import 'auth_service.dart';

class FavoritesService {
  final ApiService _apiService = ApiService();
  final AuthService _authService = AuthService();
  
  // Cache local pour les favoris
  static final Set<String> _cachedFavoriteIds = <String>{};

  String? _getCurrentUserId() {
    return _authService.currentUser?.id;
  }

  Future<List<Establishment>> getFavorites({String? userId}) async {
    try {
      // Utiliser l'utilisateur connecté ou le userId fourni
      final currentUserId = _getCurrentUserId();
      if (currentUserId == null && userId == null) {
        throw Exception('Aucun utilisateur connecté');
      }
      final targetUserId = userId ?? currentUserId!;
      
      final response = await _apiService.get(
        '${ApiConstants.apiPath}/favorites/user/$targetUserId',
      );

      if (response.statusCode == 200) {
        print('DEBUG Favorites: Response data keys: ${response.data.keys}');
        final List<dynamic> data = response.data['data'] ?? response.data;
        print('DEBUG Favorites: Nombre de favoris reçus: ${data.length}');
        
        final favorites = <Establishment>[];
        for (int i = 0; i < data.length; i++) {
          try {
            final establishmentData = data[i]['establishment'] ?? data[i];
            print('DEBUG Favorites [$i]: Type = ${establishmentData['type']}, Name = ${establishmentData['name']}');
            final establishment = _convertToAppEstablishment(establishmentData);
            favorites.add(establishment);
          } catch (e) {
            print('DEBUG Favorites [$i]: Erreur lors de la conversion: $e');
            print('DEBUG Favorites [$i]: Données: ${data[i]}');
            // Continuer avec les autres établissements
          }
        }
        
        // Mettre à jour le cache
        _cachedFavoriteIds.clear();
        _cachedFavoriteIds.addAll(favorites.map((e) => e.id));
        
        return favorites;
      } else {
        throw Exception('Erreur HTTP: ${response.statusCode}');
      }
    } catch (e) {
      // En cas d'erreur (utilisateur n'existe pas, etc.), fonctionner en mode local
      print('Erreur lors du chargement des favoris (mode local activé): $e');
      return [];
    }
  }

  Future<bool> addToFavorites(String establishmentId, {String? userId}) async {
    // Utiliser l'utilisateur connecté ou le userId fourni
    final currentUserId = _getCurrentUserId();
    if (currentUserId == null && userId == null) {
      throw Exception('Aucun utilisateur connecté');
    }
    final targetUserId = userId ?? currentUserId!;
    
    final response = await _apiService.post(
      '${ApiConstants.apiPath}/favorites',
      data: {
        'userId': targetUserId,
        'establishmentId': establishmentId,
      },
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      _cachedFavoriteIds.add(establishmentId);
      return true;
    } else {
      throw Exception('Erreur HTTP: ${response.statusCode}');
    }
  }

  Future<bool> removeFromFavorites(String establishmentId, {String? userId}) async {
    // Utiliser l'utilisateur connecté ou le userId fourni
    final currentUserId = _getCurrentUserId();
    if (currentUserId == null && userId == null) {
      throw Exception('Aucun utilisateur connecté');
    }
    final targetUserId = userId ?? currentUserId!;
    
    final response = await _apiService.delete(
      '${ApiConstants.apiPath}/favorites/user/$targetUserId/establishment/$establishmentId',
    );

    if (response.statusCode == 200 || response.statusCode == 204) {
      _cachedFavoriteIds.remove(establishmentId);
      return true;
    } else {
      throw Exception('Erreur HTTP: ${response.statusCode}');
    }
  }

  Future<bool> isFavorite(String establishmentId, {String? userId}) async {
    try {
      // Vérifier d'abord dans le cache
      if (_cachedFavoriteIds.contains(establishmentId)) {
        return true;
      }

      // Utiliser l'utilisateur connecté ou le userId fourni
      final currentUserId = _getCurrentUserId();
      if (currentUserId == null && userId == null) {
        return false; // Pas d'utilisateur connecté, donc pas de favoris
      }
      final targetUserId = userId ?? currentUserId!;
      
      // Sinon, vérifier via l'API
      final response = await _apiService.get(
        '${ApiConstants.apiPath}/favorites/check',
        queryParameters: {
          'userId': targetUserId,
          'establishmentId': establishmentId,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data['data'];
        final isFav = data?['isFavorite'] ?? false;
        if (isFav) {
          _cachedFavoriteIds.add(establishmentId);
        }
        return isFav;
      }
      return false;
    } catch (e) {
      print('API favoris indisponible, mode local activé: $e');
      // En cas d'erreur, vérifier dans le cache local
      return _cachedFavoriteIds.contains(establishmentId);
    }
  }

  Future<bool> toggleFavorite(String establishmentId) async {
    try {
      final isFav = await isFavorite(establishmentId);
      if (isFav) {
        return await removeFromFavorites(establishmentId);
      } else {
        return await addToFavorites(establishmentId);
      }
    } catch (e) {
      throw Exception('Erreur lors du changement de favori: $e');
    }
  }

  /// Convertit un établissement du backend vers le modèle de l'app
  Establishment _convertToAppEstablishment(Map<String, dynamic> json) {
    // S'assurer que le type est bien une chaîne de caractères
    final typeString = json['type']?.toString() ?? '';
    
    return Establishment(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      type: typeString,
      categoryId: _mapTypeToCategory(typeString),
      address: json['address'] ?? '',
      latitude: _parseCoordinate(json['latitude']),
      longitude: _parseCoordinate(json['longitude']),
      phoneNumber: json['phoneNumber']?.toString(),
      website: json['website']?.toString(),
      email: json['email']?.toString(),
      rating: _parseNumeric(json['rating'])?.toDouble(),
      reviewCount: _safeParseInt(json['reviewCount']),
      description: json['description']?.toString(),
      images: _parseStringList(json['images']),
      amenities: _parseStringList(json['amenities']),
      priceRange: _mapPriceRange(_parseNumeric(json['price'])),
      isOpen: json['isOpen'] as bool?,
      distance: _parseNumeric(json['distance'])?.toDouble(),
      isFavorite: true, // Toujours vrai pour les favoris
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

  // Aliases pour compatibilité
  Future<void> addFavorite(String establishmentId) async {
    await addToFavorites(establishmentId);
  }

  Future<void> removeFavorite(String establishmentId) async {
    await removeFromFavorites(establishmentId);
  }

  Future<List<String>> getFavoriteIds() async {
    try {
      final favorites = await getFavorites();
      return favorites.map((e) => e.id).toList();
    } catch (e) {
      return _cachedFavoriteIds.toList();
    }
  }
}

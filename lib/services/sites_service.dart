import '../core/network/api_service.dart';
import '../core/constants/api_constants.dart';
import '../models/site.dart';
import 'location_service.dart';

class SitesService {
  final ApiService _apiService = ApiService();
  final LocationService _locationService = LocationService();

  // Helper methods for safe parsing
  String _safeParseString(dynamic value) {
    if (value == null) return '';
    return value.toString();
  }

  double _safeParseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      return double.tryParse(value) ?? 0.0;
    }
    return 0.0;
  }

  bool _safeParseBool(dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    if (value is String) {
      return value.toLowerCase() == 'true' || value == '1';
    }
    if (value is int) return value == 1;
    return false;
  }

  List<String> _parseStringList(dynamic value) {
    if (value == null) return [];
    if (value is List) {
      return value.map((item) => item.toString()).toList();
    }
    if (value is String) {
      try {
        // Try to parse as JSON array if it's a string
        return [value]; // If it's a simple string, wrap it in a list
      } catch (e) {
        return [value];
      }
    }
    return [];
  }

  Map<String, dynamic> _parseMap(dynamic value) {
    if (value == null) return {};
    if (value is Map<String, dynamic>) return value;
    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }
    return {};
  }

  DateTime _parseDateTime(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is String) {
      return DateTime.tryParse(value) ?? DateTime.now();
    }
    return DateTime.now();
  }

  // Parse Site from API response
  Site _parseSite(dynamic siteData, {double? userLatitude, double? userLongitude}) {
    final map = siteData as Map<String, dynamic>;
    
    // Calculer la distance si la position de l'utilisateur est fournie
    double? distance;
    final siteLat = _safeParseDouble(map['latitude']);
    final siteLon = _safeParseDouble(map['longitude']);
    
    if (userLatitude != null && userLongitude != null && siteLat != 0.0 && siteLon != 0.0) {
      distance = _locationService.calculateDistance(
        userLatitude, userLongitude,
        siteLat, siteLon,
      );
    } else if (map['distance'] != null) {
      distance = _safeParseDouble(map['distance']);
    }
    
    return Site(
      id: _safeParseString(map['id']),
      name: _safeParseString(map['name']),
      description: _safeParseString(map['description']),
      type: _safeParseString(map['type']),
      images: _parseStringList(map['images']),
      address: _safeParseString(map['address']),
      phone: map['phone']?.toString(),
      email: map['email']?.toString(),
      website: map['website']?.toString(),
      latitude: siteLat,
      longitude: siteLon,
      amenities: _parseStringList(map['amenities']),
      schedule: map['schedule'] != null ? _parseMap(map['schedule']) : null,
      pricing: map['pricing'] != null ? _parseMap(map['pricing']) : null,
      isActive: _safeParseBool(map['isActive']),
      partnerId: map['partnerId']?.toString(),
      createdAt: _parseDateTime(map['createdAt']),
      updatedAt: _parseDateTime(map['updatedAt']),
      distance: distance,
    );
  }

  // Récupérer tous les sites avec calcul de distance
  Future<List<Site>> getSites({
    int page = 1,
    int limit = 20,
    String? type,
    String? search,
    bool includeDistance = true,
  }) async {
    try {
      // Récupérer la position de l'utilisateur si demandé
      double? userLat;
      double? userLon;
      
      if (includeDistance) {
        final position = await _locationService.getCurrentLocation();
        if (position != null) {
          userLat = position.latitude;
          userLon = position.longitude;
        }
      }
      
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
      };
      
      if (type != null && type.isNotEmpty) {
        queryParams['type'] = type;
      }
      
      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }

      final response = await _apiService.get(
        ApiConstants.sites,
        queryParameters: queryParams,
      );

      print('Sites API Response: ${response.data}');

      if (response.data['success'] == true) {
        final sitesData = response.data['data'] as List;
        final sites = sitesData.map((siteData) => _parseSite(
          siteData,
          userLatitude: userLat,
          userLongitude: userLon,
        )).toList();
        
        // Trier par distance si disponible
        if (userLat != null && userLon != null) {
          sites.sort((a, b) {
            if (a.distance == null && b.distance == null) return 0;
            if (a.distance == null) return 1;
            if (b.distance == null) return -1;
            return a.distance!.compareTo(b.distance!);
          });
        }
        
        return sites;
      } else {
        throw Exception(response.data['error'] ?? 'Erreur lors du chargement des sites');
      }
    } catch (e) {
      print('Erreur getSites: $e');
      throw Exception('Erreur lors du chargement des sites: $e');
    }
  }

  // Récupérer un site par ID
  Future<Site> getSiteById(String id) async {
    try {
      final response = await _apiService.get(ApiConstants.siteById(id));

      if (response.data['success'] == true) {
        return _parseSite(response.data['data']);
      } else {
        throw Exception(response.data['error'] ?? 'Site non trouvé');
      }
    } catch (e) {
      throw Exception('Erreur lors du chargement du site: $e');
    }
  }

  // Récupérer les sites par type
  Future<List<Site>> getSitesByType(String type) async {
    return getSites(type: type);
  }

  // Rechercher des sites
  Future<List<Site>> searchSites(String query) async {
    return getSites(search: query);
  }

  // Récupérer les sites proches d'une position
  Future<List<Site>> getNearbySites({
    required double latitude,
    required double longitude,
    double radiusKm = 10.0,
  }) async {
    try {
      final response = await _apiService.get(
        '${ApiConstants.sites}/nearby',
        queryParameters: {
          'latitude': latitude,
          'longitude': longitude,
          'radius': radiusKm,
        },
      );

      if (response.data['success'] == true) {
        final sitesData = response.data['data'] as List;
        return sitesData.map((siteData) => _parseSite(siteData)).toList();
      } else {
        throw Exception(response.data['error'] ?? 'Erreur lors du chargement des sites à proximité');
      }
    } catch (e) {
      throw Exception('Erreur lors du chargement des sites à proximité: $e');
    }
  }
}
import 'package:geolocator/geolocator.dart';

class LocationService {
  static LocationService? _instance;
  LocationService._internal();
  
  factory LocationService() {
    _instance ??= LocationService._internal();
    return _instance!;
  }

  // Vérifier si les permissions de localisation sont accordées
  Future<bool> hasLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    return permission == LocationPermission.always ||
           permission == LocationPermission.whileInUse;
  }

  // Demander les permissions de localisation
  Future<bool> requestLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Vérifier si le service de localisation est activé
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Le service de localisation n'est pas activé
      return false;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Les permissions sont refusées
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Les permissions sont refusées de manière permanente
      return false;
    }

    // Les permissions sont accordées
    return true;
  }

  // Obtenir la position actuelle de l'utilisateur
  Future<Position?> getCurrentLocation() async {
    try {
      bool hasPermission = await requestLocationPermission();
      if (!hasPermission) {
        return null;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      return position;
    } catch (e) {
      print('Erreur lors de l\'obtention de la localisation: $e');
      return null;
    }
  }

  // Calculer la distance entre deux points en kilomètres
  double calculateDistance(
    double lat1, double lon1, 
    double lat2, double lon2
  ) {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2) / 1000; // en km
  }

  // Écouter les changements de position
  Stream<Position> getLocationStream() {
    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 100, // Mise à jour tous les 100 mètres
    );

    return Geolocator.getPositionStream(locationSettings: locationSettings);
  }

  // Ouvrir les paramètres de localisation
  Future<bool> openLocationSettings() async {
    return await Geolocator.openLocationSettings();
  }

  // Ouvrir les paramètres d'application
  Future<bool> openAppSettings() async {
    return await Geolocator.openAppSettings();
  }
}
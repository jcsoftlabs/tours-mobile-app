import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../models/establishment.dart';
import '../models/site.dart';
import '../services/location_service.dart';

class InteractiveMap extends StatefulWidget {
  final List<Establishment>? establishments;
  final List<Site>? sites;
  final Function(Establishment)? onEstablishmentTap;
  final Function(Site)? onSiteTap;
  final bool showUserLocation;

  const InteractiveMap({
    super.key,
    this.establishments,
    this.sites,
    this.onEstablishmentTap,
    this.onSiteTap,
    this.showUserLocation = true,
  });

  @override
  State<InteractiveMap> createState() => _InteractiveMapState();
}

class _InteractiveMapState extends State<InteractiveMap> {
  final Completer<GoogleMapController> _controller = Completer();
  final LocationService _locationService = LocationService();
  
  Set<Marker> _markers = {};
  Position? _currentPosition;
  bool _isLoadingLocation = false;
  
  // Position par défaut (Paris)
  static const CameraPosition _defaultPosition = CameraPosition(
    target: LatLng(48.8566, 2.3522),
    zoom: 12,
  );

  @override
  void initState() {
    super.initState();
    _initializeMap();
  }

  Future<void> _initializeMap() async {
    // Démarrer la mise à jour des marqueurs en parallèle
    _updateMarkers();
    
    // Charger la localisation en arrière-plan
    if (widget.showUserLocation) {
      _getCurrentLocation();
    }
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoadingLocation = true;
    });

    try {
      final position = await _locationService.getCurrentLocation();
      if (position != null && mounted) {
        setState(() {
          _currentPosition = position;
        });
        
        // Centrer la carte sur la position de l'utilisateur
        final GoogleMapController controller = await _controller.future;
        controller.animateCamera(
          CameraUpdate.newLatLng(
            LatLng(position.latitude, position.longitude),
          ),
        );
      }
    } catch (e) {
      print('Erreur lors de l\'obtention de la position: $e');
    } finally {
      setState(() {
        _isLoadingLocation = false;
      });
    }
  }

  void _updateMarkers() {
    // Optimisation: ne pas reconstruire si pas nécessaire
    if (!mounted) return;
    
    Set<Marker> markers = {};

    // Limiter le nombre de marqueurs pour éviter la surcharge
    const int maxMarkers = 50;
    
    // Ajouter les marqueurs d'établissements (limités)
    if (widget.establishments != null) {
      final establishments = widget.establishments!.take(maxMarkers ~/ 2);
      for (final establishment in establishments) {
        markers.add(
          Marker(
            markerId: MarkerId('establishment_${establishment.id}'),
            position: LatLng(establishment.latitude, establishment.longitude),
            infoWindow: InfoWindow(
              title: establishment.name,
              snippet: establishment.description != null && establishment.description!.length > 100 
                  ? '${establishment.description!.substring(0, 100)}...'
                  : establishment.description,
              onTap: () => widget.onEstablishmentTap?.call(establishment),
            ),
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
            onTap: () => widget.onEstablishmentTap?.call(establishment),
          ),
        );
      }
    }

    // Ajouter les marqueurs de sites (limités)
    if (widget.sites != null) {
      final sites = widget.sites!.take(maxMarkers ~/ 2);
      for (final site in sites) {
        markers.add(
          Marker(
            markerId: MarkerId('site_${site.id}'),
            position: LatLng(site.latitude, site.longitude),
            infoWindow: InfoWindow(
              title: site.name,
              snippet: site.description.length > 100 
                  ? '${site.description.substring(0, 100)}...'
                  : site.description,
              onTap: () => widget.onSiteTap?.call(site),
            ),
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
            onTap: () => widget.onSiteTap?.call(site),
          ),
        );
      }
    }

    // Ajouter le marqueur de position utilisateur
    if (_currentPosition != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('user_location'),
          position: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
          infoWindow: const InfoWindow(
            title: 'Votre position',
            snippet: 'Vous êtes ici',
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        ),
      );
    }

    if (mounted) {
      setState(() {
        _markers = markers;
      });
    }
  }

  @override
  void didUpdateWidget(InteractiveMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.establishments != oldWidget.establishments ||
        widget.sites != oldWidget.sites) {
      _updateMarkers();
    }
  }

  Widget _buildLocationButton() {
    return Positioned(
      bottom: 16,
      right: 16,
      child: FloatingActionButton(
        onPressed: _isLoadingLocation ? null : _getCurrentLocation,
        backgroundColor: Theme.of(context).primaryColor,
        child: _isLoadingLocation
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : const Icon(
                Icons.my_location,
                color: Colors.white,
              ),
      ),
    );
  }

  Widget _buildMapTypeButton() {
    return Positioned(
      bottom: 80,
      right: 16,
      child: FloatingActionButton.small(
        onPressed: () async {
          final GoogleMapController controller = await _controller.future;
          // Toggle entre normal et satellite (optionnel)
        },
        backgroundColor: Colors.white,
        child: Icon(
          Icons.layers,
          color: Theme.of(context).primaryColor,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            mapType: MapType.normal,
            initialCameraPosition: _currentPosition != null
                ? CameraPosition(
                    target: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
                    zoom: 13,
                  )
                : _defaultPosition,
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
            },
            markers: _markers,
            myLocationEnabled: false,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false, // Désactiver pour performance
            mapToolbarEnabled: false,
            compassEnabled: false, // Désactiver pour performance
            rotateGesturesEnabled: false, // Réduire les gestes coûteux
            scrollGesturesEnabled: true,
            tiltGesturesEnabled: false, // Désactiver pour performance
            zoomGesturesEnabled: true,
            liteModeEnabled: false, // Garder interactif
            buildingsEnabled: false, // Réduire la complexité visuelle
            trafficEnabled: false,
          ),
          
          // Bouton de localisation
          if (widget.showUserLocation) _buildLocationButton(),
          
          // Bouton de type de carte (optionnel)
          _buildMapTypeButton(),
          
          // Légende
          Positioned(
            top: 50,
            left: 16,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Légende',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (widget.establishments != null) ...[
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.location_on,
                          color: Colors.red,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Établissements',
                          style: TextStyle(fontSize: 10),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                  ],
                  if (widget.sites != null) ...[
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.location_on,
                          color: Colors.green,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Sites touristiques',
                          style: TextStyle(fontSize: 10),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                  ],
                  if (widget.showUserLocation)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.location_on,
                          color: Colors.blue,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Votre position',
                          style: TextStyle(fontSize: 10),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:go_router/go_router.dart';
import '../models/establishment.dart';
import '../widgets/establishment_card.dart';
import '../services/search_service.dart';
import '../services/establishment_service.dart';

class SearchResultsScreen extends ConsumerStatefulWidget {
  final String? query;
  final String? categoryId;
  final String? categoryName;

  const SearchResultsScreen({
    super.key,
    this.query,
    this.categoryId,
    this.categoryName,
  });

  @override
  ConsumerState<SearchResultsScreen> createState() => _SearchResultsScreenState();
}

class _SearchResultsScreenState extends ConsumerState<SearchResultsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final SearchService _searchService = SearchService();
  final EstablishmentService _establishmentService = EstablishmentService();
  
  List<Establishment> _establishments = [];
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  bool _isLoading = false;
  bool _hasError = false;
  String _errorMessage = '';
  
  // Position par défaut (Paris)
  static const CameraPosition _defaultPosition = CameraPosition(
    target: LatLng(48.8566, 2.3522),
    zoom: 12.0,
  );

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadResults();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadResults() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      List<Establishment> results;
      
      if (widget.query != null) {
        // Recherche par texte
        results = await _searchService.searchEstablishments(
          query: widget.query!,
        );
      } else if (widget.categoryId != null) {
        // Recherche par catégorie
        results = await _establishmentService.getEstablishmentsByCategory(
          widget.categoryId!,
        );
      } else {
        // Tous les établissements
        results = await _establishmentService.getEstablishments();
      }
      
      setState(() {
        _establishments = results;
        _createMarkers();
      });
    } catch (e) {
      setState(() {
        _hasError = true;
        _errorMessage = e.toString();
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _createMarkers() {
    _markers = _establishments.map((establishment) {
      return Marker(
        markerId: MarkerId(establishment.id),
        position: LatLng(
          establishment.latitude,
          establishment.longitude,
        ),
        infoWindow: InfoWindow(
          title: establishment.name,
          snippet: establishment.address,
        ),
        onTap: () => _onEstablishmentTap(establishment),
      );
    }).toSet();
  }

  void _onEstablishmentTap(Establishment establishment) {
    context.push('/establishment/${establishment.id}');
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    
    if (_establishments.isNotEmpty) {
      // Centrer la carte sur les résultats
      _fitMapToEstablishments();
    }
  }

  void _fitMapToEstablishments() {
    if (_mapController == null || _establishments.isEmpty) return;
    
    double minLat = _establishments.first.latitude;
    double maxLat = _establishments.first.latitude;
    double minLng = _establishments.first.longitude;
    double maxLng = _establishments.first.longitude;
    
    for (final establishment in _establishments) {
      minLat = minLat < establishment.latitude ? minLat : establishment.latitude;
      maxLat = maxLat > establishment.latitude ? maxLat : establishment.latitude;
      minLng = minLng < establishment.longitude ? minLng : establishment.longitude;
      maxLng = maxLng > establishment.longitude ? maxLng : establishment.longitude;
    }
    
    _mapController!.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(minLat, minLng),
          northeast: LatLng(maxLat, maxLng),
        ),
        100.0,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.query ?? widget.categoryName ?? 'Résultats';
    
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(
              icon: Icon(Icons.list),
              text: 'Liste',
            ),
            Tab(
              icon: Icon(Icons.map),
              text: 'Carte',
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // TODO: Implémenter les filtres
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _hasError
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.red,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Erreur de chargement',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _errorMessage,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadResults,
                        child: const Text('Réessayer'),
                      ),
                    ],
                  ),
                )
              : TabBarView(
                  controller: _tabController,
                  children: [
                    // Onglet Liste
                    _buildListView(),
                    // Onglet Carte
                    _buildMapView(),
                  ],
                ),
    );
  }

  Widget _buildListView() {
    if (_establishments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.search_off,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              'Aucun résultat trouvé',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            const Text(
              'Essayez de modifier votre recherche',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Barre d'informations
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.grey[100],
          child: Row(
            children: [
              Text(
                '${_establishments.length} résultat(s) trouvé(s)',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              DropdownButton<String>(
                value: 'pertinence',
                items: const [
                  DropdownMenuItem(
                    value: 'pertinence',
                    child: Text('Pertinence'),
                  ),
                  DropdownMenuItem(
                    value: 'distance',
                    child: Text('Distance'),
                  ),
                  DropdownMenuItem(
                    value: 'note',
                    child: Text('Note'),
                  ),
                  DropdownMenuItem(
                    value: 'prix',
                    child: Text('Prix'),
                  ),
                ],
                onChanged: (value) {
                  // TODO: Implémenter le tri
                },
              ),
            ],
          ),
        ),
        // Liste des établissements
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _establishments.length,
            itemBuilder: (context, index) {
              final establishment = _establishments[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: EstablishmentCard(
                  establishment: establishment,
                  onTap: () => _onEstablishmentTap(establishment),
                  showDistance: true,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMapView() {
    return GoogleMap(
      onMapCreated: _onMapCreated,
      initialCameraPosition: _defaultPosition,
      markers: _markers,
      myLocationEnabled: true,
      myLocationButtonEnabled: true,
      mapType: MapType.normal,
      zoomControlsEnabled: true,
      compassEnabled: true,
    );
  }
}

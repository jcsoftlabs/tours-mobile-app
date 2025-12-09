import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../models/site.dart';
import '../../../services/sites_service.dart';
import '../../../widgets/site_card.dart';
import '../../../widgets/interactive_map.dart';
import '../../../core/network/error_handler.dart';

class SitesScreen extends ConsumerStatefulWidget {
  const SitesScreen({super.key});

  @override
  ConsumerState<SitesScreen> createState() => _SitesScreenState();
}

class _SitesScreenState extends ConsumerState<SitesScreen> {
  final SitesService _sitesService = SitesService();
  final TextEditingController _searchController = TextEditingController();
  
  List<Site> _sites = [];
  List<Site> _filteredSites = [];
  bool _isLoading = true;
  String? _error;
  String _selectedType = 'Tous';
  bool _isMapView = false;
  
  final List<String> _siteTypes = [
    'Tous',
    'Monument',
    'Musée',
    'Parc',
    'Église',
    'Château',
    'Site naturel',
    'Place',
    'Autre'
  ];

  @override
  void initState() {
    super.initState();
    _loadSites();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadSites() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final sites = await _sitesService.getSites();
      setState(() {
        _sites = sites;
        _filteredSites = sites;
        _isLoading = false;
      });
    } catch (e) {
      // Utiliser ErrorHandler pour obtenir un message sécurisé
      setState(() {
        _error = ErrorHandler.getUserFriendlyMessage(e, context: 'Erreur lors du chargement des sites');
        _isLoading = false;
      });
    }
  }

  void _filterSites() {
    final query = _searchController.text.toLowerCase();
    final typeFilter = _selectedType == 'Tous' ? null : _selectedType;

    setState(() {
      _filteredSites = _sites.where((site) {
        final matchesQuery = query.isEmpty ||
            site.name.toLowerCase().contains(query) ||
            site.description.toLowerCase().contains(query) ||
            site.address.toLowerCase().contains(query);

        final matchesType = typeFilter == null || site.type == typeFilter;

        return matchesQuery && matchesType;
      }).toList();
    });
  }

  void _onSiteTap(Site site) {
    context.push('/site/${site.id}');
  }

  Widget _buildListView() {
    if (_filteredSites.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.place_outlined,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'Aucun site trouvé',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Essayez de modifier vos critères de recherche',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadSites,
      child: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: _filteredSites.length,
        itemBuilder: (context, index) {
          final site = _filteredSites[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: SiteCard(
              site: site,
              onTap: () => _onSiteTap(site),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMapView() {
    return InteractiveMap(
      sites: _filteredSites,
      onSiteTap: _onSiteTap,
      showUserLocation: true,
    );
  }

  Widget _buildViewToggleButton({
    required IconData icon,
    required bool isSelected,
    required VoidCallback onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Icon(
          icon,
          color: isSelected ? Theme.of(context).primaryColor : Colors.white,
          size: 20,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Configuration de la barre d'état
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
    ));
    
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Column(
        children: [
            // En-tête avec couleur de statut
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Theme.of(context).primaryColor,
                    Theme.of(context).primaryColor.withOpacity(0.8),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Padding(
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top + 10,
                  left: 20,
                  right: 20,
                  bottom: 20,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Titre et boutons de vue
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Sites Touristiques',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 28,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Découvrez les merveilles de votre région',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Toggle vue liste/carte
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _buildViewToggleButton(
                                icon: Icons.list,
                                isSelected: !_isMapView,
                                onPressed: () => setState(() => _isMapView = false),
                              ),
                              _buildViewToggleButton(
                                icon: Icons.map,
                                isSelected: _isMapView,
                                onPressed: () => setState(() => _isMapView = true),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    
                    // Barre de recherche (seulement en vue liste)
                    if (!_isMapView)
                      Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _searchController,
                        onChanged: (_) => _filterSites(),
                        decoration: InputDecoration(
                          hintText: 'Rechercher un site...',
                          hintStyle: TextStyle(
                            color: Colors.grey[400],
                            fontWeight: FontWeight.w400,
                          ),
                          prefixIcon: Icon(
                            Icons.search,
                            color: Colors.grey[400],
                          ),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: Icon(
                                    Icons.clear,
                                    color: Colors.grey[400],
                                  ),
                                  onPressed: () {
                                    _searchController.clear();
                                    _filterSites();
                                  },
                                )
                              : null,
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Filtres par type (seulement en vue liste)
            if (!_isMapView)
              Container(
                height: 50,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _siteTypes.length,
                  itemBuilder: (context, index) {
                    final type = _siteTypes[index];
                    final isSelected = _selectedType == type;
                    
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(type),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            _selectedType = type;
                          });
                          _filterSites();
                        },
                        backgroundColor: Colors.white,
                        selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
                        checkmarkColor: Theme.of(context).primaryColor,
                        labelStyle: TextStyle(
                          color: isSelected
                              ? Theme.of(context).primaryColor
                              : Colors.grey[700],
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                        ),
                      ),
                    );
                  },
                ),
              ),

            // Contenu principal
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.error_outline,
                                size: 64,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Erreur de chargement',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _error!,
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.grey[500]),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: _loadSites,
                                child: const Text('Réessayer'),
                              ),
                            ],
                          ),
                        )
                      : _isMapView ? _buildMapView() : _buildListView(),
            ),
          ],
        ),
    );
  }
}

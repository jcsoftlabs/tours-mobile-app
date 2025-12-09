import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../models/establishment.dart';
import '../../../services/establishment_service.dart';
import '../../../widgets/establishment_card.dart';
import '../../../widgets/interactive_map.dart';

class EstablishmentsScreen extends ConsumerStatefulWidget {
  const EstablishmentsScreen({super.key});

  @override
  ConsumerState<EstablishmentsScreen> createState() => _EstablishmentsScreenState();
}

class _EstablishmentsScreenState extends ConsumerState<EstablishmentsScreen> {
  final EstablishmentService _establishmentService = EstablishmentService();
  final TextEditingController _searchController = TextEditingController();
  
  List<Establishment> _establishments = [];
  List<Establishment> _filteredEstablishments = [];
  bool _isLoading = true;
  String? _error;
  String _selectedCategory = 'Toutes';
  bool _isMapView = false;
  Timer? _debounceTimer;
  
  List<String> get _categories => [
    'establishments.types.all'.tr(),
    'establishments.types.restaurant'.tr(),
    'establishments.types.hotel'.tr(),
    'establishments.types.shop'.tr(),
    'establishments.types.cafe'.tr(),
    'establishments.types.bar'.tr(),
    'establishments.types.service'.tr(),
  ];

  @override
  void initState() {
    super.initState();
    _loadEstablishments();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadEstablishments() async {
    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final establishments = await _establishmentService.getEstablishments();
      if (!mounted) return;
      
      setState(() {
        _establishments = establishments;
        _filteredEstablishments = establishments;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _onSearchChanged() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      _filterEstablishments();
    });
  }

  void _filterEstablishments() {
    if (!mounted) return;
    
    final query = _searchController.text.toLowerCase();
    final categoryFilter = _selectedCategory == 'Toutes' ? null : _selectedCategory;

    final filtered = _establishments.where((establishment) {
      final matchesQuery = query.isEmpty ||
          establishment.name.toLowerCase().contains(query) ||
          (establishment.description?.toLowerCase() ?? '').contains(query) ||
          establishment.address.toLowerCase().contains(query);

      final matchesCategory = categoryFilter == null || establishment.type == categoryFilter;

      return matchesQuery && matchesCategory;
    }).toList();

    setState(() {
      _filteredEstablishments = filtered;
    });
  }

  void _onEstablishmentTap(Establishment establishment) {
    context.push('/establishment/${establishment.id}');
  }

  Widget _buildListView() {
    if (_filteredEstablishments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.store_outlined,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              'establishments.no_results'.tr(),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'establishments.try_modify_search'.tr(),
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadEstablishments,
      child: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: _filteredEstablishments.length,
        itemBuilder: (context, index) {
          final establishment = _filteredEstablishments[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: EstablishmentCard(
              establishment: establishment,
              onTap: () => _onEstablishmentTap(establishment),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMapView() {
    return InteractiveMap(
      establishments: _filteredEstablishments,
      onEstablishmentTap: _onEstablishmentTap,
      showUserLocation: true,
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
                              Text(
                                'establishments.title'.tr(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 28,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'establishments.subtitle'.tr(),
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
                          onChanged: (_) => _onSearchChanged(),
                          decoration: InputDecoration(
                            hintText: 'establishments.search_placeholder'.tr(),
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
                                      _filterEstablishments();
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

            // Filtres par catégorie (seulement en vue liste)
            if (!_isMapView)
              Container(
                height: 50,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _categories.length,
                  itemBuilder: (context, index) {
                    final category = _categories[index];
                    final isSelected = _selectedCategory == category;
                    
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(category),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            _selectedCategory = category;
                          });
                          _filterEstablishments();
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
                                'establishments.loading_error'.tr(),
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
                                onPressed: _loadEstablishments,
                                child: Text('common.retry'.tr()),
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
}

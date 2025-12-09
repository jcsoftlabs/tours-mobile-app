import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../models/category.dart';
import '../../../models/establishment.dart';
import '../../../widgets/category_card.dart';
import '../../../widgets/establishment_card.dart';
import '../../../services/search_service.dart';
import '../../../core/utils/ui_helpers.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  final SearchService _searchService = SearchService();
  Timer? _debounce;
  
  List<Category> _categories = [];
  List<Establishment> _featuredEstablishments = [];
  List<Establishment> _searchSuggestions = [];
  bool _isLoading = false;
  bool _showSuggestions = false;
  bool _isSearching = false;
  String? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    _loadCategories();
    _loadFeaturedEstablishments();
  }
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _configureStatusBar();
  }

  void _configureStatusBar() {
    // Configuration de la barre d'état pour qu'elle se fonde avec l'en-tête
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Theme.of(context).primaryColor, // Couleur dynamique du thème
        statusBarIconBrightness: Brightness.light, // Icônes blanches
        statusBarBrightness: Brightness.dark, // Pour iOS
        systemNavigationBarColor: Colors.white, // Barre de navigation
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    // Restaurer l'état par défaut de la barre d'état
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
    );
    super.dispose();
  }

  Future<void> _loadCategories() async {
    setState(() {
      _categories = Category.getDefaultCategories();
    });
  }

  Future<void> _loadFeaturedEstablishments() async {
    setState(() => _isLoading = true);
    try {
      final establishments = await _searchService.searchEstablishments(
        page: 1,
        limit: 5,
      );
      setState(() => _featuredEstablishments = establishments);
    } catch (e) {
      if (mounted) {
        // Afficher un message d'erreur sécurisé
        UiHelpers.showErrorSnackBar(context, e);
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _onSearchChanged(String query) {
    // Annuler le timer précédent
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    
    if (query.isEmpty) {
      setState(() {
        _searchSuggestions = [];
        _showSuggestions = false;
        _isSearching = false;
      });
      return;
    }
    
    setState(() => _isSearching = true);
    
    // Créer un nouveau timer qui attend 300ms avant de faire la recherche
    _debounce = Timer(const Duration(milliseconds: 300), () {
      _performSearch(query);
    });
  }
  
  Future<void> _performSearch(String query) async {
    try {
      final results = await _searchService.searchEstablishments(
        query: query,
        limit: 5, // Limiter à 5 suggestions
      );
      
      if (mounted) {
        setState(() {
          _searchSuggestions = results;
          _showSuggestions = results.isNotEmpty;
          _isSearching = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _showSuggestions = false;
          _isSearching = false;
        });
      }
    }
  }

  void _onSearchSubmit(String query) {
    if (query.trim().isEmpty) return;
    
    _hideSearchSuggestions();
    context.push('/search', extra: {
      'query': query.trim(),
      'categoryId': _selectedCategoryId,
    });
  }

  void _onCategorySelected(Category category) {
    setState(() {
      _selectedCategoryId = _selectedCategoryId == category.id ? null : category.id;
    });
    
    if (_selectedCategoryId != null) {
      context.push('/search', extra: {
        'categoryId': _selectedCategoryId!,
        'categoryName': category.name,
      });
    }
  }

  void _onEstablishmentTap(Establishment establishment) {
    context.push('/establishment/${establishment.id}');
  }

  void _hideSearchSuggestions() {
    setState(() => _showSuggestions = false);
  }
  
  IconData _getIconForType(String type) {
    switch (type.toUpperCase()) {
      case 'HOTEL':
        return Icons.hotel;
      case 'RESTAURANT':
        return Icons.restaurant;
      case 'BAR':
        return Icons.local_bar;
      case 'CAFE':
        return Icons.local_cafe;
      case 'SHOP':
        return Icons.shopping_bag;
      case 'MUSEUM':
        return Icons.museum;
      case 'PARK':
        return Icons.park;
      default:
        return Icons.place;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: GestureDetector(
        onTap: _hideSearchSuggestions,
        child: Column(
            children: [
              // Header avec barre de recherche
              Container(
                padding: EdgeInsets.fromLTRB(16, MediaQuery.of(context).padding.top + 16, 16, 24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Theme.of(context).primaryColor,
                      Theme.of(context).primaryColor.withOpacity(0.8),
                    ],
                  ),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(24),
                    bottomRight: Radius.circular(24),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).primaryColor.withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Titre et localisation
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          color: Colors.white,
                          size: 28,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'app.name'.tr(),
                                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              Text(
                                'app.slogan'.tr(),
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: Colors.white70,
                                    ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            context.push('/profile');
                          },
                          icon: const Icon(
                            Icons.person,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Barre de recherche
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 20,
                            offset: const Offset(0, 4),
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _searchController,
                        onChanged: _onSearchChanged,
                        onSubmitted: _onSearchSubmit,
                        decoration: InputDecoration(
                          hintText: 'search.placeholder'.tr(),
                          prefixIcon: const Icon(Icons.search, color: Colors.grey),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear, color: Colors.grey),
                                  onPressed: () {
                                    _searchController.clear();
                                    _hideSearchSuggestions();
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
              
              // Suggestions de recherche
              if (_showSuggestions && _searchSuggestions.isNotEmpty)
                Flexible(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height * 0.4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: Text(
                            'Suggestions',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                        Flexible(
                          child: ListView.separated(
                            shrinkWrap: true,
                            itemCount: _searchSuggestions.length,
                            separatorBuilder: (context, index) => const Divider(height: 1),
                            itemBuilder: (context, index) {
                              final establishment = _searchSuggestions[index];
                              return ListTile(
                                leading: Icon(
                                  _getIconForType(establishment.type),
                                  color: Theme.of(context).primaryColor,
                                ),
                                title: Text(
                                  establishment.name,
                                  style: const TextStyle(fontWeight: FontWeight.w500),
                                ),
                                subtitle: Text(
                                  establishment.address,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                ),
                                trailing: establishment.rating != null
                                    ? Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(Icons.star, color: Colors.amber, size: 16),
                                          const SizedBox(width: 4),
                                          Text(
                                            establishment.formattedRating,
                                            style: const TextStyle(fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      )
                                    : null,
                                onTap: () {
                                  _hideSearchSuggestions();
                                  context.push('/establishment/${establishment.id}');
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else if (_isSearching)
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
              
              // Contenu principal
              Expanded(
                child: SafeArea(
                  top: false, // On ne veut pas de SafeArea en haut
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Catégories
                      Text(
                        'navigation.home'.tr(),
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                              color: Colors.black87,
                            ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        height: 130,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          itemCount: _categories.length,
                          itemBuilder: (context, index) {
                            final category = _categories[index];
                            return Padding(
                              padding: const EdgeInsets.only(right: 16),
                              child: CategoryCard(
                                category: category,
                                isSelected: _selectedCategoryId == category.id,
                                onTap: () => _onCategorySelected(category),
                              ),
                            );
                          },
                        ),
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Établissements populaires
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Text(
                              'search.popular'.tr(),
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.5,
                                    color: Colors.black87,
                                  ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: Theme.of(context).primaryColor.withOpacity(0.1),
                            ),
                            child: TextButton(
                              onPressed: () {
                                context.push('/search');
                              },
                              style: TextButton.styleFrom(
                                foregroundColor: Theme.of(context).primaryColor,
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                              child: Text(
                                'common.see_all'.tr(),
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 16),
                      
                      if (_isLoading)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(32),
                            child: CircularProgressIndicator(),
                          ),
                        )
                      else if (_featuredEstablishments.isEmpty)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(32),
                            child: Text('establishments.no_results'.tr()),
                          ),
                        )
                      else
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _featuredEstablishments.length,
                          itemBuilder: (context, index) {
                            final establishment = _featuredEstablishments[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: EstablishmentCard(
                                establishment: establishment,
                                onTap: () => _onEstablishmentTap(establishment),
                              ),
                            );
                          },
                        ),
                    ],
                    ),
                  ),
                ),
              ),
            ],
          ),
      ),
    );
  }
}

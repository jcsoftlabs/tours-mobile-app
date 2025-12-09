import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';
import '../models/establishment.dart';
import '../widgets/establishment_card.dart';
import '../services/favorites_service.dart';
import '../services/establishment_service.dart';
import '../providers/auth_provider.dart';

class FavoritesScreen extends ConsumerStatefulWidget {
  const FavoritesScreen({super.key});

  @override
  ConsumerState<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends ConsumerState<FavoritesScreen> {
  final FavoritesService _favoritesService = FavoritesService();
  final EstablishmentService _establishmentService = EstablishmentService();
  
  List<Establishment> _favoriteEstablishments = [];
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';
  String _selectedSortOrder = 'recent'; // recent, name, type, rating

  @override
  void initState() {
    super.initState();
    // Vérifier l'authentification avant de charger
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAuthAndLoad();
    });
  }

  void _checkAuthAndLoad() {
    final authState = ref.read(authStateProvider);
    if (!authState.isLoggedIn) {
      _showAuthDialog();
    } else {
      _loadFavorites();
    }
  }

  void _showAuthDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        icon: Icon(
          Icons.favorite,
          color: Theme.of(context).primaryColor,
          size: 48,
        ),
        title: Text('auth.login_required'.tr()),
        content: Text(
          'favorites.login_message'.tr(),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.go('/');  // Retourner à l'accueil
            },
            child: Text('common.later'.tr()),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.push('/register');
            },
            child: Text('auth.register'.tr()),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.push('/login');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
            ),
            child: Text(
              'auth.login'.tr(),
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _loadFavorites() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      // Obtenir les favoris directement depuis l'API pour l'utilisateur connecté
      final favorites = await _favoritesService.getFavorites();
      
      setState(() {
        _favoriteEstablishments = favorites;
        _sortEstablishments();
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

  void _sortEstablishments() {
    switch (_selectedSortOrder) {
      case 'name':
        _favoriteEstablishments.sort((a, b) => a.name.compareTo(b.name));
        break;
      case 'type':
        _favoriteEstablishments.sort((a, b) => a.type.compareTo(b.type));
        break;
      case 'rating':
        _favoriteEstablishments.sort((a, b) => 
          (b.rating ?? 0).compareTo(a.rating ?? 0));
        break;
      case 'recent':
      default:
        // Garder l'ordre original (plus récemment ajouté en premier)
        break;
    }
  }

  Future<void> _removeFavorite(String establishmentId) async {
    try {
      await _favoritesService.removeFavorite(establishmentId);
      setState(() {
        _favoriteEstablishments.removeWhere((e) => e.id == establishmentId);
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('favorites.removed'.tr()),
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${'common.error'.tr()}: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _clearAllFavorites() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('favorites.clear_all'.tr()),
        content: Text(
          'favorites.clear_all_confirm'.tr(namedArgs: {'count': '${_favoriteEstablishments.length}'}),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('common.cancel'.tr()),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: Text(
              'favorites.clear_all'.tr(),
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        // Supprimer tous les favoris
        await Future.wait(
          _favoriteEstablishments.map((e) => _favoritesService.removeFavorite(e.id))
        );
        
        setState(() {
          _favoriteEstablishments.clear();
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('favorites.all_cleared'.tr()),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${'favorites.error'.tr()}: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _onEstablishmentTap(Establishment establishment) {
    context.push('/establishment/${establishment.id}');
  }

  void _showSortOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'favorites.sort_by'.tr(),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...[{'value': 'recent', 'label': 'favorites.sort.recent'.tr()},
                {'value': 'name', 'label': 'favorites.sort.name'.tr()},
                {'value': 'type', 'label': 'favorites.sort.type'.tr()},
                {'value': 'rating', 'label': 'favorites.sort.rating'.tr()}
               ].map((option) => ListTile(
              leading: Radio<String>(
                value: option['value']!,
                groupValue: _selectedSortOrder,
                onChanged: (value) {
                  setState(() {
                    _selectedSortOrder = value!;
                    _sortEstablishments();
                  });
                  Navigator.pop(context);
                },
              ),
              title: Text(option['label']!),
              onTap: () {
                setState(() {
                  _selectedSortOrder = option['value']!;
                  _sortEstablishments();
                });
                Navigator.pop(context);
              },
            )),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    
    // Si pas connecté, afficher un écran d'invitation à se connecter
    if (!authState.isLoggedIn) {
      return Scaffold(
        appBar: AppBar(
          title: Text('favorites.title'.tr()),
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
        ),
        body: _buildNotLoggedInState(),
      );
    }
    
    return Scaffold(
      appBar: AppBar(
        title: Text('favorites.title'.tr()),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          if (_favoriteEstablishments.isNotEmpty) ...[
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              onPressed: _clearAllFavorites,
              tooltip: 'favorites.clear_all'.tr(),
            ),
            IconButton(
              icon: const Icon(Icons.sort),
              onPressed: _showSortOptions,
              tooltip: 'favorites.sort_by'.tr(),
            ),
          ],
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _hasError
              ? _buildErrorState()
              : _favoriteEstablishments.isEmpty
                  ? _buildEmptyState()
                  : _buildFavoritesList(),
    );
  }

  Widget _buildErrorState() {
    return Center(
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
            'favorites.loading_error'.tr(),
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
            onPressed: _loadFavorites,
            child: Text('common.retry'.tr()),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.favorite_border,
              size: 100,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 24),
            Text(
              'favorites.no_favorites'.tr(),
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'favorites.add_some'.tr(),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                context.go('/');
              },
              icon: const Icon(Icons.explore),
              label: Text('favorites.discover'.tr()),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFavoritesList() {
    return Column(
      children: [
        // Barre d'informations
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.grey[100],
          child: Row(
            children: [
              Text(
                '${_favoriteEstablishments.length} favori(s)',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Text(
                _getSortLabel(),
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        // Liste des favoris
        Expanded(
          child: RefreshIndicator(
            onRefresh: _loadFavorites,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _favoriteEstablishments.length,
              itemBuilder: (context, index) {
                final establishment = _favoriteEstablishments[index];
                return Dismissible(
                  key: Key(establishment.id),
                  direction: DismissDirection.endToStart,
                  confirmDismiss: (direction) async {
                    return await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text('favorites.remove_title'.tr()),
                        content: Text(
                          'favorites.remove_confirm'.tr(namedArgs: {'name': establishment.name}),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: Text('common.cancel'.tr()),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            child: Text(
                              'favorites.remove'.tr(),
                              style: const TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                  onDismissed: (direction) {
                    _removeFavorite(establishment.id);
                  },
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    color: Colors.red,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.delete,
                          color: Colors.white,
                          size: 28,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'favorites.remove'.tr(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: EstablishmentCard(
                      establishment: establishment,
                      onTap: () => _onEstablishmentTap(establishment),
                      showFavoriteButton: true,
                      isFavorite: true,
                      onFavoriteToggle: () => _removeFavorite(establishment.id),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNotLoggedInState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.favorite_border,
              size: 100,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 24),
            Text(
              'auth.login_required'.tr(),
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.grey[700],
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'favorites.login_message'.tr(),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      context.push('/register');
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: BorderSide(color: Theme.of(context).primaryColor),
                    ),
                    child: Text('auth.register'.tr()),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      context.push('/login');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text('auth.login'.tr()),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                context.go('/');  // Retourner à l'accueil
              },
              child: Text('favorites.browse_without_account'.tr()),
            ),
          ],
        ),
      ),
    );
  }

  String _getSortLabel() {
    switch (_selectedSortOrder) {
      case 'name':
        return 'favorites.sort.name'.tr();
      case 'type':
        return 'favorites.sort.type'.tr();
      case 'rating':
        return 'favorites.sort.rating'.tr();
      case 'recent':
      default:
        return 'favorites.sort.recent'.tr();
    }
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/establishment.dart';
import '../services/favorites_service.dart';
import '../services/auth_service.dart';
import '../services/image_service.dart';

class EstablishmentCard extends StatefulWidget {
  final Establishment establishment;
  final VoidCallback? onTap;
  final bool showDistance;
  final bool showFavoriteButton;
  final bool? isFavorite;
  final VoidCallback? onFavoriteToggle;

  const EstablishmentCard({
    Key? key,
    required this.establishment,
    this.onTap,
    this.showDistance = true,
    this.showFavoriteButton = true,
    this.isFavorite,
    this.onFavoriteToggle,
  }) : super(key: key);

  @override
  State<EstablishmentCard> createState() => _EstablishmentCardState();
}

class _EstablishmentCardState extends State<EstablishmentCard> {
  final FavoritesService _favoritesService = FavoritesService();
  final AuthService _authService = AuthService();
  bool _isFavorite = false;
  bool _isLoadingFavorite = false;

  @override
  void initState() {
    super.initState();
    if (widget.isFavorite != null) {
      _isFavorite = widget.isFavorite!;
    } else {
      _loadFavoriteStatus();
    }
  }

  Future<void> _loadFavoriteStatus() async {
    _isFavorite = await _favoritesService.isFavorite(widget.establishment.id);
    if (mounted) setState(() {});
  }

  Future<void> _toggleFavorite() async {
    if (_isLoadingFavorite) return;
    
    // Vérifier si l'utilisateur est connecté
    if (!_authService.isLoggedIn) {
      if (mounted) {
        final shouldNavigate = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Connexion requise'),
            content: const Text('Vous devez être connecté pour ajouter des favoris.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Annuler'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Se connecter'),
              ),
            ],
          ),
        );
        
        if (shouldNavigate == true && mounted) {
          context.push('/login');
        }
      }
      return;
    }
    
    if (widget.onFavoriteToggle != null) {
      widget.onFavoriteToggle!();
      return;
    }
    
    setState(() => _isLoadingFavorite = true);
    
    try {
      await _favoritesService.toggleFavorite(widget.establishment.id);
      setState(() => _isFavorite = !_isFavorite);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    } finally {
      setState(() => _isLoadingFavorite = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
            spreadRadius: 2,
          ),
        ],
      ),
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image avec bouton favori
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  child: Image.network(
                    ImageService.getMainImage(widget.establishment),
                    height: 220,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        Container(
                          height: 200,
                          color: Colors.grey[300],
                          child: const Icon(Icons.image_not_supported, size: 50),
                        ),
                  ),
                ),
                if (widget.showFavoriteButton)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: _isLoadingFavorite
                          ? const Center(
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                            )
                          : IconButton(
                              icon: Icon(
                                _isFavorite ? Icons.favorite : Icons.favorite_border,
                                color: _isFavorite ? Colors.red : Colors.grey[600],
                                size: 22,
                              ),
                              onPressed: _toggleFavorite,
                            ),
                    ),
                  ),
                if (widget.establishment.activePromotions.isNotEmpty)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.red[400]!, Colors.red[600]!],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.red.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        widget.establishment.activePromotions.first.discountText,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          widget.establishment.name,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w700,
                                fontSize: 18,
                                letterSpacing: 0.2,
                              ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      // Afficher le prix uniquement pour les hôtels
                      if (widget.establishment.type.toUpperCase() == 'HOTEL' && 
                          widget.establishment.priceRange != null)
                        Text(
                          widget.establishment.formattedPrice,
                          style: TextStyle(
                            color: Colors.green[700],
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.establishment.type,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          widget.establishment.address,
                          style: Theme.of(context).textTheme.bodySmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (widget.showDistance && widget.establishment.distance != null)
                        Text(
                          widget.establishment.formattedDistance,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.grey[600],
                              ),
                        ),
                    ],
                  ),
                  if (widget.establishment.description != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      widget.establishment.description!,
                      style: Theme.of(context).textTheme.bodyMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      if (widget.establishment.rating != null) ...[
                        Icon(Icons.star, size: 16, color: Colors.amber[700]),
                        const SizedBox(width: 4),
                        Text(
                          widget.establishment.formattedRating,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        if (widget.establishment.reviewCount != null)
                          Text(
                            ' (${widget.establishment.reviewCount})',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        const Spacer(),
                      ],
                      if (widget.establishment.isOpen != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: widget.establishment.isOpen! ? Colors.green[500] : Colors.red[500],
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: (widget.establishment.isOpen! ? Colors.green : Colors.red).withOpacity(0.3),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Text(
                            widget.establishment.isOpen! ? 'Ouvert' : 'Fermé',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
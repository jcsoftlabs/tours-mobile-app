import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';
import 'package:share_plus/share_plus.dart';
import '../models/establishment.dart';
import '../models/review.dart';
import '../models/promotion.dart';
import '../models/notification.dart';
import '../services/establishment_service.dart';
import '../services/favorites_service.dart';
import '../services/location_service.dart';
import '../services/review_service.dart';
import '../services/image_service.dart';
import '../widgets/review_card.dart';
import '../widgets/review_stats.dart';
import '../widgets/full_screen_image_gallery.dart';
import 'add_review_screen.dart';

class EstablishmentDetailScreen extends ConsumerStatefulWidget {
  final String establishmentId;

  const EstablishmentDetailScreen({
    super.key,
    required this.establishmentId,
  });

  @override
  ConsumerState<EstablishmentDetailScreen> createState() =>
      _EstablishmentDetailScreenState();
}

class _EstablishmentDetailScreenState
    extends ConsumerState<EstablishmentDetailScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final EstablishmentService _establishmentService = EstablishmentService();
  final FavoritesService _favoritesService = FavoritesService();
  final LocationService _locationService = LocationService();
  final ReviewService _reviewService = ReviewService();
  final GlobalKey _shareButtonKey = GlobalKey();
  
  Establishment? _establishment;
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';
  bool _isFavorite = false;
  int _currentImageIndex = 0;
  late PageController _pageController;
  Position? _userPosition;
  GoogleMapController? _mapController;
  Set<Marker> _mapMarkers = {};
  
  // Pour les avis
  ReviewStats? _reviewStats;
  List<Review> _reviews = [];
  bool _isLoadingReviews = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _pageController = PageController();
    _loadEstablishmentDetails();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadEstablishmentDetails() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final establishment = await _establishmentService.getEstablishment(
        widget.establishmentId,
      );
      final isFavorite = await _favoritesService.isFavorite(
        widget.establishmentId,
      );
      
      setState(() {
        _establishment = establishment;
        _isFavorite = isFavorite;
      });
      
      // Charger les avis et statistiques
      await _loadReviews();
    } catch (e) {
      setState(() {
        _hasError = true;
        _errorMessage = e.toString();
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }
  
  Future<void> _loadReviews() async {
    setState(() => _isLoadingReviews = true);
    
    try {
      final stats = await _reviewService.getReviewStats(widget.establishmentId);
      final reviews = await _reviewService.getReviews(
        establishmentId: widget.establishmentId,
        limit: 50,
      );
      
      setState(() {
        _reviewStats = stats;
        _reviews = reviews;
      });
    } catch (e) {
      debugPrint('Erreur lors du chargement des avis: $e');
    } finally {
      setState(() => _isLoadingReviews = false);
    }
  }
  
  Future<void> _openAddReviewScreen() async {
    if (_establishment == null) return;
    
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => AddReviewScreen(
          establishment: _establishment!,
        ),
      ),
    );
    
    // Si un avis a été ajouté, recharger les avis
    if (result == true) {
      await _loadReviews();
    }
  }

  Future<void> _toggleFavorite() async {
    if (_establishment == null) return;
    
    try {
      if (_isFavorite) {
        await _favoritesService.removeFavorite(_establishment!.id);
      } else {
        await _favoritesService.addFavorite(_establishment!.id);
      }
      
      setState(() {
        _isFavorite = !_isFavorite;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isFavorite ? 'Ajouté aux favoris' : 'Retiré des favoris',
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _launchUrl(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Impossible d\'ouvrir le lien')),
      );
    }
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final url = 'tel:$phoneNumber';
    await _launchUrl(url);
  }

  Future<void> _sendEmail(String email) async {
    final url = 'mailto:$email';
    await _launchUrl(url);
  }

  Future<void> _shareEstablishment() async {
    if (_establishment == null) return;
    
    try {
      // Construire le message de partage
      final String shareText = ''
          '🏨 ${_establishment!.name}\n'
          '📍 ${_establishment!.address}\n'
          '⭐ ${_establishment!.formattedRating} (${_establishment!.reviewCount ?? 0} avis)\n'
          '\n'
          '${_establishment!.description ?? "Découvrez cet établissement sur Touris !"}\n'
          '\n'
          '📱 Téléchargez l\'app Touris pour plus d\'informations';
      
      // Si le site web est disponible, l'ajouter
      final String finalText = _establishment!.website != null 
          ? '$shareText\n\n🌐 ${_establishment!.website!}'
          : shareText;
      
      // Obtenir la position du bouton de partage pour iOS
      final box = _shareButtonKey.currentContext?.findRenderObject() as RenderBox?;
      final sharePositionOrigin = box != null
          ? box.localToGlobal(Offset.zero) & box.size
          : null;
      
      await Share.share(
        finalText,
        subject: 'Découvrez ${_establishment!.name} sur Touris',
        sharePositionOrigin: sharePositionOrigin,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors du partage: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Chargement...'),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_hasError || _establishment == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Erreur'),
        ),
        body: Center(
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
                onPressed: _loadEstablishmentDetails,
                child: const Text('Réessayer'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          _buildContent(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _toggleFavorite,
        backgroundColor: _isFavorite ? Colors.red : Colors.grey,
        child: Icon(
          _isFavorite ? Icons.favorite : Icons.favorite_border,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 300.0,
      floating: false,
      pinned: true,
      backgroundColor: Theme.of(context).primaryColor,
      foregroundColor: Colors.white,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          _establishment!.name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Colors.white,
            shadows: [
              Shadow(
                offset: Offset(0, 2),
                blurRadius: 8.0,
                color: Colors.black,
              ),
              Shadow(
                offset: Offset(0, 1),
                blurRadius: 4.0,
                color: Colors.black,
              ),
              Shadow(
                offset: Offset(1, 1),
                blurRadius: 3.0,
                color: Colors.black,
              ),
            ],
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        ),
        background: Stack(
          fit: StackFit.expand,
          children: [
            _buildImageCarousel(),
            // Dégradé en bas pour améliorer la lisibilité du titre
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: 120,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.7),
                      Colors.black.withValues(alpha: 0.5),
                      Colors.black.withValues(alpha: 0.3),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        IconButton(
          key: _shareButtonKey,
          icon: const Icon(Icons.share),
          onPressed: _shareEstablishment,
          tooltip: 'Partager cet établissement',
        ),
      ],
    );
  }

  Widget _buildImageCarousel() {
    // Utiliser ImageService pour obtenir les URLs complètes
    final images = ImageService.getEstablishmentImages(_establishment!);
    
    if (images.isEmpty) {
      return Container(
        color: Colors.grey[300],
        child: const Center(
          child: Icon(
            Icons.image,
            size: 64,
            color: Colors.grey,
          ),
        ),
      );
    }

    return Stack(
      children: [
        PageView.builder(
          controller: _pageController,
          onPageChanged: (index) {
            setState(() {
              _currentImageIndex = index;
            });
          },
          itemCount: images.length,
          itemBuilder: (context, index) {
            final imageUrl = images[index];
            
            return GestureDetector(
              onTap: () {
                // Ouvrir la galerie en plein écran
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FullScreenImageGallery(
                      imageUrls: images,
                      initialIndex: index,
                      title: _establishment!.name,
                    ),
                  ),
                );
              },
              child: _buildCarouselImage(imageUrl),
            );
          },
        ),
        // Indicateur de page avec compteur
        Positioned(
          bottom: 16,
          right: 16,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.75),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.2),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              '${_currentImageIndex + 1}/${images.length}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
                shadows: [
                  Shadow(
                    offset: Offset(0, 1),
                    blurRadius: 2.0,
                    color: Colors.black,
                  ),
                ],
              ),
            ),
          ),
        ),
        // Indicateurs de points (dots)
        if (images.length > 1)
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                images.length,
                (index) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentImageIndex == index
                        ? Colors.white
                        : Colors.white.withValues(alpha: 0.4),
                    border: Border.all(
                      color: _currentImageIndex == index
                          ? Colors.white.withValues(alpha: 0.5)
                          : Colors.white.withValues(alpha: 0.2),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.5),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
  
  Widget _buildCarouselImage(String imageUrl) {
    // Vérifier si l'URL est valide
    if (imageUrl.isEmpty || !Uri.tryParse(imageUrl)!.isAbsolute) {
      return Container(
        color: Colors.grey[300],
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.broken_image, size: 64, color: Colors.grey),
              SizedBox(height: 8),
              Text('Image non disponible', style: TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      );
    }
    
    return CachedNetworkImage(
      imageUrl: imageUrl,
      fit: BoxFit.cover,
      placeholder: (context, url) => Container(
        color: Colors.grey[300],
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      ),
      errorWidget: (context, url, error) {
        debugPrint('Erreur chargement image: $url - $error');
        // Si erreur 404, essayer d'utiliser une image par défaut au lieu d'afficher l'erreur
        final defaultImages = ImageService.getDefaultImages(_establishment!);
        if (defaultImages.isNotEmpty) {
          return Image.network(
            defaultImages.first,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              color: Colors.grey[300],
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.broken_image, size: 64, color: Colors.grey),
                    SizedBox(height: 8),
                    Text('Image non disponible', style: TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
            ),
          );
        }
        return Container(
          color: Colors.grey[300],
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.broken_image, size: 64, color: Colors.grey),
                SizedBox(height: 8),
                Text('Image non disponible', style: TextStyle(color: Colors.grey)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildContent() {
    return SliverList(
      delegate: SliverChildListDelegate([
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildBasicInfo(),
              const SizedBox(height: 24),
              _buildTabSection(),
            ],
          ),
        ),
      ]),
    );
  }

  Widget _buildBasicInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Chip(
              label: Text(
                _getTypeLabel(_establishment!.type),
                style: const TextStyle(color: Colors.white),
              ),
              backgroundColor: Theme.of(context).primaryColor,
            ),
            const SizedBox(width: 8),
            if (_establishment!.priceRange != null)
              Chip(
                label: Text(_establishment!.priceRange!),
                backgroundColor: Colors.green,
                labelStyle: const TextStyle(color: Colors.white),
              ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            const Icon(Icons.star, color: Colors.amber, size: 20),
            const SizedBox(width: 4),
            Text(
              _establishment!.formattedRating,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '(${_establishment!.reviewCount ?? 0} avis)',
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (_establishment!.description != null)
          Text(
            _establishment!.description!,
            style: const TextStyle(fontSize: 16),
          ),
      ],
    );
  }

  Widget _buildTabSection() {
    return Column(
      children: [
        TabBar(
          controller: _tabController,
          labelColor: Theme.of(context).primaryColor,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Theme.of(context).primaryColor,
          tabs: const [
            Tab(text: 'Infos'),
            Tab(text: 'Avis'),
            Tab(text: 'Promotions'),
          ],
        ),
        Container(
          constraints: BoxConstraints(
            minHeight: 400,
            maxHeight: MediaQuery.of(context).size.height * 0.6,
          ),
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildInfoTab(),
              _buildReviewsTab(),
              _buildPromotionsTab(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildContactInfo(),
          const SizedBox(height: 24),
          _buildLocationSection(),
          const SizedBox(height: 24),
          if (_establishment!.amenities != null &&
              _establishment!.amenities!.isNotEmpty)
            _buildAmenitiesSection(),
        ],
      ),
    );
  }

  Widget _buildContactInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Contact',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ListTile(
          leading: const Icon(Icons.location_on),
          title: Text(_establishment!.address),
          contentPadding: EdgeInsets.zero,
        ),
        if (_establishment!.phoneNumber != null)
          ListTile(
            leading: const Icon(Icons.phone),
            title: Text(_establishment!.phoneNumber!),
            contentPadding: EdgeInsets.zero,
            onTap: () => _makePhoneCall(_establishment!.phoneNumber!),
          ),
        if (_establishment!.email != null)
          ListTile(
            leading: const Icon(Icons.email),
            title: Text(_establishment!.email!),
            contentPadding: EdgeInsets.zero,
            onTap: () => _sendEmail(_establishment!.email!),
          ),
        if (_establishment!.website != null)
          ListTile(
            leading: const Icon(Icons.web),
            title: Text(_establishment!.website!),
            contentPadding: EdgeInsets.zero,
            onTap: () => _launchUrl(_establishment!.website!),
          ),
      ],
    );
  }

  Widget _buildLocationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Localisation',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton.icon(
              onPressed: _getUserLocationAndShowDirections,
              icon: const Icon(Icons.directions, size: 18),
              label: const Text('Itinéraire'),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          height: 300, // Carte optimisée pour l'écran
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: LatLng(
                  _establishment!.latitude,
                  _establishment!.longitude,
                ),
                zoom: _userPosition != null ? 13.0 : 15.0,
              ),
              onMapCreated: (GoogleMapController controller) {
                _mapController = controller;
                _getUserLocation();
              },
              markers: _mapMarkers,
              zoomControlsEnabled: true,
              mapToolbarEnabled: false,
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
            ),
          ),
        ),
        const SizedBox(height: 12),
        // Boutons d'action
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _openInGoogleMaps(),
                icon: const Icon(Icons.map),
                label: const Text('Ouvrir dans Maps'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _getUserLocationAndShowDirections,
                icon: const Icon(Icons.navigation),
                label: const Text('Y aller'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAmenitiesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Équipements',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _establishment!.amenities!
              .map((amenity) => Chip(
                    label: Text(amenity),
                    backgroundColor: Colors.grey[200],
                  ))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildReviewsTab() {
    return ListView(
      children: [
        // Statistiques des avis
        if (_reviewStats != null)
          ReviewStatsWidget(
            stats: _reviewStats!,
            onTapWriteReview: _openAddReviewScreen,
          )
        else if (_isLoadingReviews)
          const Padding(
            padding: EdgeInsets.all(32),
            child: Center(child: CircularProgressIndicator()),
          )
        else
          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton.icon(
              onPressed: _openAddReviewScreen,
              icon: const Icon(Icons.rate_review),
              label: const Text('Soyez le premier à laisser un avis'),
            ),
          ),
        
        const SizedBox(height: 8),
        
        // Liste des avis
        if (_reviews.isEmpty && !_isLoadingReviews)
          const Padding(
            padding: EdgeInsets.all(32),
            child: Center(
              child: Text(
                'Aucun avis pour le moment',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          )
        else
          ..._reviews.map((review) => ReviewCard(review: review)),
      ],
    );
  }

  Widget _buildPromotionsTab() {
    final activePromotions = _establishment!.promotions
        ?.where((p) => p.isValid)
        .toList() ?? [];

    if (activePromotions.isEmpty) {
      return const Center(
        child: Text(
          'Aucune promotion disponible',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: activePromotions.length,
      itemBuilder: (context, index) {
        final promotion = activePromotions[index];
        return _buildPromotionCard(promotion);
      },
    );
  }

  Widget _buildPromotionCard(Promotion promotion) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${promotion.discountPercentage}% OFF',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  'Valide jusqu\'au ${_formatDate(promotion.validUntil)}',
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              promotion.title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Text(promotion.description),
          ],
        ),
      ),
    );
  }

  String _getTypeLabel(String type) {
    switch (type.toUpperCase()) {
      case 'HOTEL':
        return 'Hôtel';
      case 'RESTAURANT':
        return 'Restaurant';
      case 'BAR':
        return 'Bar';
      case 'CAFE':
        return 'Café';
      case 'SHOP':
        return 'Boutique';
      case 'SITE':
        return 'Site Touristique';
      default:
        return type;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Future<void> _getUserLocation() async {
    try {
      final position = await _locationService.getCurrentLocation();
      if (position != null && mounted) {
        setState(() {
          _userPosition = position;
        });
        _updateMapMarkers();
      }
    } catch (e) {
      print('Erreur lors de l\'obtention de la position utilisateur: $e');
    }
  }

  void _updateMapMarkers() {
    final markers = <Marker>{};
    
    // Marqueur de l'établissement
    markers.add(
      Marker(
        markerId: MarkerId(_establishment!.id),
        position: LatLng(
          _establishment!.latitude,
          _establishment!.longitude,
        ),
        infoWindow: InfoWindow(
          title: _establishment!.name,
          snippet: _establishment!.address,
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      ),
    );
    
    // Marqueur de l'utilisateur si disponible
    if (_userPosition != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('user_location'),
          position: LatLng(
            _userPosition!.latitude,
            _userPosition!.longitude,
          ),
          infoWindow: const InfoWindow(
            title: 'Votre position',
            snippet: 'Vous êtes ici',
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        ),
      );
    }
    
    setState(() {
      _mapMarkers = markers;
    });
    
    // Ajuster la vue de la carte pour inclure les deux marqueurs
    if (_userPosition != null && _mapController != null) {
      _fitMapToMarkers();
    }
  }

  Future<void> _fitMapToMarkers() async {
    if (_mapController == null || _userPosition == null) return;
    
    final bounds = LatLngBounds(
      southwest: LatLng(
        _userPosition!.latitude < _establishment!.latitude
            ? _userPosition!.latitude
            : _establishment!.latitude,
        _userPosition!.longitude < _establishment!.longitude
            ? _userPosition!.longitude
            : _establishment!.longitude,
      ),
      northeast: LatLng(
        _userPosition!.latitude > _establishment!.latitude
            ? _userPosition!.latitude
            : _establishment!.latitude,
        _userPosition!.longitude > _establishment!.longitude
            ? _userPosition!.longitude
            : _establishment!.longitude,
      ),
    );
    
    await _mapController!.animateCamera(
      CameraUpdate.newLatLngBounds(bounds, 100.0),
    );
  }

  Future<void> _getUserLocationAndShowDirections() async {
    try {
      final position = await _locationService.getCurrentLocation();
      if (position != null) {
        setState(() {
          _userPosition = position;
        });
        _updateMapMarkers();
        
        // Afficher la distance
        final distance = Geolocator.distanceBetween(
          position.latitude,
          position.longitude,
          _establishment!.latitude,
          _establishment!.longitude,
        );
        
        final distanceKm = (distance / 1000).toStringAsFixed(1);
        
        // Afficher un dialogue avec options
        _showDirectionsDialog(distanceKm);
      } else {
        _showLocationPermissionDialog();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur de localisation: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showDirectionsDialog(String distance) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Navigation'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Distance: $distance km'),
            const SizedBox(height: 16),
            const Text('Comment souhaitez-vous naviguer ?'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _openDirectionsInGoogleMaps();
            },
            child: const Text('Google Maps'),
          ),
        ],
      ),
    );
  }

  Future<void> _openInGoogleMaps() async {
    final url = 'https://www.google.com/maps/search/?api=1&query=${_establishment!.latitude},${_establishment!.longitude}';
    await _launchUrl(url);
  }

  Future<void> _openDirectionsInGoogleMaps() async {
    if (_userPosition != null) {
      final url = 'https://www.google.com/maps/dir/?api=1&origin=${_userPosition!.latitude},${_userPosition!.longitude}&destination=${_establishment!.latitude},${_establishment!.longitude}&travelmode=driving';
      await _launchUrl(url);
    } else {
      final url = 'https://www.google.com/maps/dir/?api=1&destination=${_establishment!.latitude},${_establishment!.longitude}';
      await _launchUrl(url);
    }
  }

  void _showLocationPermissionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Permission de localisation'),
        content: const Text(
          'Pour afficher l\'itinéraire, nous avons besoin d\'accéder à votre position. Veuillez autoriser l\'accès à la localisation dans les paramètres.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Plus tard'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Geolocator.openLocationSettings();
            },
            child: const Text('Ouvrir les paramètres'),
          ),
        ],
      ),
    );
  }
}

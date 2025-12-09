import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';
import 'package:share_plus/share_plus.dart';
import '../models/site.dart';
import '../services/sites_service.dart';
import '../services/favorites_service.dart';
import '../services/location_service.dart';
import '../services/image_service.dart';

class SiteDetailScreen extends ConsumerStatefulWidget {
  final String siteId;

  const SiteDetailScreen({
    super.key,
    required this.siteId,
  });

  @override
  ConsumerState<SiteDetailScreen> createState() =>
      _SiteDetailScreenState();
}

class _SiteDetailScreenState
    extends ConsumerState<SiteDetailScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final SitesService _sitesService = SitesService();
  final FavoritesService _favoritesService = FavoritesService();
  final LocationService _locationService = LocationService();
  final GlobalKey _shareButtonKey = GlobalKey();
  
  Site? _site;
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';
  bool _isFavorite = false;
  int _currentImageIndex = 0;
  late PageController _pageController;
  Position? _userPosition;
  GoogleMapController? _mapController;
  Set<Marker> _mapMarkers = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this); // Sites ont 2 onglets: Infos et Avis
    _pageController = PageController();
    _loadSiteDetails();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadSiteDetails() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final site = await _sitesService.getSiteById(widget.siteId);
      
      setState(() {
        _site = site;
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

  Future<void> _shareSite() async {
    if (_site == null) return;
    
    try {
      // Construire le message de partage
      final String shareText = ''
          '🏡 ${_site!.name}\n'
          '📍 ${_site!.address}\n'
          '\n'
          '${_site!.description}\n'
          '\n'
          '📱 Téléchargez l\'app Touris pour plus d\'informations';
      
      // Si le site web est disponible, l'ajouter
      final String finalText = _site!.website != null 
          ? '$shareText\n\n🌐 ${_site!.website!}'
          : shareText;
      
      // Obtenir la position du bouton de partage pour iOS
      final box = _shareButtonKey.currentContext?.findRenderObject() as RenderBox?;
      final sharePositionOrigin = box != null
          ? box.localToGlobal(Offset.zero) & box.size
          : null;
      
      await Share.share(
        finalText,
        subject: 'Découvrez ${_site!.name} sur Touris',
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

    if (_hasError || _site == null) {
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
                onPressed: _loadSiteDetails,
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
          _site!.name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                offset: Offset(0, 1),
                blurRadius: 3.0,
                color: Color.fromARGB(255, 0, 0, 0),
              ),
            ],
          ),
        ),
        background: _buildImageCarousel(),
      ),
      actions: [
        IconButton(
          key: _shareButtonKey,
          icon: const Icon(Icons.share),
          onPressed: _shareSite,
          tooltip: 'Partager ce site',
        ),
      ],
    );
  }

  Widget _buildImageCarousel() {
    // Utiliser ImageService pour obtenir les URLs complètes
    final images = ImageService.getSiteImages(_site!);
    
    if (images.isEmpty) {
      return Container(
        color: Colors.grey[300],
        child: const Center(
          child: Icon(
            Icons.place,
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
                final defaultImages = ImageService.getDefaultSiteImages(_site!);
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
          },
        ),
        // Indicateur de page avec compteur
        Positioned(
          bottom: 16,
          right: 16,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.6),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${_currentImageIndex + 1}/${images.length}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
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
                        : Colors.white.withOpacity(0.4),
                  ),
                ),
              ),
            ),
          ),
      ],
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
                _getTypeLabel(_site!.type),
                style: const TextStyle(color: Colors.white),
              ),
              backgroundColor: Theme.of(context).primaryColor,
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          _site!.description,
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
          if (_site!.amenities.isNotEmpty)
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
          title: Text(_site!.address),
          contentPadding: EdgeInsets.zero,
        ),
        if (_site!.phone != null)
          ListTile(
            leading: const Icon(Icons.phone),
            title: Text(_site!.phone!),
            contentPadding: EdgeInsets.zero,
            onTap: () => _makePhoneCall(_site!.phone!),
          ),
        if (_site!.email != null)
          ListTile(
            leading: const Icon(Icons.email),
            title: Text(_site!.email!),
            contentPadding: EdgeInsets.zero,
            onTap: () => _sendEmail(_site!.email!),
          ),
        if (_site!.website != null)
          ListTile(
            leading: const Icon(Icons.web),
            title: Text(_site!.website!),
            contentPadding: EdgeInsets.zero,
            onTap: () => _launchUrl(_site!.website!),
          ),
      ],
    );
  }

  Widget _buildLocationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Localisation',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          height: 300,
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
                  _site!.latitude,
                  _site!.longitude,
                ),
                zoom: 15.0,
              ),
              onMapCreated: (GoogleMapController controller) {
                _mapController = controller;
                setState(() {
                  _mapMarkers = {
                    Marker(
                      markerId: MarkerId(_site!.id),
                      position: LatLng(
                        _site!.latitude,
                        _site!.longitude,
                      ),
                      infoWindow: InfoWindow(
                        title: _site!.name,
                        snippet: _site!.address,
                      ),
                    ),
                  };
                });
              },
              markers: _mapMarkers,
              zoomControlsEnabled: true,
              mapToolbarEnabled: false,
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
            ),
          ),
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
          children: _site!.amenities
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
    return const Center(
      child: Text(
        'Avis bientôt disponibles',
        style: TextStyle(color: Colors.grey),
      ),
    );
  }

  String _getTypeLabel(String type) {
    switch (type.toUpperCase()) {
      case 'MONUMENT':
        return 'Monument';
      case 'MUSÉE':
      case 'MUSEE':
        return 'Musée';
      case 'PARC':
        return 'Parc';
      case 'ÉGLISE':
      case 'EGLISE':
        return 'Église';
      case 'CHÂTEAU':
      case 'CHATEAU':
        return 'Château';
      case 'SITE_NATUREL':
        return 'Site naturel';
      case 'PLACE':
        return 'Place';
      default:
        return type;
    }
  }
}
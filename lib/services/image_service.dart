import '../models/establishment.dart';
import '../models/site.dart';
import '../core/constants/api_constants.dart';

class ImageService {
  /// Convertit un chemin d'image relatif en URL absolue
  /// Gère les URLs Cloudinary et les chemins locaux
  static String getFullImageUrl(String imagePath) {
    // Si vide, retourner une chaîne vide
    if (imagePath.isEmpty) return '';
    
    // Si c'est déjà une URL complète (Cloudinary, Unsplash, etc.), la retourner telle quelle
    if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
      return imagePath;
    }
    
    // Si c'est un chemin relatif, ajouter l'URL du serveur
    final baseUrl = ApiConstants.baseUrl;
    // Nettoyer le chemin pour éviter les doubles slashes
    final cleanPath = imagePath.startsWith('/') ? imagePath.substring(1) : imagePath;
    return '$baseUrl/$cleanPath';
  }
  
  /// Convertit une URL d'image Cloudinary thumbnail en URL complète
  /// Si l'URL contient _thumb, retirer ce suffixe pour obtenir l'image complète
  static String getFullSizeImageUrl(String imageUrl) {
    if (imageUrl.contains('_thumb.')) {
      return imageUrl.replaceAll('_thumb.', '.');
    }
    return imageUrl;
  }
  /// Génère des URLs d'images par défaut selon le type d'établissement
  static List<String> getDefaultImages(Establishment establishment) {
    switch (establishment.type.toLowerCase()) {
      case 'hotel':
        return [
          'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=500&h=300&fit=crop',
          'https://images.unsplash.com/photo-1582719478250-c89cae4dc85b?w=500&h=300&fit=crop',
        ];
      case 'restaurant':
        return [
          'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?w=500&h=300&fit=crop',
          'https://images.unsplash.com/photo-1552566062-01b8c7f40d7d?w=500&h=300&fit=crop',
        ];
      case 'bar':
        return [
          'https://images.unsplash.com/photo-1514933651103-005eec06c04b?w=500&h=300&fit=crop',
        ];
      case 'cafe':
        return [
          'https://images.unsplash.com/photo-1501339847302-ac426a4a7cbb?w=500&h=300&fit=crop',
        ];
      default:
        return [
          'https://images.unsplash.com/photo-1540553016722-983e48a2cd10?w=500&h=300&fit=crop',
        ];
    }
  }

  /// Récupère les images d'un établissement (vraies ou par défaut)
  static List<String> getEstablishmentImages(Establishment establishment) {
    if (establishment.images != null && establishment.images!.isNotEmpty) {
      // Convertir tous les chemins relatifs en URLs complètes
      // Utiliser les versions full-size (sans _thumb) pour l'affichage en grand
      final images = establishment.images!
          .map((img) {
            final fullUrl = getFullImageUrl(img);
            // Si c'est un thumbnail Cloudinary, essayer d'obtenir l'image complète
            // mais garder le thumbnail comme fallback en cas d'erreur
            return fullUrl;
          })
          .where((url) => url.isNotEmpty)
          .toList();
      
      if (images.isEmpty) {
        return getDefaultImages(establishment);
      }
      
      return images;
    }
    return getDefaultImages(establishment);
  }

  /// Récupère l'image principale d'un établissement
  static String getMainImage(Establishment establishment) {
    final images = getEstablishmentImages(establishment);
    return images.isNotEmpty ? images.first : getDefaultImages(establishment).first;
  }

  /// Génère des URLs d'images par défaut selon le type de site
  static List<String> getDefaultSiteImages(Site site) {
    switch (site.type.toLowerCase()) {
      case 'monument':
        return [
          'https://images.unsplash.com/photo-1555881400-74d7acaacd8b?w=500&h=300&fit=crop',
        ];
      case 'musée':
      case 'museum':
        return [
          'https://images.unsplash.com/photo-1565183997392-2f1b8794527f?w=500&h=300&fit=crop',
        ];
      case 'parc':
      case 'park':
        return [
          'https://images.unsplash.com/photo-1441974231531-c6227db76b6e?w=500&h=300&fit=crop',
        ];
      case 'église':
      case 'church':
        return [
          'https://images.unsplash.com/photo-1518455027359-f3f8164ba6bd?w=500&h=300&fit=crop',
        ];
      case 'château':
      case 'castle':
        return [
          'https://images.unsplash.com/photo-1599582378239-0b8f4834d5f1?w=500&h=300&fit=crop',
        ];
      case 'site naturel':
      case 'natural site':
        return [
          'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=500&h=300&fit=crop',
        ];
      case 'place':
        return [
          'https://images.unsplash.com/photo-1520271348391-049dd132bb7c?w=500&h=300&fit=crop',
        ];
      default:
        return [
          'https://images.unsplash.com/photo-1488646953014-85cb44e25828?w=500&h=300&fit=crop',
        ];
    }
  }

  /// Récupère les images d'un site (vraies ou par défaut)
  static List<String> getSiteImages(Site site) {
    if (site.images.isNotEmpty) {
      // Convertir tous les chemins relatifs en URLs complètes et filtrer les URLs vides ou invalides
      final validImages = site.images
          .map((img) => getFullImageUrl(img))
          .where((url) => url.isNotEmpty)
          .toList();
      
      // Si aucune image valide, retourner les images par défaut
      if (validImages.isEmpty) {
        return getDefaultSiteImages(site);
      }
      
      return validImages;
    }
    return getDefaultSiteImages(site);
  }

  /// Récupère l'image principale d'un site
  static String getMainSiteImage(Site site) {
    final images = getSiteImages(site);
    return images.isNotEmpty ? images.first : getDefaultSiteImages(site).first;
  }
}

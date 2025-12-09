# Intégration des images Cloudinary dans l'application mobile

## Date de mise à jour
1er Novembre 2025

## Contexte

Le backend `listing-backend` utilise maintenant **Cloudinary** pour stocker les images des établissements et sites touristiques au lieu du stockage local.

## Changements du backend

### Système de stockage
- **Avant** : Stockage local dans `public/uploads/establishments/`
- **Après** : Stockage cloud sur Cloudinary
- **URLs retournées** : URLs complètes Cloudinary 
  - Exemple : `https://res.cloudinary.com/[cloud]/image/upload/v[version]/touris-listings/establishments/establishment-123456.jpg`

### Configuration Cloudinary
- **Dossier établissements** : `touris-listings/establishments`
- **Dossier sites** : `touris-listings/sites`
- **Formats** : JPG, JPEG, PNG, WebP
- **Limite** : 5 MB par fichier, max 10 images
- **Optimisation** : Transformation automatique (1200x800, quality: auto:good)

### Détection du client mobile
Le backend détecte et optimise les réponses pour mobile :
- **Header requis** : `X-Client-Type: mobile`
- **Optimisation** : Maximum 2 images pour mobile (au lieu de toutes)
- **Données allégées** : Champs non essentiels omis dans les listings

## Modifications apportées à l'application mobile

### ✅ 1. ApiService (`lib/core/network/api_service.dart`)

**Ajout du header de détection mobile :**
```dart
headers: {
  'Content-Type': 'application/json',
  'Accept': 'application/json',
  'X-Client-Type': 'mobile', // Identifier l'app mobile pour le backend
},
```

**Impact :**
- Le backend retourne maintenant max 2 images au lieu de toutes
- Réponses optimisées pour mobile (données allégées)
- Meilleure performance réseau

### ✅ 2. ImageService (`lib/services/image_service.dart`)

**Amélioration de la gestion des URLs :**
```dart
static String getFullImageUrl(String imagePath) {
  // Si vide, retourner une chaîne vide
  if (imagePath.isEmpty) return '';
  
  // Si c'est déjà une URL complète (Cloudinary, Unsplash, etc.), la retourner telle quelle
  if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
    return imagePath;
  }
  
  // Si c'est un chemin relatif, ajouter l'URL du serveur local
  final baseUrl = ApiConstants.baseUrl;
  final cleanPath = imagePath.startsWith('/') ? imagePath : '/$imagePath';
  return '$baseUrl$cleanPath';
}
```

**Comportement :**
- ✅ URLs Cloudinary : Retournées telles quelles
- ✅ URLs Unsplash (images par défaut) : Retournées telles quelles
- ✅ Chemins relatifs : Convertis en URLs complètes avec baseUrl
- ✅ Chaînes vides : Gérées proprement

### ✅ 3. Modèle Establishment (`lib/models/establishment.dart`)

**Format des images :**
```dart
final List<String>? images;
```

Le modèle accepte déjà les URLs complètes via `json_serializable`.

**Exemples de formats supportés :**
- Cloudinary : `https://res.cloudinary.com/.../image.jpg`
- Unsplash : `https://images.unsplash.com/.../image.jpg`
- Chemin relatif : `/uploads/establishments/image.jpg` → converti en `http://localhost:3000/uploads/establishments/image.jpg`

## Widgets d'affichage existants

### OptimizedNetworkImage (`lib/shared/widgets/optimized_image.dart`)
✅ **Compatible Cloudinary**
- Utilise `CachedNetworkImage`
- Gestion du cache mémoire et disque
- Placeholder avec progression
- Error widget élégant

### EstablishmentCard (`lib/widgets/establishment_card.dart`)
✅ **Compatible Cloudinary**
```dart
Image.network(
  ImageService.getMainImage(widget.establishment),
  height: 220,
  width: double.infinity,
  fit: BoxFit.cover,
  errorBuilder: (context, error, stackTrace) => ...
)
```

### EstablishmentDetailScreen (`lib/screens/establishment_detail_screen.dart`)
✅ **Compatible Cloudinary**
- Carousel d'images avec `CachedNetworkImage`
- Validation des URLs avant affichage
- Gestion élégante des erreurs

## Tests à effectuer

### ✅ Tests automatiques (via code)
1. URLs Cloudinary complètes
2. URLs Unsplash (images par défaut)
3. Chemins relatifs
4. Images vides/nulles

### ⚠️ Tests manuels requis
1. **Lancer l'app et vérifier les images**
   ```bash
   cd "/Users/christopherjerome/backup mobile/v2-mobile"
   flutter run
   ```

2. **Scénarios à tester :**
   - [ ] Établissements avec images Cloudinary
   - [ ] Établissements sans images (images par défaut)
   - [ ] Détail d'un établissement (carousel)
   - [ ] Performance du cache
   - [ ] Connexion lente (vérifier les placeholders)
   - [ ] Mode hors ligne (vérifier le cache)

3. **Vérifier le header mobile :**
   - Consulter les logs du backend
   - Doit afficher : `📱 [mobile] - GET /api/establishments`
   - Vérifier que max 2 images sont retournées

## Avantages de l'intégration Cloudinary

### Performance
- ✅ CDN mondial → temps de chargement réduit
- ✅ Transformation automatique → images optimisées
- ✅ Cache navigateur/app → moins de requêtes réseau

### Qualité
- ✅ Format WebP supporté → meilleure compression
- ✅ Qualité automatique → adapté à la connexion
- ✅ Responsive images → adapté à l'écran

### Maintenance
- ✅ Pas de gestion de stockage local
- ✅ Backup automatique
- ✅ Sécurité via Cloudinary

## Migration des données existantes

Le backend inclut un script de migration :
```bash
cd /Users/christopherjerome/listing-backend
node migrate-images.js
```

Ce script :
1. Lit les images locales dans `public/uploads/`
2. Upload vers Cloudinary
3. Met à jour la base de données MySQL avec les nouvelles URLs

## Structure des URLs

### Cloudinary
```
https://res.cloudinary.com/[cloud_name]/image/upload/v[version]/[folder]/[public_id].[ext]
```

Exemple :
```
https://res.cloudinary.com/touris-app/image/upload/v1698765432/touris-listings/establishments/establishment-1698765432-123456789.jpg
```

### Transformations Cloudinary disponibles
- **Redimensionnement** : `w_1200,h_800,c_limit`
- **Qualité** : `q_auto:good`
- **Format** : `f_auto` (WebP sur navigateurs compatibles)

## Commandes utiles

### Lancer l'application mobile
```bash
cd "/Users/christopherjerome/backup mobile/v2-mobile"
flutter run
```

### Nettoyer le cache Flutter
```bash
flutter clean
flutter pub get
```

### Régénérer les modèles JSON
```bash
dart run build_runner build --delete-conflicting-outputs
```

### Vérifier les logs du backend
```bash
cd /Users/christopherjerome/listing-backend
npm run dev
# Observer les logs : [mobile] vs [web]
```

## Troubleshooting

### Les images ne s'affichent pas
1. Vérifier que le header `X-Client-Type: mobile` est envoyé
2. Vérifier les URLs dans les logs
3. Tester les URLs Cloudinary dans un navigateur
4. Vérifier la connexion internet

### Erreur CORS
- Cloudinary gère automatiquement CORS
- Si problème, vérifier la configuration Cloudinary

### Cache d'images
```dart
// Vider le cache si nécessaire
await DefaultCacheManager().emptyCache();
```

## Statut final

✅ **L'application mobile est compatible avec Cloudinary**

### Changements effectués
1. ✅ Header `X-Client-Type: mobile` ajouté
2. ✅ ImageService mis à jour pour Cloudinary
3. ✅ Modèles compatibles avec URLs complètes
4. ✅ Widgets d'affichage fonctionnels

### Prochaines étapes
1. ⚠️ Tests manuels avec données réelles
2. ⚠️ Vérifier la performance sur connexion lente
3. ⚠️ Valider le cache d'images
4. ⚠️ Mesurer l'impact sur la consommation de données

## Ressources

- Documentation backend : `/Users/christopherjerome/listing-backend/UPLOAD_IMAGES.md`
- Documentation Cloudinary : `/Users/christopherjerome/listing-backend/CLOUDINARY_SETUP.md`
- Détection client : `/Users/christopherjerome/listing-backend/docs/CLIENT_DETECTION.md`

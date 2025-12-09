# Intégration API listing-backend

## 🔗 Vue d'ensemble

L'application mobile utilise maintenant l'API `listing-backend` pour toutes les opérations de données. L'intégration a été réalisée via les services existants avec conversion automatique des modèles.

## 📡 Services connectés

### 1. SearchService
```dart
// Endpoint: GET /api/establishments
final results = await searchService.searchEstablishments(
  query: 'restaurant',
  categoryId: 'restaurants',
  latitude: 48.8566,
  longitude: 2.3522,
  radius: 5.0,
  sortBy: 'distance',
  page: 1,
  limit: 20,
);
```

**Paramètres supportés :**
- `search` : Recherche textuelle
- `category` : Filtrage par catégorie
- `lat/lng` : Coordonnées géographiques
- `radius` : Rayon de recherche (km)
- `sortBy` : Tri (relevance, distance, rating, name)
- `page/limit` : Pagination

### 2. FavoritesService
```dart
// Endpoints multiples
GET /api/favorites              // Liste des favoris
POST /api/favorites            // Ajouter aux favoris
DELETE /api/favorites/:id      // Supprimer des favoris
GET /api/favorites/:id/check   // Vérifier statut favori
```

**Fonctionnalités :**
- Cache local synchronisé
- Gestion offline avec fallback
- Opérations optimistes pour l'UX

### 3. EstablishmentService (nouveau)
```dart
// Endpoint: GET /api/establishments/:id
final details = await establishmentService.getEstablishmentDetails(id);
```

**Données enrichies :**
- Avis utilisateurs inclus
- Promotions actives filtrées
- Horaires d'ouverture
- Équipements détaillés

## 🔄 Conversion des données

### Mapping automatique Backend → App
```dart
// Backend model → App model
Establishment _convertToAppEstablishment(Map<String, dynamic> json) {
  return Establishment(
    id: json['id']?.toString() ?? '',
    name: json['name'] ?? '',
    categoryId: _mapTypeToCategory(json['type']), // Conversion intelligente
    priceRange: _mapPriceRange(json['price']),    // €/€€/€€€
    // ... autres mappings
  );
}
```

### Gestion des catégories
```dart
String _mapTypeToCategory(String? type) {
  switch (type?.toLowerCase()) {
    case 'hotel': return 'hotels';
    case 'restaurant':
    case 'bar':
    case 'cafe': return 'restaurants';
    case 'attraction':
    case 'museum': return 'tourism';
    case 'event': return 'events';
    default: return 'tourism';
  }
}
```

## 🛡️ Gestion d'erreurs

### Stratégie de resilience
1. **Retry automatique** sur erreurs réseau
2. **Cache local** pour les favoris
3. **Fallback** avec suggestions locales
4. **Feedback utilisateur** informatif

### Gestion des états
```dart
try {
  final response = await _apiService.get(endpoint);
  if (response.statusCode == 200) {
    // Succès
  } else {
    throw Exception('HTTP ${response.statusCode}');
  }
} catch (e) {
  // Fallback ou retry
  throw Exception('Erreur API: $e');
}
```

## 🔧 Configuration requise

### 1. ApiService initialisé
```dart
void main() {
  ApiService().init(); // Dans main.dart
  runApp(MyApp());
}
```

### 2. Endpoints configurés
```dart
// api_constants.dart
static const String establishments = '$apiPath/establishments';
static const String reviews = '$apiPath/reviews';
// ... autres endpoints
```

### 3. Headers d'authentification
```dart
// Automatiquement ajoutés par ApiService
headers: {
  'Authorization': 'Bearer $token',
  'Content-Type': 'application/json',
}
```

## 📊 Optimisations implémentées

### Cache intelligent
- **Favoris** : Cache en mémoire + API sync
- **Suggestions** : Fallback local si API indisponible
- **Établissements** : Pas de cache (données temps réel)

### Performances
- **Pagination** : 20 éléments par page par défaut
- **Lazy loading** : Chargement à la demande des détails
- **Debouncing** : Suggestions avec délai (300ms)

## 🧪 Tests et validation

### Endpoints testés
- ✅ `GET /api/establishments` - Recherche avec filtres
- ✅ `GET /api/establishments/:id` - Détails établissement  
- ✅ `GET /api/favorites` - Liste favoris
- ✅ `POST /api/favorites` - Ajout favori
- ✅ `DELETE /api/favorites/:id` - Suppression favori

### Cas d'erreur gérés
- ✅ Réseau indisponible
- ✅ API timeout
- ✅ Erreurs HTTP (4xx/5xx)
- ✅ Données malformées
- ✅ Token expiré

## 🚀 Utilisation dans les écrans

### HomeScreen
```dart
// Chargement établissements populaires
final establishments = await _searchService.searchEstablishments(limit: 5);

// Suggestions de recherche
final suggestions = await _searchService.getSearchSuggestions(query);
```

### SearchResultsScreen  
```dart
// Recherche avec filtres
final results = await _searchService.searchEstablishments(
  query: widget.query,
  categoryId: widget.categoryId,
  sortBy: _sortBy,
);
```

### EstablishmentDetailScreen
```dart
// Détails enrichis depuis l'API
final details = await _establishmentService.getEstablishmentDetails(id);
```

### FavoritesScreen
```dart
// Favoris synchronisés
final favorites = await _favoritesService.getFavorites();
```

## 🔮 Évolutions prévues

### Phase 2
- **Avis utilisateurs** : Création/modification d'avis
- **Photos** : Upload d'images utilisateur  
- **Réservations** : Intégration booking
- **Notifications** : Push sur nouveautés

### Phase 3
- **Offline first** : Synchronisation hors ligne
- **GraphQL** : Migration pour optimiser les requêtes
- **Real-time** : WebSockets pour mises à jour live
- **Analytics** : Tracking des interactions utilisateur

---

L'intégration est **complète et fonctionnelle** avec l'API `listing-backend`. L'architecture permet une évolutivité facile et une maintenance simplifiée.
# Architecture de l'application Touris App

## 📱 Vue d'ensemble

Touris App est une application mobile Flutter permettant aux utilisateurs de découvrir et gérer des lieux touristiques (hôtels, restaurants, sites touristiques, événements).

## 🗂️ Structure des dossiers

```
lib/
├── screens/              # Écrans de l'application
│   ├── home_screen.dart
│   ├── search_results_screen.dart
│   ├── establishment_detail_screen.dart
│   ├── favorites_screen.dart
│   ├── profile_screen.dart
│   ├── login_screen.dart
│   ├── register_screen.dart
│   └── main_navigation.dart
├── models/               # Modèles de données
│   ├── category.dart
│   ├── establishment.dart
│   ├── review.dart
│   └── promotion.dart
├── services/             # Services API
│   ├── search_service.dart
│   └── favorites_service.dart
├── widgets/              # Composants réutilisables
│   ├── establishment_card.dart
│   └── category_button.dart
├── shared/               # Code partagé existant
│   ├── models/
│   ├── services/
│   └── widgets/
└── main.dart
```

## 🎨 Écrans implémentés

### 1. Écran d'accueil (`home_screen.dart`)
- **Fonctionnalités** :
  - Barre de recherche intelligente avec suggestions
  - Catégories horizontales (Hôtels, Restaurants, Sites Touristiques, Événements)
  - Liste des établissements populaires
  - Navigation vers les détails d'établissements

### 2. Écran de résultats (`search_results_screen.dart`)
- **Fonctionnalités** :
  - Vue liste et vue carte (TabBar)
  - Filtrage et tri des résultats
  - Markers interactifs sur carte Google Maps
  - Options de tri (pertinence, distance, note, nom)

### 3. Écran de détails (`establishment_detail_screen.dart`)
- **Fonctionnalités** :
  - Carrousel d'images avec compteur
  - Informations détaillées (description, équipements, horaires)
  - Système d'avis avec notation
  - Promotions actives
  - Actions rapides (appel, site web, itinéraire)
  - Carte de localisation intégrée

### 4. Écran de favoris (`favorites_screen.dart`)
- **Fonctionnalités** :
  - Liste des lieux favoris
  - Gestion des favoris (ajout/suppression)
  - Actualisation par pull-to-refresh
  - État vide avec incitation à explorer

### 5. Écran de profil (`profile_screen.dart`)
- **Fonctionnalités** :
  - Informations utilisateur avec avatar
  - Gestion des paramètres (langue, notifications)
  - Section d'aide et assistance
  - Déconnexion sécurisée
  - État non-connecté avec invitation

### 6. Écrans d'authentification
- **Connexion** (`login_screen.dart`) :
  - Email/mot de passe avec validation
  - Connexion via Google et Facebook
  - Mot de passe oublié
  - Option "Se souvenir de moi"

- **Inscription** (`register_screen.dart`) :
  - Formulaire complet avec validation robuste
  - Conditions d'utilisation
  - Authentification sociale
  - Validation de mot de passe sécurisé

## 🏗️ Modèles de données

### Category
```dart
class Category {
  final String id;
  final String name;
  final String icon;
  final String color;
}
```

### Establishment
```dart
class Establishment {
  final String id;
  final String name;
  final String type;
  final String categoryId;
  final String address;
  final double latitude;
  final double longitude;
  final double? rating;
  final int? reviewCount;
  final String? description;
  final List<String>? images;
  final List<String>? amenities;
  final String? priceRange;
  final bool? isOpen;
  final List<Review>? reviews;
  final List<Promotion>? promotions;
  final bool isFavorite;
}
```

### Review
```dart
class Review {
  final String id;
  final String userId;
  final String userName;
  final String userAvatar;
  final int rating;
  final String comment;
  final DateTime createdAt;
  final List<String>? images;
}
```

### Promotion
```dart
class Promotion {
  final String id;
  final String title;
  final String description;
  final double? discount;
  final String? discountType;
  final DateTime startDate;
  final DateTime endDate;
  final bool isActive;
}
```

## 🔧 Services

### SearchService
- **Intégration API** : Utilise l'API `listing-backend` via ApiService
- **Recherche avancée** : Filtres par catégorie, localisation, rayon
- **Suggestions intelligentes** : Suggestions en temps réel depuis l'API
- **Conversion de données** : Mappe les données backend vers les modèles app

### FavoritesService
- **API endpoints** : GET/POST/DELETE `/api/favorites`
- **Cache intelligent** : Cache local avec synchronisation API
- **Gestion d'erreurs** : Fallback vers cache local
- **Optimisations** : Vérifications rapides en cache

### EstablishmentService
- **Détails complets** : Récupère établissements avec avis et promotions
- **Avis utilisateurs** : Intégration avec système de reviews
- **Promotions actives** : Filtrage automatique des offres valides
- **Données enrichies** : Horaires, équipements, géolocalisation

## 🎯 Composants réutilisables

### EstablishmentCard
- Carte d'établissement avec image
- Gestion des favoris intégrée
- Indicateurs de promotions et statut
- Actions tactiles optimisées

### CategoryButton
- Bouton de catégorie stylisé
- État sélectionné/non-sélectionné
- Icônes et couleurs personnalisées

## 🚀 Fonctionnalités avancées

### Authentification
- **Multi-plateforme** : Email/mot de passe + OAuth (Google, Facebook)
- **Sécurité** : Validation robuste, gestion des erreurs
- **UX optimisée** : États de chargement, confirmations

### Géolocalisation
- **Cartes interactives** : Google Maps avec markers personnalisés
- **Navigation** : Intégration avec les applications de navigation
- **Proximité** : Calcul et affichage des distances

### Recherche intelligente
- **Suggestions en temps réel** : API calls optimisés
- **Filtres avancés** : Catégorie, proximité, notation
- **Tri dynamique** : Pertinence, distance, popularité

### Gestion des états
- **Loading states** : Indicateurs de chargement appropriés
- **États vides** : Messages et actions d'encouragement
- **Gestion d'erreurs** : Feedback utilisateur informatif

## 🎨 Design et UX

### Principes de design
- **Material Design 3** : Composants modernes et accessibles
- **Cohérence visuelle** : Palette de couleurs unifiée
- **Responsive** : Adaptation aux différentes tailles d'écran

### Animations et transitions
- **Navigation fluide** : Transitions entre écrans
- **Interactions tactiles** : Feedback visuel immédiat
- **Chargement progressif** : Skeleton screens et placeholders

## 🛠️ Configuration technique

### Dépendances requises
```yaml
dependencies:
  flutter:
    sdk: flutter
  google_maps_flutter: ^2.2.0
  url_launcher: ^6.1.0
  json_annotation: ^4.8.0
  
dev_dependencies:
  build_runner: ^2.4.0
  json_serializable: ^6.6.0
```

### Configuration des cartes
1. Ajouter la clé API Google Maps dans :
   - `android/app/src/main/AndroidManifest.xml`
   - `ios/Runner/AppDelegate.swift`

2. Permissions requises :
   - Localisation (optionnelle)
   - Internet
   - Stockage local

## 🚀 Intégration API listing-backend

### ✅ Réalisé
- **SearchService** : Connecté à `/api/establishments` avec filtres complets
- **FavoritesService** : Intégré avec `/api/favorites` (CRUD complet)
- **EstablishmentService** : Détails via `/api/establishments/:id`
- **Authentification** : Intégration avec le système auth existant
- **Gestion d'erreurs** : Fallbacks et retry automatiques

### Prochaines étapes

### Fonctionnalités additionnelles
- Notifications push
- Partage social
- Réservation en ligne
- Système de recommandations

### Optimisations
- Cache intelligent des images
- Lazy loading des listes
- Performance monitoring

## 📱 Installation et lancement

1. **Cloner le projet** :
```bash
git clone [repository-url]
cd touris_app_mobile
```

2. **Installer les dépendances** :
```bash
flutter pub get
```

3. **Générer les modèles** :
```bash
flutter packages pub run build_runner build
```

4. **Lancer l'application** :
```bash
flutter run
```

---

Cette architecture modulaire et évolutive permet un développement maintenable et une expérience utilisateur optimale pour la découverte de lieux touristiques.
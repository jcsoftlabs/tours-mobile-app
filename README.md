# Touris App Mobile

Application mobile Flutter pour découvrir les meilleurs établissements et sites touristiques. Cette app communique avec l'API listing-backend pour offrir une expérience complète de découverte touristique.

## 🚀 Fonctionnalités

### ✅ Implémentées (MVP)
- **Navigation** : Navigation par onglets avec GoRouter
- **Architecture** : Architecture MVVM avec Riverpod pour la gestion d'état
- **Internationalisation** : Support FR/EN/ES (configuration prête)
- **API Ready** : Configuration Dio pour communiquer avec listing-backend
- **Stockage local** : SharedPreferences configuré pour les favoris
- **Cartes** : Google Maps intégré (API key à configurer)
- **Design** : Material Design 3 avec thème personnalisé

### 🔄 À venir
- Liste des établissements avec données API
- Détails des sites touristiques
- Système de favoris
- Authentification utilisateur
- Vue carte avec markers
- Système d'avis et évaluations

## 🏗️ Architecture

```
lib/
├── core/
│   ├── constants/     # Constantes API, couleurs, etc.
│   ├── network/       # Configuration Dio, interceptors
│   ├── router/        # Configuration GoRouter
│   └── utils/         # Utilitaires globaux
├── features/
│   ├── home/          # Écran d'accueil
│   ├── establishments/# Liste des établissements
│   ├── sites/         # Sites touristiques
│   ├── auth/          # Authentification
│   └── profile/       # Profil utilisateur
└── shared/
    ├── models/        # Modèles de données
    ├── providers/     # Providers Riverpod
    ├── services/      # Services API
    └── widgets/       # Widgets réutilisables
```

## 🛠️ Technologies utilisées

- **Framework** : Flutter 3.9.2+
- **State Management** : Riverpod 2.4.9
- **Navigation** : GoRouter 12.1.3
- **HTTP Client** : Dio 5.4.0
- **Cartes** : Google Maps Flutter 2.5.3
- **Stockage local** : SharedPreferences 2.2.2
- **Internationalisation** : flutter_localizations + intl
- **Images** : Cached Network Image 3.3.1

## 🚦 Configuration

### 1. Prérequis
```bash
flutter --version  # >= 3.9.2
dart --version     # >= 3.9.2
```

### 2. Installation
```bash
cd touris_app_mobile
flutter pub get
flutter gen-l10n
dart run build_runner build
```

### 3. Configuration API
Modifier `lib/core/constants/api_constants.dart` :
```dart
static const String baseUrl = 'https://your-api-domain.com';
// ou pour développement local :
static const String baseUrl = 'https://localhost:3443';
```

## 📱 Lancement

```bash
# Simulateur iOS
flutter run -d "iPhone 15"

# Émulateur Android
flutter run -d emulator-5554

# Appareil physique
flutter run
```

## 🌐 API Integration

L'app est configurée pour communiquer avec l'API listing-backend :

- **Base URL** : `https://localhost:3443` (HTTPS activé)
- **Endpoints prêts** :
  - `/api/auth/*` - Authentification
  - `/api/establishments` - Établissements
  - `/api/sites` - Sites touristiques
  - `/api/reviews` - Avis et évaluations

## 🧪 Tests

```bash
# Tests unitaires et widgets
flutter test

# Test d'analyse statique
flutter analyze
```

Ce projet fait partie de l'écosystème Touris.

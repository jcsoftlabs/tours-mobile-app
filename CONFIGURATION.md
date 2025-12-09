# Configuration pour l'intégration API listing-backend

## 🚀 Étapes de configuration

### 1. Variables d'environnement

Vérifiez que l'URL de l'API est correctement configurée dans `api_constants.dart` :

```dart
// lib/core/constants/api_constants.dart
class ApiConstants {
  // ⚠️ Remplacez par l'URL de votre API listing-backend
  static const String baseUrlHttp = 'http://localhost:3000';
  static const String baseUrlHttps = 'https://localhost:3443';
  
  // Utilisez l'URL appropriée selon votre environnement
  static const String baseUrl = baseUrlHttp; // ou baseUrlHttps
}
```

### 2. Dépendances requises

Ajoutez ces dépendances si pas déjà présentes dans `pubspec.yaml` :

```yaml
dependencies:
  # Réseau et API
  dio: ^5.3.0
  logger: ^2.0.0
  
  # Navigation et gestion d'état
  go_router: ^10.0.0
  flutter_riverpod: ^2.4.0
  
  # Cartes
  google_maps_flutter: ^2.5.0
  
  # Utils
  url_launcher: ^6.1.0
  json_annotation: ^4.8.0
  
dev_dependencies:
  # Génération de code
  build_runner: ^2.4.0
  json_serializable: ^6.7.0
```

### 3. Configuration Google Maps

#### Android (`android/app/src/main/AndroidManifest.xml`)
```xml
<application>
  <!-- Google Maps API Key -->
  <meta-data 
    android:name="com.google.android.geo.API_KEY"
    android:value="VOTRE_CLE_API_GOOGLE_MAPS"/>
</application>
```

#### iOS (`ios/Runner/AppDelegate.swift`)
```swift
import GoogleMaps

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GMSServices.provideAPIKey("VOTRE_CLE_API_GOOGLE_MAPS")
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
```

### 4. Permissions

#### Android (`android/app/src/main/AndroidManifest.xml`)
```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
```

#### iOS (`ios/Runner/Info.plist`)
```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>Cette app utilise la localisation pour trouver des établissements près de vous.</string>
```

### 5. Génération des modèles

Exécutez la génération des modèles JSON :

```bash
flutter packages pub run build_runner build --delete-conflicting-outputs
```

## 🔧 Configuration de développement

### Serveur de développement

1. **Démarrer listing-backend** :
```bash
cd /path/to/listing-backend
npm run dev
```

2. **Vérifier l'URL** dans les constantes API selon votre setup :
```dart
// Localhost (simulateur iOS)
static const String baseUrl = 'http://localhost:3000';

// Localhost (émulateur Android)
static const String baseUrl = 'http://10.0.2.2:3000';

// IP locale (device physique)
static const String baseUrl = 'http://192.168.1.XXX:3000';
```

### Variables d'environnement Flutter

Créez un fichier `.env` (optionnel) :
```
API_BASE_URL=http://localhost:3000
GOOGLE_MAPS_API_KEY=your_api_key_here
```

## 🧪 Tests de l'intégration

### 1. Test de connectivité API

Ajoutez ce widget de test temporaire :

```dart
// lib/widgets/api_test_widget.dart
class ApiTestWidget extends StatefulWidget {
  @override
  _ApiTestWidgetState createState() => _ApiTestWidgetState();
}

class _ApiTestWidgetState extends State<ApiTestWidget> {
  final SearchService _searchService = SearchService();
  String _status = 'Non testé';

  Future<void> _testApi() async {
    try {
      final results = await _searchService.searchEstablishments(limit: 1);
      setState(() {
        _status = 'API OK - ${results.length} résultats';
      });
    } catch (e) {
      setState(() {
        _status = 'Erreur API: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: _testApi,
          child: Text('Tester API'),
        ),
        Text('Status: $_status'),
      ],
    );
  }
}
```

### 2. Logs de débogage

Les logs API sont automatiquement activés. Vérifiez la console pour :
```
[LOG] GET /api/establishments
[LOG] Response 200: {"data": [...]}
```

## 🚀 Déploiement

### Configuration production

1. **URL de production** dans `api_constants.dart` :
```dart
static const String baseUrl = 'https://your-api.domain.com';
```

2. **Certificats SSL** si nécessaire

3. **Clé API Google Maps** de production

### Build release

```bash
# Android
flutter build apk --release

# iOS  
flutter build ios --release
```

## 🔍 Debugging

### Problèmes courants

1. **Erreur de connexion** :
   - Vérifiez l'URL de l'API
   - Testez l'API avec curl/Postman
   - Vérifiez les permissions réseau

2. **Authentification échouée** :
   - Vérifiez le token JWT
   - Regardez les logs d'interceptors

3. **Cartes ne s'affichent pas** :
   - Vérifiez la clé API Google Maps
   - Permissions de localisation accordées

### Logs utiles

```dart
// Activer tous les logs
Logger.level = Level.verbose;

// Logs spécifiques
final logger = Logger();
logger.d('Debug message');
logger.e('Error message');
```

## ✅ Checklist de validation

- [ ] API listing-backend démarrée et accessible
- [ ] URL correcte dans `api_constants.dart`
- [ ] Dépendances installées (`flutter pub get`)
- [ ] Modèles générés (`build_runner build`)
- [ ] Clé Google Maps configurée
- [ ] Permissions déclarées
- [ ] Tests API passants
- [ ] Navigation fonctionnelle entre écrans
- [ ] Authentification connectée

L'intégration est prête ! 🎉
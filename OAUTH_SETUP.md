# Configuration OAuth - Google & Facebook

Ce guide vous aide à configurer l'authentification Google et Facebook pour l'application Touris.

## ✅ Ce qui a été fait

1. ✅ Packages installés : `google_sign_in`, `flutter_facebook_auth`, `sign_in_with_apple`
2. ✅ Code d'authentification implémenté dans `lib/services/auth_service.dart`
3. ✅ Providers mis à jour dans `lib/providers/auth_provider.dart`
4. ✅ Écrans de connexion connectés aux méthodes OAuth
5. ✅ Configuration iOS ajoutée dans `ios/Runner/Info.plist`
6. ✅ Configuration Android ajoutée dans `android/app/src/main/AndroidManifest.xml`

## 🔧 Configuration requise

### 1. Installation des packages

Exécutez cette commande pour installer les dépendances :

```bash
flutter pub get
```

### 2. Configuration Google Sign-In

#### A. Créer un projet Google Cloud

1. Allez sur [Google Cloud Console](https://console.cloud.google.com/)
2. Créez un nouveau projet ou sélectionnez-en un existant
3. Activez l'API "Google Sign-In"

#### B. Créer les identifiants OAuth

**Pour Android :**

1. Dans Google Cloud Console > Identifiants > Créer des identifiants > ID client OAuth 2.0
2. Type : Application Android
3. Nom du package : `com.example.touris_app_mobile` (ou votre package)
4. Obtenez votre SHA-1 avec : `keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android`
5. Copiez l'ID client généré

**Pour iOS :**

1. Dans Google Cloud Console > Identifiants > Créer des identifiants > ID client OAuth 2.0
2. Type : Application iOS
3. ID du bundle : vérifiez dans `ios/Runner.xcodeproj/project.pbxproj`
4. Téléchargez le fichier `GoogleService-Info.plist`
5. Placez-le dans `ios/Runner/`
6. Copiez le `REVERSED_CLIENT_ID` du fichier

**Pour Web (optionnel) :**

1. Créez aussi un ID client OAuth 2.0 de type "Application Web"
2. Ajoutez les origines autorisées
3. Copiez l'ID client

#### C. Mettre à jour les fichiers de configuration

1. Éditez `lib/core/config/oauth_config.dart` :
```dart
static const String googleClientIdIOS = 'VOTRE_IOS_CLIENT_ID.apps.googleusercontent.com';
static const String googleClientIdAndroid = 'VOTRE_ANDROID_CLIENT_ID.apps.googleusercontent.com';
static const String googleClientIdWeb = 'VOTRE_WEB_CLIENT_ID.apps.googleusercontent.com';
```

2. Éditez `ios/Runner/Info.plist` :
```xml
<string>com.googleusercontent.apps.VOTRE_REVERSED_CLIENT_ID</string>
```

### 3. Configuration Facebook Login

#### A. Créer une application Facebook

1. Allez sur [Facebook Developers](https://developers.facebook.com/)
2. Créez une nouvelle application
3. Ajoutez le produit "Facebook Login"

#### B. Obtenir les identifiants

1. Dans le tableau de bord, notez :
   - App ID
   - Client Token (dans Paramètres > Avancé)

#### C. Configurer les plateformes

**Pour Android :**

1. Dans Facebook App > Paramètres > Basique > Ajouter une plateforme > Android
2. Nom du package : `com.example.touris_app_mobile`
3. Hash de clé : 
```bash
keytool -exportcert -alias androiddebugkey -keystore ~/.android/debug.keystore | openssl sha1 -binary | openssl base64
```
4. Activez "Single Sign On"

**Pour iOS :**

1. Dans Facebook App > Paramètres > Basique > Ajouter une plateforme > iOS
2. Bundle ID : vérifiez dans `ios/Runner.xcodeproj/project.pbxproj`
3. Activez "Single Sign On"

#### D. Mettre à jour les fichiers

1. Éditez `lib/core/config/oauth_config.dart` :
```dart
static const String facebookAppId = 'VOTRE_APP_ID';
static const String facebookClientToken = 'VOTRE_CLIENT_TOKEN';
```

2. Éditez `ios/Runner/Info.plist` :
```xml
<string>fbVOTRE_APP_ID</string>
<string>VOTRE_APP_ID</string>
<string>VOTRE_CLIENT_TOKEN</string>
```

3. Éditez `android/app/src/main/res/values/strings.xml` :
```xml
<string name="facebook_app_id">VOTRE_APP_ID</string>
<string name="facebook_client_token">VOTRE_CLIENT_TOKEN</string>
<string name="fb_login_protocol_scheme">fbVOTRE_APP_ID</string>
```

### 4. Configuration Backend (API)

Votre backend doit implémenter les endpoints suivants :

#### Google Sign-In
```
POST /api/auth/google
Body: { "idToken": "...", "accessToken": "..." }
Response: { "data": { "user": {...}, "token": "..." } }
```

#### Facebook Login
```
POST /api/auth/facebook
Body: { "accessToken": "...", "userId": "..." }
Response: { "data": { "user": {...}, "token": "..." } }
```

#### Apple Sign In (iOS)
```
POST /api/auth/apple
Body: { "identityToken": "...", "authorizationCode": "...", "email": "...", "givenName": "...", "familyName": "..." }
Response: { "data": { "user": {...}, "token": "..." } }
```

Le backend doit :
1. Vérifier le token avec l'API Google/Facebook/Apple
2. Créer ou retrouver l'utilisateur dans votre base de données
3. Générer un JWT token pour votre application
4. Retourner les informations utilisateur et le token

### 5. Test

1. **Android :**
```bash
flutter run -d android
```

2. **iOS :**
```bash
cd ios && pod install && cd ..
flutter run -d ios
```

3. **Tester les connexions :**
   - Cliquez sur "Se connecter avec Google"
   - Cliquez sur "Se connecter avec Facebook"
   - Vérifiez que l'authentification fonctionne

## 🔍 Dépannage

### Google Sign-In ne fonctionne pas

- Vérifiez que le SHA-1 est correct
- Assurez-vous que le package name correspond
- Vérifiez les logs : `flutter logs`

### Facebook Login ne fonctionne pas

- Vérifiez que l'App ID et Client Token sont corrects
- Assurez-vous que le hash de clé correspond
- Vérifiez que Facebook Login est activé dans le dashboard

### Erreurs de configuration

- Vérifiez que tous les placeholders "YOUR_..." ont été remplacés
- Assurez-vous que le backend est configuré correctement
- Consultez les logs natifs avec `adb logcat` (Android) ou Xcode (iOS)

## 📚 Ressources

- [Google Sign-In Flutter](https://pub.dev/packages/google_sign_in)
- [Facebook Login Flutter](https://pub.dev/packages/flutter_facebook_auth)
- [Sign In with Apple](https://pub.dev/packages/sign_in_with_apple)
- [Google Cloud Console](https://console.cloud.google.com/)
- [Facebook Developers](https://developers.facebook.com/)

## ⚠️ Important

- Ne commitez JAMAIS vos vrais identifiants dans le code
- Utilisez des variables d'environnement en production
- Configurez des identifiants différents pour debug et release
- Testez sur de vrais appareils, pas seulement en émulateur

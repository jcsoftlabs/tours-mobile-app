/// Configuration pour l'authentification OAuth (Google, Apple)
/// 
/// IMPORTANT: Ces valeurs doivent être remplacées par vos propres identifiants
/// obtenus depuis:
/// - Google Cloud Console: https://console.cloud.google.com/
/// - Apple Developer: https://developer.apple.com/

class OAuthConfig {
  // Google Sign-In Configuration
  // Obtenir ces valeurs depuis Google Cloud Console > Identifiants
  static const String googleClientIdIOS = '955108400371-ehi0ndlb0750m6rii0t4ep2sjuabnuo8.apps.googleusercontent.com';
  static const String googleClientIdAndroid = '955108400371-7e0dtjedlu93a9kcpvm7qbrqalua5rai.apps.googleusercontent.com';
  static const String googleClientIdWeb = '955108400371-uik3onuhrlibvaik5l6j0a28t8ajg0sd.apps.googleusercontent.com';
  
  // Apple Sign In
  // Configuré automatiquement via le bundle identifier
  static const String appleServiceId = 'YOUR_APPLE_SERVICE_ID';
  static const String appleRedirectUri = 'https://YOUR_BACKEND_URL/auth/apple/callback';
  
  // Scopes pour Google Sign-In
  static const List<String> googleScopes = [
    'email',
    'profile',
  ];
  
}

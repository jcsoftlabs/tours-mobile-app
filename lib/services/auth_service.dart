import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'dart:io' show Platform;
import '../core/network/api_service.dart';
import '../core/constants/api_constants.dart';
import '../core/config/oauth_config.dart';
import '../core/network/error_handler.dart';
import '../models/user.dart';

class AuthService {
  final ApiService _apiService = ApiService();
  User? _currentUser;
  
  // Google Sign-In instance
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: OAuthConfig.googleScopes,
    clientId: Platform.isIOS 
        ? OAuthConfig.googleClientIdIOS 
        : OAuthConfig.googleClientIdAndroid,
  );

  User? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;

  // Inscription avec email/mot de passe
  Future<User> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String country,
    String? phone,
  }) async {
    try {
      print('DEBUG: Tentative d\'inscription pour $email');
      final response = await _apiService.post(
        ApiConstants.authRegister,
        data: {
          'email': email,
          'password': password,
          'firstName': firstName,
          'lastName': lastName,
          'country': country,
          'role': 'USER',
        },
      );

      print('DEBUG: Réponse reçue: ${response.data}');
      final userData = response.data['data'] ?? response.data;
      final user = User.fromJson(userData['user']);
      final token = userData['token'];

      await _saveToken(token);
      await _saveUser(user);
      _currentUser = user;

      print('DEBUG: Inscription réussie pour ${user.email}');
      return user;
    } catch (e) {
      print('DEBUG: Erreur lors de l\'inscription: $e');
      throw _handleAuthError(e);
    }
  }

  // Connexion avec email/mot de passe
  Future<User> login({
    required String email,
    required String password,
  }) async {
    try {
      print('DEBUG Login: Tentative de connexion pour $email');
      
      final response = await _apiService.post(
        ApiConstants.authLogin,
        data: {
          'email': email,
          'password': password,
        },
      );

      print('DEBUG Login: Réponse reçue: ${response.data}');
      print('DEBUG Login: Status code: ${response.statusCode}');

      final userData = response.data['data'] ?? response.data;
      print('DEBUG Login: userData: $userData');
      
      final user = User.fromJson(userData['user']);
      print('DEBUG Login: User créé: ${user.email}');
      
      final token = userData['token'];
      print('DEBUG Login: Token reçu: ${token.substring(0, 20)}...');

      await _saveToken(token);
      print('DEBUG Login: Token sauvegardé');
      
      await _saveUser(user);
      print('DEBUG Login: User sauvegardé');
      
      _currentUser = user;

      print('DEBUG Login: Connexion réussie pour ${user.email}');
      return user;
    } catch (e) {
      print('DEBUG Login: Erreur lors de la connexion: $e');
      print('DEBUG Login: Type d\'erreur: ${e.runtimeType}');
      if (e is DioException) {
        print('DEBUG Login: DioException response: ${e.response?.data}');
        print('DEBUG Login: DioException status: ${e.response?.statusCode}');
      }
      throw _handleAuthError(e);
    }
  }

  // Connexion avec Google
  Future<User> loginWithGoogle() async {
    try {
      print('DEBUG Google: Début de la connexion Google');
      
      // Déconnexion pour forcer la sélection du compte
      await _googleSignIn.signOut();
      
      // Lancer le flux de connexion Google
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        throw Exception('Connexion Google annulée');
      }
      
      print('DEBUG Google: Utilisateur Google connecté: ${googleUser.email}');
      
      // Obtenir les détails d'authentification
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final String? idToken = googleAuth.idToken;
      final String? accessToken = googleAuth.accessToken;
      
      if (idToken == null) {
        throw Exception('Impossible d\'obtenir le token Google');
      }
      
      print('DEBUG Google: Token obtenu, envoi au backend');
      
      // Envoyer le token au backend
      final response = await _apiService.post(
        '${ApiConstants.apiPath}/auth/google',
        data: {
          'idToken': idToken,
          'accessToken': accessToken,
        },
      );
      
      print('DEBUG Google: Réponse reçue du backend');
      
      final userData = response.data['data'] ?? response.data;
      final user = User.fromJson(userData['user']);
      final token = userData['token'];
      
      await _saveToken(token);
      await _saveUser(user);
      _currentUser = user;
      
      print('DEBUG Google: Connexion réussie pour ${user.email}');
      return user;
    } catch (e) {
      print('DEBUG Google: Erreur lors de la connexion: $e');
      // Déconnexion en cas d'erreur
      await _googleSignIn.signOut();
      throw _handleAuthError(e);
    }
  }

  // Connexion avec Apple (iOS uniquement)
  Future<User> loginWithApple() async {
    try {
      print('DEBUG Apple: Début de la connexion Apple');
      
      // Vérifier la disponibilité de Sign in with Apple
      final isAvailable = await SignInWithApple.isAvailable();
      if (!isAvailable) {
        throw Exception('Sign in with Apple n\'est pas disponible sur cet appareil');
      }
      
      // Lancer le flux de connexion Apple
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );
      
      print('DEBUG Apple: Credential obtenu');
      
      // Envoyer les informations au backend
      final response = await _apiService.post(
        '${ApiConstants.apiPath}/auth/apple',
        data: {
          'identityToken': credential.identityToken,
          'authorizationCode': credential.authorizationCode,
          'email': credential.email,
          'givenName': credential.givenName,
          'familyName': credential.familyName,
        },
      );
      
      print('DEBUG Apple: Réponse reçue du backend');
      
      final userData = response.data['data'] ?? response.data;
      final user = User.fromJson(userData['user']);
      final token = userData['token'];
      
      await _saveToken(token);
      await _saveUser(user);
      _currentUser = user;
      
      print('DEBUG Apple: Connexion réussie');
      return user;
    } catch (e) {
      print('DEBUG Apple: Erreur lors de la connexion: $e');
      throw _handleAuthError(e);
    }
  }

  // Récupérer le profil utilisateur
  Future<User> getProfile() async {
    try {
      final response = await _apiService.get(ApiConstants.authProfile);
      final userData = response.data['data'] ?? response.data;
      final user = User.fromJson(userData);

      await _saveUser(user);
      _currentUser = user;

      return user;
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  // Mettre à jour le profil
  Future<User> updateProfile({
    String? name,
    String? phone,
    String? language,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (name != null) data['name'] = name;
      if (phone != null) data['phone'] = phone;
      if (language != null) data['language'] = language;

      final response = await _apiService.put(
        ApiConstants.authProfile,
        data: data,
      );

      final userData = response.data['data'] ?? response.data;
      final user = User.fromJson(userData);

      await _saveUser(user);
      _currentUser = user;

      return user;
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  // Déconnexion
  Future<void> logout() async {
    try {
      await _apiService.post(ApiConstants.authLogout);
    } catch (e) {
      // Ignorer les erreurs de déconnexion côté serveur
    } finally {
      await _clearAuthData();
      _currentUser = null;
    }
  }

  // Changement de mot de passe
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      await _apiService.put(
        '${ApiConstants.authProfile}/password',
        data: {
          'currentPassword': currentPassword,
          'newPassword': newPassword,
        },
      );
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  // Demande de récupération de mot de passe
  Future<void> resetPassword({required String email}) async {
    try {
      await _apiService.post(
        ApiConstants.authRequestReset,
        data: {'email': email},
      );
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  // Réinitialisation du mot de passe avec token
  Future<void> confirmResetPassword({
    required String token,
    required String newPassword,
  }) async {
    try {
      await _apiService.post(
        ApiConstants.authResetPassword,
        data: {
          'token': token,
          'newPassword': newPassword,
        },
      );
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  // Initialiser l'authentification au démarrage
  Future<void> init() async {
    try {
      final token = await _getStoredToken();
      if (token != null) {
        _apiService.setAuthToken(token);
        final user = await _getStoredUser();
        if (user != null) {
          _currentUser = user;
          // Vérifier si le token est toujours valide
          await getProfile();
        }
      }
    } catch (e) {
      // Token invalide, nettoyer les données
      await _clearAuthData();
    }
  }

  // Sauvegarder le token
  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
    _apiService.setAuthToken(token);
  }

  // Récupérer le token stocké
  Future<String?> _getStoredToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  // Sauvegarder l'utilisateur
  Future<void> _saveUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_data', jsonEncode(user.toJson()));
  }

  // Récupérer l'utilisateur stocké
  Future<User?> _getStoredUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString('user_data');
    if (userData != null) {
      try {
        final Map<String, dynamic> userMap = jsonDecode(userData);
        return User.fromJson(userMap);
      } catch (e) {
        print('Erreur lors de la désérialisation utilisateur: $e');
        return null;
      }
    }
    return null;
  }

  // Nettoyer les données d'authentification
  Future<void> _clearAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('user_data');
    _apiService.removeAuthToken();
  }

  // Gestion des erreurs d'authentification
  // Utilise ErrorHandler pour masquer les informations sensibles
  Exception _handleAuthError(dynamic error) {
    ErrorHandler.logError(error, context: 'AuthService');
    final userMessage = ErrorHandler.getUserFriendlyMessage(error);
    return Exception(userMessage);
  }
}
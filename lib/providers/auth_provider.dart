import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user.dart';
import '../services/auth_service.dart';

// Provider pour l'instance AuthService (singleton)
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

// Provider pour l'état de l'authentification
final authStateProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final authService = ref.read(authServiceProvider);
  return AuthNotifier(authService);
});

// État de l'authentification
class AuthState {
  final bool isLoading;
  final User? user;
  final String? error;
  final bool isLoggedIn;

  AuthState({
    this.isLoading = false,
    this.user,
    this.error,
    this.isLoggedIn = false,
  });

  AuthState copyWith({
    bool? isLoading,
    User? user,
    String? error,
    bool? isLoggedIn,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      user: user ?? this.user,
      error: error,
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
    );
  }
}

// Notifier pour gérer l'état de l'authentification
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _authService;

  AuthNotifier(this._authService) : super(AuthState()) {
    _initializeAuth();
  }

  // Initialiser l'authentification au démarrage
  Future<void> _initializeAuth() async {
    state = state.copyWith(isLoading: true);
    
    try {
      // Initialiser le service d'authentification
      await _authService.init();
      
      // Vérifier si l'utilisateur est connecté
      if (_authService.isLoggedIn) {
        final user = _authService.currentUser;
        if (user != null) {
          state = state.copyWith(
            isLoading: false,
            user: user,
            isLoggedIn: true,
          );
          return;
        }
        
        // Si pas d'utilisateur en cache, récupérer le profil
        try {
          final profile = await _authService.getProfile();
          state = state.copyWith(
            isLoading: false,
            user: profile,
            isLoggedIn: true,
          );
        } catch (e) {
          // Token invalide, déconnecter
          await _authService.logout();
          state = state.copyWith(
            isLoading: false,
            user: null,
            isLoggedIn: false,
          );
        }
      } else {
        state = state.copyWith(
          isLoading: false,
          user: null,
          isLoggedIn: false,
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
        isLoggedIn: false,
      );
    }
  }

  // Connexion
  Future<void> login({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final user = await _authService.login(
        email: email,
        password: password,
      );
      
      state = state.copyWith(
        isLoading: false,
        user: user,
        isLoggedIn: true,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  // Inscription
  Future<void> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String country,
    String? phone,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final user = await _authService.register(
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
        country: country,
        phone: phone,
      );
      
      state = state.copyWith(
        isLoading: false,
        user: user,
        isLoggedIn: true,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }
  
  // Connexion avec Google
  Future<void> loginWithGoogle() async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final user = await _authService.loginWithGoogle();
      
      state = state.copyWith(
        isLoading: false,
        user: user,
        isLoggedIn: true,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }
  
  // Connexion avec Apple
  Future<void> loginWithApple() async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final user = await _authService.loginWithApple();
      
      state = state.copyWith(
        isLoading: false,
        user: user,
        isLoggedIn: true,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  // Déconnexion
  Future<void> logout() async {
    state = state.copyWith(isLoading: true);
    
    try {
      await _authService.logout();
      state = state.copyWith(
        isLoading: false,
        user: null,
        isLoggedIn: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  // Mettre à jour le profil
  Future<void> updateProfile({
    String? name,
    String? phone,
    String? language,
  }) async {
    if (!state.isLoggedIn) return;
    
    try {
      final updatedUser = await _authService.updateProfile(
        name: name,
        phone: phone,
        language: language,
      );
      
      state = state.copyWith(user: updatedUser);
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  // Rafraîchir le profil utilisateur
  Future<void> refreshProfile() async {
    if (!state.isLoggedIn) return;
    
    try {
      final user = await _authService.getProfile();
      state = state.copyWith(user: user);
    } catch (e) {
      // Si erreur, probablement token expiré
      await logout();
    }
  }

  // Effacer l'erreur
  void clearError() {
    state = state.copyWith(error: null);
  }
}
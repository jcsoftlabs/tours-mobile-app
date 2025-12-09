import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../services/auth_service.dart';

// Auth State
class AuthState {
  final User? user;
  final String? token;
  final bool isLoading;
  final String? error;

  const AuthState({
    this.user,
    this.token,
    this.isLoading = false,
    this.error,
  });

  AuthState copyWith({
    User? user,
    String? token,
    bool? isLoading,
    String? error,
  }) {
    return AuthState(
      user: user ?? this.user,
      token: token ?? this.token,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  bool get isAuthenticated => user != null && token != null;
}

// Auth Notifier
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _authService;
  final SharedPreferences _prefs;

  AuthNotifier(this._authService, this._prefs) : super(const AuthState()) {
    _loadStoredAuth();
  }

  Future<void> _loadStoredAuth() async {
    final token = _prefs.getString('auth_token');
    final userJson = _prefs.getString('user_data');

    if (token != null && userJson != null) {
      try {
        // Parse user from stored JSON
        // For now, we'll implement this later
        state = state.copyWith(token: token);
      } catch (e) {
        // Clear invalid stored data
        await _clearStoredAuth();
      }
    }
  }

  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final authResponse = await _authService.login(email, password);
      
      if (authResponse.success) {
        // Store auth data
        await _prefs.setString('auth_token', authResponse.data.token);
        await _prefs.setString('user_data', authResponse.data.user.toJson().toString());
        
        state = state.copyWith(
          user: authResponse.data.user,
          token: authResponse.data.token,
          isLoading: false,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          error: authResponse.message,
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final authResponse = await _authService.register(
        firstName: firstName,
        lastName: lastName,
        email: email,
        password: password,
      );
      
      if (authResponse.success) {
        // Store auth data
        await _prefs.setString('auth_token', authResponse.data.token);
        await _prefs.setString('user_data', authResponse.data.user.toJson().toString());
        
        state = state.copyWith(
          user: authResponse.data.user,
          token: authResponse.data.token,
          isLoading: false,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          error: authResponse.message,
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> logout() async {
    try {
      await _authService.logout();
    } catch (e) {
      // Log error but continue with logout
    }
    
    await _clearStoredAuth();
    state = const AuthState();
  }

  Future<void> _clearStoredAuth() async {
    await _prefs.remove('auth_token');
    await _prefs.remove('user_data');
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

// Providers
final sharedPreferencesProvider = FutureProvider<SharedPreferences>((ref) async {
  return await SharedPreferences.getInstance();
});

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final authService = ref.watch(authServiceProvider);
  final prefs = ref.watch(sharedPreferencesProvider).value!;
  return AuthNotifier(authService, prefs);
});
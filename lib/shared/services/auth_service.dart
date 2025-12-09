import '../../core/network/api_service.dart';
import '../../core/constants/api_constants.dart';
import '../models/user.dart';

class AuthService {
  final ApiService _apiService = ApiService();

  Future<AuthResponse> login(String email, String password) async {
    final response = await _apiService.post(
      ApiConstants.authLogin,
      data: {
        'email': email,
        'password': password,
      },
    );

    return AuthResponse.fromJson(response.data);
  }

  Future<AuthResponse> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    String role = 'USER',
  }) async {
    final response = await _apiService.post(
      ApiConstants.authRegister,
      data: {
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'password': password,
        'role': role,
      },
    );

    return AuthResponse.fromJson(response.data);
  }

  Future<void> logout() async {
    await _apiService.post(ApiConstants.authLogout);
    _apiService.removeAuthToken();
  }

  Future<User> getProfile() async {
    final response = await _apiService.get(ApiConstants.authProfile);
    
    if (response.data['success'] == true) {
      return User.fromJson(response.data['data']);
    } else {
      throw Exception(response.data['error'] ?? 'Failed to get profile');
    }
  }
}
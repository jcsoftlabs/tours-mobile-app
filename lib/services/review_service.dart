import 'package:dio/dio.dart';
import '../models/review.dart';
import '../models/notification.dart';
import '../core/network/api_service.dart';
import '../core/constants/api_constants.dart';

class ReviewService {
  final ApiService _apiService = ApiService();

  /// Récupère les avis d'un établissement avec filtres
  Future<List<Review>> getReviews({
    String? establishmentId,
    String? userId,
    int? rating,
    int? limit,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (establishmentId != null) queryParams['establishmentId'] = establishmentId;
      if (userId != null) queryParams['userId'] = userId;
      if (rating != null) queryParams['rating'] = rating;
      if (limit != null) queryParams['limit'] = limit;

      final response = await _apiService.get(
        ApiConstants.reviews,
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final List<dynamic> reviewsData = data['data'] ?? [];
        return reviewsData.map((json) => _convertToReview(json)).toList();
      } else {
        throw Exception('Erreur HTTP: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur lors du chargement des avis: $e');
    }
  }

  /// Récupère les statistiques d'avis d'un établissement
  Future<ReviewStats> getReviewStats(String establishmentId) async {
    try {
      final response = await _apiService.get(
        ApiConstants.reviewStats(establishmentId),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        return ReviewStats.fromJson(data['data']);
      } else {
        throw Exception('Erreur HTTP: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur lors du chargement des statistiques: $e');
    }
  }

  /// Crée un nouvel avis (nécessite authentification)
  Future<Review> createReview({
    required String establishmentId,
    required int rating,
    String? comment,
  }) async {
    try {
      if (rating < 1 || rating > 5) {
        throw Exception('La note doit être entre 1 et 5');
      }

      final response = await _apiService.post(
        ApiConstants.reviews,
        data: {
          'establishmentId': establishmentId,
          'rating': rating,
          'comment': comment,
        },
      );

      if (response.statusCode == 201) {
        final data = response.data;
        return _convertToReview(data['data']);
      } else {
        throw Exception('Erreur HTTP: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Vous devez être connecté pour laisser un avis');
      } else if (e.response?.statusCode == 400) {
        final errorMsg = e.response?.data['error'] ?? 'Données invalides';
        throw Exception(errorMsg);
      }
      throw Exception('Erreur lors de la création de l\'avis: ${e.message}');
    } catch (e) {
      throw Exception('Erreur lors de la création de l\'avis: $e');
    }
  }

  /// Met à jour un avis existant
  Future<Review> updateReview({
    required String reviewId,
    int? rating,
    String? comment,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (rating != null) {
        if (rating < 1 || rating > 5) {
          throw Exception('La note doit être entre 1 et 5');
        }
        data['rating'] = rating;
      }
      if (comment != null) data['comment'] = comment;

      final response = await _apiService.put(
        ApiConstants.reviewById(reviewId),
        data: data,
      );

      if (response.statusCode == 200) {
        return _convertToReview(response.data['data']);
      } else {
        throw Exception('Erreur HTTP: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour de l\'avis: $e');
    }
  }

  /// Supprime un avis
  Future<void> deleteReview(String reviewId) async {
    try {
      final response = await _apiService.delete(
        ApiConstants.reviewById(reviewId),
      );

      if (response.statusCode != 200) {
        throw Exception('Erreur HTTP: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur lors de la suppression de l\'avis: $e');
    }
  }

  /// Récupère un avis par ID
  Future<Review> getReviewById(String reviewId) async {
    try {
      final response = await _apiService.get(
        ApiConstants.reviewById(reviewId),
      );

      if (response.statusCode == 200) {
        return _convertToReview(response.data['data']);
      } else {
        throw Exception('Erreur HTTP: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur lors du chargement de l\'avis: $e');
    }
  }

  /// Récupère les avis d'un utilisateur
  Future<List<Review>> getUserReviews(String userId) async {
    try {
      final response = await _apiService.get(
        ApiConstants.reviews,
        queryParameters: {'userId': userId},
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final List<dynamic> reviewsData = data['data'] ?? [];
        return reviewsData.map((json) => _convertToReview(json)).toList();
      } else {
        throw Exception('Erreur HTTP: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur lors du chargement des avis utilisateur: $e');
    }
  }

  /// Convertit les données JSON en objet Review
  Review _convertToReview(Map<String, dynamic> json) {
    return Review(
      id: json['id']?.toString() ?? '',
      userId: json['userId']?.toString() ?? json['user']?['id']?.toString() ?? '',
      userName: json['user'] != null
          ? '${json['user']['firstName'] ?? ''} ${json['user']['lastName'] ?? ''}'.trim()
          : 'Utilisateur',
      userAvatar: json['user']?['profilePicture'] ?? '',
      establishmentId: json['establishmentId']?.toString() ?? '',
      rating: _safeParseInt(json['rating']) ?? 0,
      comment: json['comment'] ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      images: _parseStringList(json['images']),
    );
  }

  /// Parse un entier de façon sécurisée
  int? _safeParseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    if (value is num) return value.toInt();
    return null;
  }

  /// Parse une liste de chaînes de façon sécurisée
  List<String>? _parseStringList(dynamic value) {
    if (value == null) return null;
    if (value is List) {
      return value.map((e) => e?.toString() ?? '').where((s) => s.isNotEmpty).toList();
    }
    return null;
  }
}

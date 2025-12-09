import '../models/notification.dart';
import '../core/network/api_service.dart';
import '../core/constants/api_constants.dart';

class NotificationService {
  final ApiService _apiService = ApiService();

  /// Récupère toutes les notifications de l'utilisateur connecté
  Future<List<AppNotification>> getNotifications({
    bool? isRead,
    int? limit,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (isRead != null) queryParams['isRead'] = isRead.toString();
      if (limit != null) queryParams['limit'] = limit;

      final response = await _apiService.get(
        ApiConstants.notifications,
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final List<dynamic> notificationsData = data['data'] ?? [];
        return notificationsData
            .map((json) => AppNotification.fromJson(json))
            .toList();
      } else {
        throw Exception('Erreur HTTP: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur lors du chargement des notifications: $e');
    }
  }

  /// Récupère une notification par ID
  Future<AppNotification> getNotificationById(String id) async {
    try {
      final response = await _apiService.get(
        ApiConstants.notificationById(id),
      );

      if (response.statusCode == 200) {
        return AppNotification.fromJson(response.data['data']);
      } else {
        throw Exception('Erreur HTTP: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur lors du chargement de la notification: $e');
    }
  }

  /// Récupère le nombre de notifications non lues
  Future<int> getUnreadCount() async {
    try {
      final response = await _apiService.get(
        ApiConstants.notificationsUnreadCount,
      );

      if (response.statusCode == 200) {
        final data = response.data;
        return data['data']['count'] ?? 0;
      } else {
        throw Exception('Erreur HTTP: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur lors du comptage des notifications: $e');
    }
  }

  /// Marque une notification comme lue
  Future<AppNotification> markAsRead(String id) async {
    try {
      final response = await _apiService.patch(
        ApiConstants.notificationMarkAsRead(id),
      );

      if (response.statusCode == 200) {
        return AppNotification.fromJson(response.data['data']);
      } else {
        throw Exception('Erreur HTTP: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour de la notification: $e');
    }
  }

  /// Marque toutes les notifications comme lues
  Future<int> markAllAsRead() async {
    try {
      final response = await _apiService.patch(
        ApiConstants.notificationsMarkAllRead,
      );

      if (response.statusCode == 200) {
        return response.data['count'] ?? 0;
      } else {
        throw Exception('Erreur HTTP: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour des notifications: $e');
    }
  }

  /// Supprime une notification
  Future<void> deleteNotification(String id) async {
    try {
      final response = await _apiService.delete(
        ApiConstants.notificationById(id),
      );

      if (response.statusCode != 200) {
        throw Exception('Erreur HTTP: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur lors de la suppression de la notification: $e');
    }
  }

  /// Crée une invitation à laisser un avis (usage interne/admin)
  Future<AppNotification> createReviewInvitation({
    required String userId,
    required String establishmentId,
  }) async {
    try {
      final response = await _apiService.post(
        ApiConstants.notificationCreateInvitation,
        data: {
          'userId': userId,
          'establishmentId': establishmentId,
        },
      );

      if (response.statusCode == 201) {
        return AppNotification.fromJson(response.data['data']);
      } else {
        throw Exception('Erreur HTTP: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur lors de la création de la notification: $e');
    }
  }

  /// Récupère les notifications non lues uniquement
  Future<List<AppNotification>> getUnreadNotifications() async {
    return getNotifications(isRead: false);
  }

  /// Récupère les notifications lues uniquement
  Future<List<AppNotification>> getReadNotifications() async {
    return getNotifications(isRead: true);
  }
}

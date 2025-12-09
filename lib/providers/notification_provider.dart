import 'package:flutter/foundation.dart';
import '../models/notification.dart';
import '../services/notification_service.dart';

class NotificationProvider extends ChangeNotifier {
  final NotificationService _notificationService = NotificationService();

  List<AppNotification> _notifications = [];
  int _unreadCount = 0;
  bool _isLoading = false;
  String? _errorMessage;

  List<AppNotification> get notifications => _notifications;
  int get unreadCount => _unreadCount;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  List<AppNotification> get unreadNotifications =>
      _notifications.where((n) => !n.isRead).toList();

  List<AppNotification> get readNotifications =>
      _notifications.where((n) => n.isRead).toList();

  /// Charge toutes les notifications
  Future<void> loadNotifications({bool? isRead, int? limit}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _notifications = await _notificationService.getNotifications(
        isRead: isRead,
        limit: limit,
      );
      await _loadUnreadCount();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Charge uniquement le nombre de notifications non lues
  Future<void> _loadUnreadCount() async {
    try {
      _unreadCount = await _notificationService.getUnreadCount();
    } catch (e) {
      debugPrint('Erreur lors du chargement du compteur: $e');
    }
  }

  /// Rafraîchit le compteur de notifications non lues
  Future<void> refreshUnreadCount() async {
    await _loadUnreadCount();
    notifyListeners();
  }

  /// Marque une notification comme lue
  Future<void> markAsRead(String notificationId) async {
    try {
      final updatedNotification =
          await _notificationService.markAsRead(notificationId);

      // Mettre à jour la notification dans la liste locale
      final index =
          _notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1) {
        _notifications[index] = updatedNotification;
        _unreadCount = (_unreadCount - 1).clamp(0, double.infinity).toInt();
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  /// Marque toutes les notifications comme lues
  Future<void> markAllAsRead() async {
    try {
      final count = await _notificationService.markAllAsRead();

      // Mettre à jour toutes les notifications localement
      _notifications = _notifications.map((n) {
        return n.copyWith(isRead: true, readAt: DateTime.now());
      }).toList();

      _unreadCount = 0;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  /// Supprime une notification
  Future<void> deleteNotification(String notificationId) async {
    try {
      await _notificationService.deleteNotification(notificationId);

      // Retirer la notification de la liste locale
      final notification =
          _notifications.firstWhere((n) => n.id == notificationId);
      if (!notification.isRead) {
        _unreadCount = (_unreadCount - 1).clamp(0, double.infinity).toInt();
      }

      _notifications.removeWhere((n) => n.id == notificationId);
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  /// Charge les notifications non lues uniquement
  Future<void> loadUnreadNotifications() async {
    await loadNotifications(isRead: false);
  }

  /// Charge les notifications lues uniquement
  Future<void> loadReadNotifications() async {
    await loadNotifications(isRead: true);
  }

  /// Réinitialise l'état
  void reset() {
    _notifications = [];
    _unreadCount = 0;
    _isLoading = false;
    _errorMessage = null;
    notifyListeners();
  }

  /// Efface le message d'erreur
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}

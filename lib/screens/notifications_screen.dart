import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:easy_localization/easy_localization.dart' hide DateFormat;
import '../models/notification.dart';
import '../providers/notification_provider.dart';
import 'establishment_detail_screen.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    
    // Charger les notifications au démarrage
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationProvider>().loadNotifications();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('notifications.title'.tr()),
        elevation: 0,
        actions: [
          // Bouton pour marquer toutes comme lues
          Consumer<NotificationProvider>(
            builder: (context, provider, child) {
              if (provider.unreadCount > 0) {
                return IconButton(
                  icon: const Icon(Icons.done_all),
                  tooltip: 'notifications.mark_all_read'.tr(),
                  onPressed: () async {
                    await provider.markAllAsRead();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('notifications.marked_as_read'.tr()),
                        ),
                      );
                    }
                  },
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Consumer<NotificationProvider>(
              builder: (context, provider, child) {
                return Tab(
                  text: '${'notifications.unread'.tr()} (${provider.unreadCount})',
                );
              },
            ),
            Tab(text: 'notifications.all'.tr()),
          ],
        ),
      ),
      body: Consumer<NotificationProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    provider.errorMessage!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => provider.loadNotifications(),
                    child: Text('common.retry'.tr()),
                  ),
                ],
              ),
            );
          }

          return TabBarView(
            controller: _tabController,
            children: [
              // Onglet Non lues
              _buildNotificationList(provider.unreadNotifications, provider),
              // Onglet Toutes
              _buildNotificationList(provider.notifications, provider),
            ],
          );
        },
      ),
    );
  }

  Widget _buildNotificationList(
    List<AppNotification> notifications,
    NotificationProvider provider,
  ) {
    if (notifications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_none,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'notifications.no_notifications'.tr(),
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => provider.loadNotifications(),
      child: ListView.separated(
        itemCount: notifications.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final notification = notifications[index];
          return _buildNotificationItem(notification, provider);
        },
      ),
    );
  }

  Widget _buildNotificationItem(
    AppNotification notification,
    NotificationProvider provider,
  ) {
    return Dismissible(
      key: Key(notification.id),
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) async {
        return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('notifications.delete_notification'.tr()),
            content: Text(
              'notifications.confirm_delete'.tr(),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text('common.cancel'.tr()),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: Text('common.delete'.tr()),
              ),
            ],
          ),
        );
      },
      onDismissed: (direction) {
        provider.deleteNotification(notification.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('notifications.deleted'.tr())),
        );
      },
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: notification.isRead
              ? Colors.grey[300]
              : Theme.of(context).primaryColor.withValues(alpha: 0.1),
          child: Icon(
            _getNotificationIcon(notification.type),
            color: notification.isRead
                ? Colors.grey[600]
                : Theme.of(context).primaryColor,
          ),
        ),
        title: Text(
          notification.title,
          style: TextStyle(
            fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              notification.message,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              _formatDate(notification.createdAt),
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        isThreeLine: true,
        onTap: () => _handleNotificationTap(notification, provider),
      ),
    );
  }

  IconData _getNotificationIcon(NotificationType type) {
    switch (type) {
      case NotificationType.reviewInvitation:
        return Icons.rate_review;
      case NotificationType.promotion:
        return Icons.local_offer;
      case NotificationType.system:
        return Icons.info_outline;
      case NotificationType.other:
        return Icons.notifications;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) {
      return 'time.now'.tr();
    } else if (difference.inHours < 1) {
      return 'time.minutes_ago'.tr(namedArgs: {'count': '${difference.inMinutes}'});
    } else if (difference.inDays < 1) {
      return 'time.hours_ago'.tr(namedArgs: {'count': '${difference.inHours}'});
    } else if (difference.inDays == 1) {
      return 'time.yesterday'.tr();
    } else if (difference.inDays < 7) {
      return 'time.days_ago'.tr(namedArgs: {'count': '${difference.inDays}'});
    } else {
      return DateFormat('dd/MM/yyyy').format(date);
    }
  }

  Future<void> _handleNotificationTap(
    AppNotification notification,
    NotificationProvider provider,
  ) async {
    // Marquer comme lue si non lue
    if (!notification.isRead) {
      await provider.markAsRead(notification.id);
    }

    // Action selon le type de notification
    if (notification.type == NotificationType.reviewInvitation &&
        notification.establishmentId != null) {
      // Naviguer vers l'établissement pour laisser un avis
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EstablishmentDetailScreen(
              establishmentId: notification.establishmentId!,
            ),
          ),
        );
      }
    }
  }
}

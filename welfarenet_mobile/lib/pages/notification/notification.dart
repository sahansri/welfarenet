import 'package:flutter/material.dart';
import 'package:welfarenet_mobile/pages/notification/notification_detail.dart';
import 'package:welfarenet_mobile/services/notification_service.dart';
import 'package:welfarenet_mobile/models/notification_model.dart';
import 'package:welfarenet_mobile/utils/responsive_utils.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  final NotificationService _notificationService = NotificationService();
  List<NotificationModel> _notifications = [];
  bool _isLoading = true;
  String? _errorMessage;
  int _unreadCount = 0;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
    _initializeWebSocket();
  }

  @override
  void dispose() {
    // Clear callbacks and disconnect WebSocket
    _notificationService.onNewNotification = null;
    _notificationService.onNotificationRead = null;
    _notificationService.onUnreadCountUpdate = null;
    _notificationService.disconnectWebSocket();
    super.dispose();
  }

  Future<void> _loadNotifications() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final notifications = await _notificationService.getMyNotifications();
      final unreadCount = await _notificationService.getUnreadCount();

      if (mounted) {
        setState(() {
          _notifications = notifications;
          _unreadCount = unreadCount;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceAll('Exception: ', '');
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _initializeWebSocket() async {
    // Connect WebSocket for notifications only
    try {
      await _notificationService.connectWebSocket();
      print('✅ WebSocket connected for notifications');
    } catch (e) {
      print('❌ WebSocket connection failed: $e');
    }

    // Set up callbacks for real-time updates
    // Listen for new notifications
    _notificationService.onNewNotification = (notification) {
      if (mounted) {
        setState(() {
          _notifications.insert(0, notification);
          _unreadCount++;
        });

        // Show snackbar for new notification
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('New notification: ${notification.title}'),
            duration: const Duration(seconds: 3),
            action: SnackBarAction(
              label: 'View',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) =>
                            NotificationDetail(notification: notification),
                  ),
                ).then((_) => _loadNotifications());
              },
            ),
          ),
        );
      }
    };

    // Listen for read status updates
    _notificationService.onNotificationRead = (updatedNotification) {
      if (mounted) {
        setState(() {
          final index = _notifications.indexWhere(
            (n) => n.notificationId == updatedNotification.notificationId,
          );
          if (index != -1) {
            _notifications[index] = updatedNotification;
          }
        });
      }
    };

    // Listen for unread count updates
    _notificationService.onUnreadCountUpdate = (count) {
      if (mounted) {
        setState(() {
          _unreadCount = count;
        });
      }
    };
  }

  Future<void> _markAllAsRead() async {
    try {
      final updatedNotifications = await _notificationService.markAllAsRead(
        _notifications,
      );
      if (mounted) {
        setState(() {
          _notifications = updatedNotifications;
          _unreadCount = 0;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('All notifications marked as read'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to mark all as read: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF111827)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Notifications',
          style: TextStyle(
            color: Color(0xFF111827),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          if (_unreadCount > 0)
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF7A5AF8),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$_unreadCount',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          TextButton(
            onPressed: _isLoading || _unreadCount == 0 ? null : _markAllAsRead,
            child: Text(
              'Mark all read',
              style: TextStyle(
                color:
                    _isLoading || _unreadCount == 0
                        ? Colors.grey
                        : const Color(0xFF7A5AF8),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _errorMessage != null
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 80,
                      color: Colors.red.shade300,
                    ),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Text(
                        _errorMessage!,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _loadNotifications,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF7A5AF8),
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              )
              : _notifications.isEmpty
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.notifications_off_outlined,
                      size: 80,
                      color: Colors.grey.shade300,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No notifications yet',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              )
              : RefreshIndicator(
                onRefresh: _loadNotifications,
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _notifications.length,
                  itemBuilder: (context, index) {
                    final notification = _notifications[index];
                    return _buildNotificationCard(notification, index);
                  },
                ),
              ),
    );
  }

  Widget _buildNotificationCard(NotificationModel notification, int index) {
    final displayType = notification.getDisplayType();
    IconData icon;
    Color iconColor;

    switch (displayType) {
      case 'payment':
        icon = Icons.payment;
        iconColor = const Color(0xFF7A5AF8);
        break;
      case 'event':
        icon = Icons.event;
        iconColor = Colors.orange;
        break;
      case 'info':
        icon = Icons.info_outline;
        iconColor = Colors.blue;
        break;
      default:
        icon = Icons.notifications;
        iconColor = Colors.grey;
    }

    return Dismissible(
      key: Key('notification_${notification.notificationId}'),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        setState(() {
          _notifications.removeAt(index);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Notification deleted'),
            duration: Duration(seconds: 2),
          ),
        );
      },
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: InkWell(
        onTap: () async {
          // Navigate to detail page
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => NotificationDetail(notification: notification),
            ),
          );

          // Reload notifications if marked as read in detail page
          if (result == true) {
            _loadNotifications();
          }
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color:
                notification.readStatus
                    ? Colors.white
                    : const Color(0xFFF5F3FF),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color:
                  notification.readStatus
                      ? Colors.grey.shade200
                      : const Color(0xFF7A5AF8).withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight:
                                  notification.readStatus
                                      ? FontWeight.w500
                                      : FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        if (!notification.readStatus)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Color(0xFF7A5AF8),
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification.message,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      notification.getTimeAgo(),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

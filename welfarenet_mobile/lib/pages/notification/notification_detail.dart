import 'package:flutter/material.dart';
import 'package:welfarenet_mobile/models/notification_model.dart';
import 'package:welfarenet_mobile/services/notification_service.dart';

class NotificationDetail extends StatefulWidget {
  final NotificationModel notification;

  const NotificationDetail({super.key, required this.notification});

  @override
  State<NotificationDetail> createState() => _NotificationDetailState();
}

class _NotificationDetailState extends State<NotificationDetail> {
  final NotificationService _notificationService = NotificationService();
  late NotificationModel _notification;

  @override
  void initState() {
    super.initState();
    _notification = widget.notification;

    // Automatically mark as read when viewing if not already read
    if (!_notification.readStatus) {
      _markAsReadAutomatically();
    }
  }

  Future<void> _markAsReadAutomatically() async {
    try {
      final updated = await _notificationService.markAsRead(
        _notification.notificationId,
      );
      if (mounted) {
        setState(() {
          _notification = updated;
        });
      }
    } catch (e) {
      print('Failed to mark notification as read: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final displayType = _notification.getDisplayType();

    return WillPopScope(
      onWillPop: () async {
        // Return true to indicate that notification was viewed/marked as read
        Navigator.pop(context, true);
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context, true),
          ),
          title: const Text(
            'Notification Details',
            style: TextStyle(
              color: Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon and Type Header
              Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: _getIconColor(displayType).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _getIcon(displayType),
                      color: _getIconColor(displayType),
                      size: 30,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getTypeLabel(displayType),
                          style: TextStyle(
                            fontSize: 14,
                            color: _getIconColor(displayType),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _notification.getTimeAgo(),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Title
              Text(
                _notification.title,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 16),

              // Divider
              Divider(color: Colors.grey.shade300, thickness: 1),
              const SizedBox(height: 16),

              // Message Content
              const Text(
                'Message',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                _notification.message,
                style: TextStyle(
                  fontSize: 15,
                  height: 1.6,
                  color: Colors.grey.shade800,
                ),
              ),
              const SizedBox(height: 24),

              // Additional Details Section
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F3FF),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF7A5AF8).withValues(alpha: 0.2),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Additional Information',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF7A5AF8),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildDetailRow('Type', _getTypeLabel(displayType)),
                    const SizedBox(height: 8),
                    _buildDetailRow('Date & Time', _notification.getTimeAgo()),
                    const SizedBox(height: 8),
                    _buildDetailRow(
                      'Status',
                      _notification.readStatus ? 'Read' : 'Unread',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Action Buttons (if applicable)
              if (displayType == 'payment') ...[
                const Text(
                  'Quick Actions',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          // Navigate to payment history or details
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('View Payment Details'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                        icon: const Icon(Icons.payment, size: 20),
                        label: const Text('View Payment'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF7A5AF8),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
              if (displayType == 'event') ...[
                const Text(
                  'Quick Actions',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          // Navigate to event details
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('View Event Details'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                        icon: const Icon(Icons.event, size: 20),
                        label: const Text('View Event'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  IconData _getIcon(String type) {
    switch (type) {
      case 'payment':
        return Icons.payment;
      case 'event':
        return Icons.event;
      case 'info':
        return Icons.info_outline;
      default:
        return Icons.notifications;
    }
  }

  Color _getIconColor(String type) {
    switch (type) {
      case 'payment':
        return const Color(0xFF7A5AF8);
      case 'event':
        return Colors.orange;
      case 'info':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  String _getTypeLabel(String type) {
    switch (type) {
      case 'payment':
        return 'Payment Notification';
      case 'event':
        return 'Event Notification';
      case 'info':
        return 'Information';
      default:
        return 'Notification';
    }
  }
}

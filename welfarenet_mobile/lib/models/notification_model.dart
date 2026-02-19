class NotificationModel {
  final int notificationId;
  final int recipientId;
  final String title;
  final String message;
  final String type;
  final bool readStatus;
  final DateTime createdAt;

  NotificationModel({
    required this.notificationId,
    required this.recipientId,
    required this.title,
    required this.message,
    required this.type,
    required this.readStatus,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      notificationId: json['notificationId'] ?? 0,
      recipientId: json['recipientId'] ?? 0,
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      type: (json['type'] ?? 'INFO').toString().toLowerCase(),
      readStatus: json['readStatus'] ?? false,
      createdAt:
          json['createdAt'] != null
              ? DateTime.parse(json['createdAt'])
              : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'notificationId': notificationId,
      'recipientId': recipientId,
      'title': title,
      'message': message,
      'type': type,
      'readStatus': readStatus,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // Helper method to get time ago string
  String getTimeAgo() {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return '$months ${months == 1 ? 'month' : 'months'} ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} ${difference.inMinutes == 1 ? 'minute' : 'minutes'} ago';
    } else {
      return 'Just now';
    }
  }

  // Helper method to convert backend type to frontend type
  String getDisplayType() {
    switch (type.toLowerCase()) {
      case 'announcement':
        return 'info';
      case 'event':
      case 'event_reminder':
        return 'event';
      case 'payment':
        return 'payment';
      case 'complaint':
      case 'task':
        return 'info';
      default:
        return 'info';
    }
  }

  // Create a copy with updated fields
  NotificationModel copyWith({
    int? notificationId,
    int? recipientId,
    String? title,
    String? message,
    String? type,
    bool? readStatus,
    DateTime? createdAt,
  }) {
    return NotificationModel(
      notificationId: notificationId ?? this.notificationId,
      recipientId: recipientId ?? this.recipientId,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      readStatus: readStatus ?? this.readStatus,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

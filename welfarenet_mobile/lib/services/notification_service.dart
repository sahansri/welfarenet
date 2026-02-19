import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';
import '../models/notification_model.dart';

class NotificationService {
  // Singleton pattern
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  static const String baseUrl = 'http://172.20.10.4:8080';
  static const String wsUrl = 'ws://172.20.10.4:8080/ws';

  StompClient? _stompClient;
  bool _isConnected = false;

  // Callbacks for real-time updates
  Function(NotificationModel)? onNewNotification;
  Function(NotificationModel)? onNotificationRead;
  Function(int)? onUnreadCountUpdate;

  // Get authentication token
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  // Get user ID
  Future<int?> _getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('user_id');
  }

  // Get headers with authentication
  Future<Map<String, String>> _getHeaders() async {
    final token = await _getToken();
    return {'Accept': 'application/json', 'Authorization': 'Bearer $token'};
  }

  /// Connect to WebSocket for real-time notifications
  Future<void> connectWebSocket() async {
    if (_isConnected) {
      print('⚠️ WebSocket already connected');
      return;
    }

    final userId = await _getUserId();
    final token = await _getToken();

    print('🔄 Attempting WebSocket connection...');
    print('   URL: $wsUrl');
    print('   User ID: $userId');
    print('   Token present: ${token != null}');

    if (userId == null) {
      print('❌ Cannot connect: Missing userId');
      return;
    }

    try {
      _stompClient = StompClient(
        config: StompConfig(
          url: wsUrl,
          onConnect: (frame) {
            _isConnected = true;
            print('✅ WebSocket connected successfully');
            print('   Frame: ${frame.headers}');
            _subscribeToTopics(userId);
          },
          onDisconnect: (frame) {
            _isConnected = false;
            print('❌ WebSocket disconnected');
            print('   Frame: ${frame.headers}');
          },
          onWebSocketError: (error) {
            print('⚠️ WebSocket error: $error');
            print('   Error type: ${error.runtimeType}');
            _isConnected = false;
          },
          onStompError: (frame) {
            print('⚠️ STOMP error: ${frame.body}');
            print('   Headers: ${frame.headers}');
            print('   Command: ${frame.command}');
          },
          onWebSocketDone: () {
            print('🔌 WebSocket connection closed');
            _isConnected = false;
          },
          beforeConnect: () async {
            print('🔌 Preparing to connect to WebSocket...');
          },
          reconnectDelay: const Duration(seconds: 5),
          heartbeatIncoming: const Duration(seconds: 10),
          heartbeatOutgoing: const Duration(seconds: 10),
        ),
      );

      print('🚀 Activating WebSocket client...');
      _stompClient!.activate();
    } catch (e) {
      print('💥 Fatal error creating WebSocket: $e');
      print('   Stack trace: ${StackTrace.current}');
      _isConnected = false;
    }
  }

  /// Subscribe to WebSocket topics
  void _subscribeToTopics(int userId) {
    print('📡 Subscribing to notification topics for user $userId');

    // Subscribe to new notifications
    _stompClient?.subscribe(
      destination: '/topic/notifications/$userId',
      callback: (frame) {
        print('📥 Received new notification');
        if (frame.body != null) {
          try {
            final notification = NotificationModel.fromJson(
              jsonDecode(frame.body!),
            );
            print('   Notification: ${notification.title}');
            onNewNotification?.call(notification);
          } catch (e) {
            print('❌ Error parsing new notification: $e');
            print('   Body: ${frame.body}');
          }
        }
      },
    );
    print('✅ Subscribed to /topic/notifications/$userId');

    // Subscribe to read status updates
    _stompClient?.subscribe(
      destination: '/topic/notifications/$userId/read',
      callback: (frame) {
        print('📥 Received read status update');
        if (frame.body != null) {
          try {
            final notification = NotificationModel.fromJson(
              jsonDecode(frame.body!),
            );
            print(
              '   Notification marked as read: ${notification.notificationId}',
            );
            onNotificationRead?.call(notification);
          } catch (e) {
            print('❌ Error parsing read notification: $e');
          }
        }
      },
    );
    print('✅ Subscribed to /topic/notifications/$userId/read');

    // Subscribe to unread count updates
    _stompClient?.subscribe(
      destination: '/topic/notifications/$userId/unread-count',
      callback: (frame) {
        print('📥 Received unread count update');
        if (frame.body != null) {
          try {
            final count = int.parse(frame.body!);
            print('   Unread count: $count');
            onUnreadCountUpdate?.call(count);
          } catch (e) {
            print('❌ Error parsing unread count: $e');
          }
        }
      },
    );
    print('✅ Subscribed to /topic/notifications/$userId/unread-count');
  }

  /// Disconnect WebSocket
  void disconnectWebSocket() {
    print('🔌 Disconnecting WebSocket...');
    if (_stompClient != null) {
      _stompClient!.deactivate();
      _stompClient = null;
      _isConnected = false;
      print('✅ WebSocket disconnected');
    }
  }

  /// Fetch all notifications for the current user
  Future<List<NotificationModel>> getMyNotifications() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/api/notifications/me'),
        headers: headers,
      );
      print(response.body);
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => NotificationModel.fromJson(json)).toList();
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized. Please login again.');
      } else {
        throw Exception('Failed to load notifications: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching notifications: $e');
    }
  }

  /// Mark a notification as read
  Future<NotificationModel> markAsRead(int notificationId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.put(
        Uri.parse('$baseUrl/api/notifications/$notificationId/read'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return NotificationModel.fromJson(jsonDecode(response.body));
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized. Please login again.');
      } else {
        throw Exception(
          'Failed to mark notification as read: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error marking notification as read: $e');
    }
  }

  /// Get unread notification count
  Future<int> getUnreadCount() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/api/notifications/me/unread-count'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return int.parse(response.body);
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized. Please login again.');
      } else {
        throw Exception('Failed to load unread count: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching unread count: $e');
    }
  }

  /// Mark all notifications as read (client-side batch operation)
  Future<List<NotificationModel>> markAllAsRead(
    List<NotificationModel> notifications,
  ) async {
    List<NotificationModel> updatedNotifications = [];

    for (var notification in notifications) {
      if (!notification.readStatus) {
        try {
          final updated = await markAsRead(notification.notificationId);
          updatedNotifications.add(updated);
        } catch (e) {
          // Continue with other notifications even if one fails
          print(
            'Failed to mark notification ${notification.notificationId} as read: $e',
          );
          updatedNotifications.add(notification);
        }
      } else {
        updatedNotifications.add(notification);
      }
    }

    return updatedNotifications;
  }
}

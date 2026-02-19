# WebSocket Architecture for WelfareNet Mobile

## Overview
The WebSocket connection is implemented **only for the notification feature**. The connection is established when users open the notification page and disconnected when they leave. This ensures real-time notifications work efficiently without maintaining unnecessary global connections.

## Architecture Components

### 1. **Singleton NotificationService**
- Location: `lib/services/notification_service.dart`
- Pattern: Singleton (one instance for entire app)
- Purpose: Manages WebSocket connection and notification APIs

```dart
// Singleton pattern ensures same instance everywhere
NotificationService(); // Always returns the same instance
```

### 2. **WebSocket Initialization (Notification Page Only)**
- Location: `lib/pages/notification/notification.dart`
- When: Initialized when user opens notification page
- Lifecycle:
  - **Connect**: When notification page initializes (`initState`)
  - **Disconnect**: When user leaves notification page (`dispose`)

### 3. **Real-time Updates**
The WebSocket provides 3 types of real-time updates:

#### a) New Notifications
```dart
_notificationService.onNewNotification = (notification) {
  // Handle new notification
};
```

#### b) Read Status Updates
```dart
_notificationService.onNotificationRead = (notification) {
  // Handle notification marked as read
};
```

#### c) Unread Count Updates
```dart
_notificationService.onUnreadCountUpdate = (count) {
  // Update badge count
};
```

## How It Works Across Pages

## How It Works

### Notification Page
- **Connects** WebSocket when page opens (`initState`)
- Listens to all three callbacks for real-time updates
- Updates notification list in real-time
- Shows snackbar for new notifications
- Automatically updates read status
- **Disconnects** WebSocket when page closes (`dispose`)

### Dashboard and Other Pages
- Use HTTP API calls to fetch notification count
- No WebSocket connection needed
- Call `_notificationService.getUnreadCount()` to get badge count
- Refresh count when user returns to page

## Connection Management

### Auto-Reconnection
- WebSocket automatically reconnects if connection drops (while on notification page)
- Reconnection delay: 5 seconds
- Heartbeat: 10 seconds (incoming & outgoing)

### Lifecycle
- **Connect**: Only when notification page is active
- **Disconnect**: When user leaves notification page
- No global persistent connection

## Usage Pattern

### For Notification Page (WebSocket)
```dart
class NotificationPage extends StatefulWidget {
  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  final NotificationService _notificationService = NotificationService();

  @override
  void initState() {
    super.initState();
    _loadNotifications();
    _initializeWebSocket(); // Connect WebSocket
  }
  
  Future<void> _initializeWebSocket() async {
    await _notificationService.connectWebSocket();
    
    // Set up callbacks for real-time updates
    _notificationService.onNewNotification = (notification) {
      // Handle new notification
    };
    
    _notificationService.onUnreadCountUpdate = (count) {
      // Update UI with new count
    };
  }

  @override
  void dispose() {
    // Clear callbacks and disconnect
    _notificationService.onNewNotification = null;
    _notificationService.onUnreadCountUpdate = null;
    _notificationService.disconnectWebSocket();
    super.dispose();
  }
}
```

### For Other Pages (HTTP API Only)
```dart
class Dashboard extends StatefulWidget {
  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  final NotificationService _notificationService = NotificationService();
  int _unreadCount = 0;

  @override
  void initState() {
    super.initState();
    _loadUnreadCount(); // Use HTTP API, not WebSocket
  }

  Future<void> _loadUnreadCount() async {
    try {
      final count = await _notificationService.getUnreadCount();
      setState(() => _unreadCount = count);
    } catch (e) {
      print('Error loading count: $e');
    }
  }
}
```

## Benefits

1. **Efficient**: WebSocket only active when needed (notification page)
2. **Battery Friendly**: No persistent background connection
3. **Simple**: Other pages use lightweight HTTP calls
4. **Auto-Reconnection**: Handles network interruptions gracefully
5. **Memory Efficient**: Singleton pattern prevents multiple instances
6. **Easy Integration**: Simple callback system for any page

## Backend Integration

### WebSocket Topics Subscribed
When on notification page:
- `/topic/notifications/{userId}` - New notifications
- `/topic/notifications/{userId}/read` - Read status updates
- `/topic/notifications/{userId}/unread-count` - Unread count updates

### HTTP API Endpoints
For all pages:
- `GET /api/notifications/me` - Fetch user notifications
- `PUT /api/notifications/{id}/read` - Mark as read
- `GET /api/notifications/me/unread-count` - Get unread count

### REST API Endpoints Used
- `GET /api/notifications/me` - Fetch all notifications
- `GET /api/notifications/me/unread-count` - Get unread count
- `PUT /api/notifications/{id}/read` - Mark notification as read

## Troubleshooting

### WebSocket not connecting?
1. Check if user is logged in (token must be present)
2. Check if userId is stored in SharedPreferences
3. Check backend WebSocket endpoint is running
4. Check network connectivity

### Not receiving real-time updates?
1. Ensure callbacks are set up in your page
2. Check if page is mounted before updating state
3. Verify backend is sending to correct user topic
4. Check console logs for WebSocket messages

### Badge not updating?
1. Dashboard must be loaded at least once
2. Callbacks must be set in Dashboard's initState
3. Check `_loadUnreadNotificationCount()` is called
4. Verify backend `/unread-count` endpoint works

## Debug Logs

Enable debug logs in `notification_service.dart`:
- ✅ Connection success
- ❌ Connection errors
- 📥 Message received
- 🔌 Connection status changes
- ⚠️ Warnings and issues

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:welfarenet_mobile/services/auth_service.dart';
import 'package:welfarenet_mobile/services/announcement_service.dart';
import 'package:welfarenet_mobile/services/event_service.dart';
import 'package:welfarenet_mobile/services/notification_service.dart';
import 'package:welfarenet_mobile/services/stars_service.dart';
import 'package:welfarenet_mobile/pages/notification/notification.dart';
import 'package:welfarenet_mobile/pages/announcement/announcements.dart';
import 'package:welfarenet_mobile/pages/announcement/announcement_detail.dart';
import 'package:welfarenet_mobile/pages/loyalty_rewards.dart';
import 'package:welfarenet_mobile/pages/profile/profile.dart';
import 'package:welfarenet_mobile/utils/responsive_utils.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  final AuthService _authService = AuthService();
  final AnnouncementService _announcementService = AnnouncementService();
  final EventService _eventService = EventService();
  final NotificationService _notificationService = NotificationService();
  final StarsService _starsService = StarsService();
  SharedPreferences? _prefs;
  Map<String, dynamic>? _userData;
  bool _isLoading = true;
  bool _isLoadingAnnouncements = true;
  bool _isLoadingEvents = true;
  int _unreadNotificationCount = 0;
  int _unityStarsBalance = 0;
  final PageController _sliderController = PageController(
    viewportFraction: 0.92,
  );
  int _currentSliderPage = 0;

  // Announcements data from API
  List<Map<String, dynamic>> _announcements = [];
  // Events data from API
  List<Map<String, dynamic>> _recentEvents = [];

  // Fallback sample announcements data
  final List<Map<String, dynamic>> _fallbackAnnouncements = [
    {
      'title': 'Annual General Meeting 2025',
      'date': '2025 Dec 25',
      'category': 'Event',
      'summary': 'Join us for our Annual General Meeting',
      'description':
          'We are pleased to invite all members to our Annual General Meeting. This is an important event where we will discuss our achievements, financial reports, and future plans. Your participation is highly valued.',
      'icon': Icons.event,
      'color': const Color(0xFF7A5AF8),
      'attachments': [
        {'id': 1, 'fileUrl': 'https://picsum.photos/800/600?random=1'},
        {'id': 2, 'fileUrl': 'https://picsum.photos/800/600?random=2'},
      ],
    },
    {
      'title': 'New Membership Benefits',
      'date': '2025 Dec 20',
      'category': 'Update',
      'summary': 'Enhanced benefits for all members',
      'description':
          'We are excited to announce new membership benefits including exclusive discounts, priority event registration, and additional welfare support programs. Check your member portal for full details.',
      'icon': Icons.card_giftcard,
      'color': Colors.orange,
      'attachments': [
        {'id': 3, 'fileUrl': 'https://picsum.photos/800/600?random=3'},
      ],
    },
    {
      'title': 'Payment Deadline Extension',
      'date': '2025 Dec 15',
      'category': 'Important',
      'summary': 'Membership fee payment deadline extended',
      'description':
          'Due to multiple requests, we have extended the membership fee payment deadline to December 31st, 2025. Please ensure your payment is completed before the new deadline to avoid any service interruptions.',
      'icon': Icons.schedule,
      'color': Colors.red,
    },
    {
      'title': 'Community Service Day',
      'date': '2025 Dec 10',
      'category': 'Event',
      'summary': 'Volunteer for community development',
      'description':
          'Join our community service initiative. We will be organizing a cleaning drive and educational program for underprivileged children. Volunteers are welcome to participate and make a difference.',
      'icon': Icons.volunteer_activism,
      'color': Colors.green,
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadAnnouncements();
    _loadEvents();
    _loadUnreadNotificationCount();
    _loadUnityStarsBalance();
  }

  Future<void> _loadUnreadNotificationCount() async {
    try {
      final count = await _notificationService.getUnreadCount();
      if (mounted) {
        setState(() {
          _unreadNotificationCount = count;
        });
      }
    } catch (e) {
      print('Error loading unread notification count: $e');
    }
  }

  Future<void> _loadUnityStarsBalance() async {
    try {
      final userInfo = await _authService.getUserInfo();
      if (userInfo['success'] == true && userInfo['data'] != null) {
        final memberId = userInfo['data']['memberID'];
        final result = await _starsService.getMemberBalance(memberId);
        if (mounted && result['success'] == true) {
          setState(() {
            _unityStarsBalance = result['balance'] ?? 0;
          });
        }
      }
    } catch (e) {
      print('Error loading Unity Stars balance: $e');
    }
  }

  @override
  void dispose() {
    _sliderController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
    });

    _prefs = await SharedPreferences.getInstance();
    final result = await _authService.getUserInfo();

    if (mounted) {
      setState(() {
        _isLoading = false;
        if (result['success'] == true) {
          _userData = result['data'];
        } else {
          _userData = null;
        }
      });

      // Silently handle user data load errors - data will reload on next app open
      if (result['success'] != true) {
        // Only log error, don't show snackbar for better UX
        print('Failed to load user data: ${result['message']}');
      }
    }
  }

  Future<void> _loadAnnouncements() async {
    setState(() {
      _isLoadingAnnouncements = true;
    });

    final result = await _announcementService.fetchlatest3Announcements();

    if (mounted) {
      setState(() {
        _isLoadingAnnouncements = false;
        if (result['success'] == true && result['data'] != null) {
          final List<dynamic> apiData =
              result['data'] is List
                  ? result['data']
                  : (result['data']['announcements'] ??
                      result['data']['data'] ??
                      []);

          _announcements =
              apiData.map<Map<String, dynamic>>((item) {
                return {
                  'title': item['title'] ?? 'No Title',
                  'date':
                      item['createdDate'] != null
                          ? _formatDate(item['createdDate'])
                          : 'No Date',
                  'category': item['priority'] ?? 'General',
                  'summary':
                      item['summary'] ??
                      item['content'] ??
                      'No summary available',
                  'description':
                      item['content'] ??
                      item['description'] ??
                      'No description available',
                  'icon': _getIconForCategory(item['priority'] ?? 'General'),
                  'color': _getColorForCategory(item['priority']),
                  'attachments': item['attachments'] ?? [],
                };
              }).toList();

          // If no announcements from API, show no announcements
          if (_announcements.isEmpty) {
            _announcements = [];
          }
        } else {
          // Use fallback announcements on error
          _announcements = _fallbackAnnouncements;
        }
      });
    }
  }

  Future<void> _loadEvents() async {
    setState(() {
      _isLoadingEvents = true;
    });

    final result = await _eventService.getRecentEvents();

    if (mounted) {
      setState(() {
        _isLoadingEvents = false;
      });

      if (result['success']) {
        try {
          final List<dynamic> data = result['data'];
          setState(() {
            _recentEvents =
                data.map<Map<String, dynamic>>((item) {
                  return {
                    'eventId': item['eventId'],
                    'title': item['eventName'] ?? 'No Title',
                    'description': item['description'] ?? 'No description',
                    'date': item['date'] ?? '',
                    'time': item['time'] ?? '',
                    'venue': item['venue'] ?? 'No venue',
                    'eventType': item['eventType'] ?? 'general',
                  };
                }).toList();
          });
        } catch (e) {
          print('Error loading events: $e');
        }
      }
    }
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      final months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];
      return '${date.year} ${months[date.month - 1]} ${date.day}';
    } catch (e) {
      return dateStr;
    }
  }

  IconData _getIconForCategory(String category) {
    switch (category.toLowerCase()) {
      case 'medium':
        return Icons.event;
      case 'high':
        return Icons.card_giftcard;
      case 'urgent':
        return Icons.schedule;
      case 'low':
        return Icons.construction;
      default:
        return Icons.announcement;
    }
  }

  Color _getColorForCategory(String category) {
    switch (category.toLowerCase()) {
      case 'medium':
        return const Color(0xFF7A5AF8);
      case 'high':
        return Colors.orange;
      case 'urgent':
        return Colors.red;
      case 'low':
        return Colors.grey;
      default:
        return const Color(0xFF7A5AF8);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final double appBarHeight = (screenHeight * 0.09).clamp(56.0, 110.0);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF8B70F7), Color(0xFFA98FE8), Color(0xFF7862D8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildWelcomeHeader(),
                      const SizedBox(height: 24),
                      _buildAnnouncementCard(),
                      const SizedBox(height: 16),
                      _upComingEvents(),
                      const SizedBox(height: 16),
                      _buildUnityStarsCard(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    final responsive = context.responsive;
    final textStyles = context.textStyles;
    final avatarSize = responsive.iconSize(40);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: responsive.spacing(16),
        vertical: responsive.spacing(12),
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () async {
              try {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProfilePage()),
                );
                // Reload user data when returning from profile page
                _loadUserData();
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error opening profile: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: Container(
              width: avatarSize,
              height: avatarSize,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF7C3AED), Color(0xFF8B5CF6)],
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.person,
                color: Colors.white,
                size: responsive.iconSize(24),
              ),
            ),
          ),
          SizedBox(width: responsive.spacing(12)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isLoading
                      ? 'Loading...'
                      : 'Hello, ${_userData?['fullName'] ?? _userData?['email']?.split('@')[0] ?? _prefs?.getString('fullName')}!',
                  style: textStyles.subtitle2.copyWith(
                    color: const Color(0xFF7A5AF8),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'Welcome back to WelfareNet',
                  style: textStyles.caption.copyWith(
                    color: const Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: avatarSize,
            height: avatarSize,
            decoration: const BoxDecoration(
              color: Color(0xFFF5F3FF),
              shape: BoxShape.circle,
            ),
            child: Stack(
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.notifications,
                    color: Color(0xFF7A5AF8),
                    size: 24,
                  ),
                  padding: EdgeInsets.zero,
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const NotificationPage(),
                      ),
                    );
                    // Reload unread count after returning from notifications
                    _loadUnreadNotificationCount();
                  },
                ),
                if (_unreadNotificationCount > 0)
                  Positioned(
                    right: 6,
                    top: 6,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1.5),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        _unreadNotificationCount > 9
                            ? '9+'
                            : _unreadNotificationCount.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeHeader() {
    final responsive = context.responsive;
    final textStyles = context.textStyles;

    return Container(
      padding: EdgeInsets.all(responsive.spacing(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome Back!',
            style: textStyles.headline1.copyWith(
              color: Colors.white.withOpacity(0.95),
            ),
          ),
          SizedBox(height: responsive.spacing(8)),
          Text(
            "Let's keep your community running smoothly.",
            style: textStyles.subtitle2.copyWith(
              color: Colors.white.withOpacity(0.85),
            ),
          ),
        ],
      ),
    );
  }

  //slider widget
  Widget _buildSlider() {
    if (_isLoadingAnnouncements) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF7A5AF8)),
        ),
      );
    }

    if (_announcements.isEmpty) {
      return Center(
        child: Text(
          'No announcements available',
          style: TextStyle(color: Colors.grey[600]),
        ),
      );
    }

    final itemCount = _announcements.length;
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final cardHeight = (MediaQuery.of(context).size.height * 0.18).clamp(
          120.0,
          200.0,
        );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: cardHeight,
              child: PageView.builder(
                controller: _sliderController,
                itemCount: itemCount,
                onPageChanged:
                    (index) => setState(() => _currentSliderPage = index),
                itemBuilder: (context, index) {
                  final announcement = _announcements[index];
                  return Padding(
                    padding: EdgeInsets.only(
                      left: index == 0 ? 0 : 8,
                      right: index == itemCount - 1 ? 0 : 8,
                    ),
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => AnnouncementDetail(
                                  announcement: announcement,
                                ),
                          ),
                        );
                      },
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                        child: Container(
                          width: width * 0.9,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: announcement['color'].withValues(alpha: 0.1),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 1,
                                child: Container(
                                  height: cardHeight * 0.6,
                                  decoration: BoxDecoration(
                                    color: announcement['color'].withValues(
                                      alpha: 0.2,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        announcement['icon'],
                                        size: 40,
                                        color: announcement['color'],
                                      ),
                                      const SizedBox(height: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: announcement['color'],
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: Text(
                                          announcement['category'],
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                flex: 2,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.calendar_today,
                                          size: 11,
                                          color: Colors.grey.shade600,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          announcement['date'],
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      announcement['title'],
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      announcement['description'],
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey.shade700,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 3),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Text(
                                          'Read more',
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: announcement['color'],
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(width: 2),
                                        Icon(
                                          Icons.arrow_forward_ios,
                                          size: 9,
                                          color: announcement['color'],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(itemCount, (i) {
                final active = i == _currentSliderPage;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: active ? 18 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color:
                        active
                            ? const Color.fromRGBO(122, 90, 248, 1)
                            : Colors.grey[300],
                    borderRadius: BorderRadius.circular(8),
                  ),
                );
              }),
            ),
          ],
        );
      },
    );
  }

  //announcement card widget
  Widget _buildAnnouncementCard() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;
        // Inner content width - keep some horizontal padding
        final innerWidth = (availableWidth * 0.94).clamp(200.0, 900.0);
        // Responsive card height based on screen height
        final cardHeight = (MediaQuery.of(context).size.height * 0.28).clamp(
          160.0,
          280.0,
        );

        return Container(
          height: cardHeight,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFF7A5AF8).withOpacity(0.2)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                spreadRadius: 1,
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Announcements',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const Announcements(),
                          ),
                        );
                      },
                      child: const Text(
                        'See more',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Color(0xFF7A5AF8),
                        ),
                      ),
                    ),
                  ],
                ),
                Center(
                  child: SizedBox(
                    width: innerWidth,
                    height: cardHeight - 60,
                    child: _buildSlider(),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

Widget _upComingEvents() {
  return Builder(
    builder: (context) {
      final state = context.findAncestorStateOfType<_DashboardState>();
      final isLoading = state?._isLoadingEvents ?? true;
      final events = state?._recentEvents ?? [];

      return LayoutBuilder(
        builder: (context, constraints) {
          // Responsive card height based on screen height
          final cardHeight = (MediaQuery.of(context).size.height * 0.28).clamp(
            50.0,
            150.0,
          );
          return Container(
            height: cardHeight,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Color(0xFF8B70F7),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFF8B70F7).withOpacity(0.3),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  spreadRadius: 1,
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Upcoming Events',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.95),
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6),
                            isLoading
                                ? SizedBox(
                                  height: 16,
                                  width: 16,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                                : events.isEmpty
                                ? Text(
                                  'No upcoming events',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.85),
                                    fontSize: 14,
                                  ),
                                )
                                : Text(
                                  '${events[0]['title']} on ${events[0]['date']}',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.85),
                                    fontSize: 14,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 1,
                        child: Container(
                          height: cardHeight * 0.6,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Image.asset(
                              'lib/assets/freepik__background__33966.png',
                              errorBuilder: (context, error, stackTrace) {
                                return Icon(
                                  Icons.event,
                                  color: Colors.white.withOpacity(0.7),
                                  size: 50,
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}

//Unity Stars card widget
Widget _buildUnityStarsCard() {
  return Builder(
    builder: (context) {
      final state = context.findAncestorStateOfType<_DashboardState>();
      final balance = state?._unityStarsBalance ?? 0;

      return InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const LoyaltyRewards()),
          );
        },
        borderRadius: BorderRadius.circular(20),
        child: Container(
          height: 120,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                spreadRadius: 1,
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(30.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Image.asset(
                  'lib/assets/meteor-rain.png',
                  width: 60,
                  height: 60,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Unity Stars',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text('You have $balance Unity Stars'),
                      const SizedBox(height: 4),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios,
                  color: Color(0xFF7A5AF8),
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

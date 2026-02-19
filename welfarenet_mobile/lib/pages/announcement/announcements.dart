import 'package:flutter/material.dart';
import 'package:welfarenet_mobile/pages/announcement/announcement_detail.dart';
import 'package:welfarenet_mobile/services/announcement_service.dart';
import 'package:welfarenet_mobile/utils/responsive_utils.dart';

class Announcements extends StatefulWidget {
  const Announcements({super.key});

  @override
  State<Announcements> createState() => _AnnouncementsState();
}

class _AnnouncementsState extends State<Announcements> {
  final AnnouncementService _announcementService = AnnouncementService();
  List<Map<String, dynamic>> _announcements = [];
  bool _isLoading = true;

  // Fallback announcements
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
    {
      'title': 'Website Maintenance Notice',
      'date': '2025 Dec 5',
      'category': 'Notice',
      'summary': 'Scheduled system maintenance',
      'description':
          'Our website and member portal will undergo scheduled maintenance on December 8th from 2:00 AM to 6:00 AM. Services will be temporarily unavailable during this period. We apologize for any inconvenience.',
      'icon': Icons.construction,
      'color': Colors.grey,
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadAnnouncements();
  }

  Future<void> _loadAnnouncements() async {
    setState(() {
      _isLoading = true;
    });

    final result = await _announcementService.fetchAllAnnouncements();

    if (mounted) {
      setState(() {
        _isLoading = false;
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

          // If no announcements from API, use empty list
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
          'Announcements',
          style: TextStyle(
            color: Color(0xFF111827),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body:
          _isLoading
              ? const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF7A5AF8)),
                ),
              )
              : _announcements.isEmpty
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.campaign_outlined,
                      size: 80,
                      color: Colors.grey.shade300,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No announcements yet',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              )
              : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _announcements.length,
                itemBuilder: (context, index) {
                  final announcement = _announcements[index];
                  return _buildAnnouncementCard(announcement);
                },
              ),
    );
  }

  Widget _buildAnnouncementCard(Map<String, dynamic> announcement) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => AnnouncementDetail(announcement: announcement),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: announcement['color'].withValues(alpha: 0.3),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: announcement['color'].withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                announcement['icon'],
                color: announcement['color'],
                size: 28,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: announcement['color'].withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          announcement['category'],
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: announcement['color'],
                          ),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        announcement['date'],
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    announcement['title'],
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    announcement['description'],
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        'Read more',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: announcement['color'],
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.arrow_forward,
                        size: 14,
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
    );
  }
}

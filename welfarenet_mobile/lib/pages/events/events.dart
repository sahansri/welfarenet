import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:welfarenet_mobile/services/event_service.dart';
import 'package:welfarenet_mobile/pages/events/event_detail.dart';
import 'package:welfarenet_mobile/utils/responsive_utils.dart';

class Events extends StatefulWidget {
  const Events({super.key});

  @override
  State<Events> createState() => _EventsState();
}

class _EventsState extends State<Events> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  final ScrollController _scrollController = ScrollController();
  bool _isCalendarExpanded = true;
  final EventService _eventService = EventService();
  bool _isLoading = true;

  List<Map<String, dynamic>> _events = [];

  @override
  void initState() {
    super.initState();
    _loadEvents();

    // Add scroll listener to collapse/expand calendar
    _scrollController.addListener(() {
      if (_scrollController.hasClients) {
        if (_scrollController.offset > 50 && _isCalendarExpanded) {
          setState(() {
            _isCalendarExpanded = false;
          });
        } else if (_scrollController.offset <= 50 && !_isCalendarExpanded) {
          setState(() {
            _isCalendarExpanded = true;
          });
        }
      }
    });
  }

  Future<void> _loadEvents() async {
    setState(() {
      _isLoading = true;
    });

    final result = await _eventService.getEventsByMonth(
      _focusedDay.year,
      _focusedDay.month,
    );

    if (mounted) {
      setState(() {
        _isLoading = false;
      });

      if (result['success']) {
        try {
          final List<dynamic> data = result['data'];
          setState(() {
            _events =
                data.map<Map<String, dynamic>>((item) {
                  return {
                    'eventId': item['eventId'],
                    'title': item['eventName'] ?? 'No Title',
                    'description': item['description'] ?? 'No description',
                    'date': item['date'] ?? '',
                    'time': item['time'] ?? '',
                    'venue': item['venue'] ?? 'No venue',
                    'eventType': item['eventType'] ?? 'general',
                    'qrCode': item['qrCode'],
                    'donationAccepted': item['donationAccepted'] ?? false,
                    'published': item['published'] ?? false,
                  };
                }).toList();
          });
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error loading events: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Failed to load events'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> _getEventsForDay(DateTime day) {
    return _events.where((event) {
      if (event['date'] == null || event['date'].toString().isEmpty) {
        return false;
      }
      try {
        final eventDate = DateTime.parse(event['date']);
        return eventDate.year == day.year &&
            eventDate.month == day.month &&
            eventDate.day == day.day;
      } catch (e) {
        return false;
      }
    }).toList();
  }

  Color _getEventTypeColor(String? type) {
    switch (type?.toLowerCase()) {
      case 'community':
        return Colors.purple;
      case 'meeting':
        return Colors.blue;
      case 'charity':
        return Colors.orange;
      case 'celebration':
        return Colors.pink;
      case 'sports':
        return Colors.green;
      case 'volunteer':
        return Colors.indigo;
      default:
        return const Color(0xFF7A5AF8);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Purple gradient background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF7A5AF8),
                  Color(0xFF9B5DE5),
                  Color(0xFF5D45BC),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          // Content
          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(24),
                        topRight: Radius.circular(24),
                      ),
                    ),
                    child: Column(
                      children: [
                        // Calendar (expandable/collapsible)
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          child: _buildCalendar(),
                        ),
                        // Events list (scrollable)
                        Expanded(child: _buildEventsList()),
                      ],
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

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 10.0, 0, 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'Events',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Let\'s tackle all the events',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(0),
            child: Image.asset(
              'lib/assets/freepik__background__33966.png',
              width: 90,
              height: 90,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(
                  Icons.calendar_month,
                  color: Colors.white,
                  size: 50,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendar() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0xFF7A5AF8), width: 1),
          top: BorderSide(color: Color(0xFF7A5AF8), width: 1),
          left: BorderSide(color: Color(0xFF7A5AF8), width: 1),
          right: BorderSide(color: Color(0xFF7A5AF8), width: 1),
        ),
        color: const Color.fromARGB(255, 255, 255, 255),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TableCalendar(
        firstDay: DateTime.utc(2020, 1, 1),
        lastDay: DateTime.utc(2030, 12, 31),
        focusedDay: _focusedDay,
        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
        eventLoader: _getEventsForDay,
        calendarFormat:
            _isCalendarExpanded ? CalendarFormat.month : CalendarFormat.week,
        onDaySelected: (selectedDay, focusedDay) {
          setState(() {
            _selectedDay = selectedDay;
            _focusedDay = focusedDay;
          });
        },
        onPageChanged: (focusedDay) {
          _focusedDay = focusedDay;
          _loadEvents();
        },
        calendarStyle: CalendarStyle(
          todayDecoration: BoxDecoration(
            color: const Color(0xFF7A5AF8).withValues(alpha: 0.3),
            shape: BoxShape.circle,
          ),
          selectedDecoration: const BoxDecoration(
            color: Color(0xFF7A5AF8),
            shape: BoxShape.circle,
          ),
          markerDecoration: const BoxDecoration(
            color: Color(0xFF7A5AF8),
            shape: BoxShape.circle,
          ),
        ),
        calendarBuilders: CalendarBuilders(
          markerBuilder: (context, date, events) {
            if (events.isEmpty) return const SizedBox();

            return Positioned(
              bottom: 1,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children:
                    events.take(3).map((event) {
                      final eventData = event as Map<String, dynamic>;
                      return Container(
                        width: 5,
                        height: 5,
                        margin: const EdgeInsets.symmetric(horizontal: 0.5),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _getEventTypeColor(eventData['eventType']),
                        ),
                      );
                    }).toList(),
              ),
            );
          },
        ),
        headerStyle: const HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
          titleTextStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildEventsList() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Events',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Expanded(
            child:
                _isLoading
                    ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF7A5AF8),
                      ),
                    )
                    : _events.isEmpty
                    ? Center(
                      child: Text(
                        'No events available',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    )
                    : ListView.builder(
                      controller: _scrollController,
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: _events.length,
                      itemBuilder: (context, index) {
                        final event = _events[index];
                        return InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => EventDetail(eventData: event),
                              ),
                            );
                          },
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: _getEventTypeColor(
                                  event['eventType'],
                                ).withOpacity(0.3),
                                width: 1.5,
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
                              children: [
                                // Event type color indicator
                                Container(
                                  width: 4,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    color: _getEventTypeColor(
                                      event['eventType'],
                                    ),
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              event['title'] ?? 'No Title',
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: _getEventTypeColor(
                                                event['eventType'],
                                              ).withOpacity(0.15),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              event['eventType']
                                                      ?.toUpperCase() ??
                                                  '',
                                              style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                                color: _getEventTypeColor(
                                                  event['eventType'],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        event['description'] ??
                                            'No Description',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey[600],
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.calendar_today,
                                            size: 14,
                                            color: Colors.grey[600],
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            event['date'] ?? '',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Icon(
                                            Icons.access_time,
                                            size: 14,
                                            color: Colors.grey[600],
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            event['time'] ?? '',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF7A5AF8),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.arrow_forward,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }
}

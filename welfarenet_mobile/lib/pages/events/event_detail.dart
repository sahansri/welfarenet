import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:welfarenet_mobile/services/attendance_service.dart';
import 'package:welfarenet_mobile/pages/events/qr_scanner.dart';

class EventDetail extends StatefulWidget {
  final Map<String, dynamic> eventData;

  const EventDetail({super.key, required this.eventData});

  @override
  State<EventDetail> createState() => _EventDetailState();
}

class _EventDetailState extends State<EventDetail> {
  final AttendanceService _attendanceService = AttendanceService();
  bool _isSubmitting = false;
  String? _scannedQrCode;

  bool _isCurrentMonthEvent() {
    try {
      final eventDate = DateTime.parse(widget.eventData['date'] ?? '');
      final now = DateTime.now();
      return eventDate.year == now.year && eventDate.month == now.month;
    } catch (e) {
      return false;
    }
  }

  Future<void> _openQRScanner() async {
    if (!_isCurrentMonthEvent()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'QR scanning is only available for current month events',
          ),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const QRScanner()),
    );

    if (result != null && result is String) {
      _markAttendance(result);
    }
  }

  Future<void> _markAttendance(String scannedCode) async {
    // Validate QR code format
    String qrCode = scannedCode.trim();

    // Convert QR code format from EVENT_ID=15 to EVENT:15
    if (qrCode.toUpperCase().startsWith('EVENT_ID=')) {
      final eventId = qrCode.substring(9); // Extract the ID after "EVENT_ID="
      qrCode = 'EVENT:$eventId';
    } else if (!qrCode.toUpperCase().startsWith('EVENT:')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid QR code format'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    // Mark attendance via API (backend validates QR code and extracts eventId)
    final result = await _attendanceService.markAttendance(qrCodeData: qrCode);

    if (mounted) {
      setState(() {
        _isSubmitting = false;
      });

      if (result['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result['message'] ?? 'Attendance marked successfully!',
            ),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Failed to mark attendance'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return 'TBA';
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
      return '${date.day} ${months[date.month - 1]} ${date.year}';
    } catch (e) {
      return dateStr;
    }
  }

  String _formatTime(String? timeStr) {
    if (timeStr == null || timeStr.isEmpty) return 'TBA';
    try {
      final parts = timeStr.split(':');
      if (parts.length >= 2) {
        int hour = int.parse(parts[0]);
        int minute = int.parse(parts[1]);
        String period = hour >= 12 ? 'PM' : 'AM';
        hour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
        return '$hour:${minute.toString().padLeft(2, '0')} $period';
      }
      return timeStr;
    } catch (e) {
      return timeStr;
    }
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF7A5AF8),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Event Details',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    _getEventTypeColor(widget.eventData['eventType']),
                    _getEventTypeColor(
                      widget.eventData['eventType'],
                    ).withOpacity(0.7),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      widget.eventData['eventType']?.toUpperCase() ?? 'EVENT',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.eventData['title'] ?? 'Event Name',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            // Details Section
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Date & Time
                  _buildInfoRow(
                    Icons.calendar_today,
                    'Date',
                    _formatDate(widget.eventData['date']),
                  ),
                  const SizedBox(height: 16),
                  _buildInfoRow(
                    Icons.access_time,
                    'Time',
                    _formatTime(widget.eventData['time']),
                  ),
                  const SizedBox(height: 16),
                  _buildInfoRow(
                    Icons.location_on,
                    'Venue',
                    widget.eventData['venue'] ?? 'TBA',
                  ),
                  const SizedBox(height: 24),

                  // Description
                  const Text(
                    'Description',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.eventData['description'] ??
                        'No description available',
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey[700],
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Donation Status
                  if (widget.eventData['donationAccepted'] == true)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.green),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.card_giftcard, color: Colors.green),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              'Donations Accepted',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Colors.green,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 24),

                  // QR Attendance Section
                  const Text(
                    'Mark Attendance',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _isCurrentMonthEvent()
                        ? 'Scan the QR code at the event venue to mark your attendance'
                        : 'QR scanning is only available during the event month',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 16),

                  // Scan QR Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed:
                          (_isSubmitting || !_isCurrentMonthEvent())
                              ? null
                              : _openQRScanner,
                      icon: const Icon(
                        Icons.qr_code_scanner,
                        color: Colors.white,
                      ),
                      label:
                          _isSubmitting
                              ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                              : const Text(
                                'Scan QR Code',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            _isCurrentMonthEvent()
                                ? const Color(0xFF7A5AF8)
                                : Colors.grey,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Info Text
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Colors.blue[700],
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'The QR code will be provided at the event venue',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.blue[700],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF7A5AF8).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: const Color(0xFF7A5AF8), size: 20),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:welfarenet_mobile/services/auth_service.dart';

class EventService {
  String get baseUrl => AuthService.baseUrl;

  // Get all events
  Future<Map<String, dynamic>> getAllEvents() async {
    try {
      final token = await AuthService().getToken();

      final response = await http
          .get(
            Uri.parse('$baseUrl/api/events/getAll'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              throw Exception('Connection timeout - server not reachable');
            },
          );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'data': data};
      } else {
        return {
          'success': false,
          'message': 'Failed to load events: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  // Get events by month
  Future<Map<String, dynamic>> getEventsByMonth(int year, int month) async {
    try {
      final token = await AuthService().getToken();

      final response = await http
          .get(
            Uri.parse('$baseUrl/api/events/by-month').replace(
              queryParameters: {
                'year': year.toString(),
                'month': month.toString(),
              },
            ),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              throw Exception('Connection timeout - server not reachable');
            },
          );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'data': data};
      } else {
        return {
          'success': false,
          'message': 'Failed to load events: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  // Get recent events (last 30 days)
  Future<Map<String, dynamic>> getRecentEvents() async {
    try {
      final token = await AuthService().getToken();

      final response = await http
          .get(
            Uri.parse('$baseUrl/api/events/upcoming'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              throw Exception('Connection timeout - server not reachable');
            },
          );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'data': data};
      } else {
        return {
          'success': false,
          'message': 'Failed to load recent events: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  //get future donation accepted events
  Future<Map<String, dynamic>> getFutureDonationAcceptedEvents() async {
    try {
      final token = await AuthService().getToken();

      final response = await http
          .get(
            Uri.parse('$baseUrl/api/events/upcoming/donation-accepted'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              throw Exception('Connection timeout - server not reachable');
            },
          );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'data': data};
      } else {
        return {
          'success': false,
          'message':
              'Failed to load future donation accepted events: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }
}

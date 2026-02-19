import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:welfarenet_mobile/services/auth_service.dart';

class AnnouncementService {
  String get baseUrl => AuthService.baseUrl;

  Future<Map<String, dynamic>> fetchlatest3Announcements() async {
    try {
      final token = await AuthService().getToken();

      final response = await http
          .get(
            Uri.parse('$baseUrl/api/announcements/recent-3'),
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
        return {'success': false, 'message': 'Failed to fetch announcements'};
      }
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> fetchAllAnnouncements() async {
    try {
      final token = await AuthService().getToken();

      final response = await http
          .get(
            Uri.parse('$baseUrl/api/announcements/getall'),
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
        return {'success': false, 'message': 'Failed to fetch announcements'};
      }
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }
}

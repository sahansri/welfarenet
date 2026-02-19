import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:welfarenet_mobile/services/auth_service.dart';

class ComplainService {
  String get baseUrl => AuthService.baseUrl;

  // Submit a new complaint
  Future<Map<String, dynamic>> submitComplaint({
    required String type,
    required String title,
    required String description,
    required bool anonymous,
  }) async {
    try {
      final token = await AuthService().getToken();

      final response = await http
          .post(
            Uri.parse('$baseUrl/api/complaints/submit').replace(
              queryParameters: {
                'type': type,
                'title': title,
                'description': description,
                'anonymous': anonymous.toString(),
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
          'message': 'Failed to submit complaint: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  // Get member's past complaints
  Future<Map<String, dynamic>> getMyComplaints() async {
    try {
      final token = await AuthService().getToken();

      final response = await http
          .get(
            Uri.parse('$baseUrl/api/complaints/my'),
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
          'message': 'Failed to fetch complaints: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }
}

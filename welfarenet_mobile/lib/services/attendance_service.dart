import 'package:http/http.dart' as http;
import 'package:welfarenet_mobile/services/auth_service.dart';

class AttendanceService {
  String get baseUrl => AuthService.baseUrl;

  // Mark attendance using QR code
  Future<Map<String, dynamic>> markAttendance({
    required String qrCodeData,
  }) async {
    try {
      final token = await AuthService().getToken();

      final response = await http
          .post(
            Uri.parse(
              '$baseUrl/api/attendance/mark',
            ).replace(queryParameters: {'qrContent': qrCodeData}),
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
        // Backend returns a simple string message
        final message = response.body;
        return {'success': true, 'message': message};
      } else if (response.statusCode == 400) {
        // Invalid or expired QR code
        return {
          'success': false,
          'message':
              response.body.isNotEmpty
                  ? response.body
                  : 'Invalid or expired QR code',
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to mark attendance: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }
}

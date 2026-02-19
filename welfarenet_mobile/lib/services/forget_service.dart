import 'package:http/http.dart' as http;
import 'package:welfarenet_mobile/services/auth_service.dart';

class ForgetService {
  String get baseUrl => AuthService.baseUrl;

Future<Map<String, dynamic>> sendEmailToReset(String email) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/member/forgot-password?email=$email'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
       return {'success': true, 'message': response.body};
      } else {
        return {'success': false, 'message': 'Failed to send reset email'};
      }
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

Future<Map<String, dynamic>> verifyOtpCode(String email, String otpCode) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/member/verify-otp?email=$email&otp=$otpCode'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
       return {'success': true, 'message': response.body};
      } else {
        return {'success': false, 'message': 'Invalid OTP code'};
      }
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> resetPassword(String email, String newPassword) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/member/reset-password?email=$email&password=$newPassword&confirmPassword=$newPassword'),
        headers: {'Content-Type': 'application/json'},
      );
      // ignore: avoid_print
      print(response.body);
      if (response.statusCode == 200) {
       return {'success': true, 'message': response.body};
      } else {
        return {'success': false, 'message': 'Failed to reset password'};
      }
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }
}

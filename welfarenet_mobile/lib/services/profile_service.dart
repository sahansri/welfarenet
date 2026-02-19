import 'dart:convert';
import 'package:welfarenet_mobile/services/auth_service.dart';
import 'package:http/http.dart' as http;

class ProfileService {
  String get baseUrl => AuthService.baseUrl;

  Future<Map<String, dynamic>> updateMyDetails(
    Map<String, dynamic> memberData,
  ) async {
    try {
      // Get the authentication token
      final token = await AuthService().getToken();

      if (token == null || token.isEmpty) {
        return {'success': false, 'message': 'Not authenticated'};
      }

      final response = await http.put(
        Uri.parse('$baseUrl/api/member/me'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(memberData),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'data': data,
          'message': 'Profile updated successfully',
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to update profile: ${response.body}',
        };
      }
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      // Get the authentication token
      final token = await AuthService().getToken();

      if (token == null || token.isEmpty) {
        return {'success': false, 'message': 'Not authenticated'};
      }

      final response = await http.put(
        Uri.parse('$baseUrl/api/member/me/password'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'oldPassword': oldPassword,
          'newPassword': newPassword,
        }),
      );

      if (response.statusCode == 200) {
        return {'success': true, 'message': 'Password changed successfully'};
      } else if (response.statusCode == 401) {
        return {'success': false, 'message': 'Old password is incorrect'};
      } else if (response.statusCode == 404) {
        return {'success': false, 'message': 'User not found'};
      } else if (response.statusCode == 400) {
        return {'success': false, 'message': response.body};
      } else {
        return {
          'success': false,
          'message': 'Failed to change password: ${response.body}',
        };
      }
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }
}

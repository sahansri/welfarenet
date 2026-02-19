import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:welfarenet_mobile/services/auth_service.dart';

class StarsService {
  String get baseUrl => AuthService.baseUrl;
  final AuthService _authService = AuthService();

  Future<Map<String, dynamic>> getMemberBalance(int memberId) async {
    try {
      final token = await _authService.getToken();
      if (token == null) {
        return {'success': false, 'message': 'No authentication token found'};
      }

      final response = await http.get(
        Uri.parse('$baseUrl/api/stars/balance/$memberId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final balance = data['balance'] ?? 0;
        return {'success': true, 'balance': balance};
      } else {
        return {
          'success': false,
          'message': 'Failed to fetch balance: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error fetching balance: $e'};
    }
  }
}

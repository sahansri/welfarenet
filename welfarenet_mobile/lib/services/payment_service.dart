import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:welfarenet_mobile/services/auth_service.dart';
import 'package:welfarenet_mobile/models/payment_model.dart';

class PaymentService {
  final AuthService _authService = AuthService();
  String get baseUrl => AuthService.baseUrl;

  // Get headers with authentication token
  Future<Map<String, String>> _getHeaders() async {
    final token = await _authService.getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // Get total amount (all payments)
  Future<double> getTotalAmount() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/api/payment/my-total'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return (data['totalAmount'] ?? 0).toDouble();
      } else {
        throw Exception('Failed to load total amount');
      }
    } catch (e) {
      print('Error fetching total amount: $e');
      return 0.0;
    }
  }

  // Get pending (review) total amount
  Future<double> getPendingTotalAmount() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/api/payment/my-pending-total'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return (data['totalAmount'] ?? 0).toDouble();
      } else {
        throw Exception('Failed to load pending total amount');
      }
    } catch (e) {
      print('Error fetching pending total amount: $e');
      return 0.0;
    }
  }

  // Get approved total amount
  Future<double> getApprovedTotalAmount() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/api/payment/my-approved-total'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return (data['totalAmount'] ?? 0).toDouble();
      } else {
        throw Exception('Failed to load approved total amount');
      }
    } catch (e) {
      print('Error fetching approved total amount: $e');
      return 0.0;
    }
  }

  // Get my payments for current year list
  Future<List<PaymentModel>> getMyPayments() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/api/payment/my-payments-by-year'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => PaymentModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load payments');
      }
    } catch (e) {
      print('Error fetching payments: $e');
      return [];
    }
  }

  // Get payments filtered by status
  Future<List<PaymentModel>> getPaymentsByStatus(String status) async {
    final allPayments = await getMyPayments();
    return allPayments.where((payment) => payment.status == status).toList();
  }

  // Get pending (review) payments
  Future<List<PaymentModel>> getPendingPayments() async {
    return await getPaymentsByStatus('PENDING');
  }

  // Get approved payments
  Future<List<PaymentModel>> getApprovedPayments() async {
    return await getPaymentsByStatus('APPROVED');
  }

  // Get all payment details (view all payments)
  Future<List<PaymentModel>> getAllPaymentDetails() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/api/payment/my-payments'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => PaymentModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load all payment details');
      }
    } catch (e) {
      print('Error fetching all payment details: $e');
      return [];
    }
  }

  // Submit donation payment
  Future<Map<String, dynamic>> submitDonation({
    required File slipFile,
    required int? eventId,
    required double amount,
    required DateTime paymentDate,
    String? remarks,
  }) async {
    try {
      final token = await _authService.getToken();

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/api/payment/donation'),
      );

      // Add headers
      request.headers['Authorization'] = 'Bearer $token';
      request.headers['Accept'] = 'application/json';

      // Add file
      request.files.add(
        await http.MultipartFile.fromPath('slip', slipFile.path),
      );

      // Add form fields
      // Only add eventId if it's not null (i.e., not "Other" donation)
      if (eventId != null) {
        request.fields['eventId'] = eventId.toString();
      }
      request.fields['amount'] = amount.toString();
      request.fields['paymentDate'] =
          '${paymentDate.year}-${paymentDate.month.toString().padLeft(2, '0')}-${paymentDate.day.toString().padLeft(2, '0')}';
      if (remarks != null && remarks.isNotEmpty) {
        request.fields['remarks'] = remarks;
      }

      // Send request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'data': data};
      } else {
        return {
          'success': false,
          'message': 'Failed to submit donation: ${response.statusCode}',
        };
      }
    } catch (e) {
      print('Error submitting donation: $e');
      return {'success': false, 'message': e.toString()};
    }
  }

  // Get unpaid membership months
  Future<List<String>> getUnpaidMonths() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/api/payment/membership/unpaid-months'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        // Convert YearMonth format (e.g., "2026-01") to display format
        return data.map((yearMonth) => yearMonth.toString()).toList();
      } else {
        throw Exception('Failed to load unpaid months');
      }
    } catch (e) {
      print('Error fetching unpaid months: $e');
      return [];
    }
  }

  // Submit membership payment
  Future<Map<String, dynamic>> submitMembershipPayment({
    required File slipFile,
    required double amount,
    required String selectedMonth, // Format: "yyyy-MM"
    required DateTime paymentDate,
    String? remarks,
  }) async {
    try {
      final token = await _authService.getToken();

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/api/payment/membership'),
      );

      // Add headers
      request.headers['Authorization'] = 'Bearer $token';
      request.headers['Accept'] = 'application/json';

      // Add file
      request.files.add(
        await http.MultipartFile.fromPath('slip', slipFile.path),
      );

      // Add form fields
      request.fields['amount'] = amount.toString();
      request.fields['selectedMonth'] = selectedMonth;
      request.fields['paymentDate'] =
          '${paymentDate.year}-${paymentDate.month.toString().padLeft(2, '0')}-${paymentDate.day.toString().padLeft(2, '0')}';
      if (remarks != null && remarks.isNotEmpty) {
        request.fields['remarks'] = remarks;
      }

      // Send request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'data': data};
      } else {
        return {
          'success': false,
          'message':
              'Failed to submit membership payment: ${response.statusCode}',
        };
      }
    } catch (e) {
      print('Error submitting membership payment: $e');
      return {'success': false, 'message': e.toString()};
    }
  }
}

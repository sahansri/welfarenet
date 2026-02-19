import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:welfarenet_mobile/services/auth_service.dart';
import 'package:welfarenet_mobile/models/star_claim_offer.dart';
import 'package:welfarenet_mobile/models/star_claim_request.dart';

class RewardsService {
  String get baseUrl => AuthService.baseUrl;
  final AuthService _authService = AuthService();

  /// Fetch all available offers
  Future<Map<String, dynamic>> getAllOffers() async {
    try {
      final token = await _authService.getToken();
      if (token == null) {
        return {'success': false, 'message': 'No authentication token found'};
      }

      final response = await http.get(
        Uri.parse('$baseUrl/api/claims/offers'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        final List<StarClaimOffer> offers =
            jsonList.map((json) => StarClaimOffer.fromJson(json)).toList();
        return {'success': true, 'offers': offers};
      } else {
        return {
          'success': false,
          'message': 'Failed to load offers: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  /// Fetch only redeemable offers (based on user's available stars)
  Future<Map<String, dynamic>> getRedeemableOffers() async {
    try {
      final token = await _authService.getToken();
      if (token == null) {
        return {'success': false, 'message': 'No authentication token found'};
      }

      final response = await http.get(
        Uri.parse('$baseUrl/api/claims/redeemable-offers'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        final List<StarClaimOffer> offers =
            jsonList.map((json) => StarClaimOffer.fromJson(json)).toList();
        return {'success': true, 'offers': offers};
      } else {
        return {
          'success': false,
          'message': 'Failed to load redeemable offers: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  /// Redeem/Apply for a claim offer
  Future<Map<String, dynamic>> redeemOffer(
    int memberId,
    int claimTypeId,
  ) async {
    try {
      final token = await _authService.getToken();
      if (token == null) {
        return {'success': false, 'message': 'No authentication token found'};
      }

      final response = await http.post(
        Uri.parse(
          '$baseUrl/api/claims/apply?memberId=$memberId&claimTypeId=$claimTypeId',
        ),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return {'success': true, 'data': responseData};
      } else {
        return {
          'success': false,
          'message': 'Failed to redeem offer: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  /// Fetch member's claim request history
  Future<Map<String, dynamic>> getMemberClaimRequests() async {
    try {
      final token = await _authService.getToken();
      if (token == null) {
        return {'success': false, 'message': 'No authentication token found'};
      }

      final response = await http.get(
        Uri.parse('$baseUrl/api/claims/member/requests'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        final List<StarClaimRequest> requests =
            jsonList.map((json) => StarClaimRequest.fromJson(json)).toList();
        return {'success': true, 'requests': requests};
      } else {
        return {
          'success': false,
          'message': 'Failed to load claim history: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }
}

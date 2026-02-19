import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http_parser/http_parser.dart';

class AuthService {
  //  Replace with your actual Spring Boot backend URL
  static const String baseUrl = 'http://172.20.10.4:8080';

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    return token != null && token.isNotEmpty;
  }

  // Get stored token
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  // Get stored user ID
  Future<int?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('user_id');
  }

  // Login with email and password
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/login'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Store the token and user info
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', data['token'] ?? '');
        await prefs.setString('user_email', email);

        // Store user ID (check different possible field names)
        if (data['userId'] != null) {
          await prefs.setInt('user_id', data['userId']);
        } else if (data['id'] != null) {
          await prefs.setInt('user_id', data['id']);
        } else if (data['memberId'] != null) {
          await prefs.setInt('user_id', data['memberId']);
        }

        return {'success': true, 'message': 'Login successful', 'data': data};
      } else if (response.statusCode == 403) {
        return {
          'success': false,
          'message':'Account inactive or not found',
        };
      } else {
        final error = jsonDecode(response.body);
        return {
          'success': false,
          'message': error['message'] ?? 'Login failed',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }

  // Logout
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('user_email');
  }

  // Get user info
  Future<Map<String, dynamic>> getUserInfo() async {
    try {
      final token = await getToken();
      if (token == null) {
        return {'success': false, 'message': 'No token found'};
      }

      final response = await http.get(
        Uri.parse('$baseUrl/api/member/me'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        //store user data in shared preferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('fullName', data['fullName'] ?? '');
        await prefs.setString('address', data['address'] ?? '');
        await prefs.setString('contactNumber', data['contactNumber'] ?? '');
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'message': 'Failed to fetch user info'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }

  // Register new member
  Future<Map<String, dynamic>> register({
    required String fullName,
    required String address,
    required String contactNumber,
    required String email,
    required String houseNo,
    required PlatformFile proofDocument,
  }) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/api/auth/self-register'),
      );

      // Add text fields
      request.fields['fullName'] = fullName;
      request.fields['address'] = address;
      request.fields['contactNumber'] = contactNumber;
      request.fields['email'] = email;
      request.fields['houseNo'] = houseNo;

      // Add file
      print('📎 Attaching file: ${proofDocument.name}');
      print('   File size: ${proofDocument.size} bytes');
      print('   Has bytes: ${proofDocument.bytes != null}');
      print('   Has path: ${proofDocument.path != null}');

      final mimeType = _getMimeType(proofDocument.extension ?? '');

      if (proofDocument.bytes != null) {
        print('   Using bytes for upload');
        request.files.add(
          http.MultipartFile.fromBytes(
            'proofDocument',
            proofDocument.bytes!,
            filename: proofDocument.name,
            contentType: MediaType(mimeType[0], mimeType[1]),
          ),
        );
      } else if (proofDocument.path != null) {
        print('   Using path for upload: ${proofDocument.path}');
        request.files.add(
          await http.MultipartFile.fromPath(
            'proofDocument',
            proofDocument.path!,
            filename: proofDocument.name,
            contentType: MediaType(mimeType[0], mimeType[1]),
          ),
        );
      } else {
        throw Exception('File has neither bytes nor path');
      }

      print('📋 Request fields: ${request.fields}');
      print('📎 Request files: ${request.files.length} file(s)');
      if (request.files.isNotEmpty) {
        print('   File field name: ${request.files.first.field}');
        print('   File filename: ${request.files.first.filename}');
        print('   File content type: ${request.files.first.contentType}');
        print('   File length: ${request.files.first.length} bytes');
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('📥 Response status: ${response.statusCode}');
      print('📥 Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        // API returns plain text, not JSON
        return {'success': true, 'message': response.body};
      } else {
        try {
          final error = jsonDecode(response.body);
          return {
            'success': false,
            'message': error['message'] ?? 'Registration failed',
          };
        } catch (e) {
          return {
            'success': false,
            'message':
                response.body.isNotEmpty
                    ? response.body
                    : 'Registration failed: ${response.statusCode}',
          };
        }
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }

  // Helper method to get MIME type based on file extension
  List<String> _getMimeType(String extension) {
    switch (extension.toLowerCase()) {
      case 'pdf':
        return ['application', 'pdf'];
      case 'jpg':
      case 'jpeg':
        return ['image', 'jpeg'];
      case 'png':
        return ['image', 'png'];
      case 'gif':
        return ['image', 'gif'];
      case 'bmp':
        return ['image', 'bmp'];
      case 'webp':
        return ['image', 'webp'];
      case 'doc':
        return ['application', 'msword'];
      case 'docx':
        return [
          'application',
          'vnd.openxmlformats-officedocument.wordprocessingml.document',
        ];
      case 'xls':
        return ['application', 'vnd.ms-excel'];
      case 'xlsx':
        return [
          'application',
          'vnd.openxmlformats-officedocument.spreadsheetml.sheet',
        ];
      case 'txt':
        return ['text', 'plain'];
      case 'zip':
        return ['application', 'zip'];
      case 'rar':
        return ['application', 'x-rar-compressed'];
      default:
        return ['application', 'octet-stream'];
    }
  }

  // Deactivate account
  Future<Map<String, dynamic>> deactivateAccount(String reason) async {
    try {
      final token = await getToken();
      if (token == null) {
        return {'success': false, 'message': 'No token found'};
      }

      final response = await http.post(
        Uri.parse('$baseUrl/api/member/deactivate'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'reason': reason}),
      );

      if (response.statusCode == 200) {
        // Clear stored data after deactivation
        final prefs = await SharedPreferences.getInstance();
        await prefs.clear();

        return {'success': true, 'message': response.body};
      } else {
        return {
          'success': false,
          'message':
              response.body.isNotEmpty
                  ? response.body
                  : 'You must pay membership fee up to current month before deactivation.',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }
}

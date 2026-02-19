import 'package:http/http.dart' as http;
import 'package:welfarenet_mobile/services/auth_service.dart';

class NewsfeedService {
  String get baseUrl => AuthService.baseUrl;

  Future<Map<String, dynamic>> fetchNewsfeed() async {
    try {
      // Get token inside the async method
      final token = await AuthService().getToken();

      final response = await http.get(
        Uri.parse('$baseUrl/api/newsfeed/sorted-bydate'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      // ignore: avoid_print
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = response.body;
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'message': 'Failed to fetch newsfeed'};
      }
    } catch (e) {
      // ignore: avoid_print
      print('Error in fetchNewsfeed: $e');
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> uploadPost({
    required int authorId,
    required String content,
    List<int>? imageBytes,
    String? imageName,
  }) async {
    try {
      final token = await AuthService().getToken();

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/api/newsfeed/create'),
      );

      request.headers['Authorization'] = 'Bearer $token';
      request.fields['authorId'] = authorId.toString();

      if (content.isNotEmpty) {
        request.fields['content'] = content;
        print('✅ Added content field');
      } else {
        print('⚠️ Content is empty');
      }

      // Add image if provided
      if (imageBytes != null && imageName != null) {
        if (imageBytes.isEmpty) {
          print('❌ ERROR: imageBytes is empty!');
        } else {
          request.files.add(
            http.MultipartFile.fromBytes(
              'images',
              imageBytes,
              filename: imageName,
            ),
          );
          print('✅ Added image file: $imageName (${imageBytes.length} bytes)');
        }
      } else {
        print(
          '⚠️ No image provided (bytes: ${imageBytes == null ? "null" : "exists"}, name: ${imageName ?? "null"})',
        );
      }

      if (request.files.isNotEmpty) {
        for (var file in request.files) {
          print('   - ${file.field}: ${file.filename} (${file.length} bytes)');
        }
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {'success': true, 'message': 'Post created successfully'};
      } else {
        return {
          'success': false,
          'message': 'Failed to create post: ${response.statusCode}',
        };
      }
    } catch (e) {
      print('❌ ERROR in uploadPost: $e');
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> likePost({
    required int postId,
    required int memberId,
  }) async {
    try {
      final token = await AuthService().getToken();

      final response = await http.post(
        Uri.parse('$baseUrl/api/newsfeed/$postId/like?memberId=$memberId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('👍 Like API Response: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {'success': true, 'message': 'Post liked successfully'};
      } else {
        return {
          'success': false,
          'message': 'Failed to like post: ${response.statusCode}',
        };
      }
    } catch (e) {
      print('❌ ERROR in likePost: $e');
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> unlikePost({
    required int postId,
    required int memberId,
  }) async {
    try {
      final token = await AuthService().getToken();

      final response = await http.delete(
        Uri.parse('$baseUrl/api/newsfeed/$postId/unlike?memberId=$memberId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('👎 Unlike API Response: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 204) {
        return {'success': true, 'message': 'Post unliked successfully'};
      } else {
        return {
          'success': false,
          'message': 'Failed to unlike post: ${response.statusCode}',
        };
      }
    } catch (e) {
      print('❌ ERROR in unlikePost: $e');
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> addComment({
    required int postId,
    required int memberId,
    required String content,
  }) async {
    try {
      final token = await AuthService().getToken();

      final response = await http.post(
        Uri.parse(
          '$baseUrl/api/newsfeed/$postId/addcomment?memberId=$memberId&commentText=$content',
        ),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('💬 Comment API Response: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {'success': true, 'message': 'Comment added successfully'};
      } else {
        return {
          'success': false,
          'message': 'Failed to add comment: ${response.statusCode}',
        };
      }
    } catch (e) {
      print('❌ ERROR in addComment: $e');
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> deleteComment({
    required int postId,
    required int commentId,
  }) async {
    try {
      final token = await AuthService().getToken();

      final response = await http.delete(
        Uri.parse(
          '$baseUrl/api/newsfeed/$postId/deletecomment?postId=$postId&commentId=$commentId',
        ),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('🗑️ Delete Comment API Response: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 204) {
        return {'success': true, 'message': 'Comment deleted successfully'};
      } else {
        return {
          'success': false,
          'message': 'Failed to delete comment: ${response.statusCode}',
        };
      }
    } catch (e) {
      print('❌ ERROR in deleteComment: $e');
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> editComment({
    required int postId,
    required int commentId,
    required String newContent,
  }) async {
    try {
      final token = await AuthService().getToken();

      final response = await http.put(
        Uri.parse(
          '$baseUrl/api/newsfeed/$postId/editcomment?commentId=$commentId&newText=$newContent',
        ),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('✏️ Edit Comment API Response: ${response.statusCode}');

      if (response.statusCode == 200) {
        return {'success': true, 'message': 'Comment edited successfully'};
      } else {
        return {
          'success': false,
          'message': 'Failed to edit comment: ${response.statusCode}',
        };
      }
    } catch (e) {
      print('❌ ERROR in editComment: $e');
      return {'success': false, 'message': e.toString()};
    }
  }

  // Fetch posts by specific user
  Future<Map<String, dynamic>> fetchUserPosts(int userId) async {
    try {
      final token = await AuthService().getToken();

      final response = await http.get(
        Uri.parse('$baseUrl/api/newsfeed/getposts/$userId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('📱 User Posts Response: ${response.body}');

      if (response.statusCode == 200) {
        return {'success': true, 'data': response.body};
      } else {
        return {'success': false, 'message': 'Failed to fetch user posts'};
      }
    } catch (e) {
      print('❌ ERROR in fetchUserPosts: $e');
      return {'success': false, 'message': e.toString()};
    }
  }

  // Delete a post
  Future<Map<String, dynamic>> deletePost(int postId) async {
    try {
      final token = await AuthService().getToken();

      final response = await http.delete(
        Uri.parse('$baseUrl/api/newsfeed/$postId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('🗑️ Delete Post Response: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 204) {
        return {'success': true, 'message': 'Post deleted successfully'};
      } else {
        return {
          'success': false,
          'message': 'Failed to delete post: ${response.statusCode}',
        };
      }
    } catch (e) {
      print('❌ ERROR in deletePost: $e');
      return {'success': false, 'message': e.toString()};
    }
  }

  // Update a post
  Future<Map<String, dynamic>> updatePost({
    required int postId,
    required String content,
    List<int>? imageBytes,
    String? imageName,
  }) async {
    try {
      final token = await AuthService().getToken();

      var request = http.MultipartRequest(
        'put',
        Uri.parse('$baseUrl/api/newsfeed/$postId/edit'),
      );

      request.headers['Authorization'] = 'Bearer $token';

      if (content.isNotEmpty) {
        request.fields['content'] = content;
      }

      // Add image if provided
      if (imageBytes != null && imageName != null && imageBytes.isNotEmpty) {
        request.files.add(
          http.MultipartFile.fromBytes(
            'images',
            imageBytes,
            filename: imageName,
          ),
        );
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('✏️ Update Post Response: ${response.statusCode}');

      if (response.statusCode == 200) {
        return {'success': true, 'message': 'Post updated successfully'};
      } else {
        return {
          'success': false,
          'message': 'Failed to update post: ${response.statusCode}',
        };
      }
    } catch (e) {
      print('❌ ERROR in updatePost: $e');
      return {'success': false, 'message': e.toString()};
    }
  }
}

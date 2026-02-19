import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:file_picker/file_picker.dart';
import 'package:welfarenet_mobile/services/auth_service.dart';
import 'package:welfarenet_mobile/services/profile_service.dart';
import 'package:welfarenet_mobile/services/newsfeed_service.dart';
import 'package:welfarenet_mobile/pages/profile/edit_profile_details.dart';
import 'package:welfarenet_mobile/utils/responsive_utils.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final AuthService _authService = AuthService();
  final ProfileService _profileService = ProfileService();
  final NewsfeedService _newsfeedService = NewsfeedService();

  bool _isLoading = true;
  bool _isLoadingPosts = true;

  // User info
  Map<String, dynamic>? _userInfo;
  int? _currentUserId;

  // User posts
  final List<Map<String, dynamic>> _userPosts = [];

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
    _loadUserPosts();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _loadUserProfile() async {
    setState(() {
      _isLoading = true;
    });

    final result = await _authService.getUserInfo();
    _currentUserId = await _authService.getUserId();

    if (mounted) {
      setState(() {
        _isLoading = false;
      });

      if (result['success']) {
        setState(() {
          _userInfo = result['data'];
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Failed to load profile'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _loadUserPosts() async {
    if (_currentUserId == null) {
      _currentUserId = await _authService.getUserId();
    }

    if (_currentUserId == null) return;

    setState(() {
      _isLoadingPosts = true;
    });

    final result = await _newsfeedService.fetchUserPosts(_currentUserId!);

    if (mounted) {
      setState(() {
        _isLoadingPosts = false;
      });

      if (result['success']) {
        try {
          final List<dynamic> data = jsonDecode(result['data']);

          // Sort posts by date and time in descending order (newest first)
          data.sort((a, b) {
            try {
              DateTime? dateA = _parsePostDateTime(
                a['datePosted'],
                a['timePosted'],
              );
              DateTime? dateB = _parsePostDateTime(
                b['datePosted'],
                b['timePosted'],
              );

              if (dateA == null && dateB == null) return 0;
              if (dateA == null) return 1;
              if (dateB == null) return -1;

              return dateB.compareTo(dateA); // Descending order (newest first)
            } catch (e) {
              return 0;
            }
          });

          setState(() {
            _userPosts.clear();
            for (var item in data) {
              String authorName = 'Unknown';
              if (item['author'] != null && item['author'] is Map) {
                authorName = item['author']['fullName'] ?? 'Unknown';
              }

              String timeStr = _formatDateTime(
                item['datePosted'],
                item['timePosted'],
              );

              // Handle images
              String? mediaUrl;
              if (item['images'] != null &&
                  item['images'] is List &&
                  (item['images'] as List).isNotEmpty) {
                final firstImage = item['images'][0];
                if (firstImage is Map && firstImage['imagePath'] != null) {
                  final imagePath = firstImage['imagePath'].toString().trim();
                  if (_isValidImageUrl(imagePath)) {
                    mediaUrl = imagePath;
                  }
                }
              }

              // Parse comments with author information
              List<Map<String, dynamic>> commentsList = [];
              if (item['comments'] != null && item['comments'] is List) {
                for (var comment in item['comments']) {
                  if (comment is Map) {
                    String commentAuthor = 'Anonymous';
                    int? commentAuthorId;
                    if (comment['member'] != null && comment['member'] is Map) {
                      commentAuthor =
                          comment['member']['fullName'] ?? 'Anonymous';
                      commentAuthorId = comment['member']['memberID'];
                    }

                    commentsList.add({
                      'commentId': comment['commentID'],
                      'content': comment['commentText'] ?? '',
                      'author': commentAuthor,
                      'authorId': commentAuthorId,
                      'timestamp': comment['timestamp'] ?? '',
                    });
                  }
                }
              }

              // Check if current user has liked this post and get all likes
              bool isLikedByUser = false;
              List<Map<String, dynamic>> likedByUsers = [];
              int totalLikes = item['likeCount'] ?? 0;

              if (item['likes'] != null && item['likes'] is List) {
                for (var like in item['likes']) {
                  if (like is Map &&
                      like['member'] != null &&
                      like['member'] is Map) {
                    final likeMemberId = like['member']['memberID'];
                    final likeMemberName =
                        like['member']['fullName'] ?? 'Unknown';

                    likedByUsers.add({
                      'memberId': likeMemberId,
                      'name': likeMemberName,
                    });

                    if (_currentUserId != null &&
                        likeMemberId == _currentUserId) {
                      isLikedByUser = true;
                    }
                  }
                }
              }

              _userPosts.add({
                'postID': item['postID'],
                'name': authorName,
                'time': timeStr,
                'content': item['content'] ?? '',
                'likes': totalLikes,
                'isLiked': isLikedByUser,
                'likedBy': likedByUsers,
                'comments': commentsList,
                'media': mediaUrl,
              });
            }
          });
        } catch (e) {
          print('Error parsing user posts: $e');
        }
      }
    }
  }

  bool _isValidImageUrl(String? url) {
    if (url == null || url.isEmpty) return false;
    return url.startsWith('http://') || url.startsWith('https://');
  }

  String _formatTime(String? time) {
    if (time == null || time.isEmpty) return '';

    try {
      final parts = time.split(':');
      if (parts.isEmpty) return time;

      int hour = int.parse(parts[0]);
      int minute = parts.length > 1 ? int.parse(parts[1]) : 0;

      String period = hour >= 12 ? 'PM' : 'AM';
      if (hour > 12) {
        hour -= 12;
      } else if (hour == 0) {
        hour = 12;
      }

      return '${hour}:${minute.toString().padLeft(2, '0')} $period';
    } catch (e) {
      return time;
    }
  }

  String _formatDateTime(String? date, String? time) {
    if (date == null && time == null) return 'Unknown time';

    try {
      String formattedTime = _formatTime(time);

      if (date != null && formattedTime.isNotEmpty) {
        DateTime? parsedDate;

        if (date.contains('-')) {
          parsedDate = DateTime.tryParse(date);
        } else if (date.contains('/')) {
          final parts = date.split('/');
          if (parts.length == 3) {
            parsedDate = DateTime(
              int.parse(parts[2]),
              int.parse(parts[1]),
              int.parse(parts[0]),
            );
          }
        }

        if (parsedDate != null) {
          final months = [
            'Jan',
            'Feb',
            'Mar',
            'Apr',
            'May',
            'Jun',
            'Jul',
            'Aug',
            'Sep',
            'Oct',
            'Nov',
            'Dec',
          ];
          final formattedDate =
              '${months[parsedDate.month - 1]} ${parsedDate.day}, ${parsedDate.year}';
          return '$formattedDate at $formattedTime';
        }
        return '$date at $formattedTime';
      }

      if (date != null && formattedTime.isEmpty) return date;
      if (formattedTime.isNotEmpty) return formattedTime;
    } catch (e) {
      print('Error formatting date/time: $e');
    }

    return 'Unknown time';
  }

  DateTime? _parsePostDateTime(String? date, String? time) {
    if (date == null) return null;

    try {
      DateTime? parsedDate;

      // Parse date
      if (date.contains('-')) {
        parsedDate = DateTime.tryParse(date);
      } else if (date.contains('/')) {
        final parts = date.split('/');
        if (parts.length == 3) {
          parsedDate = DateTime(
            int.parse(parts[2]),
            int.parse(parts[1]),
            int.parse(parts[0]),
          );
        }
      }

      if (parsedDate == null) return null;

      // Parse time if available
      if (time != null && time.isNotEmpty) {
        try {
          final parts = time.split(':');
          if (parts.isNotEmpty) {
            int hour = int.parse(parts[0]);
            int minute = parts.length > 1 ? int.parse(parts[1]) : 0;
            int second =
                parts.length > 2 ? int.parse(parts[2].split('.')[0]) : 0;

            parsedDate = DateTime(
              parsedDate.year,
              parsedDate.month,
              parsedDate.day,
              hour,
              minute,
              second,
            );
          }
        } catch (e) {
          // If time parsing fails, just use the date
        }
      }

      return parsedDate;
    } catch (e) {
      return null;
    }
  }

  int _getCommentCount(Map<String, dynamic> post) {
    final comments = post['comments'];
    if (comments is List) {
      return comments.length;
    } else if (comments is int) {
      return comments;
    }
    return 0;
  }

  List<Map<String, dynamic>> _getCommentsList(Map<String, dynamic> post) {
    final comments = post['comments'];
    if (comments is List) {
      return comments.cast<Map<String, dynamic>>();
    }
    return [];
  }

  Future<void> _handleLikeToggle(int postIndex) async {
    if (_currentUserId == null) return;

    final post = _userPosts[postIndex];
    final bool wasLiked = post['isLiked'];
    final int postId = post['postID'];

    // Optimistic UI update
    setState(() {
      _userPosts[postIndex]['isLiked'] = !wasLiked;
      _userPosts[postIndex]['likes'] =
          wasLiked ? post['likes'] - 1 : post['likes'] + 1;

      if (!wasLiked) {
        // Add current user to liked by list
        final userInfo = _userInfo;
        if (userInfo != null) {
          _userPosts[postIndex]['likedBy'].add({
            'memberId': _currentUserId,
            'name': userInfo['fullName'] ?? 'You',
          });
        }
      } else {
        // Remove current user from liked by list
        (_userPosts[postIndex]['likedBy'] as List).removeWhere(
          (user) => user['memberId'] == _currentUserId,
        );
      }
    });

    // Call API
    final result =
        wasLiked
            ? await _newsfeedService.unlikePost(
              postId: postId,
              memberId: _currentUserId!,
            )
            : await _newsfeedService.likePost(
              postId: postId,
              memberId: _currentUserId!,
            );

    // Revert on failure
    if (!result['success']) {
      if (!mounted) return;

      setState(() {
        _userPosts[postIndex]['isLiked'] = wasLiked;
        _userPosts[postIndex]['likes'] =
            wasLiked ? post['likes'] + 1 : post['likes'] - 1;

        if (!wasLiked) {
          (_userPosts[postIndex]['likedBy'] as List).removeWhere(
            (user) => user['memberId'] == _currentUserId,
          );
        } else {
          final userInfo = _userInfo;
          if (userInfo != null) {
            _userPosts[postIndex]['likedBy'].add({
              'memberId': _currentUserId,
              'name': userInfo['fullName'] ?? 'You',
            });
          }
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Failed to update like'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _refreshPostComments(int postIndex) async {
    try {
      if (_currentUserId == null) return;

      final result = await _newsfeedService.fetchUserPosts(_currentUserId!);

      if (result['success']) {
        final List<dynamic> data = jsonDecode(result['data']);

        // Sort posts by date and time in descending order (newest first)
        data.sort((a, b) {
          try {
            DateTime? dateA = _parsePostDateTime(
              a['datePosted'],
              a['timePosted'],
            );
            DateTime? dateB = _parsePostDateTime(
              b['datePosted'],
              b['timePosted'],
            );

            if (dateA == null && dateB == null) return 0;
            if (dateA == null) return 1;
            if (dateB == null) return -1;

            return dateB.compareTo(dateA); // Descending order (newest first)
          } catch (e) {
            return 0;
          }
        });

        final postId = _userPosts[postIndex]['postID'];

        // Find the specific post in the response
        for (var item in data) {
          if (item['postID'] == postId) {
            // Parse comments with author information
            List<Map<String, dynamic>> commentsList = [];
            if (item['comments'] != null && item['comments'] is List) {
              for (var comment in item['comments']) {
                if (comment is Map) {
                  String commentAuthor = 'Anonymous';
                  int? commentAuthorId;
                  if (comment['member'] != null && comment['member'] is Map) {
                    commentAuthor =
                        comment['member']['fullName'] ?? 'Anonymous';
                    commentAuthorId = comment['member']['memberID'];
                  }

                  commentsList.add({
                    'commentId': comment['commentID'],
                    'content': comment['commentText'] ?? '',
                    'author': commentAuthor,
                    'authorId': commentAuthorId,
                    'timestamp': comment['timestamp'] ?? '',
                  });
                }
              }
            }

            // Update only the comments for this post
            if (mounted) {
              setState(() {
                _userPosts[postIndex]['comments'] = commentsList;
              });
            }
            break;
          }
        }
      }
    } catch (e) {
      print('Error refreshing comments: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF7A5AF8), Color(0xFF9B5DE5)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                  ),
                  child:
                      _isLoading
                          ? const Center(
                            child: CircularProgressIndicator(
                              color: Color(0xFF7A5AF8),
                            ),
                          )
                          : SingleChildScrollView(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildProfileInfo(),
                                const SizedBox(height: 20),
                                _buildEditButton(),
                                const SizedBox(height: 32),
                                _buildPostsSection(),
                              ],
                            ),
                          ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          const Expanded(
            child: Text(
              'My Profile',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileInfo() {
    if (_userInfo == null) return const SizedBox.shrink();

    final initial = (_userInfo!['fullName'] ?? 'U').toString()[0].toUpperCase();

    return Column(
      children: [
        // Profile Avatar
        Center(
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Color(0xFF7A5AF8), Color(0xFF9B5DE5)],
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF7A5AF8).withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Text(
                initial,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        // User Name
        Text(
          _userInfo!['fullName'] ?? 'Unknown',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF333333),
          ),
        ),
        const SizedBox(height: 8),
        // Email
        Text(
          _userInfo!['email'] ?? '',
          style: TextStyle(fontSize: 16, color: Colors.grey[600]),
        ),
        const SizedBox(height: 16),
        // Info Cards
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildInfoCard(
              Icons.article,
              _userPosts.length.toString(),
              'Posts',
            ),
            _buildInfoCard(
              Icons.phone,
              _userInfo!['contactNumber'] ?? _userInfo!['phoneNumber'] ?? 'N/A',
              'Phone',
            ),
            _buildInfoCard(Icons.home, _userInfo!['houseNo'] ?? 'N/A', 'House'),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoCard(IconData icon, String value, String label) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF7A5AF8).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: const Color(0xFF7A5AF8), size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF333333),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              label,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const EditProfileDetailsPage(),
            ),
          );
          // Reload profile if changes were made
          if (result == true && mounted) {
            _loadUserProfile();
          }
        },
        icon: const Icon(Icons.edit, color: Colors.white),
        label: const Text(
          'Edit Personal Details',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF7A5AF8),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
      ),
    );
  }

  Widget _buildPostsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'My Posts',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF333333),
              ),
            ),
            TextButton.icon(
              onPressed: _loadUserPosts,
              icon: const Icon(Icons.refresh, size: 20),
              label: const Text('Refresh'),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF7A5AF8),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _isLoadingPosts
            ? const Center(
              child: Padding(
                padding: EdgeInsets.all(32.0),
                child: CircularProgressIndicator(color: Color(0xFF7A5AF8)),
              ),
            )
            : _userPosts.isEmpty
            ? _buildEmptyPostsWidget()
            : ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _userPosts.length,
              itemBuilder: (context, index) {
                return _buildPostCard(_userPosts[index], index);
              },
            ),
      ],
    );
  }

  Widget _buildEmptyPostsWidget() {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(Icons.article_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No posts yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your posts will appear here',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildPostCard(Map<String, dynamic> post, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Post header with menu
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Author avatar
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [Color(0xFF7A5AF8), Color(0xFF9B5DE5)],
                    ),
                  ),
                  child: Center(
                    child: Text(
                      post['name'][0].toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Author name and time
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post['name'],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        post['time'],
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                // Menu button
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert),
                  onSelected: (value) {
                    if (value == 'edit') {
                      _showEditPostDialog(post, index);
                    } else if (value == 'delete') {
                      _showDeletePostDialog(post, index);
                    }
                  },
                  itemBuilder:
                      (context) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit, color: Color(0xFF7A5AF8)),
                              SizedBox(width: 8),
                              Text('Edit Post'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete, color: Colors.red),
                              SizedBox(width: 8),
                              Text('Delete Post'),
                            ],
                          ),
                        ),
                      ],
                ),
              ],
            ),
          ),
          // Post content
          if (post['content'] != null && post['content'].toString().isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                post['content'],
                style: const TextStyle(fontSize: 15),
              ),
            ),
          // Post image
          if (post['media'] != null && post['media'].toString().isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CachedNetworkImage(
                  imageUrl: post['media'],
                  width: double.infinity,
                  fit: BoxFit.cover,
                  placeholder:
                      (context, url) => Container(
                        height: 200,
                        color: Colors.grey[200],
                        child: const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFF7A5AF8),
                          ),
                        ),
                      ),
                  errorWidget:
                      (context, url, error) => Container(
                        height: 200,
                        color: Colors.grey[200],
                        child: const Center(
                          child: Icon(Icons.broken_image, size: 50),
                        ),
                      ),
                ),
              ),
            ),
          // Post actions (like and comment buttons)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                // Like button
                Expanded(
                  child: InkWell(
                    onTap: () => _handleLikeToggle(index),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            post['isLiked'] == true
                                ? Icons.favorite
                                : Icons.favorite_border,
                            size: 20,
                            color:
                                post['isLiked'] == true
                                    ? Colors.red
                                    : Colors.grey[600],
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Like',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color:
                                  post['isLiked'] == true
                                      ? Colors.red
                                      : Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Container(width: 1, height: 20, color: Colors.grey[300]),
                // Comment button
                Expanded(
                  child: InkWell(
                    onTap: () => _showCommentDialog(index),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.comment_outlined,
                            size: 20,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Comment',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Divider
          Divider(height: 1, color: Colors.grey[300]),
          // Post stats
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Likes (tappable)
                InkWell(
                  onTap: () => _showLikesDialog(index),
                  child: Row(
                    children: [
                      Icon(Icons.favorite, size: 18, color: Colors.red),
                      const SizedBox(width: 4),
                      Text(
                        '${post['likes']}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 20),
                // Comments (tappable)
                InkWell(
                  onTap: () => _showCommentDialog(index),
                  child: Row(
                    children: [
                      Icon(Icons.comment, size: 18, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        '${_getCommentCount(post)} comments',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showEditPostDialog(Map<String, dynamic> post, int index) {
    final TextEditingController contentController = TextEditingController(
      text: post['content'],
    );
    PlatformFile? selectedMedia;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Row(
                children: [
                  Icon(Icons.edit, color: Color(0xFF7A5AF8)),
                  SizedBox(width: 8),
                  Text('Edit Post'),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: contentController,
                      decoration: const InputDecoration(
                        hintText: 'What\'s on your mind?',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 5,
                    ),
                    const SizedBox(height: 16),
                    if (selectedMedia != null)
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.image, color: Color(0xFF7A5AF8)),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                selectedMedia!.name,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close, size: 20),
                              onPressed: () {
                                setDialogState(() {
                                  selectedMedia = null;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 8),
                    TextButton.icon(
                      onPressed: () async {
                        final result = await FilePicker.platform.pickFiles(
                          type: FileType.image,
                          withData: true,
                        );
                        if (result != null && result.files.isNotEmpty) {
                          setDialogState(() {
                            selectedMedia = result.files.first;
                          });
                        }
                      },
                      icon: const Icon(Icons.add_photo_alternate),
                      label: const Text('Add/Change Image'),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (contentController.text.isEmpty &&
                        selectedMedia == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Post cannot be empty'),
                          backgroundColor: Colors.orange,
                        ),
                      );
                      return;
                    }

                    final scaffoldMessenger = ScaffoldMessenger.of(context);
                    Navigator.pop(context);

                    final result = await _newsfeedService.updatePost(
                      postId: post['postID'],
                      content: contentController.text,
                      imageBytes: selectedMedia?.bytes,
                      imageName: selectedMedia?.name,
                    );

                    if (result['success']) {
                      scaffoldMessenger.showSnackBar(
                        const SnackBar(
                          content: Text('Post updated successfully!'),
                          backgroundColor: Colors.green,
                        ),
                      );
                      if (mounted) _loadUserPosts();
                    } else {
                      scaffoldMessenger.showSnackBar(
                        SnackBar(
                          content: Text(
                            result['message'] ?? 'Failed to update post',
                          ),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7A5AF8),
                  ),
                  child: const Text(
                    'Update',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showDeletePostDialog(Map<String, dynamic> post, int index) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.warning, color: Colors.red),
                SizedBox(width: 8),
                Text('Delete Post'),
              ],
            ),
            content: const Text(
              'Are you sure you want to delete this post? This action cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  final scaffoldMessenger = ScaffoldMessenger.of(context);
                  Navigator.pop(context);

                  // Optimistic UI update
                  if (!mounted) return;
                  setState(() {
                    _userPosts.removeAt(index);
                  });

                  scaffoldMessenger.showSnackBar(
                    const SnackBar(
                      content: Text('Deleting post...'),
                      duration: Duration(seconds: 1),
                    ),
                  );

                  final result = await _newsfeedService.deletePost(
                    post['postID'],
                  );

                  if (result['success']) {
                    scaffoldMessenger.showSnackBar(
                      const SnackBar(
                        content: Text('Post deleted successfully!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } else {
                    // Revert UI update on failure
                    if (mounted) {
                      setState(() {
                        _userPosts.insert(index, post);
                      });
                    }
                    scaffoldMessenger.showSnackBar(
                      SnackBar(
                        content: Text(
                          result['message'] ?? 'Failed to delete post',
                        ),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
    );
  }

  void _showCommentDialog(int postIndex) {
    final TextEditingController commentController = TextEditingController();
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Comments'),
            content: SizedBox(
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Comment input
                  TextField(
                    controller: commentController,
                    decoration: const InputDecoration(
                      hintText: 'Write a comment...',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 12),
                  // Existing comments
                  Flexible(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: _getCommentCount(_userPosts[postIndex]),
                      itemBuilder: (context, commentIndex) {
                        final commentsList = _getCommentsList(
                          _userPosts[postIndex],
                        );
                        if (commentIndex >= commentsList.length) {
                          return const SizedBox.shrink();
                        }
                        final comment = commentsList[commentIndex];
                        final isOwnComment =
                            comment['authorId'] == _currentUserId;

                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    // Author avatar
                                    Container(
                                      width: 32,
                                      height: 32,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        gradient: const LinearGradient(
                                          colors: [
                                            Color(0xFF7A5AF8),
                                            Color(0xFF9B5DE5),
                                          ],
                                        ),
                                      ),
                                      child: Center(
                                        child: Text(
                                          comment['author'][0].toUpperCase(),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            comment['author'],
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                            ),
                                          ),
                                          Text(
                                            comment['content'],
                                            style: const TextStyle(
                                              fontSize: 13,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    // Edit/Delete buttons for own comments
                                    if (isOwnComment)
                                      PopupMenuButton<String>(
                                        icon: Icon(
                                          Icons.more_vert,
                                          size: 18,
                                          color: Colors.grey[600],
                                        ),
                                        onSelected: (value) {
                                          if (value == 'edit') {
                                            Navigator.pop(context);
                                            _editComment(
                                              postIndex,
                                              commentIndex,
                                              comment['content'],
                                            );
                                          } else if (value == 'delete') {
                                            Navigator.pop(context);
                                            _deleteComment(
                                              postIndex,
                                              commentIndex,
                                            );
                                          }
                                        },
                                        itemBuilder:
                                            (context) => [
                                              const PopupMenuItem(
                                                value: 'edit',
                                                child: Row(
                                                  children: [
                                                    Icon(
                                                      Icons.edit,
                                                      size: 18,
                                                      color: Color(0xFF7A5AF8),
                                                    ),
                                                    SizedBox(width: 8),
                                                    Text('Edit'),
                                                  ],
                                                ),
                                              ),
                                              const PopupMenuItem(
                                                value: 'delete',
                                                child: Row(
                                                  children: [
                                                    Icon(
                                                      Icons.delete,
                                                      size: 18,
                                                      color: Colors.red,
                                                    ),
                                                    SizedBox(width: 8),
                                                    Text('Delete'),
                                                  ],
                                                ),
                                              ),
                                            ],
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (commentController.text.isNotEmpty) {
                    if (_currentUserId == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please login to comment'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    final scaffoldMessenger = ScaffoldMessenger.of(context);
                    Navigator.pop(context);

                    // Optimistic UI update
                    if (!mounted) return;
                    setState(() {
                      // Ensure comments is a List
                      final comments = _userPosts[postIndex]['comments'];
                      if (comments is! List) {
                        _userPosts[postIndex]['comments'] = [];
                      }
                      final commentsList = _getCommentsList(
                        _userPosts[postIndex],
                      );
                      commentsList.insert(0, {
                        'commentId': null,
                        'content': commentController.text,
                        'author': _userInfo?['fullName'] ?? 'You',
                        'authorId': _currentUserId,
                        'timestamp': DateTime.now().toString(),
                      });
                      _userPosts[postIndex]['comments'] = commentsList;
                    });

                    scaffoldMessenger.showSnackBar(
                      const SnackBar(
                        content: Text('Posting comment...'),
                        duration: Duration(seconds: 1),
                      ),
                    );

                    final result = await _newsfeedService.addComment(
                      postId: _userPosts[postIndex]['postID'],
                      memberId: _currentUserId!,
                      content: commentController.text,
                    );

                    if (result['success']) {
                      scaffoldMessenger.showSnackBar(
                        const SnackBar(
                          content: Text('Comment added!'),
                          backgroundColor: Colors.green,
                        ),
                      );
                      await _refreshPostComments(postIndex);
                    } else {
                      // Remove optimistic comment on failure
                      if (mounted) {
                        setState(() {
                          final commentsList = _getCommentsList(
                            _userPosts[postIndex],
                          );
                          if (commentsList.isNotEmpty) {
                            commentsList.removeAt(0);
                            _userPosts[postIndex]['comments'] = commentsList;
                          }
                        });
                      }
                      scaffoldMessenger.showSnackBar(
                        SnackBar(
                          content: Text(
                            result['message'] ?? 'Failed to add comment',
                          ),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7A5AF8),
                ),
                child: const Text(
                  'Comment',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
    );
  }

  void _editComment(int postIndex, int commentIndex, String currentContent) {
    final TextEditingController editController = TextEditingController(
      text: currentContent,
    );

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.edit, color: Color(0xFF7A5AF8)),
                SizedBox(width: 8),
                Text('Edit Comment'),
              ],
            ),
            content: TextField(
              controller: editController,
              decoration: const InputDecoration(
                hintText: 'Edit your comment...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              autofocus: true,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (editController.text.isNotEmpty) {
                    final commentsList = _getCommentsList(
                      _userPosts[postIndex],
                    );
                    if (commentIndex >= commentsList.length) return;
                    final comment = commentsList[commentIndex];
                    final commentId = comment['commentId'];

                    if (commentId == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Cannot edit this comment'),
                          backgroundColor: Colors.orange,
                        ),
                      );
                      return;
                    }

                    final scaffoldMessenger = ScaffoldMessenger.of(context);
                    Navigator.pop(context);

                    // Optimistic UI update
                    if (!mounted) return;
                    final oldContent = comment['content'];
                    setState(() {
                      _userPosts[postIndex]['comments'][commentIndex]['content'] =
                          editController.text;
                    });

                    scaffoldMessenger.showSnackBar(
                      const SnackBar(
                        content: Text('Updating comment...'),
                        duration: Duration(seconds: 1),
                      ),
                    );

                    final result = await _newsfeedService.editComment(
                      postId: _userPosts[postIndex]['postID'],
                      commentId: commentId,
                      newContent: editController.text,
                    );

                    if (result['success']) {
                      scaffoldMessenger.showSnackBar(
                        const SnackBar(
                          content: Text('Comment updated!'),
                          backgroundColor: Colors.green,
                        ),
                      );
                      await _refreshPostComments(postIndex);
                    } else {
                      // Revert on failure
                      if (mounted) {
                        setState(() {
                          _userPosts[postIndex]['comments'][commentIndex]['content'] =
                              oldContent;
                        });
                      }
                      scaffoldMessenger.showSnackBar(
                        SnackBar(
                          content: Text(
                            result['message'] ?? 'Failed to update comment',
                          ),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7A5AF8),
                ),
                child: const Text(
                  'Update',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
    );
  }

  void _deleteComment(int postIndex, int commentIndex) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.warning, color: Colors.orange),
                SizedBox(width: 8),
                Text('Delete Comment'),
              ],
            ),
            content: const Text(
              'Are you sure you want to delete this comment?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  final commentsList = _getCommentsList(_userPosts[postIndex]);
                  if (commentIndex >= commentsList.length) return;
                  final comment = commentsList[commentIndex];
                  final commentId = comment['commentId'];

                  final scaffoldMessenger = ScaffoldMessenger.of(context);
                  Navigator.pop(context);

                  // Optimistic UI update
                  if (!mounted) return;
                  final deletedComment = comment;
                  setState(() {
                    final commentsList = _getCommentsList(
                      _userPosts[postIndex],
                    );
                    if (commentIndex < commentsList.length) {
                      commentsList.removeAt(commentIndex);
                      _userPosts[postIndex]['comments'] = commentsList;
                    }
                  });

                  scaffoldMessenger.showSnackBar(
                    const SnackBar(
                      content: Text('Deleting comment...'),
                      duration: Duration(seconds: 1),
                    ),
                  );

                  // Call API if commentId exists (from server)
                  if (commentId != null) {
                    final result = await _newsfeedService.deleteComment(
                      postId: _userPosts[postIndex]['postID'],
                      commentId: commentId,
                    );

                    if (result['success']) {
                      scaffoldMessenger.showSnackBar(
                        const SnackBar(
                          content: Text('Comment deleted!'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    } else {
                      // Revert on failure
                      if (mounted) {
                        setState(() {
                          final commentsList = _getCommentsList(
                            _userPosts[postIndex],
                          );
                          commentsList.insert(commentIndex, deletedComment);
                          _userPosts[postIndex]['comments'] = commentsList;
                        });
                      }
                      scaffoldMessenger.showSnackBar(
                        SnackBar(
                          content: Text(
                            result['message'] ?? 'Failed to delete comment',
                          ),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
    );
  }

  void _showLikesDialog(int postIndex) {
    final post = _userPosts[postIndex];
    final likedByUsers = post['likedBy'] as List<Map<String, dynamic>>? ?? [];

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Row(
              children: [
                const Icon(Icons.favorite, color: Colors.red, size: 24),
                const SizedBox(width: 8),
                Text(
                  '${post['likes']} ${post['likes'] == 1 ? 'Like' : 'Likes'}',
                ),
              ],
            ),
            content: SizedBox(
              width: double.maxFinite,
              child:
                  likedByUsers.isEmpty
                      ? const Padding(
                        padding: EdgeInsets.all(20),
                        child: Text(
                          'No likes yet',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                      : ListView.builder(
                        shrinkWrap: true,
                        itemCount: likedByUsers.length,
                        itemBuilder: (context, index) {
                          final user = likedByUsers[index];
                          return ListTile(
                            leading: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF7A5AF8),
                                    Color(0xFF9B5DE5),
                                  ],
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  user['name'][0].toUpperCase(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            title: Text(
                              user['name'],
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            trailing: const Icon(
                              Icons.favorite,
                              color: Colors.red,
                              size: 20,
                            ),
                          );
                        },
                      ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
    );
  }
}

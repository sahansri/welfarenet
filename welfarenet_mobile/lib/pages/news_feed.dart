import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:welfarenet_mobile/services/auth_service.dart';
import 'package:welfarenet_mobile/services/newsfeed_service.dart';
import 'package:welfarenet_mobile/utils/responsive_utils.dart';

class NewsFeed extends StatefulWidget {
  const NewsFeed({super.key});

  @override
  State<NewsFeed> createState() => _NewsFeedState();
}

class _NewsFeedState extends State<NewsFeed> {
  String get baseUrl => AuthService.baseUrl;
  final NewsfeedService _newsfeedService = NewsfeedService();
  final TextEditingController _postController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  PlatformFile? _selectedMedia;
  String? _selectedMediaType;
  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _isUploading = false;

  // Network timeout for slow connections
  static const Duration _imageTimeout = Duration(seconds: 15);
  DateTime? _lastFetchTime;
  static const String _cacheKey = 'newsfeed_cache';
  static const String _timestampKey = 'newsfeed_timestamp';
  final userId = AuthService().getUserId();
  int? _currentUserId;
  final List<Map<String, dynamic>> _allPosts = []; // All posts from API
  final List<Map<String, dynamic>> _displayedPosts =
      <Map<String, dynamic>>[]; // Posts currently displayed
  static const int _postsPerPage = 5; // Number of posts to load at a time

  @override
  void initState() {
    super.initState();
    _loadCurrentUserId();
    _loadCachedData();
    _loadNewsfeed();
    _scrollController.addListener(_onScroll);
  }

  Future<void> _loadCurrentUserId() async {
    _currentUserId = await AuthService().getUserId();
  }

  void _onScroll() {
    // Check if user has scrolled to bottom
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMorePosts();
    }
  }

  void _loadMorePosts() {
    if (_isLoadingMore || _displayedPosts.length >= _allPosts.length) return;

    setState(() {
      _isLoadingMore = true;
    });

    // Simulate a slight delay for smooth loading
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() {
          final startIndex = _displayedPosts.length;
          final endIndex = (startIndex + _postsPerPage).clamp(
            0,
            _allPosts.length,
          );

          if (startIndex < _allPosts.length) {
            _displayedPosts.addAll(_allPosts.sublist(startIndex, endIndex));
          }
          _isLoadingMore = false;
        });
      }
    });
  }

  Future<void> _loadCachedData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedData = prefs.getString(_cacheKey);
      final timestamp = prefs.getInt(_timestampKey);

      if (cachedData != null && timestamp != null) {
        _lastFetchTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
        final List<dynamic> data = jsonDecode(cachedData);
        setState(() {
          _allPosts.clear();
          _allPosts.addAll(data.cast<Map<String, dynamic>>());

          // Load first page of posts
          _displayedPosts.clear();
          final endIndex = _postsPerPage.clamp(0, _allPosts.length);
          _displayedPosts.addAll(_allPosts.sublist(0, endIndex));

          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading cached data: $e');
    }
  }

  Future<void> _loadNewsfeed({bool showLoading = true}) async {
    if (showLoading) {
      setState(() {
        _isLoading = true;
      });
    }

    final result = await _newsfeedService.fetchNewsfeed();
    final currentUserId = await AuthService().getUserId();

    if (mounted) {
      setState(() {
        _isLoading = false;
      });

      if (result['success']) {
        try {
          final List<dynamic> data = jsonDecode(result['data']);
          setState(() {
            _allPosts.clear();
            for (var item in data) {
              String authorName = 'Unknown';
              if (item['author'] != null && item['author'] is Map) {
                authorName = item['author']['fullName'] ?? 'Unknown';
              }

              String timeStr = _formatDateTime(
                item['datePosted'],
                item['timePosted'],
              );

              // Handle images from API
              String? mediaUrl;
              String? mediaType;

              // Check for images array
              if (item['images'] != null &&
                  item['images'] is List &&
                  (item['images'] as List).isNotEmpty) {
                final firstImage = item['images'][0];
                if (firstImage is Map && firstImage['imagePath'] != null) {
                  // Construct full URL: base URL + image path
                  final imagePath = firstImage['imagePath'].toString().trim();
                  // Validate URL before using
                  if (_isValidImageUrl(imagePath)) {
                    mediaUrl = imagePath;
                    mediaType = 'image';
                    print('🖼️ Image URL: $mediaUrl');
                    print(
                      '📝 Post by: $authorName - PostID: ${item['postID']}',
                    );
                  } else {
                    print('⚠️ Invalid image URL: $imagePath');
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
                      'authorId': commentAuthorId,
                      'author': commentAuthor,
                      'content': comment['commentText'] ?? '',
                      'time': comment['commentTime'] ?? '',
                      'date': comment['commentDate'] ?? '',
                      'isOwnComment':
                          commentAuthorId != null &&
                          commentAuthorId == _currentUserId,
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
                    int? likeMemberId = like['member']['memberID'];
                    String likerName = like['member']['fullName'] ?? 'Unknown';

                    likedByUsers.add({
                      'memberID': likeMemberId,
                      'name': likerName,
                    });

                    if (currentUserId != null &&
                        likeMemberId == currentUserId) {
                      isLikedByUser = true;
                    }
                  }
                }
              }

              print(
                '📊 Post ${item['postID']}: $totalLikes likes, isLiked: $isLikedByUser, likedBy: ${likedByUsers.length} users',
              );

              _allPosts.add({
                'postID': item['postID'],
                'name': authorName,
                'time': timeStr,
                'content': item['content'] ?? '',
                'likes': totalLikes,
                'isLiked': isLikedByUser,
                'likedBy': likedByUsers,
                'comments': commentsList,
                'media': mediaUrl,
                'mediaType': mediaType,
              });
            }

            // Load first page of posts
            _displayedPosts.clear();
            final endIndex = _postsPerPage.clamp(0, _allPosts.length);
            _displayedPosts.addAll(_allPosts.sublist(0, endIndex));
          });

          // Cache the data
          _cacheNewsfeed();
          _lastFetchTime = DateTime.now();
        } catch (e) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error parsing newsfeed: $e')));
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Failed to load newsfeed'),
          ),
        );
      }
    }
  }

  Future<void> _cacheNewsfeed() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonData = jsonEncode(_allPosts);
      await prefs.setString(_cacheKey, jsonData);
      await prefs.setInt(_timestampKey, DateTime.now().millisecondsSinceEpoch);
    } catch (e) {
      print('Error caching newsfeed: $e');
    }
  }

  Future<void> _refreshNewsfeed() async {
    await _loadNewsfeed(showLoading: false);
    // Scroll to top after refresh
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _refreshPostComments(int postIndex) async {
    try {
      final postId = _displayedPosts[postIndex]['postID'];
      final result = await _newsfeedService.fetchNewsfeed();

      if (result['success']) {
        final List<dynamic> data = jsonDecode(result['data']);
        final currentUserId = await AuthService().getUserId();

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
                    'authorId': commentAuthorId,
                    'author': commentAuthor,
                    'content': comment['commentText'] ?? '',
                    'time': comment['commentTime'] ?? '',
                    'date': comment['commentDate'] ?? '',
                    'isOwnComment':
                        commentAuthorId != null &&
                        commentAuthorId == currentUserId,
                  });
                }
              }
            }

            // Update only the comments for this post
            setState(() {
              _displayedPosts[postIndex]['comments'] = commentsList;
            });
            break;
          }
        }
      }
    } catch (e) {
      print('Error refreshing comments: $e');
    }
  }

  Future<void> _handlePostSubmit() async {
    if (_postController.text.isEmpty && _selectedMedia == null) return;

    print('\n🚀 ====== POST SUBMIT STARTED ======');
    print('📝 Content length: ${_postController.text.length}');
    print('📎 Has media: ${_selectedMedia != null}');

    setState(() {
      _isUploading = true;
    });

    try {
      // Get user ID
      final userId = await AuthService().getUserId();
      print('🔑 User ID: $userId');

      if (userId == null) {
        print('❌ ERROR: User ID is NULL!');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please login to post'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      // Prepare image data
      List<int>? imageBytes;
      String? imageName;
      if (_selectedMedia != null) {
        imageBytes = _selectedMedia!.bytes;
        imageName = _selectedMedia!.name;
        print('📎 Preparing image data:');
        print('   - Name: $imageName');
        print('   - Bytes: ${imageBytes?.length ?? 0}');
        print('   - Bytes is null: ${imageBytes == null}');
        print('   - Bytes is empty: ${imageBytes?.isEmpty ?? true}');
      } else {
        print('⚠️ No media selected');
      }

      print('📤 Calling uploadPost API...');
      // Upload post
      final result = await _newsfeedService.uploadPost(
        authorId: userId,
        content: _postController.text,
        imageBytes: imageBytes,
        imageName: imageName,
      );

      print('📥 API Response: ${result['success']}');
      print('====== POST SUBMIT END ======\n');

      if (mounted) {
        if (result['success']) {
          // Clear form
          _postController.clear();
          setState(() {
            _selectedMedia = null;
            _selectedMediaType = null;
          });

          // Show success
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Post uploaded successfully! 🎉'),
              backgroundColor: Colors.green,
            ),
          );

          // Refresh feed
          await _loadNewsfeed(showLoading: false);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'Failed to upload'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _postController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _pickMedia() async {
    try {
      print('🎯 Opening file picker...');
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.media,
        allowMultiple: false,
        withData: true, // Important: This loads the file bytes
      );

      if (result != null && result.files.isNotEmpty) {
        PlatformFile file = result.files.first;
        print('📁 File picked: ${file.name}');
        print('📏 File size: ${file.size} bytes');
        print('📦 Bytes loaded: ${file.bytes?.length ?? 0}');
        print('🔍 Extension: ${file.extension}');

        String? extension = file.extension?.toLowerCase();
        String mediaType;

        if (extension == 'jpg' ||
            extension == 'jpeg' ||
            extension == 'png' ||
            extension == 'gif') {
          mediaType = 'image';
        } else if (extension == 'mp4' ||
            extension == 'mov' ||
            extension == 'avi' ||
            extension == 'mkv') {
          mediaType = 'video';
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Unsupported file type'),
                backgroundColor: Colors.red,
              ),
            );
          }
          return;
        }

        // Check if bytes are loaded
        if (file.bytes == null || file.bytes!.isEmpty) {
          print('❌ ERROR: File bytes are NULL or EMPTY!');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Failed to load file data. Please try again.'),
                backgroundColor: Colors.red,
              ),
            );
          }
          return;
        }

        setState(() {
          _selectedMedia = file;
          _selectedMediaType = mediaType;
        });
        print('✅ Media selected successfully: ${file.name} ($mediaType)');
      } else {
        print('⚠️ No file selected');
      }
    } catch (e) {
      print('❌ Error in _pickMedia: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking file: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Helper to check if image URL is valid
  bool _isValidImageUrl(String? url) {
    if (url == null || url.isEmpty) return false;
    return url.startsWith('http://') || url.startsWith('https://');
  }

  void _viewFullscreenImage(String imageUrl) {
    showDialog(
      context: context,
      builder:
          (context) => Dialog(
            backgroundColor: Colors.black,
            insetPadding: EdgeInsets.zero,
            child: Stack(
              children: [
                Center(
                  child: InteractiveViewer(
                    child: CachedNetworkImage(
                      imageUrl: imageUrl,
                      fit: BoxFit.contain,
                      fadeInDuration: const Duration(milliseconds: 300),
                      fadeOutDuration: const Duration(milliseconds: 100),
                      memCacheHeight: 800, // Optimize memory usage
                      maxHeightDiskCache: 1000, // Optimize disk cache
                      httpHeaders: const {'Connection': 'keep-alive'},
                      placeholder: (context, url) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const CircularProgressIndicator(
                                color: Colors.white,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Loading image...',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.7),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                      errorWidget: (context, url, error) {
                        // Determine if it's a network error
                        final isNetworkError =
                            error.toString().contains('SocketException') ||
                            error.toString().contains('Failed host lookup') ||
                            error.toString().contains(
                              'Network is unreachable',
                            ) ||
                            error.toString().contains('Connection timed out');

                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.cloud_off,
                                color: Colors.white,
                                size: 60,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                isNetworkError
                                    ? 'No Internet Connection'
                                    : 'Failed to load image',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                isNetworkError
                                    ? 'Please check your WiFi or mobile data'
                                    : 'The image is temporarily unavailable',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.7),
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.pop(context);
                                  Future.delayed(
                                    const Duration(milliseconds: 100),
                                    () {
                                      _viewFullscreenImage(imageUrl);
                                    },
                                  );
                                },
                                icon: const Icon(Icons.refresh, size: 18),
                                label: const Text('Retry'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF7A5AF8),
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
                Positioned(
                  top: 40,
                  right: 16,
                  child: IconButton(
                    icon: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 30,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ],
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Purple gradient background - full screen
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF7A5AF8), Color(0xFF9B5DE5)],
              ),
            ),
          ),
          // Content
          SafeArea(
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
                    child: RefreshIndicator(
                      onRefresh: _refreshNewsfeed,
                      color: const Color(0xFF7A5AF8),
                      child: CustomScrollView(
                        controller: _scrollController,
                        slivers: [
                          SliverToBoxAdapter(child: _buildPostInput()),
                          if (_isLoading)
                            const SliverFillRemaining(
                              child: Center(
                                child: CircularProgressIndicator(
                                  color: Color(0xFF7A5AF8),
                                ),
                              ),
                            )
                          else if (_displayedPosts.isEmpty)
                            const SliverFillRemaining(
                              child: Center(child: Text('No posts available')),
                            )
                          else
                            SliverList(
                              delegate: SliverChildBuilderDelegate((
                                context,
                                index,
                              ) {
                                final post = _displayedPosts[index];
                                return Container(
                                  margin: const EdgeInsets.only(
                                    bottom: 16,
                                    left: 16,
                                    right: 16,
                                  ),
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(
                                          alpha: 0.08,
                                        ),
                                        blurRadius: 12,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // ...existing post content code...
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              CircleAvatar(
                                                radius: 20,
                                                backgroundColor: const Color(
                                                  0xFFEDE7FE,
                                                ),
                                                child: Text(
                                                  post['name']![0],
                                                  style: const TextStyle(
                                                    color: Color(0xFF7A5AF8),
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    post['name'] ?? 'Anonymous',
                                                    style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                  Text(
                                                    post['time'] ??
                                                        'Unknown time',
                                                    style: TextStyle(
                                                      color: Colors.grey[600],
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                          PopupMenuButton<String>(
                                            icon: Icon(
                                              Icons.more_vert,
                                              color: Colors.grey[600],
                                              size: 20,
                                            ),
                                            onSelected: (value) {
                                              if (value == 'report') {
                                                _showReportDialog(index);
                                              }
                                            },
                                            itemBuilder:
                                                (context) => [
                                                  const PopupMenuItem(
                                                    value: 'report',
                                                    child: Row(
                                                      children: [
                                                        Icon(
                                                          Icons.flag,
                                                          color: Colors.red,
                                                          size: 20,
                                                        ),
                                                        SizedBox(width: 8),
                                                        Text('Report Post'),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        post['content'] ?? '',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          height: 1.5,
                                        ),
                                      ),
                                      // Display image from API if available
                                      if (post['media'] != null &&
                                          post['media'].toString().isNotEmpty &&
                                          post['mediaType'] == 'image' &&
                                          _isValidImageUrl(post['media'])) ...[
                                        const SizedBox(height: 12),
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          child: GestureDetector(
                                            onTap: () {
                                              try {
                                                _viewFullscreenImage(
                                                  post['media'],
                                                );
                                              } catch (e) {
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                      'Unable to open image: Check connection',
                                                    ),
                                                    backgroundColor:
                                                        Colors.orange,
                                                  ),
                                                );
                                              }
                                            },
                                            child: CachedNetworkImage(
                                              imageUrl: post['media'],
                                              width: double.infinity,
                                              fit: BoxFit.cover,
                                              fadeInDuration: const Duration(
                                                milliseconds: 500,
                                              ),
                                              fadeOutDuration: const Duration(
                                                milliseconds: 200,
                                              ),
                                              memCacheHeight:
                                                  400, // Reduce memory usage in feed
                                              memCacheWidth: 600,
                                              maxHeightDiskCache: 600,
                                              maxWidthDiskCache: 800,
                                              httpHeaders: const {
                                                'Connection': 'keep-alive',
                                              },
                                              placeholder: (context, url) {
                                                return Container(
                                                  height: 200,
                                                  alignment: Alignment.center,
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      const CircularProgressIndicator(
                                                        color: Color(
                                                          0xFF7A5AF8,
                                                        ),
                                                        strokeWidth: 3,
                                                      ),
                                                      const SizedBox(
                                                        height: 12,
                                                      ),
                                                      Text(
                                                        'Loading...',
                                                        style: TextStyle(
                                                          color:
                                                              Colors.grey[600],
                                                          fontSize: 12,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              },
                                              errorWidget: (
                                                context,
                                                url,
                                                error,
                                              ) {
                                                // Determine error type
                                                final isNetworkError =
                                                    error.toString().contains(
                                                      'SocketException',
                                                    ) ||
                                                    error.toString().contains(
                                                      'Failed host lookup',
                                                    ) ||
                                                    error.toString().contains(
                                                      'Network is unreachable',
                                                    );

                                                return Container(
                                                  height: 200,
                                                  color: Colors.grey[200],
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Icon(
                                                        isNetworkError
                                                            ? Icons.cloud_off
                                                            : Icons
                                                                .broken_image,
                                                        size: 50,
                                                        color: Colors.grey,
                                                      ),
                                                      const SizedBox(height: 8),
                                                      Text(
                                                        isNetworkError
                                                            ? 'No connection'
                                                            : 'Failed to load image',
                                                        style: const TextStyle(
                                                          color: Colors.grey,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                        ),
                                                      ),
                                                      const SizedBox(height: 4),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets.symmetric(
                                                              horizontal: 16,
                                                            ),
                                                        child: Text(
                                                          isNetworkError
                                                              ? 'Check your internet connection'
                                                              : 'Image unavailable',
                                                          style:
                                                              const TextStyle(
                                                                color:
                                                                    Colors.grey,
                                                                fontSize: 12,
                                                              ),
                                                          textAlign:
                                                              TextAlign.center,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                        ),
                                      ],
                                      const SizedBox(height: 16),
                                      // Likes and Comments count
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          bottom: 12,
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            GestureDetector(
                                              onTap: () {
                                                if (post['likes'] > 0) {
                                                  _showLikesDialog(index);
                                                }
                                              },
                                              child: Text(
                                                '${post['likes']} ${post['likes'] == 1 ? 'like' : 'likes'}',
                                                style: TextStyle(
                                                  color: Colors.grey[700],
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                            GestureDetector(
                                              onTap:
                                                  () =>
                                                      _showCommentDialog(index),
                                              child: Text(
                                                '${post['comments'].length} ${post['comments'].length == 1 ? 'comment' : 'comments'}',
                                                style: TextStyle(
                                                  color: Colors.grey[700],
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      // Divider
                                      Divider(
                                        height: 1,
                                        thickness: 1,
                                        color: Colors.grey[300],
                                      ),
                                      const SizedBox(height: 8),
                                      // Action buttons: Like, Comment, Share
                                      Row(
                                        children: [
                                          // Like button
                                          Expanded(
                                            child: InkWell(
                                              onTap: () async {
                                                // Optimistic UI update
                                                final bool wasLiked =
                                                    post['isLiked'];
                                                final int previousLikes =
                                                    post['likes'];

                                                setState(() {
                                                  post['isLiked'] =
                                                      !post['isLiked'];
                                                  post['likes'] +=
                                                      post['isLiked'] ? 1 : -1;
                                                });

                                                // Call API
                                                if (_currentUserId != null) {
                                                  final result =
                                                      post['isLiked']
                                                          ? await _newsfeedService
                                                              .likePost(
                                                                postId:
                                                                    post['postID'],
                                                                memberId:
                                                                    _currentUserId!,
                                                              )
                                                          : await _newsfeedService
                                                              .unlikePost(
                                                                postId:
                                                                    post['postID'],
                                                                memberId:
                                                                    _currentUserId!,
                                                              );

                                                  // Rollback on failure
                                                  if (!result['success']) {
                                                    setState(() {
                                                      post['isLiked'] =
                                                          wasLiked;
                                                      post['likes'] =
                                                          previousLikes;
                                                    });
                                                    if (mounted) {
                                                      ScaffoldMessenger.of(
                                                        context,
                                                      ).showSnackBar(
                                                        SnackBar(
                                                          content: Text(
                                                            result['message'] ??
                                                                'Failed to update like',
                                                          ),
                                                          backgroundColor:
                                                              Colors.red,
                                                        ),
                                                      );
                                                    }
                                                  }
                                                }
                                              },
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      vertical: 12,
                                                    ),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Icon(
                                                      post['isLiked']
                                                          ? Icons.favorite
                                                          : Icons
                                                              .favorite_border,
                                                      color:
                                                          post['isLiked']
                                                              ? Colors.red
                                                              : Colors
                                                                  .grey[600],
                                                      size: 22,
                                                    ),
                                                    const SizedBox(width: 6),
                                                    Text(
                                                      'Like',
                                                      style: TextStyle(
                                                        color:
                                                            post['isLiked']
                                                                ? Colors.red
                                                                : Colors
                                                                    .grey[700],
                                                        fontSize: 15,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                          // Comment button
                                          Expanded(
                                            child: InkWell(
                                              onTap:
                                                  () =>
                                                      _showCommentDialog(index),
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      vertical: 12,
                                                    ),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Icon(
                                                      Icons
                                                          .mode_comment_outlined,
                                                      color: Colors.grey[600],
                                                      size: 22,
                                                    ),
                                                    const SizedBox(width: 6),
                                                    Text(
                                                      'Comment',
                                                      style: TextStyle(
                                                        color: Colors.grey[700],
                                                        fontSize: 15,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                          // Share button
                                          Expanded(
                                            child: InkWell(
                                              onTap: () {
                                                // TODO: Implement share functionality
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  const SnackBar(
                                                    content: Text(
                                                      'Share feature coming soon!',
                                                    ),
                                                    duration: Duration(
                                                      seconds: 2,
                                                    ),
                                                  ),
                                                );
                                              },
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      vertical: 12,
                                                    ),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Icon(
                                                      Icons.share_outlined,
                                                      color: Colors.grey[600],
                                                      size: 22,
                                                    ),
                                                    const SizedBox(width: 6),
                                                    Text(
                                                      'Share',
                                                      style: TextStyle(
                                                        color: Colors.grey[700],
                                                        fontSize: 15,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                );
                              }, childCount: _displayedPosts.length),
                            ),
                          // Loading indicator at bottom when loading more
                          if (_isLoadingMore)
                            const SliverToBoxAdapter(
                              child: Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Center(
                                  child: CircularProgressIndicator(
                                    color: Color(0xFF7A5AF8),
                                  ),
                                ),
                              ),
                            )
                          // End of list indicator
                          else if (_displayedPosts.length >= _allPosts.length &&
                              _displayedPosts.isNotEmpty)
                            SliverToBoxAdapter(
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Center(
                                  child: Text(
                                    'You\'re all caught up! 🎉',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 14,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ),
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
        ],
      ),
    );
  }

  String _getTimeAgo() {
    if (_lastFetchTime == null) return '';
    final difference = DateTime.now().difference(_lastFetchTime!);
    if (difference.inMinutes < 1) return 'Just now';
    if (difference.inMinutes < 60) return '${difference.inMinutes}m ago';
    if (difference.inHours < 24) return '${difference.inHours}h ago';
    return '${difference.inDays}d ago';
  }

  String _formatTime(String? time) {
    if (time == null || time.isEmpty) return '';

    try {
      // Parse time in format "HH:mm:ss" or "HH:mm"
      final parts = time.split(':');
      if (parts.isEmpty) return time;

      int hour = int.parse(parts[0]);
      int minute = parts.length > 1 ? int.parse(parts[1]) : 0;

      // Convert to 12-hour format
      String period = hour >= 12 ? 'PM' : 'AM';
      if (hour > 12) {
        hour -= 12;
      } else if (hour == 0) {
        hour = 12;
      }

      return '${hour}:${minute.toString().padLeft(2, '0')} $period';
    } catch (e) {
      print('Error formatting time: $e');
      return time;
    }
  }

  String _formatDateTime(String? date, String? time) {
    if (date == null && time == null) return 'Unknown time';

    try {
      String formattedTime = _formatTime(time);

      if (date != null && formattedTime.isNotEmpty) {
        // Parse date (e.g., "2024-12-18" or "18/12/2024")
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
          // Format: "Dec 18, 2024 at 2:30 PM"
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
        // Fallback with formatted time
        return '$date at $formattedTime';
      }

      if (date != null && formattedTime.isEmpty) return date;
      if (formattedTime.isNotEmpty) return formattedTime;
    } catch (e) {
      print('Error formatting date/time: $e');
    }

    return 'Unknown time';
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 10.0, 16.0, 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'News Feed',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Flexible(
                      child: Text(
                        'Don\'t miss new updated!',
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (_lastFetchTime != null) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.access_time,
                              size: 12,
                              color: Colors.white70,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _getTimeAgo(),
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Image.asset('lib/assets/icons/Group.png', width: 70, height: 70),
        ],
      ),
    );
  }

  Widget _buildPostInput() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
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
          const Text(
            'Post your thoughts!',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 230, 230, 230),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                TextField(
                  controller: _postController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    hintText: 'What\'s on your mind?',
                    border: InputBorder.none,
                    hintStyle: TextStyle(color: Colors.black54),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.image,
                            color: Color(0xFF7A5AF8),
                          ),
                          onPressed: _pickMedia,
                        ),
                        if (_selectedMedia != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(
                                0xFF7A5AF8,
                              ).withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  _selectedMediaType == 'image'
                                      ? Icons.image
                                      : Icons.videocam,
                                  size: 16,
                                  color: const Color(0xFF7A5AF8),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  _selectedMedia!.name.length > 15
                                      ? '${_selectedMedia!.name.substring(0, 15)}...'
                                      : _selectedMedia!.name,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF7A5AF8),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _selectedMedia = null;
                                      _selectedMediaType = null;
                                    });
                                  },
                                  child: const Icon(
                                    Icons.close,
                                    size: 16,
                                    color: Color(0xFF7A5AF8),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    ElevatedButton(
                      onPressed: _isUploading ? null : _handlePostSubmit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF7A5AF8),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 8,
                        ),
                      ),
                      child:
                          _isUploading
                              ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                              : const Text(
                                'post',
                                style: TextStyle(color: Colors.white),
                              ),
                    ),
                  ],
                ),
              ],
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
                      itemCount: _displayedPosts[postIndex]['comments'].length,
                      itemBuilder: (context, index) {
                        final comment =
                            _displayedPosts[postIndex]['comments'][index];
                        final isMap = comment is Map<String, dynamic>;

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF5F5F5),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (isMap && comment['author'] != null)
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 4),
                                    child: Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 12,
                                          backgroundColor: const Color(
                                            0xFFE8DEFF,
                                          ),
                                          child: Text(
                                            comment['author'][0].toUpperCase(),
                                            style: const TextStyle(
                                              color: Color(0xFF7A5AF8),
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
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
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                  color: Color(0xFF7A5AF8),
                                                ),
                                              ),
                                              if (comment['date'] != null ||
                                                  comment['time'] != null)
                                                Text(
                                                  _formatDateTime(
                                                    comment['date'],
                                                    comment['time'],
                                                  ),
                                                  style: TextStyle(
                                                    fontSize: 9,
                                                    color: Colors.grey[500],
                                                    fontStyle: FontStyle.italic,
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                        // Show menu for user's own comments
                                        if (isMap &&
                                            comment['isOwnComment'] == true)
                                          PopupMenuButton<String>(
                                            icon: Icon(
                                              Icons.more_vert,
                                              size: 16,
                                              color: Colors.grey[600],
                                            ),
                                            onSelected: (value) {
                                              if (value == 'edit') {
                                                Navigator.pop(context);
                                                _editComment(
                                                  postIndex,
                                                  index,
                                                  comment['content'],
                                                );
                                              } else if (value == 'delete') {
                                                _deleteComment(
                                                  postIndex,
                                                  index,
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
                                                          color: Color(
                                                            0xFF7A5AF8,
                                                          ),
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
                                  ),
                                Text(
                                  isMap
                                      ? (comment['content'] ?? '')
                                      : comment.toString(),
                                  style: const TextStyle(fontSize: 14),
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
                    // Get current user info
                    final getResult = await AuthService().getUserInfo();
                    final userName = getResult['data']['fullName'];

                    if (_currentUserId == null) {
                      // Capture ScaffoldMessenger before showing snackbar
                      final scaffoldMessenger = ScaffoldMessenger.of(context);
                      scaffoldMessenger.showSnackBar(
                        const SnackBar(
                          content: Text('Please Re-login to comment'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    final now = DateTime.now();
                    final timeStr = TimeOfDay.now().format(context);
                    final dateStr =
                        '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}';

                    // Optimistic UI update
                    final newComment = {
                      'author': userName,
                      'content': commentController.text,
                      'time': timeStr,
                      'date': dateStr,
                      'isOwnComment': true,
                    };

                    setState(() {
                      _displayedPosts[postIndex]['comments'].add(newComment);
                    });

                    final commentText = commentController.text;
                    commentController.clear();

                    // Capture ScaffoldMessenger before popping dialog
                    final scaffoldMessenger = ScaffoldMessenger.of(context);
                    Navigator.pop(context);

                    // Call API
                    final result = await _newsfeedService.addComment(
                      postId: _displayedPosts[postIndex]['postID'],
                      memberId: _currentUserId!,
                      content: commentText,
                    );

                    if (!result['success']) {
                      // Rollback on failure
                      if (mounted) {
                        setState(() {
                          _displayedPosts[postIndex]['comments'].remove(
                            newComment,
                          );
                        });
                        scaffoldMessenger.showSnackBar(
                          SnackBar(
                            content: Text(
                              result['message'] ?? 'Failed to add comment',
                            ),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    } else {
                      // Refresh to get the comment with proper ID from server
                      await _loadNewsfeed(showLoading: false);
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
                    final originalContent =
                        _displayedPosts[postIndex]['comments'][commentIndex]['content'];
                    final commentId =
                        _displayedPosts[postIndex]['comments'][commentIndex]['commentId'];
                    final editedCommentText = editController.text;

                    // Capture ScaffoldMessenger before popping dialog
                    final scaffoldMessenger = ScaffoldMessenger.of(context);
                    Navigator.pop(context);

                    if (commentId == null) {
                      scaffoldMessenger.showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Cannot edit local comment. Please refresh the feed.',
                          ),
                          backgroundColor: Colors.orange,
                          duration: Duration(seconds: 2),
                        ),
                      );
                      return;
                    }

                    // Optimistic UI update - update local content immediately
                    setState(() {
                      _displayedPosts[postIndex]['comments'][commentIndex]['content'] =
                          editedCommentText;
                    });

                    scaffoldMessenger.showSnackBar(
                      const SnackBar(
                        content: Text('Updating comment...'),
                        backgroundColor: Colors.blue,
                        duration: Duration(seconds: 3),
                      ),
                    );

                    // Call API
                    final result = await _newsfeedService.editComment(
                      postId: _displayedPosts[postIndex]['postID'],
                      commentId: commentId,
                      newContent: editedCommentText,
                    );

                    if (result['success']) {
                      // Refresh only the comments for this specific post
                      await _refreshPostComments(postIndex);

                      if (mounted) {
                        scaffoldMessenger.showSnackBar(
                          const SnackBar(
                            content: Text('Comment updated successfully'),
                            backgroundColor: Colors.green,
                            duration: Duration(seconds: 1),
                          ),
                        );

                        // Reopen comments dialog to show updated comment
                        Future.delayed(const Duration(milliseconds: 50), () {
                          if (mounted) {
                            _showCommentDialog(postIndex);
                          }
                        });
                      }
                    } else {
                      // Rollback on failure
                      if (mounted) {
                        setState(() {
                          _displayedPosts[postIndex]['comments'][commentIndex]['content'] =
                              originalContent;
                        });
                        scaffoldMessenger.showSnackBar(
                          SnackBar(
                            content: Text(
                              result['message'] ?? 'Failed to update comment',
                            ),
                            backgroundColor: Colors.red,
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      }
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
                  final comment =
                      _displayedPosts[postIndex]['comments'][commentIndex];
                  final commentId = comment['commentId'];

                  // Capture ScaffoldMessenger before popping dialog
                  final scaffoldMessenger = ScaffoldMessenger.of(context);
                  Navigator.pop(context);

                  // Optimistic UI update
                  setState(() {
                    _displayedPosts[postIndex]['comments'].removeAt(
                      commentIndex,
                    );
                  });

                  scaffoldMessenger.showSnackBar(
                    const SnackBar(
                      content: Text('Comment deleted'),
                      backgroundColor: Colors.red,
                      duration: Duration(seconds: 2),
                    ),
                  );

                  // Call API if commentId exists (from server)
                  if (commentId != null) {
                    final result = await _newsfeedService.deleteComment(
                      postId: _displayedPosts[postIndex]['postID'],
                      commentId: commentId,
                    );

                    if (!result['success']) {
                      // Rollback on failure
                      if (mounted) {
                        setState(() {
                          _displayedPosts[postIndex]['comments'].insert(
                            commentIndex,
                            comment,
                          );
                        });
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
    final post = _displayedPosts[postIndex];
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
                        padding: EdgeInsets.all(20.0),
                        child: Center(
                          child: Text(
                            'No likes yet',
                            style: TextStyle(color: Colors.grey, fontSize: 14),
                          ),
                        ),
                      )
                      : ListView.builder(
                        shrinkWrap: true,
                        itemCount: likedByUsers.length,
                        itemBuilder: (context, index) {
                          final user = likedByUsers[index];
                          final userName = user['name'] ?? 'Unknown';

                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF5F5F5),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 20,
                                  backgroundColor: const Color(0xFFE8DEFF),
                                  child: Text(
                                    userName[0].toUpperCase(),
                                    style: const TextStyle(
                                      color: Color(0xFF7A5AF8),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    userName,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF333333),
                                    ),
                                  ),
                                ),
                                const Icon(
                                  Icons.favorite,
                                  color: Colors.red,
                                  size: 18,
                                ),
                              ],
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

  void _showReportDialog(int postIndex) {
    String? selectedReason;
    final TextEditingController customReasonController =
        TextEditingController();
    final List<String> reportReasons = [
      'Spam or misleading',
      'Harassment or hate speech',
      'Inappropriate content',
      'Violence or dangerous organizations',
      'Intellectual property violation',
      'False information',
      'Other',
    ];

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final isOtherSelected = selectedReason == 'Other';
            final canSubmit =
                selectedReason != null &&
                (!isOtherSelected ||
                    customReasonController.text.trim().isNotEmpty);

            return AlertDialog(
              title: const Row(
                children: [
                  Icon(Icons.flag, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Report Post'),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Why are you reporting this post?',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 16),
                    ...reportReasons.map((reason) {
                      return RadioListTile<String>(
                        title: Text(
                          reason,
                          style: const TextStyle(fontSize: 14),
                        ),
                        value: reason,
                        groupValue: selectedReason,
                        activeColor: const Color(0xFF7A5AF8),
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                        onChanged: (value) {
                          setDialogState(() {
                            selectedReason = value;
                          });
                        },
                      );
                    }),
                    if (isOtherSelected) ...[
                      const SizedBox(height: 12),
                      TextField(
                        controller: customReasonController,
                        decoration: InputDecoration(
                          hintText: 'Please specify your reason...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: Color(0xFF7A5AF8),
                              width: 2,
                            ),
                          ),
                          contentPadding: const EdgeInsets.all(12),
                        ),
                        maxLines: 3,
                        maxLength: 200,
                        onChanged: (value) {
                          setDialogState(() {});
                        },
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    customReasonController.dispose();
                    Navigator.pop(context);
                  },
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed:
                      canSubmit
                          ? () {
                            final reportReason =
                                isOtherSelected
                                    ? customReasonController.text.trim()
                                    : selectedReason;
                            customReasonController.dispose();
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Post reported for: $reportReason',
                                ),
                                backgroundColor: Colors.green,
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          }
                          : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    disabledBackgroundColor: Colors.grey,
                  ),
                  child: const Text(
                    'Report',
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
}

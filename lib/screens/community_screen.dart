// Input: None
// Output: Community screen with social features, posts, discussions, and user interactions

import 'package:flutter/material.dart';
import '../components/prediction_card.dart';
import '../components/custom_text_field.dart';
import '../constants/theme_constants.dart';
import '../models/post.dart';
import '../models/user.dart';
import '../models/prediction.dart';
import '../services/post_service.dart';
import '../services/user_service.dart';
import '../services/prediction_service.dart';
import '../services/auth_service.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({Key? key}) : super(key: key);

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _postController = TextEditingController();

  // Services
  final PostService _postService = PostService();
  final UserService _userService = UserService();
  final PredictionService _predictionService = PredictionService();
  final AuthService _authService = AuthService();

  // State
  String? _token;
  bool _isLoading = false;
  bool _isPosting = false;

  // Data
  List<Post> _feedPosts = [];
  List<Post> _trendingPosts = [];
  List<Prediction> _communityPredictions = [];
  List<User> _suggestedUsers = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _postController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      _token = await _authService.getToken();
      if (_token == null) {
        _showError('Please log in to view community');
        return;
      }

      // Load community data in parallel
      final futures = await Future.wait([
        _loadFeedPosts(),
        _loadTrendingPosts(),
        _loadCommunityPredictions(),
        _loadSuggestedUsers(),
      ]);

      setState(() {
        _feedPosts = futures[0] as List<Post>;
        _trendingPosts = futures[1] as List<Post>;
        _communityPredictions = futures[2] as List<Prediction>;
        _suggestedUsers = futures[3] as List<User>;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showError('Error loading community: $e');
    }
  }

  Future<List<Post>> _loadFeedPosts() async {
    try {
      // This would load posts from followed users
      // For now, return empty list as the API endpoint might not exist
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<List<Post>> _loadTrendingPosts() async {
    try {
      // This would load trending posts
      // For now, return empty list as the API endpoint might not exist
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<List<Prediction>> _loadCommunityPredictions() async {
    try {
      if (_token == null) return [];
      return await _predictionService.getTrendingPredictions(_token!);
    } catch (e) {
      return [];
    }
  }

  Future<List<User>> _loadSuggestedUsers() async {
    try {
      // This would load suggested users to follow
      // For now, return empty list as the API endpoint might not exist
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<void> _createPost() async {
    final content = _postController.text.trim();
    if (content.isEmpty || _token == null) return;

    setState(() {
      _isPosting = true;
    });

    try {
      final post = await _postService.createPost(content, _token!);

      if (post != null) {
        _postController.clear();
        _showSuccess('Post created successfully!');
        _loadData(); // Refresh data
      } else {
        _showError('Failed to create post');
      }
    } catch (e) {
      _showError('Error creating post: $e');
    } finally {
      setState(() {
        _isPosting = false;
      });
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.lossColor,
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.gainColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              floating: true,
              pinned: true,
              backgroundColor: AppColors.backgroundColor,
              title: const Text(
                'Community',
                style: TextStyle(
                  color: AppColors.primaryTextColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(
                    Icons.add_circle_outline,
                    color: AppColors.primaryColor,
                  ),
                  onPressed: _showCreatePostDialog,
                ),
              ],
              bottom: TabBar(
                controller: _tabController,
                indicatorColor: AppColors.primaryColor,
                labelColor: AppColors.primaryColor,
                unselectedLabelColor: AppColors.secondaryTextColor,
                tabs: const [
                  Tab(text: 'Feed'),
                  Tab(text: 'Trending'),
                  Tab(text: 'Predictions'),
                ],
              ),
            ),
          ];
        },
        body: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  color: AppColors.primaryColor,
                ),
              )
            : TabBarView(
                controller: _tabController,
                children: [
                  _buildFeedTab(),
                  _buildTrendingTab(),
                  _buildPredictionsTab(),
                ],
              ),
      ),
    );
  }

  Widget _buildFeedTab() {
    return RefreshIndicator(
      onRefresh: _loadData,
      color: AppColors.primaryColor,
      child: CustomScrollView(
        slivers: [
          // Suggested Users Section
          if (_suggestedUsers.isNotEmpty) ...[
            SliverToBoxAdapter(
              child: _buildSuggestedUsersSection(),
            ),
          ],

          // Posts Feed
          if (_feedPosts.isEmpty)
            SliverFillRemaining(
              child: _buildEmptyFeedState(),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final post = _feedPosts[index];
                  return _buildPostCard(post);
                },
                childCount: _feedPosts.length,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTrendingTab() {
    if (_trendingPosts.isEmpty) {
      return _buildEmptyState(
        icon: Icons.trending_up,
        title: 'No trending posts',
        subtitle: 'Trending discussions will appear here',
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      color: AppColors.primaryColor,
      child: ListView.builder(
        padding: const EdgeInsets.all(AppSizes.smallPadding),
        itemCount: _trendingPosts.length,
        itemBuilder: (context, index) {
          final post = _trendingPosts[index];
          return _buildPostCard(post);
        },
      ),
    );
  }

  Widget _buildPredictionsTab() {
    if (_communityPredictions.isEmpty) {
      return _buildEmptyState(
        icon: Icons.psychology,
        title: 'No community predictions',
        subtitle: 'Community predictions will appear here',
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      color: AppColors.primaryColor,
      child: ListView.builder(
        padding: const EdgeInsets.all(AppSizes.smallPadding),
        itemCount: _communityPredictions.length,
        itemBuilder: (context, index) {
          final prediction = _communityPredictions[index];
          return PredictionCard(
            prediction: prediction,
            onTap: () => _showPredictionDetail(prediction),
            onLike: (isLiked) => _handlePredictionLike(prediction, isLiked),
          );
        },
      ),
    );
  }

  Widget _buildSuggestedUsersSection() {
    return Container(
      margin: const EdgeInsets.all(AppSizes.mediumPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Suggested for you',
            style: TextStyle(
              color: AppColors.primaryTextColor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _suggestedUsers.length,
              itemBuilder: (context, index) {
                final user = _suggestedUsers[index];
                return _buildSuggestedUserCard(user);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestedUserCard(User user) {
    return Container(
      width: 100,
      margin: const EdgeInsets.only(right: AppSizes.mediumPadding),
      child: Card(
        color: AppColors.cardBackgroundColor,
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.smallPadding),
          child: Column(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.primaryColor,
                backgroundImage: user.displayProfileImageUrl.isNotEmpty
                    ? NetworkImage(user.displayProfileImageUrl)
                    : null,
                child: user.displayProfileImageUrl.isEmpty
                    ? Text(
                        user.displayName.isNotEmpty
                            ? user.displayName[0].toUpperCase()
                            : 'U',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : null,
              ),
              const SizedBox(height: 8),
              Text(
                user.displayName,
                style: const TextStyle(
                  color: AppColors.primaryTextColor,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              ElevatedButton(
                onPressed: () => _followUser(user),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(60, 24),
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                ),
                child: const Text(
                  'Follow',
                  style: TextStyle(fontSize: 10),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPostCard(Post post) {
    return Card(
      color: AppColors.cardBackgroundColor,
      margin: const EdgeInsets.symmetric(
        horizontal: AppSizes.mediumPadding,
        vertical: AppSizes.smallPadding,
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.mediumPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Info
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: AppColors.primaryColor,
                  child: Text(
                    post.userId.isNotEmpty ? post.userId[0].toUpperCase() : 'U',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'User ${post.userId}', // Would be actual username
                        style: const TextStyle(
                          color: AppColors.primaryTextColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        _formatDate(post.createdAt),
                        style: const TextStyle(
                          color: AppColors.secondaryTextColor,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.more_vert,
                    color: AppColors.iconColor,
                  ),
                  onPressed: () => _showPostOptions(post),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Post Content
            Text(
              post.content,
              style: const TextStyle(
                color: AppColors.primaryTextColor,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 16),

            // Post Actions
            Row(
              children: [
                _buildActionButton(
                  icon: post.isLikedByUser
                      ? Icons.favorite
                      : Icons.favorite_border,
                  label: '${post.likes}',
                  color: post.isLikedByUser
                      ? AppColors.lossColor
                      : AppColors.iconColor,
                  onTap: () => _handlePostLike(post),
                ),
                const SizedBox(width: 20),
                _buildActionButton(
                  icon: Icons.comment_outlined,
                  label: '${post.comments}',
                  color: AppColors.iconColor,
                  onTap: () => _showPostComments(post),
                ),
                const SizedBox(width: 20),
                _buildActionButton(
                  icon: Icons.share_outlined,
                  label: 'Share',
                  color: AppColors.iconColor,
                  onTap: () => _sharePost(post),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyFeedState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.largePadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.people_outline,
              size: 64,
              color: AppColors.secondaryTextColor,
            ),
            const SizedBox(height: 16),
            const Text(
              'Your feed is empty',
              style: TextStyle(
                color: AppColors.primaryTextColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Follow other traders to see their posts and predictions in your feed',
              style: TextStyle(
                color: AppColors.secondaryTextColor,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Navigate to explore to find users
                DefaultTabController.of(context).animateTo(1); // Explore tab
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                foregroundColor: Colors.white,
              ),
              child: const Text('Discover Traders'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.largePadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 64,
              color: AppColors.secondaryTextColor,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                color: AppColors.primaryTextColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: const TextStyle(
                color: AppColors.secondaryTextColor,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _showCreatePostDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardBackgroundColor,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          padding: const EdgeInsets.all(AppSizes.largePadding),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text(
                    'Create Post',
                    style: TextStyle(
                      color: AppColors.primaryTextColor,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      Icons.close,
                      color: AppColors.iconColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              CustomTextField(
                controller: _postController,
                hint: 'What\'s on your mind about the market?',
                keyboardType: TextInputType.multiline,
                textInputAction: TextInputAction.newline,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isPosting
                          ? null
                          : () {
                              Navigator.pop(context);
                              _createPost();
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        foregroundColor: Colors.white,
                      ),
                      child: _isPosting
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text('Post'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPredictionDetail(Prediction prediction) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardBackgroundColor,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(AppSizes.largePadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.dividerColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Prediction Details',
                style: const TextStyle(
                  color: AppColors.primaryTextColor,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Detailed prediction view with comments and analysis would be implemented here',
                style: TextStyle(
                  color: AppColors.secondaryTextColor,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPostOptions(Post post) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardBackgroundColor,
      builder: (context) => Container(
        padding: const EdgeInsets.all(AppSizes.largePadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.share, color: AppColors.iconColor),
              title: const Text(
                'Share Post',
                style: TextStyle(color: AppColors.primaryTextColor),
              ),
              onTap: () {
                Navigator.pop(context);
                _sharePost(post);
              },
            ),
            ListTile(
              leading: const Icon(Icons.report, color: AppColors.iconColor),
              title: const Text(
                'Report Post',
                style: TextStyle(color: AppColors.primaryTextColor),
              ),
              onTap: () {
                Navigator.pop(context);
                _reportPost(post);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showPostComments(Post post) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardBackgroundColor,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(AppSizes.largePadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.dividerColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Comments (${post.comments})',
                style: const TextStyle(
                  color: AppColors.primaryTextColor,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Comments section would be implemented here with the ability to add and view comments',
                style: TextStyle(
                  color: AppColors.secondaryTextColor,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  Future<void> _followUser(User user) async {
    if (_token == null) return;

    try {
      await _userService.followUser(user.id, _token!);
      _showSuccess('Now following ${user.displayName}');
      _loadData(); // Refresh data
    } catch (e) {
      _showError('Failed to follow user');
    }
  }

  Future<void> _handlePostLike(Post post) async {
    if (_token == null) return;

    try {
      if (post.isLikedByUser) {
        await _postService.unlikePost(post.id, _token!);
      } else {
        await _postService.likePost(post.id, _token!);
      }
      _loadData(); // Refresh data
    } catch (e) {
      _showError('Failed to update like');
    }
  }

  Future<void> _handlePredictionLike(
      Prediction prediction, bool isLiked) async {
    if (_token == null) return;

    try {
      await _predictionService.toggleLikePrediction(
        prediction.id,
        isLiked,
        _token!,
      );
      _loadData(); // Refresh data
    } catch (e) {
      _showError('Failed to update like');
    }
  }

  void _sharePost(Post post) {
    // Implement share functionality
    _showSuccess('Share functionality would be implemented here');
  }

  void _reportPost(Post post) {
    // Implement report functionality
    _showSuccess('Report functionality would be implemented here');
  }
}

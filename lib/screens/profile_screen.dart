// Input: None
// Output: Profile screen with user information, settings, predictions history, and account management

import 'package:flutter/material.dart';
import '../components/prediction_card.dart';
import '../components/custom_button.dart';
import '../constants/theme_constants.dart';
import '../models/user.dart';
import '../models/prediction.dart';
import '../services/user_service.dart';
import '../services/prediction_service.dart';
import '../services/auth_service.dart';
import 'auth_screen.dart';
import 'developer_options_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Services
  final UserService _userService = UserService();
  final PredictionService _predictionService = PredictionService();
  final AuthService _authService = AuthService();

  // State
  String? _token;
  User? _currentUser;
  bool _isLoading = false;

  // Data
  List<Prediction> _userPredictions = [];
  List<User> _followers = [];
  List<User> _following = [];

  // Stats
  int _totalPredictions = 0;
  int _successfulPredictions = 0;
  double _accuracyRate = 0.0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadUserData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      _token = await _authService.getToken();
      if (_token == null) {
        _showError('Please log in to view profile');
        return;
      }

      // Get current user profile
      _currentUser = await _authService.getUserProfile();

      if (_currentUser != null) {
        // Load user data in parallel
        final futures = await Future.wait([
          _loadUserPredictions(),
          _loadFollowers(),
          _loadFollowing(),
        ]);

        setState(() {
          _userPredictions = futures[0] as List<Prediction>;
          _followers = futures[1] as List<User>;
          _following = futures[2] as List<User>;
          _calculateStats();
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showError('Error loading profile: $e');
    }
  }

  Future<List<Prediction>> _loadUserPredictions() async {
    try {
      if (_token == null || _currentUser == null) return [];
      return await _predictionService.getUserPredictions(
          _currentUser!.id, _token!);
    } catch (e) {
      return [];
    }
  }

  Future<List<User>> _loadFollowers() async {
    try {
      if (_token == null || _currentUser == null) return [];
      final result =
          await _userService.getUserFollowers(_currentUser!.id, _token!);
      return result ?? [];
    } catch (e) {
      return [];
    }
  }

  Future<List<User>> _loadFollowing() async {
    try {
      if (_token == null || _currentUser == null) return [];
      final result =
          await _userService.getUserFollowing(_currentUser!.id, _token!);
      return result ?? [];
    } catch (e) {
      return [];
    }
  }

  void _calculateStats() {
    _totalPredictions = _userPredictions.length;
    _successfulPredictions = _userPredictions.where((p) => p.isSuccess).length;
    _accuracyRate = _totalPredictions > 0
        ? (_successfulPredictions / _totalPredictions) * 100
        : 0.0;
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
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.backgroundColor,
        body: Center(
          child: CircularProgressIndicator(
            color: AppColors.primaryColor,
          ),
        ),
      );
    }

    if (_currentUser == null) {
      return _buildNotLoggedInState();
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              floating: true,
              pinned: true,
              expandedHeight: 300,
              backgroundColor: AppColors.backgroundColor,
              flexibleSpace: FlexibleSpaceBar(
                background: _buildProfileHeader(),
              ),
              actions: [
                IconButton(
                  icon: const Icon(
                    Icons.settings,
                    color: AppColors.iconColor,
                  ),
                  onPressed: _showSettingsMenu,
                ),
              ],
              bottom: TabBar(
                controller: _tabController,
                indicatorColor: AppColors.primaryColor,
                labelColor: AppColors.primaryColor,
                unselectedLabelColor: AppColors.secondaryTextColor,
                tabs: const [
                  Tab(text: 'Predictions'),
                  Tab(text: 'Followers'),
                  Tab(text: 'Following'),
                ],
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildPredictionsTab(),
            _buildFollowersTab(),
            _buildFollowingTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildNotLoggedInState() {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.largePadding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.person_outline,
                size: 64,
                color: AppColors.secondaryTextColor,
              ),
              const SizedBox(height: 16),
              const Text(
                'Not Logged In',
                style: TextStyle(
                  color: AppColors.primaryTextColor,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Please log in to view your profile and manage your account',
                style: TextStyle(
                  color: AppColors.secondaryTextColor,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              CustomButton(
                text: 'Login',
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => const AuthScreen()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      padding: const EdgeInsets.all(AppSizes.largePadding),
      child: Column(
        children: [
          const SizedBox(height: 60), // Status bar padding

          // Profile Picture and Basic Info
          Row(
            children: [
              CircleAvatar(
                radius: 40,
                backgroundColor: AppColors.primaryColor,
                backgroundImage: _currentUser!.displayProfileImageUrl.isNotEmpty
                    ? NetworkImage(_currentUser!.displayProfileImageUrl)
                    : null,
                child: _currentUser!.displayProfileImageUrl.isEmpty
                    ? Text(
                        _currentUser!.displayName.isNotEmpty
                            ? _currentUser!.displayName[0].toUpperCase()
                            : 'U',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 32,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _currentUser!.displayName,
                      style: const TextStyle(
                        color: AppColors.primaryTextColor,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '@${_currentUser!.displayUsername}',
                      style: const TextStyle(
                        color: AppColors.secondaryTextColor,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      _currentUser!.email,
                      style: const TextStyle(
                        color: AppColors.secondaryTextColor,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Bio
          if (_currentUser!.displayBio.isNotEmpty) ...[
            Text(
              _currentUser!.displayBio,
              style: const TextStyle(
                color: AppColors.primaryTextColor,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
          ],

          // Stats Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatItem('Predictions', '$_totalPredictions'),
              _buildStatItem('Followers', '${_followers.length}'),
              _buildStatItem('Following', '${_following.length}'),
              _buildStatItem(
                  'Accuracy', '${_accuracyRate.toStringAsFixed(1)}%'),
            ],
          ),

          const SizedBox(height: 20),

          // Edit Profile Button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: _showEditProfileDialog,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primaryColor,
                side: const BorderSide(color: AppColors.primaryColor),
              ),
              child: const Text('Edit Profile'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: AppColors.primaryTextColor,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.secondaryTextColor,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildPredictionsTab() {
    if (_userPredictions.isEmpty) {
      return _buildEmptyState(
        icon: Icons.psychology_outlined,
        title: 'No predictions yet',
        subtitle: 'Start making predictions to track your performance',
        actionText: 'Make Prediction',
        onAction: () {
          // Navigate to create prediction
          DefaultTabController.of(context).animateTo(0); // Home tab
        },
      );
    }

    return RefreshIndicator(
      onRefresh: _loadUserData,
      color: AppColors.primaryColor,
      child: ListView.builder(
        padding: const EdgeInsets.all(AppSizes.smallPadding),
        itemCount: _userPredictions.length,
        itemBuilder: (context, index) {
          final prediction = _userPredictions[index];
          return PredictionCard(
            prediction: prediction,
            onTap: () => _showPredictionDetail(prediction),
            onLike: (isLiked) => _handlePredictionLike(prediction, isLiked),
          );
        },
      ),
    );
  }

  Widget _buildFollowersTab() {
    if (_followers.isEmpty) {
      return _buildEmptyState(
        icon: Icons.people_outline,
        title: 'No followers yet',
        subtitle: 'Share great predictions to attract followers',
      );
    }

    return RefreshIndicator(
      onRefresh: _loadUserData,
      color: AppColors.primaryColor,
      child: ListView.builder(
        padding: const EdgeInsets.all(AppSizes.smallPadding),
        itemCount: _followers.length,
        itemBuilder: (context, index) {
          final user = _followers[index];
          return _buildUserListItem(user, showFollowButton: false);
        },
      ),
    );
  }

  Widget _buildFollowingTab() {
    if (_following.isEmpty) {
      return _buildEmptyState(
        icon: Icons.person_add_outlined,
        title: 'Not following anyone',
        subtitle: 'Follow other traders to see their predictions',
        actionText: 'Discover Traders',
        onAction: () {
          // Navigate to explore
          DefaultTabController.of(context).animateTo(1); // Explore tab
        },
      );
    }

    return RefreshIndicator(
      onRefresh: _loadUserData,
      color: AppColors.primaryColor,
      child: ListView.builder(
        padding: const EdgeInsets.all(AppSizes.smallPadding),
        itemCount: _following.length,
        itemBuilder: (context, index) {
          final user = _following[index];
          return _buildUserListItem(user,
              showFollowButton: true, isFollowing: true);
        },
      ),
    );
  }

  Widget _buildUserListItem(User user,
      {bool showFollowButton = false, bool isFollowing = false}) {
    return Card(
      color: AppColors.cardBackgroundColor,
      margin: const EdgeInsets.symmetric(vertical: AppSizes.smallPadding),
      child: ListTile(
        leading: CircleAvatar(
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
        title: Text(
          user.displayName,
          style: const TextStyle(
            color: AppColors.primaryTextColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '@${user.displayUsername}',
              style: const TextStyle(
                color: AppColors.secondaryTextColor,
                fontSize: 12,
              ),
            ),
            if (user.displayBio.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                user.displayBio,
                style: const TextStyle(
                  color: AppColors.secondaryTextColor,
                  fontSize: 12,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
        trailing: showFollowButton
            ? ElevatedButton(
                onPressed: () => _toggleFollowUser(user, isFollowing),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isFollowing
                      ? AppColors.cardBackgroundColor
                      : AppColors.primaryColor,
                  foregroundColor:
                      isFollowing ? AppColors.primaryColor : Colors.white,
                  side: isFollowing
                      ? const BorderSide(color: AppColors.primaryColor)
                      : null,
                  minimumSize: const Size(80, 32),
                ),
                child: Text(
                  isFollowing ? 'Unfollow' : 'Follow',
                  style: const TextStyle(fontSize: 12),
                ),
              )
            : null,
        onTap: () => _showUserProfile(user),
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
    String? actionText,
    VoidCallback? onAction,
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
            if (actionText != null && onAction != null) ...[
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: onAction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  foregroundColor: Colors.white,
                ),
                child: Text(actionText),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showSettingsMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardBackgroundColor,
      builder: (context) => Container(
        padding: const EdgeInsets.all(AppSizes.largePadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Settings',
              style: TextStyle(
                color: AppColors.primaryTextColor,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.edit, color: AppColors.iconColor),
              title: const Text(
                'Edit Profile',
                style: TextStyle(color: AppColors.primaryTextColor),
              ),
              onTap: () {
                Navigator.pop(context);
                _showEditProfileDialog();
              },
            ),
            ListTile(
              leading:
                  const Icon(Icons.notifications, color: AppColors.iconColor),
              title: const Text(
                'Notifications',
                style: TextStyle(color: AppColors.primaryTextColor),
              ),
              onTap: () {
                Navigator.pop(context);
                _showNotificationSettings();
              },
            ),
            ListTile(
              leading:
                  const Icon(Icons.privacy_tip, color: AppColors.iconColor),
              title: const Text(
                'Privacy & Security',
                style: TextStyle(color: AppColors.primaryTextColor),
              ),
              onTap: () {
                Navigator.pop(context);
                _showPrivacySettings();
              },
            ),
            ListTile(
              leading:
                  const Icon(Icons.developer_mode, color: AppColors.iconColor),
              title: const Text(
                'Developer Options',
                style: TextStyle(color: AppColors.primaryTextColor),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const DeveloperOptionsScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.help, color: AppColors.iconColor),
              title: const Text(
                'Help & Support',
                style: TextStyle(color: AppColors.primaryTextColor),
              ),
              onTap: () {
                Navigator.pop(context);
                _showHelpSupport();
              },
            ),
            const Divider(color: AppColors.dividerColor),
            ListTile(
              leading: const Icon(Icons.logout, color: AppColors.lossColor),
              title: const Text(
                'Logout',
                style: TextStyle(color: AppColors.lossColor),
              ),
              onTap: () {
                Navigator.pop(context);
                _showLogoutConfirmation();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showEditProfileDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackgroundColor,
        title: const Text(
          'Edit Profile',
          style: TextStyle(color: AppColors.primaryTextColor),
        ),
        content: const Text(
          'Profile editing functionality would be implemented here with form fields for name, bio, and profile picture.',
          style: TextStyle(color: AppColors.secondaryTextColor),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showNotificationSettings() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackgroundColor,
        title: const Text(
          'Notification Settings',
          style: TextStyle(color: AppColors.primaryTextColor),
        ),
        content: const Text(
          'Notification preferences would be implemented here with toggles for different types of notifications.',
          style: TextStyle(color: AppColors.secondaryTextColor),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showPrivacySettings() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackgroundColor,
        title: const Text(
          'Privacy & Security',
          style: TextStyle(color: AppColors.primaryTextColor),
        ),
        content: const Text(
          'Privacy and security settings would be implemented here with options for account visibility, data sharing, etc.',
          style: TextStyle(color: AppColors.secondaryTextColor),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showHelpSupport() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackgroundColor,
        title: const Text(
          'Help & Support',
          style: TextStyle(color: AppColors.primaryTextColor),
        ),
        content: const Text(
          'Help and support section would be implemented here with FAQs, contact information, and troubleshooting guides.',
          style: TextStyle(color: AppColors.secondaryTextColor),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showLogoutConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackgroundColor,
        title: const Text(
          'Logout',
          style: TextStyle(color: AppColors.primaryTextColor),
        ),
        content: const Text(
          'Are you sure you want to logout?',
          style: TextStyle(color: AppColors.secondaryTextColor),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await _logout();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.lossColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('Logout'),
          ),
        ],
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
                'Detailed prediction view with performance analysis would be implemented here',
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

  void _showUserProfile(User user) {
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
                user.displayName,
                style: const TextStyle(
                  color: AppColors.primaryTextColor,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'User profile details would be implemented here',
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

  Future<void> _toggleFollowUser(User user, bool isCurrentlyFollowing) async {
    if (_token == null) return;

    try {
      if (isCurrentlyFollowing) {
        await _userService.unfollowUser(user.id, _token!);
        _showSuccess('Unfollowed ${user.displayName}');
      } else {
        await _userService.followUser(user.id, _token!);
        _showSuccess('Now following ${user.displayName}');
      }

      _loadUserData(); // Refresh data
    } catch (e) {
      _showError('Failed to update follow status');
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
      _loadUserData(); // Refresh data
    } catch (e) {
      _showError('Failed to update like');
    }
  }

  Future<void> _logout() async {
    try {
      await _authService.logout();
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const AuthScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      _showError('Failed to logout');
    }
  }
}

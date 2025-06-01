// Input: None
// Output: Explore screen with search functionality for stocks, predictions, and users

import 'package:flutter/material.dart';
import '../components/stock_card.dart';
import '../components/prediction_card.dart';
import '../components/custom_text_field.dart';
import '../constants/theme_constants.dart';
import '../models/stock.dart';
import '../models/prediction.dart';
import '../models/user.dart';
import '../services/stock_service.dart';
import '../services/prediction_service.dart';
import '../services/user_service.dart';
import '../services/auth_service.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({Key? key}) : super(key: key);

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  // Services
  final StockService _stockService = StockService();
  final PredictionService _predictionService = PredictionService();
  final UserService _userService = UserService();
  final AuthService _authService = AuthService();

  // State
  String? _token;
  bool _isLoading = false;
  bool _isSearching = false;
  String _searchQuery = '';

  // Search results
  List<Stock> _searchedStocks = [];
  List<Prediction> _searchedPredictions = [];
  List<User> _searchedUsers = [];

  // Trending data
  List<Stock> _trendingStocks = [];
  List<Prediction> _trendingPredictions = [];
  List<User> _topTraders = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadInitialData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      _token = await _authService.getToken();
      if (_token == null) {
        _showError('Please log in to explore content');
        return;
      }

      // Load trending data in parallel
      final futures = await Future.wait([
        _stockService.getTrendingStocks(_token!),
        _predictionService.getTrendingPredictions(_token!),
        _loadTopTraders(),
      ]);

      setState(() {
        _trendingStocks = futures[0] as List<Stock>;
        _trendingPredictions = futures[1] as List<Prediction>;
        _topTraders = futures[2] as List<User>;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showError('Error loading data: $e');
    }
  }

  Future<List<User>> _loadTopTraders() async {
    try {
      // This would be a real API call to get top traders
      // For now, return empty list as the API endpoint might not exist
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _searchQuery = '';
        _searchedStocks = [];
        _searchedPredictions = [];
        _searchedUsers = [];
        _isSearching = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _searchQuery = query;
    });

    try {
      if (_token == null) return;

      // Perform searches in parallel
      final futures = await Future.wait([
        _stockService.searchStocks(query, _token!),
        _searchPredictions(query),
        _searchUsers(query),
      ]);

      setState(() {
        _searchedStocks = futures[0] as List<Stock>;
        _searchedPredictions = futures[1] as List<Prediction>;
        _searchedUsers = futures[2] as List<User>;
        _isSearching = false;
      });
    } catch (e) {
      setState(() {
        _isSearching = false;
      });
      _showError('Search failed: $e');
    }
  }

  Future<List<Prediction>> _searchPredictions(String query) async {
    try {
      // This would search predictions by stock symbol or description
      // For now, filter trending predictions
      return _trendingPredictions
          .where((p) =>
              p.stockSymbol.toLowerCase().contains(query.toLowerCase()) ||
              p.stockName.toLowerCase().contains(query.toLowerCase()) ||
              (p.description?.toLowerCase().contains(query.toLowerCase()) ??
                  false))
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<User>> _searchUsers(String query) async {
    try {
      // This would be a real API call to search users
      // For now, return empty list
      return [];
    } catch (e) {
      return [];
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
                'Explore',
                style: TextStyle(
                  color: AppColors.primaryTextColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(120),
                child: Column(
                  children: [
                    // Search Bar
                    Padding(
                      padding: const EdgeInsets.all(AppSizes.mediumPadding),
                      child: CustomTextField(
                        controller: _searchController,
                        hint: 'Search stocks, predictions, or users...',
                        prefixIcon: const Icon(
                          Icons.search,
                          color: AppColors.iconColor,
                        ),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(
                                  Icons.clear,
                                  color: AppColors.iconColor,
                                ),
                                onPressed: () {
                                  _searchController.clear();
                                  _performSearch('');
                                },
                              )
                            : null,
                        onChanged: (value) {
                          if (value.length > 2 || value.isEmpty) {
                            _performSearch(value);
                          }
                        },
                      ),
                    ),
                    // Tab Bar
                    TabBar(
                      controller: _tabController,
                      indicatorColor: AppColors.primaryColor,
                      labelColor: AppColors.primaryColor,
                      unselectedLabelColor: AppColors.secondaryTextColor,
                      tabs: const [
                        Tab(text: 'Stocks'),
                        Tab(text: 'Predictions'),
                        Tab(text: 'Traders'),
                      ],
                    ),
                  ],
                ),
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
                  _buildStocksTab(),
                  _buildPredictionsTab(),
                  _buildTradersTab(),
                ],
              ),
      ),
    );
  }

  Widget _buildStocksTab() {
    final stocks = _searchQuery.isNotEmpty ? _searchedStocks : _trendingStocks;

    if (_isSearching) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primaryColor),
      );
    }

    if (stocks.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.largePadding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _searchQuery.isNotEmpty ? Icons.search_off : Icons.trending_up,
                size: 64,
                color: AppColors.secondaryTextColor,
              ),
              const SizedBox(height: 16),
              Text(
                _searchQuery.isNotEmpty ? 'No stocks found' : 'Trending Stocks',
                style: const TextStyle(
                  color: AppColors.primaryTextColor,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _searchQuery.isNotEmpty
                    ? 'Try searching for different stock symbols'
                    : 'Discover trending stocks in the market',
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

    return RefreshIndicator(
      onRefresh: _loadInitialData,
      color: AppColors.primaryColor,
      child: ListView.builder(
        padding: const EdgeInsets.all(AppSizes.smallPadding),
        itemCount: stocks.length,
        itemBuilder: (context, index) {
          final stock = stocks[index];
          return StockCard(
            stock: stock,
            onTap: () {
              // Navigate to stock detail screen
              _showStockDetail(stock);
            },
          );
        },
      ),
    );
  }

  Widget _buildPredictionsTab() {
    final predictions =
        _searchQuery.isNotEmpty ? _searchedPredictions : _trendingPredictions;

    if (_isSearching) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primaryColor),
      );
    }

    if (predictions.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.largePadding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _searchQuery.isNotEmpty ? Icons.search_off : Icons.psychology,
                size: 64,
                color: AppColors.secondaryTextColor,
              ),
              const SizedBox(height: 16),
              Text(
                _searchQuery.isNotEmpty
                    ? 'No predictions found'
                    : 'Trending Predictions',
                style: const TextStyle(
                  color: AppColors.primaryTextColor,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _searchQuery.isNotEmpty
                    ? 'Try searching for different stocks or keywords'
                    : 'Discover what the community is predicting',
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

    return RefreshIndicator(
      onRefresh: _loadInitialData,
      color: AppColors.primaryColor,
      child: ListView.builder(
        padding: const EdgeInsets.all(AppSizes.smallPadding),
        itemCount: predictions.length,
        itemBuilder: (context, index) {
          final prediction = predictions[index];
          return PredictionCard(
            prediction: prediction,
            onTap: () {
              // Navigate to prediction detail screen
              _showPredictionDetail(prediction);
            },
            onLike: (isLiked) async {
              if (_token == null) return;

              try {
                await _predictionService.toggleLikePrediction(
                  prediction.id,
                  isLiked,
                  _token!,
                );
                // Refresh data to show updated likes
                _loadInitialData();
              } catch (e) {
                _showError('Failed to update like');
              }
            },
          );
        },
      ),
    );
  }

  Widget _buildTradersTab() {
    final users = _searchQuery.isNotEmpty ? _searchedUsers : _topTraders;

    if (_isSearching) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primaryColor),
      );
    }

    if (users.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.largePadding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _searchQuery.isNotEmpty ? Icons.search_off : Icons.people,
                size: 64,
                color: AppColors.secondaryTextColor,
              ),
              const SizedBox(height: 16),
              Text(
                _searchQuery.isNotEmpty ? 'No traders found' : 'Top Traders',
                style: const TextStyle(
                  color: AppColors.primaryTextColor,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _searchQuery.isNotEmpty
                    ? 'Try searching for different usernames'
                    : 'Discover top performing traders',
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

    return RefreshIndicator(
      onRefresh: _loadInitialData,
      color: AppColors.primaryColor,
      child: ListView.builder(
        padding: const EdgeInsets.all(AppSizes.smallPadding),
        itemCount: users.length,
        itemBuilder: (context, index) {
          final user = users[index];
          return _buildUserCard(user);
        },
      ),
    );
  }

  Widget _buildUserCard(User user) {
    return Card(
      color: AppColors.cardBackgroundColor,
      margin: const EdgeInsets.symmetric(
        horizontal: AppSizes.smallPadding,
        vertical: AppSizes.smallPadding / 2,
      ),
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
        trailing: ElevatedButton(
          onPressed: () {
            // Follow/unfollow user
            _toggleFollowUser(user);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: user.isFollowing
                ? AppColors.cardBackgroundColor
                : AppColors.primaryColor,
            foregroundColor:
                user.isFollowing ? AppColors.primaryColor : Colors.white,
            side: user.isFollowing
                ? const BorderSide(color: AppColors.primaryColor)
                : null,
            minimumSize: const Size(80, 32),
          ),
          child: Text(
            user.isFollowing ? 'Following' : 'Follow',
            style: const TextStyle(fontSize: 12),
          ),
        ),
        onTap: () {
          // Navigate to user profile
          _showUserProfile(user);
        },
      ),
    );
  }

  void _showStockDetail(Stock stock) {
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
                stock.name,
                style: const TextStyle(
                  color: AppColors.primaryTextColor,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                stock.symbol,
                style: const TextStyle(
                  color: AppColors.secondaryTextColor,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                '₹${stock.currentPrice.toStringAsFixed(2)}',
                style: const TextStyle(
                  color: AppColors.primaryTextColor,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${stock.isPositiveChange ? '+' : ''}₹${stock.change.toStringAsFixed(2)} (${stock.changePercentage.toStringAsFixed(2)}%)',
                style: TextStyle(
                  color: stock.isPositiveChange
                      ? AppColors.gainColor
                      : AppColors.lossColor,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Stock details and charts would be implemented here',
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
                'Prediction for ${prediction.stockName}',
                style: const TextStyle(
                  color: AppColors.primaryTextColor,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Target: ₹${prediction.targetPrice.toStringAsFixed(2)}',
                style: const TextStyle(
                  color: AppColors.primaryTextColor,
                  fontSize: 18,
                ),
              ),
              if (prediction.description != null) ...[
                const SizedBox(height: 16),
                Text(
                  prediction.description!,
                  style: const TextStyle(
                    color: AppColors.secondaryTextColor,
                    fontSize: 14,
                  ),
                ),
              ],
              const SizedBox(height: 20),
              const Text(
                'Prediction details and comments would be implemented here',
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
              Row(
                children: [
                  CircleAvatar(
                    radius: 30,
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
                              fontSize: 24,
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.displayName,
                          style: const TextStyle(
                            color: AppColors.primaryTextColor,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '@${user.displayUsername}',
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
              if (user.displayBio.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  user.displayBio,
                  style: const TextStyle(
                    color: AppColors.secondaryTextColor,
                    fontSize: 14,
                  ),
                ),
              ],
              const SizedBox(height: 20),
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

  Future<void> _toggleFollowUser(User user) async {
    if (_token == null) return;

    try {
      if (user.isFollowing) {
        await _userService.unfollowUser(user.id, _token!);
      } else {
        await _userService.followUser(user.id, _token!);
      }

      // Refresh data to show updated follow status
      _loadInitialData();
    } catch (e) {
      _showError('Failed to update follow status');
    }
  }
}

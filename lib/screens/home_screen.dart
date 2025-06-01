// Input: None
// Output: Home screen displaying trending predictions and stocks

import 'package:flutter/material.dart';
import '../components/stock_card.dart';
import '../components/prediction_card.dart';
import '../constants/theme_constants.dart';
import '../models/stock.dart';
import '../models/prediction.dart';
import '../services/stock_service.dart';
import '../services/prediction_service.dart';
import '../services/auth_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final StockService _stockService = StockService();
  final PredictionService _predictionService = PredictionService();
  final AuthService _authService = AuthService();

  List<Stock> _trendingStocks = [];
  List<Prediction> _trendingPredictions = [];
  bool _isLoading = true;
  String? _token;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Get authentication token
      _token = await _authService.getToken();

      if (_token == null) {
        // User not authenticated, show error
        setState(() {
          _isLoading = false;
        });
        _showError('Please log in to view content');
        return;
      }

      // Load data in parallel
      final futures = await Future.wait([
        _stockService.getTrendingStocks(_token!),
        _predictionService.getTrendingPredictions(_token!),
      ]);

      setState(() {
        _trendingStocks = futures[0] as List<Stock>;
        _trendingPredictions = futures[1] as List<Prediction>;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showError('Error loading data: $e');
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
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: RefreshIndicator(
        onRefresh: _loadData,
        color: AppColors.primaryColor,
        child: CustomScrollView(
          slivers: [
            // App Bar
            SliverAppBar(
              floating: true,
              pinned: true,
              backgroundColor: AppColors.backgroundColor,
              title: const Text(
                'SimpleHot',
                style: TextStyle(
                  color: AppColors.primaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(
                    Icons.notifications_outlined,
                    color: AppColors.iconColor,
                  ),
                  onPressed: () {
                    // Navigate to notifications
                  },
                ),
                IconButton(
                  icon: const Icon(
                    Icons.message_outlined,
                    color: AppColors.iconColor,
                  ),
                  onPressed: () {
                    // Navigate to messages
                  },
                ),
              ],
              bottom: TabBar(
                controller: _tabController,
                indicatorColor: AppColors.primaryColor,
                labelColor: AppColors.primaryColor,
                unselectedLabelColor: AppColors.secondaryTextColor,
                tabs: const [
                  Tab(text: 'Predictions'),
                  Tab(text: 'Stocks'),
                ],
              ),
            ),

            // Content
            if (_isLoading)
              const SliverFillRemaining(
                child: Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primaryColor,
                  ),
                ),
              )
            else
              SliverFillRemaining(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // Predictions Tab
                    _buildPredictionsTab(),

                    // Stocks Tab
                    _buildStocksTab(),
                  ],
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to create prediction
          _showCreatePredictionDialog();
        },
        backgroundColor: AppColors.primaryColor,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildPredictionsTab() {
    if (_trendingPredictions.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(AppSizes.largePadding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.trending_up,
                size: 64,
                color: AppColors.secondaryTextColor,
              ),
              SizedBox(height: 16),
              Text(
                'No predictions found',
                style: TextStyle(
                  color: AppColors.primaryTextColor,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Be the first to make a stock prediction!',
                style: TextStyle(
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

    return ListView.builder(
      itemCount: _trendingPredictions.length,
      itemBuilder: (context, index) {
        final prediction = _trendingPredictions[index];
        return PredictionCard(
          prediction: prediction,
          onTap: () {
            // Navigate to prediction detail
          },
          onLike: (isLiked) async {
            if (_token == null) return;

            try {
              final success = await _predictionService.toggleLikePrediction(
                prediction.id,
                isLiked,
                _token!,
              );

              if (success) {
                setState(() {
                  final updatedPredictions =
                      List<Prediction>.from(_trendingPredictions);
                  final predIndex = updatedPredictions
                      .indexWhere((p) => p.id == prediction.id);

                  if (predIndex != -1) {
                    final updatedPrediction = Prediction(
                      id: prediction.id,
                      stockSymbol: prediction.stockSymbol,
                      stockName: prediction.stockName,
                      userId: prediction.userId,
                      username: prediction.username,
                      userAvatar: prediction.userAvatar,
                      targetPrice: prediction.targetPrice,
                      createdAt: prediction.createdAt,
                      targetDate: prediction.targetDate,
                      description: prediction.description,
                      status: prediction.status,
                      direction: prediction.direction,
                      likes:
                          isLiked ? prediction.likes + 1 : prediction.likes - 1,
                      comments: prediction.comments,
                      isLikedByUser: isLiked,
                      finalPrice: prediction.finalPrice,
                      resolvedAt: prediction.resolvedAt,
                      originalPrice: prediction.originalPrice,
                      percentageDifference: prediction.percentageDifference,
                    );

                    updatedPredictions[predIndex] = updatedPrediction;
                    _trendingPredictions = updatedPredictions;
                  }
                });
              } else {
                _showError('Failed to update like');
              }
            } catch (e) {
              _showError('Error updating like: $e');
            }
          },
        );
      },
    );
  }

  Widget _buildStocksTab() {
    if (_trendingStocks.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(AppSizes.largePadding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.show_chart,
                size: 64,
                color: AppColors.secondaryTextColor,
              ),
              SizedBox(height: 16),
              Text(
                'No stocks found',
                style: TextStyle(
                  color: AppColors.primaryTextColor,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Stock data will appear here once available',
                style: TextStyle(
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

    return ListView.builder(
      itemCount: _trendingStocks.length,
      itemBuilder: (context, index) {
        final stock = _trendingStocks[index];
        return StockCard(
          stock: stock,
          onTap: () {
            // Navigate to stock detail
          },
        );
      },
    );
  }

  void _showCreatePredictionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackgroundColor,
        title: const Text(
          'Create Prediction',
          style: TextStyle(color: AppColors.primaryTextColor),
        ),
        content: const Text(
          'Create prediction feature will be implemented with stock selection, target price, and date picker.',
          style: TextStyle(color: AppColors.secondaryTextColor),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

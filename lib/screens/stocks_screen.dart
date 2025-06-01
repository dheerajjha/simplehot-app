// Input: None
// Output: Stocks screen with market overview, watchlist, trending stocks, and stock details

import 'package:flutter/material.dart';
import '../components/stock_card.dart';
import '../components/custom_text_field.dart';
import '../constants/theme_constants.dart';
import '../models/stock.dart';
import '../services/stock_service.dart';
import '../services/auth_service.dart';

class StocksScreen extends StatefulWidget {
  const StocksScreen({Key? key}) : super(key: key);

  @override
  State<StocksScreen> createState() => _StocksScreenState();
}

class _StocksScreenState extends State<StocksScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  // Services
  final StockService _stockService = StockService();
  final AuthService _authService = AuthService();

  // State
  String? _token;
  bool _isLoading = false;
  bool _isSearching = false;
  String _searchQuery = '';

  // Data
  List<Stock> _trendingStocks = [];
  List<Stock> _watchlistStocks = [];
  List<Stock> _searchResults = [];
  List<Stock> _topGainers = [];
  List<Stock> _topLosers = [];

  // Market indices (mock data for now)
  final List<Map<String, dynamic>> _marketIndices = [
    {
      'name': 'NIFTY 50',
      'value': 19850.25,
      'change': 125.30,
      'changePercent': 0.63,
    },
    {
      'name': 'SENSEX',
      'value': 66589.93,
      'change': 418.60,
      'changePercent': 0.63,
    },
    {
      'name': 'NIFTY BANK',
      'value': 45123.75,
      'change': -89.45,
      'changePercent': -0.20,
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      _token = await _authService.getToken();
      if (_token == null) {
        _showError('Please log in to view stocks');
        return;
      }

      // Load trending stocks
      final trendingStocks = await _stockService.getTrendingStocks(_token!);

      setState(() {
        _trendingStocks = trendingStocks;
        // Mock data for other categories
        _topGainers =
            trendingStocks.where((s) => s.isPositiveChange).take(10).toList();
        _topLosers =
            trendingStocks.where((s) => !s.isPositiveChange).take(10).toList();
        _watchlistStocks = []; // Would be loaded from user preferences
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showError('Error loading stocks: $e');
    }
  }

  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _searchQuery = '';
        _searchResults = [];
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

      final results = await _stockService.searchStocks(query, _token!);

      setState(() {
        _searchResults = results;
        _isSearching = false;
      });
    } catch (e) {
      setState(() {
        _isSearching = false;
      });
      _showError('Search failed: $e');
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
              expandedHeight: 200,
              flexibleSpace: FlexibleSpaceBar(
                background: _buildMarketOverview(),
              ),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(120),
                child: Container(
                  color: AppColors.backgroundColor,
                  child: Column(
                    children: [
                      // Search Bar
                      Padding(
                        padding: const EdgeInsets.all(AppSizes.mediumPadding),
                        child: CustomTextField(
                          controller: _searchController,
                          hint: 'Search stocks by symbol or name...',
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
                        isScrollable: true,
                        tabs: const [
                          Tab(text: 'Trending'),
                          Tab(text: 'Watchlist'),
                          Tab(text: 'Gainers'),
                          Tab(text: 'Losers'),
                        ],
                      ),
                    ],
                  ),
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
            : _searchQuery.isNotEmpty
                ? _buildSearchResults()
                : TabBarView(
                    controller: _tabController,
                    children: [
                      _buildTrendingTab(),
                      _buildWatchlistTab(),
                      _buildGainersTab(),
                      _buildLosersTab(),
                    ],
                  ),
      ),
    );
  }

  Widget _buildMarketOverview() {
    return Container(
      padding: const EdgeInsets.all(AppSizes.mediumPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 40), // Status bar padding
          const Text(
            'Market Overview',
            style: TextStyle(
              color: AppColors.primaryTextColor,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _marketIndices.length,
              itemBuilder: (context, index) {
                final index_data = _marketIndices[index];
                final isPositive = index_data['change'] >= 0;

                return Container(
                  width: 160,
                  margin: const EdgeInsets.only(right: AppSizes.mediumPadding),
                  padding: const EdgeInsets.all(AppSizes.mediumPadding),
                  decoration: BoxDecoration(
                    color: AppColors.cardBackgroundColor,
                    borderRadius: BorderRadius.circular(AppSizes.mediumRadius),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        index_data['name'],
                        style: const TextStyle(
                          color: AppColors.secondaryTextColor,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        index_data['value'].toStringAsFixed(2),
                        style: const TextStyle(
                          color: AppColors.primaryTextColor,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            isPositive
                                ? Icons.arrow_upward
                                : Icons.arrow_downward,
                            color: isPositive
                                ? AppColors.gainColor
                                : AppColors.lossColor,
                            size: 12,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${isPositive ? '+' : ''}${index_data['change'].toStringAsFixed(2)} (${index_data['changePercent'].toStringAsFixed(2)}%)',
                            style: TextStyle(
                              color: isPositive
                                  ? AppColors.gainColor
                                  : AppColors.lossColor,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    if (_isSearching) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primaryColor),
      );
    }

    if (_searchResults.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.largePadding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.search_off,
                size: 64,
                color: AppColors.secondaryTextColor,
              ),
              const SizedBox(height: 16),
              const Text(
                'No stocks found',
                style: TextStyle(
                  color: AppColors.primaryTextColor,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Try searching for "${_searchQuery}" with different keywords',
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

    return ListView.builder(
      padding: const EdgeInsets.all(AppSizes.smallPadding),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final stock = _searchResults[index];
        return StockCard(
          stock: stock,
          onTap: () => _showStockDetail(stock),
        );
      },
    );
  }

  Widget _buildTrendingTab() {
    if (_trendingStocks.isEmpty) {
      return _buildEmptyState(
        icon: Icons.trending_up,
        title: 'No trending stocks',
        subtitle: 'Trending stocks will appear here',
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      color: AppColors.primaryColor,
      child: ListView.builder(
        padding: const EdgeInsets.all(AppSizes.smallPadding),
        itemCount: _trendingStocks.length,
        itemBuilder: (context, index) {
          final stock = _trendingStocks[index];
          return StockCard(
            stock: stock,
            onTap: () => _showStockDetail(stock),
          );
        },
      ),
    );
  }

  Widget _buildWatchlistTab() {
    if (_watchlistStocks.isEmpty) {
      return _buildEmptyState(
        icon: Icons.bookmark_border,
        title: 'Your watchlist is empty',
        subtitle: 'Add stocks to your watchlist to track them here',
        actionText: 'Browse Stocks',
        onAction: () {
          _tabController.animateTo(0); // Go to trending tab
        },
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      color: AppColors.primaryColor,
      child: ListView.builder(
        padding: const EdgeInsets.all(AppSizes.smallPadding),
        itemCount: _watchlistStocks.length,
        itemBuilder: (context, index) {
          final stock = _watchlistStocks[index];
          return StockCard(
            stock: stock,
            onTap: () => _showStockDetail(stock),
          );
        },
      ),
    );
  }

  Widget _buildGainersTab() {
    if (_topGainers.isEmpty) {
      return _buildEmptyState(
        icon: Icons.trending_up,
        title: 'No gainers found',
        subtitle: 'Top gaining stocks will appear here',
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      color: AppColors.primaryColor,
      child: ListView.builder(
        padding: const EdgeInsets.all(AppSizes.smallPadding),
        itemCount: _topGainers.length,
        itemBuilder: (context, index) {
          final stock = _topGainers[index];
          return StockCard(
            stock: stock,
            onTap: () => _showStockDetail(stock),
          );
        },
      ),
    );
  }

  Widget _buildLosersTab() {
    if (_topLosers.isEmpty) {
      return _buildEmptyState(
        icon: Icons.trending_down,
        title: 'No losers found',
        subtitle: 'Top losing stocks will appear here',
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      color: AppColors.primaryColor,
      child: ListView.builder(
        padding: const EdgeInsets.all(AppSizes.smallPadding),
        itemCount: _topLosers.length,
        itemBuilder: (context, index) {
          final stock = _topLosers[index];
          return StockCard(
            stock: stock,
            onTap: () => _showStockDetail(stock),
          );
        },
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

  void _showStockDetail(Stock stock) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardBackgroundColor,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.8,
        maxChildSize: 0.95,
        minChildSize: 0.6,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(AppSizes.largePadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
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

              // Stock Header
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          stock.name,
                          style: const TextStyle(
                            color: AppColors.primaryTextColor,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${stock.symbol} • ${stock.exchange}',
                          style: const TextStyle(
                            color: AppColors.secondaryTextColor,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      // Add to watchlist
                      _toggleWatchlist(stock);
                    },
                    icon: Icon(
                      _isInWatchlist(stock)
                          ? Icons.bookmark
                          : Icons.bookmark_border,
                      color: _isInWatchlist(stock)
                          ? AppColors.primaryColor
                          : AppColors.iconColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Price Information
              Text(
                '₹${stock.currentPrice.toStringAsFixed(2)}',
                style: const TextStyle(
                  color: AppColors.primaryTextColor,
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: [
                  Icon(
                    stock.isPositiveChange
                        ? Icons.arrow_upward
                        : Icons.arrow_downward,
                    color: stock.isPositiveChange
                        ? AppColors.gainColor
                        : AppColors.lossColor,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
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
                ],
              ),
              const SizedBox(height: 30),

              // Stock Stats
              _buildStockStats(stock),

              const SizedBox(height: 30),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        // Navigate to create prediction
                        Navigator.pop(context);
                        _showCreatePredictionDialog(stock);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Make Prediction'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        // View predictions for this stock
                        Navigator.pop(context);
                        _showStockPredictions(stock);
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primaryColor,
                        side: const BorderSide(color: AppColors.primaryColor),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('View Predictions'),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Additional Information
              const Text(
                'Additional Information',
                style: TextStyle(
                  color: AppColors.primaryTextColor,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              _buildInfoRow('Sector', stock.sector),
              _buildInfoRow('Volume', '${stock.volume}'),

              const SizedBox(height: 20),
              const Text(
                'Charts and detailed analysis would be implemented here',
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

  Widget _buildStockStats(Stock stock) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.mediumPadding),
      decoration: BoxDecoration(
        color: AppColors.backgroundColor,
        borderRadius: BorderRadius.circular(AppSizes.mediumRadius),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                  child: _buildStatItem(
                      'Day High', '₹${stock.dayHigh.toStringAsFixed(2)}')),
              Expanded(
                  child: _buildStatItem(
                      'Day Low', '₹${stock.dayLow.toStringAsFixed(2)}')),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                  child: _buildStatItem(
                      '52W High', '₹${stock.yearHigh.toStringAsFixed(2)}')),
              Expanded(
                  child: _buildStatItem(
                      '52W Low', '₹${stock.yearLow.toStringAsFixed(2)}')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.secondaryTextColor,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: AppColors.primaryTextColor,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColors.secondaryTextColor,
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.primaryTextColor,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  bool _isInWatchlist(Stock stock) {
    return _watchlistStocks.any((s) => s.symbol == stock.symbol);
  }

  void _toggleWatchlist(Stock stock) {
    setState(() {
      if (_isInWatchlist(stock)) {
        _watchlistStocks.removeWhere((s) => s.symbol == stock.symbol);
      } else {
        _watchlistStocks.add(stock);
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isInWatchlist(stock)
              ? 'Added to watchlist'
              : 'Removed from watchlist',
        ),
        backgroundColor: AppColors.primaryColor,
      ),
    );
  }

  void _showCreatePredictionDialog(Stock stock) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackgroundColor,
        title: Text(
          'Create Prediction for ${stock.symbol}',
          style: const TextStyle(color: AppColors.primaryTextColor),
        ),
        content: const Text(
          'Create prediction feature will be implemented with target price, date picker, and reasoning.',
          style: TextStyle(color: AppColors.secondaryTextColor),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  void _showStockPredictions(Stock stock) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackgroundColor,
        title: Text(
          'Predictions for ${stock.symbol}',
          style: const TextStyle(color: AppColors.primaryTextColor),
        ),
        content: const Text(
          'Stock predictions list will be implemented here showing community predictions for this stock.',
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
}

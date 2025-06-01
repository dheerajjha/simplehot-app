// Input: None
// Output: App configuration class with environment settings

import 'package:shared_preferences/shared_preferences.dart';

class AppConfig {
  static const String _baseUrlKey = 'base_url';

  // Default API endpoints
  static const String defaultGatewayUrl = 'http://20.193.143.179:5050';
  static const String defaultAuthServiceUrl = 'http://localhost:5001';
  static const String defaultUserServiceUrl = 'http://localhost:5002';

  // Current gateway URL (can be changed in developer options)
  static String _gatewayUrl = defaultGatewayUrl;

  // Authentication API paths
  static const String loginEndpoint = '/api/auth/login';
  static const String registerEndpoint = '/api/auth/register';
  static const String verifyEndpoint = '/api/auth/verify';

  // User API paths
  static const String userProfileEndpoint = '/api/users/profile';
  static const String usersEndpoint = '/api/users';
  static const String followEndpoint = '/follow';
  static const String followersEndpoint = '/followers';
  static const String followingEndpoint = '/following';

  // Posts API paths
  static const String postsEndpoint = '/api/posts';
  static const String userPostsEndpoint = '/api/posts/user';
  static const String likeEndpoint = '/like';
  static const String likesEndpoint = '/likes';
  static const String commentsEndpoint = '/comments';

  // Stock API paths
  static const String stocksEndpoint = '/api/stocks';
  static const String trendingStocksEndpoint = '/api/stocks/trending';
  static const String stockSearchEndpoint = '/api/stocks/search';
  static const String stockHistoryEndpoint = '/history';

  // Prediction API paths
  static const String predictionsEndpoint = '/api/predictions';
  static const String trendingPredictionsEndpoint = '/api/predictions/trending';
  static const String stockPredictionsEndpoint = '/api/predictions/stock';
  static const String userPredictionsEndpoint = '/api/predictions/user';

  // News API paths
  static const String newsEndpoint = '/api/news/stocks';

  // Health check
  static const String healthEndpoint = '/health';

  // Token storage
  static const String tokenKey = 'auth_token';

  // Get current gateway URL
  static String get gatewayUrl => _gatewayUrl;

  // Initialize config
  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final savedUrl = prefs.getString(_baseUrlKey);
    if (savedUrl != null && savedUrl.isNotEmpty) {
      _gatewayUrl = savedUrl;
    }
  }

  // Update gateway URL
  static Future<void> setGatewayUrl(String url) async {
    if (url.isEmpty) {
      _gatewayUrl = defaultGatewayUrl;
    } else {
      _gatewayUrl = url;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_baseUrlKey, _gatewayUrl);
  }

  // Reset to default URL
  static Future<void> resetToDefaultUrl() async {
    _gatewayUrl = defaultGatewayUrl;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_baseUrlKey, _gatewayUrl);
  }
}

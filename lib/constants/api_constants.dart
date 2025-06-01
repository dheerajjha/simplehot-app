// Input: None
// Output: API URLs and endpoints for the app

class ApiConstants {
  static const String baseUrl =
      'https://api.example.com'; // Replace with actual API endpoint

  // Stock data endpoints
  static const String stocksEndpoint = '/stocks';
  static const String stockDetailEndpoint = '/stock/'; // Append stock symbol
  static const String stockPredictionsEndpoint = '/predictions';

  // User endpoints
  static const String loginEndpoint = '/auth/login';
  static const String registerEndpoint = '/auth/register';
  static const String userProfileEndpoint = '/user/profile';

  // Community endpoints
  static const String communitiesEndpoint = '/communities';
  static const String communityDetailEndpoint =
      '/community/'; // Append community id

  // News endpoints
  static const String newsEndpoint = '/news';
  static const String trendingNewsEndpoint = '/news/trending';

  // NSE/BSE stock API (sample, to be replaced with actual API)
  static const String nseStocksListUrl =
      'https://www.nseindia.com/api/equity-stockIndices?index=NIFTY%2050';
  static const String bseStocksListUrl =
      'https://api.bseindia.com/BseIndiaAPI/api/StockIndicesData/w';
}

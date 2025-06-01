// Input: Authentication token
// Output: News data from backend APIs

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';

class NewsService {
  // Get stock news
  Future<List<Map<String, dynamic>>> getStockNews(
    String token, {
    String? symbol,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      String url =
          '${AppConfig.gatewayUrl}${AppConfig.newsEndpoint}?page=$page&limit=$limit';
      if (symbol != null && symbol.isNotEmpty) {
        url += '&symbol=${Uri.encodeComponent(symbol)}';
      }

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'x-auth-token': token,
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> responseData = jsonDecode(response.body);
        return responseData.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Failed to load news: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load news: $e');
    }
  }

  // Get general financial news
  Future<List<Map<String, dynamic>>> getGeneralNews(
    String token, {
    int page = 1,
    int limit = 10,
  }) async {
    return await getStockNews(token, page: page, limit: limit);
  }

  // Get news for specific stock
  Future<List<Map<String, dynamic>>> getNewsForStock(
    String symbol,
    String token, {
    int page = 1,
    int limit = 10,
  }) async {
    return await getStockNews(token, symbol: symbol, page: page, limit: limit);
  }
}

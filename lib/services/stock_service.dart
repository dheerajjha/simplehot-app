// Input: Authentication token
// Output: Stock data from backend APIs

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/stock.dart';
import '../config/app_config.dart';

class StockService {
  // Get trending stocks
  Future<List<Stock>> getTrendingStocks(String token) async {
    try {
      final response = await http.get(
        Uri.parse('${AppConfig.gatewayUrl}/api/stocks/trending'),
        headers: {
          'Content-Type': 'application/json',
          'x-auth-token': token,
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> responseData = jsonDecode(response.body);
        return responseData.map((data) => Stock.fromApiJson(data)).toList();
      } else {
        throw Exception(
            'Failed to load trending stocks: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load trending stocks: $e');
    }
  }

  // Get stock details by symbol
  Future<Stock> getStockDetails(String symbol, String token) async {
    try {
      final response = await http.get(
        Uri.parse('${AppConfig.gatewayUrl}/api/stocks/$symbol'),
        headers: {
          'Content-Type': 'application/json',
          'x-auth-token': token,
        },
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return Stock.fromApiJson(responseData);
      } else {
        throw Exception('Failed to load stock details: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load stock details: $e');
    }
  }

  // Search stocks by query
  Future<List<Stock>> searchStocks(String query, String token) async {
    try {
      final response = await http.get(
        Uri.parse(
            '${AppConfig.gatewayUrl}/api/stocks/search/${Uri.encodeComponent(query)}'),
        headers: {
          'Content-Type': 'application/json',
          'x-auth-token': token,
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> responseData = jsonDecode(response.body);
        return responseData.map((data) => Stock.fromApiJson(data)).toList();
      } else {
        throw Exception('Failed to search stocks: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to search stocks: $e');
    }
  }

  // Get stock historical data for charts
  Future<List<Map<String, dynamic>>> getStockHistoricalData(
    String symbol,
    String token, {
    String period = '1M',
  }) async {
    try {
      final response = await http.get(
        Uri.parse(
            '${AppConfig.gatewayUrl}/api/stocks/$symbol/history?period=$period'),
        headers: {
          'Content-Type': 'application/json',
          'x-auth-token': token,
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> responseData = jsonDecode(response.body);
        return responseData.cast<Map<String, dynamic>>();
      } else {
        throw Exception(
            'Failed to load historical data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load historical data: $e');
    }
  }
}
 
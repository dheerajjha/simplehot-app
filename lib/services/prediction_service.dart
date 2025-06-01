// Input: Authentication token
// Output: Prediction data from backend APIs

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/prediction.dart';
import '../config/app_config.dart';

class PredictionService {
  // Get trending predictions
  Future<List<Prediction>> getTrendingPredictions(String token,
      {int page = 1, int limit = 10}) async {
    try {
      final response = await http.get(
        Uri.parse(
            '${AppConfig.gatewayUrl}/api/predictions/trending?page=$page&limit=$limit'),
        headers: {
          'Content-Type': 'application/json',
          'x-auth-token': token,
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> responseData = jsonDecode(response.body);
        return responseData
            .map((data) => Prediction.fromApiJson(data))
            .toList();
      } else {
        throw Exception(
            'Failed to load trending predictions: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load trending predictions: $e');
    }
  }

  // Get predictions for a specific stock
  Future<List<Prediction>> getPredictionsForStock(String symbol, String token,
      {int page = 1, int limit = 10}) async {
    try {
      final response = await http.get(
        Uri.parse(
            '${AppConfig.gatewayUrl}/api/predictions/stock/$symbol?page=$page&limit=$limit'),
        headers: {
          'Content-Type': 'application/json',
          'x-auth-token': token,
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> responseData = jsonDecode(response.body);
        return responseData
            .map((data) => Prediction.fromApiJson(data))
            .toList();
      } else {
        throw Exception(
            'Failed to load predictions for $symbol: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load predictions for $symbol: $e');
    }
  }

  // Get user's predictions
  Future<List<Prediction>> getUserPredictions(String userId, String token,
      {int page = 1, int limit = 10}) async {
    try {
      final response = await http.get(
        Uri.parse(
            '${AppConfig.gatewayUrl}/api/predictions/user/$userId?page=$page&limit=$limit'),
        headers: {
          'Content-Type': 'application/json',
          'x-auth-token': token,
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> responseData = jsonDecode(response.body);
        return responseData
            .map((data) => Prediction.fromApiJson(data))
            .toList();
      } else {
        throw Exception(
            'Failed to load user predictions: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load user predictions: $e');
    }
  }

  // Create a new prediction
  Future<Prediction?> createPrediction({
    required String token,
    required String stockSymbol,
    required double targetPrice,
    required DateTime targetDate,
    required PredictionDirection direction,
    required double currentPrice,
    String? description,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${AppConfig.gatewayUrl}/api/predictions'),
        headers: {
          'Content-Type': 'application/json',
          'x-auth-token': token,
        },
        body: jsonEncode({
          'stockSymbol': stockSymbol,
          'targetPrice': targetPrice,
          'targetDate': targetDate.toIso8601String(),
          'direction': direction == PredictionDirection.up ? 'up' : 'down',
          'currentPrice': currentPrice,
          if (description != null) 'description': description,
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return Prediction.fromApiJson(responseData);
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  // Like a prediction
  Future<bool> likePrediction(String predictionId, String token) async {
    try {
      final response = await http.post(
        Uri.parse('${AppConfig.gatewayUrl}/api/predictions/$predictionId/like'),
        headers: {
          'Content-Type': 'application/json',
          'x-auth-token': token,
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // Unlike a prediction
  Future<bool> unlikePrediction(String predictionId, String token) async {
    try {
      final response = await http.delete(
        Uri.parse('${AppConfig.gatewayUrl}/api/predictions/$predictionId/like'),
        headers: {
          'Content-Type': 'application/json',
          'x-auth-token': token,
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // Toggle like/unlike prediction
  Future<bool> toggleLikePrediction(
      String predictionId, bool isLiked, String token) async {
    if (isLiked) {
      return await likePrediction(predictionId, token);
    } else {
      return await unlikePrediction(predictionId, token);
    }
  }

  // Comment on a prediction
  Future<bool> commentOnPrediction(
      String predictionId, String content, String token) async {
    try {
      final response = await http.post(
        Uri.parse(
            '${AppConfig.gatewayUrl}/api/predictions/$predictionId/comments'),
        headers: {
          'Content-Type': 'application/json',
          'x-auth-token': token,
        },
        body: jsonEncode({
          'content': content,
        }),
      );

      return response.statusCode == 201 || response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // Get comments for a prediction
  Future<List<dynamic>?> getPredictionComments(
      String predictionId, String token) async {
    try {
      final response = await http.get(
        Uri.parse(
            '${AppConfig.gatewayUrl}/api/predictions/$predictionId/comments'),
        headers: {
          'Content-Type': 'application/json',
          'x-auth-token': token,
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }
}

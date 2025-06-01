// Input: None
// Output: Prediction model with properties and methods

import '../utils/date_formatter.dart';

enum PredictionStatus { pending, success, failed, cancelled }

enum PredictionDirection { up, down, neutral }

class Prediction {
  final String id;
  final String stockSymbol;
  final String stockName;
  final String userId;
  final String username;
  final String userAvatar;
  final double targetPrice;
  final DateTime createdAt;
  final DateTime targetDate;
  final String? description;
  final PredictionStatus status;
  final PredictionDirection direction;
  final int likes;
  final int comments;
  final bool isLikedByUser;
  final double? finalPrice;
  final DateTime? resolvedAt;
  final double originalPrice;
  final double percentageDifference;

  Prediction({
    required this.id,
    required this.stockSymbol,
    required this.stockName,
    required this.userId,
    required this.username,
    required this.userAvatar,
    required this.targetPrice,
    required this.createdAt,
    required this.targetDate,
    this.description,
    required this.status,
    required this.direction,
    required this.likes,
    required this.comments,
    required this.isLikedByUser,
    this.finalPrice,
    this.resolvedAt,
    required this.originalPrice,
    required this.percentageDifference,
  });

  bool get isResolved =>
      status == PredictionStatus.success || status == PredictionStatus.failed;
  bool get isPending => status == PredictionStatus.pending;
  bool get isSuccess => status == PredictionStatus.success;
  bool get isFailed => status == PredictionStatus.failed;

  String get formattedCreatedDate => DateFormatter.formatDate(createdAt);
  String get formattedTargetDate => DateFormatter.formatDate(targetDate);
  String get formattedResolvedDate =>
      resolvedAt != null ? DateFormatter.formatDate(resolvedAt!) : '';

  String get timeLeft => DateFormatter.formatTimeLeft(targetDate);

  factory Prediction.fromJson(Map<String, dynamic> json) {
    return Prediction(
      id: json['id'] ?? '',
      stockSymbol: json['stockSymbol'] ?? '',
      stockName: json['stockName'] ?? '',
      userId: json['userId'] ?? '',
      username: json['username'] ?? '',
      userAvatar: json['userAvatar'] ?? '',
      targetPrice: (json['targetPrice'] ?? 0.0).toDouble(),
      createdAt:
          DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      targetDate: DateTime.parse(
          json['targetDate'] ?? DateTime.now().toIso8601String()),
      description: json['description'],
      status: PredictionStatus.values[json['status'] ?? 0],
      direction: PredictionDirection.values[json['direction'] ?? 0],
      likes: json['likes'] ?? 0,
      comments: json['comments'] ?? 0,
      isLikedByUser: json['isLikedByUser'] ?? false,
      finalPrice: json['finalPrice'] != null
          ? (json['finalPrice'] as num).toDouble()
          : null,
      resolvedAt: json['resolvedAt'] != null
          ? DateTime.parse(json['resolvedAt'])
          : null,
      originalPrice: (json['originalPrice'] ?? 0.0).toDouble(),
      percentageDifference: (json['percentageDifference'] ?? 0.0).toDouble(),
    );
  }

  // Factory method to create from API response (matches backend API format)
  factory Prediction.fromApiJson(Map<String, dynamic> json) {
    // Parse status from string
    PredictionStatus parseStatus(String? statusStr) {
      switch (statusStr?.toLowerCase()) {
        case 'pending':
          return PredictionStatus.pending;
        case 'success':
          return PredictionStatus.success;
        case 'failed':
          return PredictionStatus.failed;
        case 'cancelled':
          return PredictionStatus.cancelled;
        default:
          return PredictionStatus.pending;
      }
    }

    // Parse direction from string
    PredictionDirection parseDirection(String? directionStr) {
      switch (directionStr?.toLowerCase()) {
        case 'up':
          return PredictionDirection.up;
        case 'down':
          return PredictionDirection.down;
        case 'neutral':
          return PredictionDirection.neutral;
        default:
          return PredictionDirection.up;
      }
    }

    // Extract user info from nested user object or direct fields
    final userInfo = json['user'] as Map<String, dynamic>?;
    final username =
        userInfo?['username'] ?? userInfo?['name'] ?? 'Unknown User';
    final userAvatar = userInfo?['profileImageUrl'] ?? '';

    // Handle likes - could be array of user IDs or count
    int likesCount = 0;
    bool isLikedByCurrentUser = false;
    if (json['likes'] is List) {
      final likesList = json['likes'] as List;
      likesCount = likesList.length;
      // Note: We can't determine if current user liked without knowing current user ID
      // This would need to be handled by the API or passed separately
    } else if (json['likes'] is int) {
      likesCount = json['likes'];
    }

    return Prediction(
      id: (json['id'] ?? '').toString(), // Convert int to string
      stockSymbol: (json['stockSymbol'] ?? '').toString(),
      stockName: (json['stockName'] ?? '').toString(),
      userId: (json['userId'] ?? '').toString(), // Convert int to string
      username: username.toString(),
      userAvatar: userAvatar.toString(),
      targetPrice: (json['targetPrice'] ?? 0.0).toDouble(),
      createdAt:
          DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      targetDate: DateTime.parse(
          json['targetDate'] ?? DateTime.now().toIso8601String()),
      description: json['description']?.toString(),
      status: parseStatus(json['status']?.toString()),
      direction: parseDirection(json['direction']?.toString()),
      likes: likesCount,
      comments: json['commentCount'] ?? 0, // API uses 'commentCount'
      isLikedByUser: isLikedByCurrentUser,
      finalPrice: json['finalPrice'] != null
          ? (json['finalPrice'] as num).toDouble()
          : null,
      resolvedAt: json['resolvedAt'] != null
          ? DateTime.parse(json['resolvedAt'])
          : null,
      originalPrice: (json['currentPrice'] ?? 0.0)
          .toDouble(), // API uses 'currentPrice' for original
      percentageDifference: (json['percentageDifference'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'stockSymbol': stockSymbol,
      'stockName': stockName,
      'userId': userId,
      'username': username,
      'userAvatar': userAvatar,
      'targetPrice': targetPrice,
      'createdAt': createdAt.toIso8601String(),
      'targetDate': targetDate.toIso8601String(),
      'description': description,
      'status': status.index,
      'direction': direction.index,
      'likes': likes,
      'comments': comments,
      'isLikedByUser': isLikedByUser,
      'finalPrice': finalPrice,
      'resolvedAt': resolvedAt?.toIso8601String(),
      'originalPrice': originalPrice,
      'percentageDifference': percentageDifference,
    };
  }

  // Factory method to create a demo prediction
  factory Prediction.demo() {
    final now = DateTime.now();
    return Prediction(
      id: '1',
      stockSymbol: 'RELIANCE',
      stockName: 'Reliance Industries',
      userId: 'user1',
      username: 'StockGuru',
      userAvatar: 'https://example.com/avatars/user1.jpg',
      targetPrice: 2600.0,
      createdAt: now.subtract(const Duration(days: 2)),
      targetDate: now.add(const Duration(days: 5)),
      description:
          'I predict Reliance will hit 2600 by next week due to strong quarterly results',
      status: PredictionStatus.pending,
      direction: PredictionDirection.up,
      likes: 42,
      comments: 7,
      isLikedByUser: false,
      originalPrice: 2500.75,
      percentageDifference: 3.97,
    );
  }
}

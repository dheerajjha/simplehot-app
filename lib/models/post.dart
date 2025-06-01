// Input: None
// Output: Post model representing a user post

class Post {
  final String id;
  final String userId;
  final String content;
  final String? imageUrl;
  final DateTime createdAt;
  final List<String> likes;
  final int commentCount;
  final bool isLikedByUser;

  Post({
    required this.id,
    required this.userId,
    required this.content,
    this.imageUrl,
    required this.createdAt,
    required this.likes,
    required this.commentCount,
    this.isLikedByUser = false,
  });

  // Getter for compatibility
  int get comments => commentCount;

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: (json['id'] ?? '').toString(),
      userId: (json['userId'] ?? '').toString(),
      content: (json['content'] ?? '').toString(),
      imageUrl: json['imageUrl']?.toString(),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      likes: List<String>.from((json['likes'] ?? []).map((e) => e.toString())),
      commentCount: json['commentCount'] ?? 0,
      isLikedByUser: json['isLikedByUser'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'content': content,
      'imageUrl': imageUrl,
      'createdAt': createdAt.toIso8601String(),
      'likes': likes,
      'commentCount': commentCount,
      'isLikedByUser': isLikedByUser,
    };
  }

  bool isLikedBy(String userId) => likes.contains(userId);

  Post copyWith({
    String? id,
    String? userId,
    String? content,
    String? imageUrl,
    DateTime? createdAt,
    List<String>? likes,
    int? commentCount,
    bool? isLikedByUser,
  }) {
    return Post(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      content: content ?? this.content,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
      likes: likes ?? this.likes,
      commentCount: commentCount ?? this.commentCount,
      isLikedByUser: isLikedByUser ?? this.isLikedByUser,
    );
  }
}

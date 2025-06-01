// Input: None
// Output: User model representing user profile data

class User {
  final String id;
  final String email;
  final String? name;
  final String? username;
  final String? bio;
  final String? profileImageUrl;
  final DateTime createdAt;
  final List<String> following;
  final List<String> followers;

  User({
    required this.id,
    required this.email,
    this.name,
    this.username,
    this.bio,
    this.profileImageUrl,
    required this.createdAt,
    this.following = const [],
    this.followers = const [],
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      name: json['name'],
      username: json['username'],
      bio: json['bio'],
      profileImageUrl: json['profileImageUrl'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      following: List<String>.from(json['following'] ?? []),
      followers: List<String>.from(json['followers'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'username': username,
      'bio': bio,
      'profileImageUrl': profileImageUrl,
      'createdAt': createdAt.toIso8601String(),
      'following': following,
      'followers': followers,
    };
  }

  User copyWith({
    String? id,
    String? email,
    String? name,
    String? username,
    String? bio,
    String? profileImageUrl,
    DateTime? createdAt,
    List<String>? following,
    List<String>? followers,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      username: username ?? this.username,
      bio: bio ?? this.bio,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      createdAt: createdAt ?? this.createdAt,
      following: following ?? this.following,
      followers: followers ?? this.followers,
    );
  }
}

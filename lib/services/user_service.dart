// Input: Authentication token
// Output: User data and social features

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user.dart';
import '../config/app_config.dart';

class UserService {
  // Get user by ID
  Future<User?> getUserById(String userId, String token) async {
    try {
      final response = await http.get(
        Uri.parse('${AppConfig.gatewayUrl}${AppConfig.usersEndpoint}/$userId'),
        headers: {
          'Content-Type': 'application/json',
          'x-auth-token': token,
        },
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return User.fromJson(responseData);
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  // Get current user profile
  Future<User?> getCurrentUserProfile(String token) async {
    try {
      final response = await http.get(
        Uri.parse('${AppConfig.gatewayUrl}${AppConfig.userProfileEndpoint}'),
        headers: {
          'Content-Type': 'application/json',
          'x-auth-token': token,
        },
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return User.fromJson(responseData);
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  // Update user profile
  Future<bool> updateUserProfile({
    required String token,
    String? name,
    String? username,
    String? bio,
    String? profileImageUrl,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('${AppConfig.gatewayUrl}${AppConfig.userProfileEndpoint}'),
        headers: {
          'Content-Type': 'application/json',
          'x-auth-token': token,
        },
        body: jsonEncode({
          if (name != null) 'name': name,
          if (username != null) 'username': username,
          if (bio != null) 'bio': bio,
          if (profileImageUrl != null) 'profileImageUrl': profileImageUrl,
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // Follow a user
  Future<bool> followUser(String userId, String token) async {
    try {
      final response = await http.post(
        Uri.parse(
            '${AppConfig.gatewayUrl}${AppConfig.usersEndpoint}/$userId${AppConfig.followEndpoint}'),
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

  // Unfollow a user
  Future<bool> unfollowUser(String userId, String token) async {
    try {
      final response = await http.delete(
        Uri.parse(
            '${AppConfig.gatewayUrl}${AppConfig.usersEndpoint}/$userId${AppConfig.followEndpoint}'),
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

  // Get user's followers
  Future<List<User>?> getUserFollowers(String userId, String token) async {
    try {
      final response = await http.get(
        Uri.parse(
            '${AppConfig.gatewayUrl}${AppConfig.usersEndpoint}/$userId${AppConfig.followersEndpoint}'),
        headers: {
          'Content-Type': 'application/json',
          'x-auth-token': token,
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> responseData = jsonDecode(response.body);
        return responseData.map((data) => User.fromJson(data)).toList();
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  // Get user's following
  Future<List<User>?> getUserFollowing(String userId, String token) async {
    try {
      final response = await http.get(
        Uri.parse(
            '${AppConfig.gatewayUrl}${AppConfig.usersEndpoint}/$userId${AppConfig.followingEndpoint}'),
        headers: {
          'Content-Type': 'application/json',
          'x-auth-token': token,
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> responseData = jsonDecode(response.body);
        return responseData.map((data) => User.fromJson(data)).toList();
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }
}

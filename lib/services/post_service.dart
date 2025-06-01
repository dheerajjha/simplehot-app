// Input: Authentication token
// Output: Post data and post operations

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/post.dart';
import '../config/app_config.dart';

class PostService {
  // Create a post
  Future<Post?> createPost(String token, String content,
      {String? imageUrl}) async {
    try {
      final response = await http.post(
        Uri.parse('${AppConfig.gatewayUrl}${AppConfig.postsEndpoint}'),
        headers: {
          'Content-Type': 'application/json',
          'x-auth-token': token,
        },
        body: jsonEncode({
          'content': content,
          if (imageUrl != null) 'imageUrl': imageUrl,
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return Post.fromJson(responseData);
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  // Get post by ID
  Future<Post?> getPostById(String token, String postId) async {
    try {
      final response = await http.get(
        Uri.parse('${AppConfig.gatewayUrl}${AppConfig.postsEndpoint}/$postId'),
        headers: {
          'Content-Type': 'application/json',
          'x-auth-token': token,
        },
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return Post.fromJson(responseData);
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  // Get posts by user
  Future<List<Post>?> getPostsByUser(String token, String userId,
      {int page = 1, int limit = 10}) async {
    try {
      final response = await http.get(
        Uri.parse(
            '${AppConfig.gatewayUrl}${AppConfig.userPostsEndpoint}/$userId?page=$page&limit=$limit'),
        headers: {
          'Content-Type': 'application/json',
          'x-auth-token': token,
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> responseData = jsonDecode(response.body);
        return responseData.map((data) => Post.fromJson(data)).toList();
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  // Like a post
  Future<bool> likePost(String token, String postId) async {
    try {
      final response = await http.post(
        Uri.parse(
            '${AppConfig.gatewayUrl}${AppConfig.postsEndpoint}/$postId${AppConfig.likeEndpoint}'),
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

  // Unlike a post
  Future<bool> unlikePost(String token, String postId) async {
    try {
      final response = await http.delete(
        Uri.parse(
            '${AppConfig.gatewayUrl}${AppConfig.postsEndpoint}/$postId${AppConfig.likeEndpoint}'),
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

  // Get likes for a post
  Future<List<String>?> getPostLikes(String token, String postId) async {
    try {
      final response = await http.get(
        Uri.parse(
            '${AppConfig.gatewayUrl}${AppConfig.postsEndpoint}/$postId${AppConfig.likesEndpoint}'),
        headers: {
          'Content-Type': 'application/json',
          'x-auth-token': token,
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> responseData = jsonDecode(response.body);
        return responseData.cast<String>();
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  // Comment on a post
  Future<bool> commentOnPost(
      String token, String postId, String content) async {
    try {
      final response = await http.post(
        Uri.parse(
            '${AppConfig.gatewayUrl}${AppConfig.postsEndpoint}/$postId${AppConfig.commentsEndpoint}'),
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

  // Get comments for a post
  Future<List<dynamic>?> getPostComments(String token, String postId) async {
    try {
      final response = await http.get(
        Uri.parse(
            '${AppConfig.gatewayUrl}${AppConfig.postsEndpoint}/$postId${AppConfig.commentsEndpoint}'),
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

// Input: Email and password for login/registration
// Output: Authentication response with token or error message

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/auth_response.dart';
import '../models/user.dart';
import '../config/app_config.dart';
import 'user_service.dart';

class AuthService {
  final UserService _userService;

  AuthService({UserService? userService})
      : _userService = userService ?? UserService();

  // Health check to test API connectivity
  Future<bool> healthCheck() async {
    try {
      final response = await http.get(
        Uri.parse('${AppConfig.gatewayUrl}${AppConfig.healthEndpoint}'),
        headers: {'Content-Type': 'application/json'},
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // Login user
  Future<AuthResponse> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('${AppConfig.gatewayUrl}${AppConfig.loginEndpoint}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final authResponse = AuthResponse.fromJson(responseData);

        // Save token to shared preferences
        if (authResponse.success) {
          await _saveToken(authResponse.token);
        }

        return authResponse;
      } else {
        return AuthResponse.error(
          responseData['error'] ?? 'Login failed. Please try again.',
        );
      }
    } catch (e) {
      return AuthResponse.error('Network error. Please check your connection.');
    }
  }

  // Register new user
  Future<AuthResponse> register(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('${AppConfig.gatewayUrl}${AppConfig.registerEndpoint}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final authResponse = AuthResponse.fromJson(responseData);

        // Save token to shared preferences
        if (authResponse.success) {
          await _saveToken(authResponse.token);
        }

        return authResponse;
      } else {
        return AuthResponse.error(
          responseData['error'] ?? 'Registration failed. Please try again.',
        );
      }
    } catch (e) {
      return AuthResponse.error('Network error. Please check your connection.');
    }
  }

  // Verify token
  Future<bool> verifyToken(String token) async {
    try {
      final response = await http.get(
        Uri.parse('${AppConfig.gatewayUrl}${AppConfig.verifyEndpoint}'),
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

  // Get user profile
  Future<User?> getUserProfile() async {
    final token = await getToken();
    if (token == null) return null;

    return await _userService.getCurrentUserProfile(token);
  }

  // Get stored token
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConfig.tokenKey);
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    final token = await getToken();
    if (token == null || token.isEmpty) return false;

    // Validate token by verifying it with the API
    return await verifyToken(token);
  }

  // Logout user
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConfig.tokenKey);
  }

  // Save token to shared preferences
  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConfig.tokenKey, token);
  }
}

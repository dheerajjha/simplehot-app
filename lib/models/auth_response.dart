// Input: None
// Output: Authentication response model

class AuthResponse {
  final String token;
  final String? error;
  final bool success;

  AuthResponse({
    required this.token,
    this.error,
    required this.success,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      token: json['token'] ?? '',
      error: json['error'],
      success: json['token'] != null && json['token'].isNotEmpty,
    );
  }

  factory AuthResponse.error(String errorMessage) {
    return AuthResponse(
      token: '',
      error: errorMessage,
      success: false,
    );
  }
}

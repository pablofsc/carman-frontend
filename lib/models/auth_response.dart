import 'package:carman/models/user.dart';

class AuthResponse {
  final String accessToken;
  final String refreshToken;
  final String tokenType;
  final int expiresIn;
  final DateTime generatedAt;
  final User user;

  AuthResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.tokenType,
    required this.expiresIn,
    required this.generatedAt,
    required this.user,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String,
      tokenType: json['tokenType'] as String,
      expiresIn: json['expiresIn'] as int,
      generatedAt: DateTime.parse(json['generatedAt']),
      user: User.fromJson(json['user'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'accessToken': accessToken,
      'refreshToken': refreshToken,
      'tokenType': tokenType,
      'expiresIn': expiresIn,
      'generatedAt': generatedAt.toIso8601String(),
      'user': user.toJson(),
    };
  }

  bool isExpiringSoon(int bufferSeconds) {
    final expiryTime = generatedAt.millisecondsSinceEpoch + (expiresIn * 1000);
    final now = DateTime.now().millisecondsSinceEpoch;
    final bufferMs = bufferSeconds * 1000;
    return now >= (expiryTime - bufferMs);
  }
}

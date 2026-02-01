class LoginResponse {
  final String accessToken;
  final String refreshToken;
  final String tokenType;
  final int expiresIn;
  final DateTime generatedAt;
  final String userId;
  final String username;

  LoginResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.tokenType,
    required this.expiresIn,
    required this.generatedAt,
    required this.userId,
    required this.username,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String,
      tokenType: json['tokenType'] as String,
      expiresIn: json['expiresIn'] as int,
      generatedAt: DateTime.parse(json['generatedAt']),
      userId: json['userId'] as String,
      username: json['username'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'accessToken': accessToken,
      'refreshToken': refreshToken,
      'tokenType': tokenType,
      'expiresIn': expiresIn,
      'generatedAt': generatedAt.toIso8601String(),
      'userId': userId,
      'username': username,
    };
  }

  bool isExpiringSoon(int bufferSeconds) {
    final expiryTime = generatedAt.millisecondsSinceEpoch + (expiresIn * 1000);
    final now = DateTime.now().millisecondsSinceEpoch;
    final bufferMs = bufferSeconds * 1000;
    return now >= (expiryTime - bufferMs);
  }
}

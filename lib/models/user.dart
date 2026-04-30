import 'login_response.dart';
import 'user_vehicle_rel.dart';

class User {
  final String id;
  final DateTime createdAt;
  final DateTime modifiedAt;
  final String username;
  final UserVehicleRel? selectedVehicle;
  final String? selectedLanguage;
  final String? selectedCurrency;
  final String? selectedTheme;

  User({
    required this.id,
    required this.createdAt,
    required this.modifiedAt,
    required this.username,
    this.selectedVehicle,
    this.selectedLanguage,
    this.selectedCurrency,
    this.selectedTheme,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      createdAt: DateTime.parse(json['createdAt']),
      modifiedAt: DateTime.parse(json['modifiedAt']),
      username: json['username'],
      selectedVehicle: json['selectedVehicle'] != null
          ? UserVehicleRel.fromJson(json['selectedVehicle'])
          : null,
      selectedLanguage: json['selectedLanguage'],
      selectedCurrency: json['selectedCurrency'],
      selectedTheme: json['selectedTheme'],
    );
  }

  factory User.fromLoginResponse(LoginResponse response) {
    return User(
      id: response.userId,
      createdAt: response.generatedAt,
      modifiedAt: response.generatedAt,
      username: response.username,
      selectedLanguage: response.selectedLanguage,
      selectedCurrency: response.selectedCurrency,
      selectedTheme: response.selectedTheme,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'createdAt': createdAt.toIso8601String(),
      'modifiedAt': modifiedAt.toIso8601String(),
      'username': username,
      'selectedVehicle': selectedVehicle?.toJson(),
      'selectedLanguage': selectedLanguage,
      'selectedCurrency': selectedCurrency,
      'selectedTheme': selectedTheme,
    };
  }

  User copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? modifiedAt,
    String? username,
    UserVehicleRel? selectedVehicle,
    String? selectedLanguage,
    String? selectedCurrency,
    String? selectedTheme,
  }) {
    return User(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      modifiedAt: modifiedAt ?? this.modifiedAt,
      username: username ?? this.username,
      selectedVehicle: selectedVehicle ?? this.selectedVehicle,
      selectedLanguage: selectedLanguage ?? this.selectedLanguage,
      selectedCurrency: selectedCurrency ?? this.selectedCurrency,
      selectedTheme: selectedTheme ?? this.selectedTheme,
    );
  }
}

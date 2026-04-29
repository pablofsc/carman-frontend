import 'user_vehicle_rel.dart';

class User {
  final String id;
  final DateTime createdAt;
  final DateTime modifiedAt;
  final String username;
  final UserVehicleRel? selectedVehicle;
  final String? selectedLanguage;
  final String? selectedCurrency;

  User({
    required this.id,
    required this.createdAt,
    required this.modifiedAt,
    required this.username,
    this.selectedVehicle,
    this.selectedLanguage,
    this.selectedCurrency,
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
    };
  }
}

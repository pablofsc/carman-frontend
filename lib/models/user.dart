import 'user_vehicle_rel.dart';

class User {
  final String id;
  final DateTime createdAt;
  final DateTime modifiedAt;
  final String username;
  final UserVehicleRel? selectedVehicle;

  User({
    required this.id,
    required this.createdAt,
    required this.modifiedAt,
    required this.username,
    this.selectedVehicle,
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
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'createdAt': createdAt.toIso8601String(),
      'modifiedAt': modifiedAt.toIso8601String(),
      'username': username,
      'selectedVehicle': selectedVehicle?.toJson(),
    };
  }
}

import 'user.dart';
import 'vehicle.dart';

class UserVehicleRel {
  final String id;
  final DateTime createdAt;
  final User user;
  final Vehicle vehicle;
  final String relRole;

  UserVehicleRel({
    required this.id,
    required this.createdAt,
    required this.user,
    required this.vehicle,
    required this.relRole,
  });

  factory UserVehicleRel.fromJson(Map<String, dynamic> json) {
    return UserVehicleRel(
      id: json['id'],
      createdAt: DateTime.parse(json['createdAt']),
      user: User.fromJson(json['user']),
      vehicle: Vehicle.fromJson(json['vehicle']),
      relRole: json['relRole'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'createdAt': createdAt.toIso8601String(),
      'user': user.toJson(),
      'vehicle': vehicle.toJson(),
      'relRole': relRole,
    };
  }
}

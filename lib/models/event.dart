import 'vehicle.dart';
import 'user.dart';
import 'refuel_info.dart';

class Event {
  final String id;
  final DateTime createdAt;
  final DateTime? modifiedAt;
  final Vehicle vehicle;
  final User author;
  final String? type;
  final String? description;
  final double? odometer;
  final int? costValueMinor;
  final String? costCurrencyCode;
  final RefuelInfo? refuelInfo;

  Event({
    required this.id,
    required this.createdAt,
    this.modifiedAt,
    required this.vehicle,
    required this.author,
    this.type,
    this.description,
    this.odometer,
    this.costValueMinor,
    this.costCurrencyCode,
    this.refuelInfo,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'],
      createdAt: DateTime.parse(json['createdAt']),
      modifiedAt: json['modifiedAt'] != null
          ? DateTime.parse(json['modifiedAt'])
          : null,
      vehicle: Vehicle.fromJson(json['vehicle']),
      author: User.fromJson(json['author']),
      type: json['type'],
      description: json['description'],
      odometer: json['odometer']?.toDouble(),
      costValueMinor: json['costValueMinor'],
      costCurrencyCode: json['costCurrencyCode'],
      refuelInfo: json['refuelInfo'] != null
          ? RefuelInfo.fromJson(json['refuelInfo'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'createdAt': createdAt.toIso8601String(),
      'modifiedAt': modifiedAt?.toIso8601String(),
      'vehicle': {'id': vehicle.id},
      'author': {'id': author.id},
      'type': type,
      'description': description,
      'odometer': odometer,
      'costValueMinor': costValueMinor,
      'costCurrencyCode': costCurrencyCode,
      if (refuelInfo != null) 'refuelInfo': refuelInfo!.toJson(),
    };
  }
}

import 'dart:convert' as convert;
import 'user.dart';

class Vehicle {
  final String id;
  final String type;
  final String make;
  final String model;
  final String year;
  final User? author;
  final DateTime createdAt;
  final DateTime modifiedAt;

  Vehicle({
    required this.id,
    required this.type,
    required this.make,
    required this.model,
    required this.year,
    required this.author,
    required this.createdAt,
    required this.modifiedAt,
  });

  String get displayName => '$year $make $model';

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      id: json['id'],
      type: json['type'],
      make: json['make'],
      model: json['model'],
      year: json['year'],
      author: User.fromJson(json['author']),
      createdAt: DateTime.parse(json['createdAt']),
      modifiedAt: DateTime.parse(json['modifiedAt']),
    );
  }

  factory Vehicle.fromResponseBody(String body) {
    return Vehicle.fromJson(convert.jsonDecode(body));
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'make': make,
      'model': model,
      'year': year,
      'author': author?.toJson(),
      'createdAt': createdAt.toIso8601String(),
      'modifiedAt': modifiedAt.toIso8601String(),
    };
  }
}

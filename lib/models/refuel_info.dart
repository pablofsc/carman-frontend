class RefuelInfo {
  final String? id;
  final String? fuelType;
  final double? fuelAmount;
  final String? fuelAmountUnit;
  final String? gasStation;

  RefuelInfo({
    this.id,
    this.fuelType,
    this.fuelAmount,
    this.fuelAmountUnit,
    this.gasStation,
  });

  factory RefuelInfo.fromJson(Map<String, dynamic> json) {
    return RefuelInfo(
      id: json['id'],
      fuelType: json['fuelType'],
      fuelAmount: json['fuelAmount']?.toDouble(),
      fuelAmountUnit: json['fuelAmountUnit'],
      gasStation: json['gasStation'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'fuelType': fuelType,
      'fuelAmount': fuelAmount,
      'fuelAmountUnit': fuelAmountUnit,
      'gasStation': gasStation,
    };
  }
}

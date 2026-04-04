class RefuelInfo {
  final String? id;
  final String? fuelType;
  final double? fuelAmount;
  final String? fuelAmountUnit;
  final String? gasStation;
  final int? fuelUnitPrice;

  RefuelInfo({
    this.id,
    this.fuelType,
    this.fuelAmount,
    this.fuelAmountUnit,
    this.gasStation,
    this.fuelUnitPrice,
  });

  factory RefuelInfo.fromJson(Map<String, dynamic> json) {
    return RefuelInfo(
      id: json['id'],
      fuelType: json['fuelType'],
      fuelAmount: json['fuelAmount']?.toDouble(),
      fuelAmountUnit: json['fuelAmountUnit'],
      gasStation: json['gasStation'],
      fuelUnitPrice: json['fuelUnitPrice']?.toInt(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'fuelType': fuelType,
      'fuelAmount': fuelAmount,
      'fuelAmountUnit': fuelAmountUnit,
      'gasStation': gasStation,
      'fuelUnitPrice': fuelUnitPrice,
    };
  }
}

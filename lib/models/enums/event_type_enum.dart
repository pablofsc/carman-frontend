enum EventTypeEnum {
  maintenance('maintenance', 'Maintenance'),
  refuel('refuel', 'Refuel'),
  repair('repair', 'Repair'),
  service('service', 'Service'),
  oilChange('oil_change', 'Oil Change'),
  tireChange('tire_change', 'Tire Change'),
  inspection('inspection', 'Inspection'),
  other('other', 'Other');

  final String value;
  final String label;

  const EventTypeEnum(this.value, this.label);

  static EventTypeEnum? fromValue(String? value) {
    if (value == null) return null;
    return EventTypeEnum.values.firstWhere(
      (e) => e.value == value,
      orElse: () => EventTypeEnum.other,
    );
  }
}

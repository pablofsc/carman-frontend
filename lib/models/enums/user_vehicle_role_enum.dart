enum UserVehicleRoleEnum {
  owner('OWNER'),
  driver('DRIVER');

  final String value;

  const UserVehicleRoleEnum(this.value);

  static UserVehicleRoleEnum? fromValue(String? value) {
    if (value == null) return null;
    return UserVehicleRoleEnum.values.firstWhere((e) => e.value == value);
  }
}

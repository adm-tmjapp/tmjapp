class RideVehicleSummary {
  const RideVehicleSummary({
    required this.licensePlate,
    required this.model,
    required this.color,
    required this.type,
  });

  final String? licensePlate;
  final String? model;
  final String? color;
  final String? type;

  bool get hasData {
    return (licensePlate != null && licensePlate!.isNotEmpty) ||
        (model != null && model!.isNotEmpty) ||
        (color != null && color!.isNotEmpty);
  }
}

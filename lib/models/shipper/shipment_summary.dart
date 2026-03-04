class ShipmentSummary {
  final int createdCount;
  final int acceptedCount;
  final int completedCount;

  ShipmentSummary({
    required this.createdCount,
    required this.acceptedCount,
    required this.completedCount,
  });

  factory ShipmentSummary.fromJson(Map<String, dynamic> json) {
    return ShipmentSummary(
      createdCount: json['createdCount'] ?? 0,
      acceptedCount: json['acceptedCount'] ?? 0,
      completedCount: json['completedCount'] ?? 0,
    );
  }
}
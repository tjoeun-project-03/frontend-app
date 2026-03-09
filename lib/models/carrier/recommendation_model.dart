class RecommendedOrder {
  final int orderId;
  final int rank;
  final double finalScore;
  final int totalPrice;
  final int predictedEta;
  final double pickupDist;
  final double returnDist;
  final double depLat;
  final double depLng;
  final double arrLat;
  final double arrLng;
  // 🚀 파이썬 응답에 맞게 필드 추가
  final String departure;
  final String arrival;
  final double distance;

  RecommendedOrder({
    required this.orderId,
    required this.rank,
    required this.finalScore,
    required this.totalPrice,
    required this.predictedEta,
    required this.pickupDist,
    required this.returnDist,
    required this.depLat,
    required this.depLng,
    required this.arrLat,
    required this.arrLng,
    required this.departure,
    required this.arrival,
    required this.distance,
  });

  factory RecommendedOrder.fromJson(Map<String, dynamic> json) {
    return RecommendedOrder(
      orderId: json['orderId'] ?? 0,
      rank: json['rank'] ?? 0,
      finalScore: (json['final_score'] as num?)?.toDouble() ?? 0.0,
      totalPrice: json['total_price'] ?? 0,
      predictedEta: json['predicted_eta'] ?? 0,
      pickupDist: (json['pickup_dist'] as num?)?.toDouble() ?? 0.0,
      returnDist: (json['return_dist'] as num?)?.toDouble() ?? 0.0,
      depLat: (json['dep_lat'] as num?)?.toDouble() ?? 0.0,
      depLng: (json['dep_lng'] as num?)?.toDouble() ?? 0.0,
      arrLat: (json['arr_lat'] as num?)?.toDouble() ?? 0.0,
      arrLng: (json['arr_lng'] as num?)?.toDouble() ?? 0.0,
      // 🚀 추가된 필드 매핑
      departure: json['departure'] ?? '출발지 정보 없음',
      arrival: json['arrival'] ?? '도착지 정보 없음',
      distance: (json['distance'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

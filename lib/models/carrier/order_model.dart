// lib/models/carrier/order_model.dart
class OrderResponse {
  final int orderId;
  final String departure;
  final String arrival;
  final String content;
  final String carType;
  final int price;
  final String created;
  final double distance;
  final int duration;

  OrderResponse({
    required this.orderId,
    required this.departure,
    required this.arrival,
    required this.content,
    required this.carType,
    required this.price,
    required this.created,
    required this.distance,
    required this.duration,
  });

  factory OrderResponse.fromJson(Map<String, dynamic> json) {
    return OrderResponse(
      orderId: json['orderId'] ?? 0,
      departure: json['departure'] ?? '',
      arrival: json['arrival'] ?? '',
      content: json['content'] ?? '',
      carType: json['carType'] ?? '정보 없음',
      price: json['price'] ?? 0,
      created: json['created'] ?? '',
      // 🚀 에러 방지: num을 사용하여 int/double 모두 안전하게 처리
      distance: (json['distance'] as num?)?.toDouble() ?? 0.0,
      duration: (json['duration'] as num?)?.toInt() ?? 0,
    );
  }
}
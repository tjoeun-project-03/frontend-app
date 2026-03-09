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
  final String status; // 현재 상태
  final String? invoiceNo;
  final double? startLat;
  final double? startLng;
  final double? endLat;
  final double? endLng;

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
    required this.status,
    this.invoiceNo,
    this.startLat,
    this.startLng,
    this.endLat,
    this.endLng,
  });

  factory OrderResponse.fromJson(Map<String, dynamic> json) {
    double? parseDouble(dynamic value) {
      if (value == null) return null;
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value);
      return null;
    }

    return OrderResponse(
      orderId: json['orderId'] ?? 0,
      departure: json['departure'] ?? '',
      arrival: json['arrival'] ?? '',
      content: json['content'] ?? '',
      carType: json['carType'] ?? '정보 없음',
      price: json['price'] ?? 0,
      created: json['created'] ?? '',
      distance: parseDouble(json['distance']) ?? 0.0,
      duration: (json['duration'] as num?)?.toInt() ?? 0,
      // 🚀 서버 필드명이 status일 수도 있고 currentStatus일 수도 있으므로 둘 다 확인
      status: (json['status'] ?? json['currentStatus'] ?? 'CREATED').toString().toUpperCase(),
      invoiceNo: json['invoiceNo'],
      startLat: parseDouble(json['startLat']),
      startLng: parseDouble(json['startLng']),
      endLat: parseDouble(json['endLat']),
      endLng: parseDouble(json['endLng']),
    );
  }
}

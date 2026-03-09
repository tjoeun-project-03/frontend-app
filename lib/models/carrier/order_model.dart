class OrderResponse {
  final int orderId;
  final String invoiceNo;
  final String status;
  final String created;
  final int price;
  final String carrierId;
  final String shipperId;
  final String departure;
  final String arrival;
  final String carType;
  final String consigneeName;
  final String consigneeContact;
  final double weight;
  final String content;
  final String? clientNote;
  final double distance;
  final int duration;
  final double? startLat;
  final double? startLng;
  final double? endLat;
  final double? endLng;

  OrderResponse({
    required this.orderId,
    required this.invoiceNo,
    required this.status,
    required this.created,
    required this.price,
    required this.carrierId,
    required this.shipperId,
    required this.departure,
    required this.arrival,
    required this.carType,
    required this.consigneeName,
    required this.consigneeContact,
    required this.weight,
    required this.content,
    this.clientNote,
    required this.distance,
    required this.duration,
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
      invoiceNo: json['invoiceNo'] ?? '',
      status: (json['currentStatus'] ?? json['status'] ?? 'CREATED').toString().toUpperCase(),
      created: json['created'] ?? '',
      price: json['price'] ?? 0,
      carrierId: json['carrierId']?.toString() ?? '',
      shipperId: json['shipperId']?.toString() ?? '',
      departure: json['departure'] ?? '',
      arrival: json['arrival'] ?? '',
      content: json['content'] ?? '',
      carType: json['carType'] ?? '정보 없음',
      weight: (json['weight'] as num?)?.toDouble() ?? 0.0,
      consigneeName: json['consigneeName'] ?? '',
      consigneeContact: json['consigneeContact'] ?? '',
      clientNote: json['clientNote'],
      distance: parseDouble(json['distance']) ?? 0.0,
      duration: (json['duration'] as num?)?.toInt() ?? 0,
      startLat: parseDouble(json['startLat']),
      startLng: parseDouble(json['startLng']),
      endLat: parseDouble(json['endLat']),
      endLng: parseDouble(json['endLng']),
    );
  }

  String get statusText {
    switch (status) {
      case 'CREATED': return '예약완료';
      case 'PROCEEDING': return '운송중';
      case 'COMPLETED': return '운송완료';
      case 'CANCELLED': return '취소됨';
      default: return status;
    }
  }

  String get formattedDate {
    try {
      if (created.isEmpty) return "";
      DateTime dt = DateTime.parse(created);
      return "${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}";
    } catch (e) {
      return created;
    }
  }
}

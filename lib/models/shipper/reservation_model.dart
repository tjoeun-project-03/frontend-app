class ReservationModel {
  final int orderId;
  final String departure;
  final String arrival;
  final String status;
  final String created;
  final int price;
  final String invoiceNo;
  final String carType;
  final String carrierName;
  final String content;
  final double weight;

  ReservationModel({
    required this.orderId,
    required this.departure,
    required this.arrival,
    required this.status,
    required this.created,
    required this.price,
    required this.invoiceNo,
    required this.carType,
    required this.carrierName,
    required this.content,
    required this.weight,
  });

  factory ReservationModel.fromJson(Map<String, dynamic> json) {
    return ReservationModel(
      orderId: json['orderId'] ?? 0,
      departure: json['departure'] ?? '출발지 정보 없음',
      arrival: json['arrival'] ?? '도착지 정보 없음',
      status: json['status'] ?? '미정',
      created: json['created'] ?? '',
      price: json['price'] ?? 0,
      invoiceNo: json['invoiceNo'] ?? '-',
      carType: json['carType'] ?? '-',
      carrierName: json['carrierName'] ?? '배정 중',
      content: json['content'] ?? '-',
      weight: (json['weight'] ?? 0.0).toDouble(),
    );
  }

  // 날짜 형식 변환 (2026.02.26 17:32)
  String get formattedDate {
    try {
      if (created.isEmpty) return "";
      DateTime dt = DateTime.parse(created);
      return "${dt.year}.${dt.month.toString().padLeft(2, '0')}.${dt.day.toString().padLeft(2, '0')} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
    } catch (e) {
      return created;
    }
  }

  // 가격 콤마 표시
  String get formattedPrice {
    return "${price.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}원";
  }
}

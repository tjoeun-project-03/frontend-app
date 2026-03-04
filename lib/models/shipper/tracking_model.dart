class TrackingModel {
  final String? status;      // 추가: 현재 배송 상태 (배송중, 완료 등)
  final String? driverName;
  final String? carInfo;
  final String? route;
  final String? carrierContact; // 추가: 기사님 연락처
  final double lat; // 위도
  final double lng; // 경도
  final double? startLat;
  final double? startLng;
  final double? endLat;
  final double? endLng;
  final Map<String, dynamic>? summary;
  final List<TimelineItemData> timelines;

  TrackingModel({
    this.status,
    this.driverName,
    this.carInfo,
    this.route,
    this.carrierContact,
    this.lat = 37.5665, // 기본값
    this.lng = 126.9780,
    this.startLat,
    this.startLng,
    this.endLat,
    this.endLng,
    this.summary,
    required this.timelines,
  });

  TrackingModel copyWith({
    String? status,
    String? driverName,
    String? carInfo,
    String? route,
    String? carrierContact,
    double? lat,
    double? lng,
    double? startLat,
    double? startLng,
    double? endLat,
    double? endLng,
    List<TimelineItemData>? timelines,
  }) {
    return TrackingModel(
      status: status ?? this.status,
      driverName: driverName ?? this.driverName,
      carInfo: carInfo ?? this.carInfo,
      route: route ?? this.route,
      carrierContact: carrierContact ?? this.carrierContact,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      startLat: startLat ?? this.startLat,
      startLng: startLng ?? this.startLng,
      endLat: endLat ?? this.endLat,
      endLng: endLng ?? this.endLng,
      timelines: timelines ?? this.timelines,
    );
  }
}

class TimelineItemData {
  final String? title;
  final String? time;
  final bool isDone;
  final bool isCurrent;

  TimelineItemData({this.title, this.time, this.isDone = false, this.isCurrent = false});
}

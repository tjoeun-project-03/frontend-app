class TrackingModel {
  final Map<String, String> summary;
  final String route;
  final String driverName;
  final String carInfo;
  final List<TimelineItemData> timelines;

  TrackingModel({
    required this.summary,
    required this.route,
    required this.driverName,
    required this.carInfo,
    required this.timelines,
  });
}

class TimelineItemData {
  final String title;
  final String time;
  final bool isDone;
  final bool isCurrent;

  TimelineItemData({
    required this.title,
    required this.time,
    required this.isDone,
    this.isCurrent = false,
  });
}
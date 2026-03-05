class ReportModel {
  final int id;
  final String? adminComment;
  final String content;
  final String createdAt;
  final String? endDate;
  final String? penalty;
  final String reason; // 카테고리/사유
  final String status;
  final String? updatedAt;
  final String reportedUserId; // 신고 대상 ID
  final String reporterUserId; // 신고자 ID

  ReportModel({
    required this.id,
    this.adminComment,
    required this.content,
    required this.createdAt,
    this.endDate,
    this.penalty,
    required this.reason,
    required this.status,
    this.updatedAt,
    required this.reportedUserId,
    required this.reporterUserId,
  });

  factory ReportModel.fromJson(Map<String, dynamic> json) {
    return ReportModel(
      id: json['id'] ?? 0,
      adminComment: json['adminComment'],
      content: json['content'] ?? '',
      createdAt: json['createdAt'] ?? '',
      endDate: json['endDate'],
      penalty: json['penalty'],
      reason: json['reason'] ?? '',
      status: json['status'] ?? 'PENDING',
      updatedAt: json['updatedAt'],
      reportedUserId: json['reportedUserId'] ?? '',
      reporterUserId: json['reporterUserId'] ?? '',
    );
  }

  // UI용 상태 텍스트
  String get statusText {
    switch (status) {
      case 'PENDING': return '검토중';
      case 'PROCESSED': return '처리완료';
      case 'REJECTED': return '반려';
      default: return status;
    }
  }

  // 날짜 포맷팅
  String get formattedDate {
    try {
      if (createdAt.isEmpty) return "";
      DateTime dt = DateTime.parse(createdAt);
      return "${dt.year}.${dt.month.toString().padLeft(2, '0')}.${dt.day.toString().padLeft(2, '0')}";
    } catch (e) {
      return createdAt;
    }
  }
}

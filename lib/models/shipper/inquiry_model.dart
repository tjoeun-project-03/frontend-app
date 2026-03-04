class InquiryModel {
  final int id;
  final String title;
  final String content;
  final String? answer;
  final String status;
  final String createdAt;
  final String category;

  InquiryModel({
    required this.id,
    required this.title,
    required this.content,
    this.answer,
    required this.status,
    required this.createdAt,
    required this.category,
  });

  factory InquiryModel.fromJson(Map<String, dynamic> json) {
    return InquiryModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      answer: json['answer'],
      status: json['status'] ?? 'WAITING',
      createdAt: json['createdAt'] ?? '',
      category: json['category'] ?? '기타', // 기본값 설정
    );
  }

  String get statusText => status == "COMPLETED" ? "답변완료" : "답변대기";
  bool get isAnswered => status == "COMPLETED";

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

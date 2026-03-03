class NoticeModel {
  final int id;
  final String title;
  final String content;
  final String createdAt;
  final int isPinned; // 1이면 필독
  final int target;   // 0: 화주, 1: 차주, 2: 전체

  NoticeModel({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.isPinned,
    required this.target,
  });

  factory NoticeModel.fromJson(Map<String, dynamic> json) {
    // pinned가 String으로 올 경우를 대비해 int.tryParse 처리
    int parsePinned(dynamic value) {
      if (value is int) return value;
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }

    return NoticeModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      createdAt: json['createdAt'] ?? '',
      isPinned: parsePinned(json['pinned']), // 서버 필드명 'pinned' 반영
      target: json['target'] ?? 0,
    );
  }

  // 날짜 포맷팅 (YYYY.MM.DD HH:mm)
  String get formattedDate {
    try {
      if (createdAt.isEmpty) return "";
      DateTime dt = DateTime.parse(createdAt);
      return "${dt.year}.${dt.month.toString().padLeft(2, '0')}.${dt.day.toString().padLeft(2, '0')} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
    } catch (e) {
      return createdAt; 
    }
  }

  // 대상 텍스트 반환
  String get targetText {
    switch (target) {
      case 0: return "화주";
      case 1: return "차주";
      case 2: return "전체";
      default: return "";
    }
  }

  NoticeModel copyWith({
    int? id,
    String? title,
    String? content,
    String? createdAt,
    int? isPinned,
    int? target,
  }) {
    return NoticeModel(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      isPinned: isPinned ?? this.isPinned,
      target: target ?? this.target,
    );
  }
}

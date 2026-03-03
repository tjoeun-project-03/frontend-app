import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/shipper/notice_model.dart';
import '../../services/shipper/notice_service.dart';

class NoticeState {
  final List<NoticeModel> notices;
  final bool isLoading;

  NoticeState({
    this.notices = const [],
    this.isLoading = false,
  });

  NoticeState copyWith({
    List<NoticeModel>? notices,
    bool? isLoading,
  }) {
    return NoticeState(
      notices: notices ?? this.notices,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class NoticeNotifier extends StateNotifier<NoticeState> {
  final NoticeService _service;

  NoticeNotifier(this._service) : super(NoticeState()) {
    fetchNotices();
  }

  Future<void> fetchNotices() async {
    state = state.copyWith(isLoading: true);
    try {
      final List<NoticeModel> notices = await _service.getNotices();
      
      // 정렬 로직: isPinned가 1인 항목을 맨 위로 고정
      notices.sort((a, b) {
        if (a.isPinned == 1 && b.isPinned != 1) return -1;
        if (a.isPinned != 1 && b.isPinned == 1) return 1;
        return b.createdAt.compareTo(a.createdAt);
      });

      state = state.copyWith(notices: notices, isLoading: false);
    } catch (e) {
      print("🚨 [NoticeNotifier] Error: $e");
      state = state.copyWith(isLoading: false);
    }
  }
}

final noticeServiceProvider = Provider((ref) => NoticeService());

final noticeViewModelProvider = StateNotifierProvider<NoticeNotifier, NoticeState>((ref) {
  final service = ref.watch(noticeServiceProvider);
  return NoticeNotifier(service);
});

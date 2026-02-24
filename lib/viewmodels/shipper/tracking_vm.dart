import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/shipper/tracking_model.dart';
import '../../services/common/notification_service.dart';

class TrackingState {
  final int selectedTabIndex;
  final TrackingModel? data;
  final bool isLoading;

  TrackingState({this.selectedTabIndex = 1, this.data, this.isLoading = true});

  TrackingState copyWith({int? selectedTabIndex, TrackingModel? data, bool? isLoading}) {
    return TrackingState(
      selectedTabIndex: selectedTabIndex ?? this.selectedTabIndex,
      data: data ?? this.data,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class TrackingViewModel extends StateNotifier<TrackingState> {
  TrackingViewModel() : super(TrackingState()) {
    _init();
  }

  void _init() {
    final mockData = TrackingModel(
      summary: {"waiting": "1", "ing": "1", "done": "2"},
      route: "서울 서초구 → 부산 강서구",
      driverName: "김수기사님",
      carInfo: "11톤 윙바디 · 경기82 가 1234",
      timelines: [
        TimelineItemData(title: "배차 완료", time: "02월 14일 오전 09:00", isDone: true),
        TimelineItemData(title: "상차 완료", time: "02월 14일 오전 11:30", isDone: true),
        TimelineItemData(title: "운송중", time: "02월 16일 오전 11:30", isDone: true, isCurrent: true),
        TimelineItemData(title: "하차 완료", time: "오늘 오후 16:30 예정", isDone: true),
      ],
    );
    // 데이터 먼저 주입 후 로딩 해제
    state = state.copyWith(data: mockData, isLoading: false);

    // 데이터 로드 후 하차 완료(isDone: true) 상태이면 알림 발송
    if (mockData.timelines.any((item) => item.title == "하차 완료" && item.isDone)) {
      NotificationService().showDeliveryCompleteNotification();
    }

  }

  void changeTab(int index) => state = state.copyWith(selectedTabIndex: index);
}

final trackingProvider = StateNotifierProvider<TrackingViewModel, TrackingState>((ref) => TrackingViewModel());
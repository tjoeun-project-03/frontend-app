import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../../models/shipper/tracking_model.dart';
import '../../services/common/api_service.dart';

class TrackingState {
  final int selectedTabIndex;
  final TrackingModel? data;
  final bool isLoading;

  TrackingState({this.selectedTabIndex = 0, this.data, this.isLoading = false});

  TrackingState copyWith({int? selectedTabIndex, TrackingModel? data, bool? isLoading}) {
    return TrackingState(
      selectedTabIndex: selectedTabIndex ?? this.selectedTabIndex,
      data: data ?? this.data,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class TrackingViewModel extends StateNotifier<TrackingState> {
  WebSocketChannel? _channel;
  final Dio _dio = ApiService().dio;

  TrackingViewModel() : super(TrackingState());

  Future<void> fetchOrderTimeline(int orderId) async {
    state = state.copyWith(isLoading: true);

    try {
      // 주문 상세 정보와 타임라인을 병렬로 호출
      final results = await Future.wait([
        _dio.get('/api/orders/id/$orderId'),          // 주문 상세
        _dio.get('/api/orders/$orderId/timeline')  // 타임라인 로그
      ]);

      final orderData = results[0].data;
      final List<dynamic> rawLogs = results[1].data;

      // 타임라인 변환
      final List<TimelineItemData> uiTimelines = rawLogs.asMap().entries.map((entry) {
        int idx = entry.key;
        var log = entry.value;

        return TimelineItemData(
          title: log['statusDescription'] ?? log['statusName'] ?? '상태 정보 없음',
          time: _formatDate(log['updateTime']),
          isDone: true,
          isCurrent: idx == 0, // 첫 번째 요소가 가장 최근 상태
        );
      }).toList();

      // UI 객체 조립
      final updatedData = TrackingModel(
        status: orderData['status'] ?? "운행중",
        route: "${orderData['departure'] ?? '출발지'} → ${orderData['arrival'] ?? '도착지'}",
        driverName: orderData['carrierName'] ?? "기사 배정 중",
        carInfo: "${orderData['carType'] ?? ''}",
        carrierContact: orderData['consigneeContact'] ?? "연락처 없음",
        timelines: uiTimelines,
      );

      state = state.copyWith(data: updatedData, isLoading: false);
    } catch (e) {
      print("데이터 로드 에러: $e");
      state = state.copyWith(isLoading: false);
    }
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return "";
    try {
      DateTime dt = DateTime.parse(dateStr);
      return DateFormat('MM/dd HH:mm').format(dt);
    } catch (e) {
      return dateStr;
    }
  }
  void connectToTrackingSocket(int orderId) {
    // 서버 주소에 맞게 수정 (예: ws://10.0.2.2:8000/api/v1/tracking/ws/$orderId)
    final wsUrl = Uri.parse('ws://10.0.2.2:8000/api/v1/tracking/ws/$orderId');
    _channel = WebSocketChannel.connect(wsUrl);

    _channel!.stream.listen((message) {
      final data = jsonDecode(message);
      if (data['lat'] != null && data['lng'] != null) {
        // 새로운 좌표로 상태 업데이트
        final updatedModel = state.data?.copyWith(
          lat: double.parse(data['lat'].toString()),
          lng: double.parse(data['lng'].toString()),
        );
        state = state.copyWith(data: updatedModel);
      }
    }, onError: (error) {
      print("소켓 에러: $error");
    }, onDone: () {
      print("소켓 연결 종료");
    });
  }

  @override
  void dispose() {
    _channel?.sink.close();
    super.dispose();
  }

  // 이 메서드가 클래스 중괄호 { } 안에 정확히 들어와야 합니다.
  void changeTab(int index) {
    state = state.copyWith(selectedTabIndex: index);
  }
}

final trackingProvider = StateNotifierProvider<TrackingViewModel, TrackingState>((ref) => TrackingViewModel());
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
      final results = await Future.wait([
        _dio.get('/api/orders/id/$orderId'),
        _dio.get('/api/orders/$orderId/timeline')
      ]);

      var orderData = results[0].data;
      
      // 서버 응답이 리스트인 경우 처리
      if (orderData is List) {
        if (orderData.isNotEmpty) {
          orderData = orderData.firstWhere(
            (item) => item['orderId'] == orderId,
            orElse: () => orderData[0],
          );
        } else {
          throw Exception("Order not found");
        }
      }

      final List<dynamic> rawLogs = results[1].data;

      final List<TimelineItemData> uiTimelines = rawLogs.asMap().entries.map((entry) {
        int idx = entry.key;
        var log = entry.value;

        return TimelineItemData(
          title: log['statusDescription'] ?? log['statusName'] ?? '상태 정보 없음',
          time: _formatDate(log['updateTime']),
          isDone: true,
          isCurrent: idx == 0,
        );
      }).toList();

      final updatedData = TrackingModel(
        status: orderData['status'] ?? "운행중",
        route: "${orderData['departure'] ?? '출발지'} → ${orderData['arrival'] ?? '도착지'}",
        driverName: orderData['carrierName'] ?? "기사 배정 중",
        carInfo: "${orderData['carType'] ?? ''}",
        carrierContact: orderData['consigneeContact'] ?? "연락처 없음",
        startLat: double.tryParse(orderData['startLat']?.toString() ?? ''),
        startLng: double.tryParse(orderData['startLng']?.toString() ?? ''),
        endLat: double.tryParse(orderData['endLat']?.toString() ?? ''),
        endLng: double.tryParse(orderData['endLng']?.toString() ?? ''),
        lat: double.tryParse(orderData['startLat']?.toString() ?? '') ?? 37.5665,
        lng: double.tryParse(orderData['startLng']?.toString() ?? '') ?? 126.9780,
        timelines: uiTimelines,
      );

      state = state.copyWith(data: updatedData, isLoading: false);
      
      connectToTrackingSocket(orderId);
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
    _channel?.sink.close();
    
    final baseUrl = _dio.options.baseUrl;
    final uri = Uri.parse(baseUrl);
    final host = uri.host;
    
    // 포트가 명시되어 있지 않으면 기본값 사용, 있으면 해당 호스트 유지
    // 에뮬레이터 10.0.2.2 대응
    final wsUrl = Uri.parse('ws://$host:8000/api/v1/tracking/ws/$orderId');
    print("웹소켓 연결 시도: $wsUrl");

    try {
      _channel = WebSocketChannel.connect(wsUrl);

      _channel!.stream.listen((message) {
        print("소켓 메시지 수신: $message");
        final data = jsonDecode(message);
        if (data['lat'] != null && data['lng'] != null) {
          final currentData = state.data;
          if (currentData != null) {
            final updatedModel = currentData.copyWith(
              lat: double.parse(data['lat'].toString()),
              lng: double.parse(data['lng'].toString()),
            );
            state = state.copyWith(data: updatedModel);
          }
        }
      }, onError: (error) {
        print("소켓 에러 상세: $error");
      }, onDone: () {
        print("소켓 연결 종료");
      }, cancelOnError: false);
    } catch (e) {
      print("소켓 연결 예외 발생: $e");
    }
  }

  @override
  void dispose() {
    _channel?.sink.close();
    super.dispose();
  }

  void changeTab(int index) {
    state = state.copyWith(selectedTabIndex: index);
  }
}

final trackingProvider = StateNotifierProvider<TrackingViewModel, TrackingState>((ref) => TrackingViewModel());

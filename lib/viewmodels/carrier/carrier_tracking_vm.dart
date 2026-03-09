import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../../services/common/api_service.dart';

class CarrierTrackingViewModel extends StateNotifier<bool> {
  CarrierTrackingViewModel() : super(false); // false: 운행 정지, true: 운행 중

  WebSocketChannel? _channel;
  StreamSubscription<Position>? _positionStream;

  Future<void> startTracking(int orderId) async {
    if (state) return; // 이미 운행 중이면 무시

    // 1. 위치 권한 확인
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    // 2. 웹소켓 연결
    final baseUrl = ApiService().dio.options.baseUrl;
    final host = Uri.parse(baseUrl).host;
    final wsUrl = Uri.parse('ws://$host:8000/api/v1/tracking/ws/$orderId');
    
    try {
      _channel = WebSocketChannel.connect(wsUrl);
      state = true;

      // 3. 위치 변화 감지 및 직접 전송
      _positionStream = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 5,
        ),
      ).listen((Position position) {
        final data = {
          "lat": position.latitude,
          "lng": position.longitude,
          "role": "driver",
          "order_id": orderId.toString()
        };
        _channel?.sink.add(jsonEncode(data));
        debugPrint("📡 [VM] 위치 전송 완료: $data");
      }, onError: (error) {
        stopTracking();
      });
    } catch (e) {
      debugPrint("❌ [VM] 소켓 연결 실패: $e");
      state = false;
    }
  }

  // 🚀 Future<void> 유지하여 View의 await 코드와 호환
  Future<void> stopTracking() async {
    debugPrint("🛑 [VM] 위치 추적 및 소켓 종료 중...");
    await _positionStream?.cancel();
    _positionStream = null;
    
    await _channel?.sink.close();
    _channel = null;
    
    state = false;
  }

  @override
  void dispose() {
    stopTracking();
    super.dispose();
  }
}

final carrierTrackingProvider = StateNotifierProvider<CarrierTrackingViewModel, bool>((ref) => CarrierTrackingViewModel());

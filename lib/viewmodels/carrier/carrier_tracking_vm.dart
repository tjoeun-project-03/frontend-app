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

    // 1. 위치 권한 확인 및 요청
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      debugPrint("위치 서비스가 비활성화되어 있습니다.");
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        debugPrint("위치 권한이 거부되었습니다.");
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      debugPrint("위치 권한이 영구적으로 거부되었습니다. 설정에서 변경이 필요합니다.");
      return;
    }

    // 2. 웹소켓 연결
    final baseUrl = ApiService().dio.options.baseUrl;
    final uri = Uri.parse(baseUrl);
    final host = uri.host;
    
    // 백엔드 명세 포트 8000번 사용
    final wsUrl = Uri.parse('ws://$host:8000/api/v1/tracking/ws/$orderId');
    debugPrint("기사 웹소켓 연결 시도: $wsUrl");
    
    try {
      _channel = WebSocketChannel.connect(wsUrl);
      state = true;

      // 3. 위치 변화 감지 및 전송 (5초마다 또는 5미터 이동 시)
      _positionStream = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 5, // 5미터 이동 시마다 업데이트
        ),
      ).listen((Position position) {
        final data = {
          "lat": position.latitude,
          "lng": position.longitude,
          "role": "driver",
          "order_id": orderId.toString()
        };
        
        try {
          _channel?.sink.add(jsonEncode(data));
          debugPrint("기사 위치 전송 완료: $data");
        } catch (e) {
          debugPrint("위치 데이터 전송 에러: $e");
          stopTracking();
        }
      }, onError: (error) {
        debugPrint("위치 스트림 에러: $error");
        stopTracking();
      });
    } catch (e) {
      debugPrint("기사 소켓 연결 예외 발생: $e");
      state = false;
    }
  }

  void stopTracking() {
    debugPrint("기사 위치 추적 중지");
    _positionStream?.cancel();
    _positionStream = null;
    _channel?.sink.close();
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

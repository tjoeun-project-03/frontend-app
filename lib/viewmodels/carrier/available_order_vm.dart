import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:jimline/services/common/api_service.dart';
import '../../models/carrier/order_model.dart';

class AvailableOrderViewModel extends StateNotifier<AsyncValue<List<OrderResponse>>> {
  AvailableOrderViewModel() : super(const AsyncValue.loading());

  final _api = ApiService();

  /// 🚀 오더 목록 조회 및 거리순 정렬
  Future<void> fetchAvailableOrders() async {
    state = const AsyncValue.loading();
    try {
      // 1. 서버에서 가능한 오더 목록 가져오기
      final response = await _api.dio.get("/api/orders/available");
      final List<dynamic> data = response.data;
      List<OrderResponse> orders = data.map((json) => OrderResponse.fromJson(json)).toList();

      // 2. 📍 기사의 현재 위치 가져오기
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.always || permission == LocationPermission.whileInUse) {
        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high
        );

        // 3. 📏 현재 위치와 출발지(상차지) 간의 거리순으로 정렬
        orders.sort((a, b) {
          double distA = Geolocator.distanceBetween(
            position.latitude,
            position.longitude,
            a.startLat ?? 0.0,
            a.startLng ?? 0.0,
          );
          double distB = Geolocator.distanceBetween(
            position.latitude,
            position.longitude,
            b.startLat ?? 0.0,
            b.startLng ?? 0.0,
          );
          return distA.compareTo(distB);
        });
        
        debugPrint("✅ 오더 목록을 기사님 현재 위치 기준 거리순으로 정렬했습니다.");
      }

      state = AsyncValue.data(orders);
    } catch (e, stack) {
      debugPrint("❌ 오더 목록 조회 실패: $e");
      state = AsyncValue.error(e, stack);
    }
  }

  Future<bool> acceptOrder(int orderId) async {
    try {
      await _api.dio.patch("/api/orders/$orderId/accept");
      await fetchAvailableOrders();
      return true;
    } catch (e) {
      debugPrint("❌ 주문 수락 실패: $e");
      return false;
    }
  }
}

final availableOrderProvider = StateNotifierProvider<AvailableOrderViewModel, AsyncValue<List<OrderResponse>>>((ref) {
  return AvailableOrderViewModel();
});

// lib/viewmodels/carrier/available_order_vm.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jimline/services/common/api_service.dart';
import '../../models/carrier/order_model.dart';

class AvailableOrderViewModel extends StateNotifier<AsyncValue<List<OrderResponse>>> {
  AvailableOrderViewModel() : super(const AsyncValue.loading());

  final _api = ApiService();

  // 1. 대기 중인 주문 조회 (차주용)
  Future<void> fetchAvailableOrders() async {
    state = const AsyncValue.loading();
    try {
      final response = await _api.dio.get("/api/orders/available"); //
      final List<dynamic> data = response.data;
      final orders = data.map((json) => OrderResponse.fromJson(json)).toList();
      state = AsyncValue.data(orders);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  // 2. 주문 수락 기능
  Future<bool> acceptOrder(int orderId) async {
    try {
      // 서버의 PATCH /api/orders/{orderId}/accept 호출
      await _api.dio.patch("/api/orders/$orderId/accept");

      // 수락 성공 후 목록을 새로고침하여 수락한 항목을 제거함
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
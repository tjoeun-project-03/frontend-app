import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/common/api_service.dart';
import '../../models/carrier/order_model.dart';

class ActiveOrderState {
  final OrderResponse? activeOrder;
  final bool isInitialized;

  ActiveOrderState({this.activeOrder, this.isInitialized = false});
}

class ActiveOrderViewModel extends StateNotifier<ActiveOrderState> {
  final _api = ApiService();

  ActiveOrderViewModel() : super(ActiveOrderState());

  /// 서버 데이터 동기화 (운송 중인 오더 찾기)
  Future<void> syncWithServer() async {
    try {
      print("📡 [ActiveOrder] 서버 데이터 동기화 시작...");
      final response = await _api.dio.get("/api/orders/my");
      final List<dynamic> list = response.data;
      
      print("🔍 [ActiveOrder] 서버 응답 개수: ${list.length}");

      final activeJson = list.firstWhere(
        (o) {
          final s = (o['status'] ?? o['currentStatus'] ?? '').toString().trim();
          final upperS = s.toUpperCase();
          return upperS.contains('ACCEPTED') || s.contains('배차') || 
                 upperS.contains('DEPARTED') || s.contains('출발') ||
                 upperS.contains('ARRIVED') || s.contains('도착');
        },
        orElse: () => null,
      );

      if (activeJson != null) {
        final order = OrderResponse.fromJson(activeJson);
        state = ActiveOrderState(activeOrder: order, isInitialized: true);
        print("✅ [ActiveOrder] 운송 중인 오더 발견: ID ${order.orderId}");
      } else {
        state = ActiveOrderState(activeOrder: null, isInitialized: true);
        print("ℹ️ [ActiveOrder] 진행 중인 운송 없음.");
      }
    } catch (e) {
      print("❌ [ActiveOrder] 동기화 중 에러: $e");
      state = ActiveOrderState(activeOrder: null, isInitialized: true);
    }
  }

  void setActiveOrder(OrderResponse order) {
    state = ActiveOrderState(activeOrder: order, isInitialized: true);
  }

  /// 상차 완료 처리
  Future<bool> pickupOrder(int orderId) async {
    try {
      await _api.dio.patch("/api/orders/$orderId/pickup");
      await syncWithServer(); 
      return true;
    } catch (e) {
      return false;
    }
  }

  /// 🚀 백엔드 OrderCompleteRequest(String invoice) 형식에 맞춰 수정
  Future<bool> completeOrder(int orderId, String invoiceNo) async {
    try {
      // 🚩 필드명을 'invoiceNo'에서 'invoice'로 변경하여 백엔드 DTO와 매칭
      await _api.dio.post("/api/orders/$orderId/complete", data: {
        'invoice': invoiceNo, 
      });
      state = ActiveOrderState(activeOrder: null, isInitialized: true);
      return true;
    } catch (e) {
      print("❌ [ActiveOrder] 배송 완료 요청 실패: $e");
      return false;
    }
  }
}

final activeOrderProvider = StateNotifierProvider<ActiveOrderViewModel, ActiveOrderState>((ref) => ActiveOrderViewModel());

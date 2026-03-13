import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../services/common/api_service.dart';
import '../../models/carrier/order_model.dart';

class ActiveOrderState {
  final OrderResponse? activeOrder;
  final bool isInitialized;

  ActiveOrderState({this.activeOrder, this.isInitialized = false});
}

class ActiveOrderViewModel extends StateNotifier<ActiveOrderState> {
  final _api = ApiService();
  final _storage = const FlutterSecureStorage();

  ActiveOrderViewModel() : super(ActiveOrderState());

  /// 서버 데이터 동기화
  Future<void> syncWithServer() async {
    try {
      print("📡 [ActiveOrder] 서버 데이터 동기화 시작...");
      final response = await _api.dio.get("/api/orders/my");
      final List<dynamic> list = response.data;
      
      print("🔍 [ActiveOrder] 서버 응답 개수: ${list.length}");

      const activeStatusNames = ['ACCEPTED', 'DEPARTED', 'PICKUP'];
      const activeStatusDescs = ['배차 완료', '출발', '상차 완료', '운송 중'];

      final activeJson = list.firstWhere(
        (o) {
          final s = (o['status'] ?? o['currentStatus'] ?? '').toString().trim();
          return activeStatusNames.contains(s.toUpperCase()) || 
                 activeStatusDescs.contains(s);
        },
        orElse: () => null,
      );

      if (activeJson != null) {
        state = ActiveOrderState(activeOrder: OrderResponse.fromJson(activeJson), isInitialized: true);
      } else {
        state = ActiveOrderState(activeOrder: null, isInitialized: true);
      }
    } catch (e) {
      state = ActiveOrderState(activeOrder: null, isInitialized: true);
    }
  }

  /// 🚀 주문 완료 처리: 상태를 강제 초기화하여 UI 스위칭을 유도합니다.
  Future<bool> completeOrder(int orderId, String invoiceNo) async {
    try {
      print("📡 [ActiveOrder] 배송 완료 서버 요청 중: OrderID $orderId");
      
      // 1. 서버에 완료 신호 송신
      final response = await _api.dio.post("/api/orders/$orderId/complete", data: {'invoice': invoiceNo});
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        await _storage.delete(key: 'active_order_id');
        
        // 2. 🚀 핵심: 새로운 객체로 상태를 덮어씌워 리빌드를 강제합니다.
        state = ActiveOrderState(activeOrder: null, isInitialized: true);
        print("✅ [ActiveOrder] 상태 초기화 완료 -> 오더보드로 전환 유도");
        return true;
      }
      return false;
    } catch (e) {
      print("❌ [ActiveOrder] 배송 완료 요청 실패: $e");
      return false;
    }
  }

  void setActiveOrder(OrderResponse order) {
    state = ActiveOrderState(activeOrder: order.copyWith(status: 'ACCEPTED'), isInitialized: true);
  }

  Future<bool> pickupOrder(int orderId) async {
    try {
      await _api.dio.patch("/api/orders/$orderId/pickup");
      await syncWithServer(); 
      return true;
    } catch (e) { return false; }
  }
  
  // 🚀 로그아웃 시 상태 초기화
  void clear() {
    state = ActiveOrderState();
  }
}

final activeOrderProvider = StateNotifierProvider<ActiveOrderViewModel, ActiveOrderState>((ref) {
  return ActiveOrderViewModel();
});

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jimline/services/common/api_service.dart';

class OrderViewModel extends StateNotifier<bool> {
  OrderViewModel() : super(false);

  final _api = ApiService();

  Future<bool> createOrder(Map<String, dynamic> orderData) async {
    state = true;

    try {
      final response = await _api.dio.post(
        "/api/orders/confirm",
        data: orderData,
      );

      state = false;

      // 🚀 로그 확인 (디버깅용)
      print("Response Status: ${response.statusCode}");
      print("Response Data: ${response.data}");

      if (response.statusCode == 200) {
        return true;
      }

      return false;
    } catch (e) {
      print("주문 생성 에러: $e");
      state = false;
      return false;
    }
  }

  Future<String?> getNewInvoiceNo() async {
    try {
      // 서버의 /api/orders/generate-invoice 엔드포인트 호출
      final response = await _api.dio.get("/api/orders/generate-invoice");

      if (response.statusCode == 200) {
        return response.data.toString(); // JIM-260226-ABCD 형태의 문자열 반환
      }
      return null;
    } catch (e) {
      print("인보이스 번호 생성 실패: $e");
      return null;
    }
  }
}

final orderViewModelProvider = StateNotifierProvider<OrderViewModel, bool>((ref) => OrderViewModel());
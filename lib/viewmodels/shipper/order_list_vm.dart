import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jimline/services/common/api_service.dart';
import '../../models/shipper/order_response.dart';

class OrderListState {
  final List<OrderResponse> orders;
  final bool isLoading;
  final int selectedTabIndex;
  final Map<String, int> summary;

  OrderListState({this.orders = const [], this.isLoading = false, this.selectedTabIndex = 0, this.summary = const {"waiting": 0, "ing" : 0, "done": 0}});

  OrderListState copyWith({
    List<OrderResponse>? orders,
    bool? isLoading,
    int? selectedTabIndex,
    Map<String, int>? summary
  }) {
    return OrderListState(
      orders: orders ?? this.orders,
      isLoading: isLoading ?? this.isLoading,
      selectedTabIndex: selectedTabIndex ?? this.selectedTabIndex,
      summary: summary ?? this.summary,
    );
  }
}

class OrderListViewModel extends StateNotifier<OrderListState> {
  final ApiService _api = ApiService();

  OrderListViewModel() : super(OrderListState()) {
    fetchMyOrders(); // 초기화 시 목록 로드
  }

  void changeTab(int index) {
    state = state.copyWith(selectedTabIndex: index);
  }

  Future<void> fetchMyOrders() async {
    state = state.copyWith(isLoading: true);
    try {
      final response = await _api.dio.get('/api/orders/my');
      final summary = await _api.dio.get('/api/orders/summary');
      print("서버 응답 상태: ${response.statusCode}");
      print("서버 데이터: ${response.data}"); // 👈 여기가 [] 인지 확인하세요!

      final List<dynamic> data = response.data;
      final orders = data.map((json) => OrderResponse.fromJson(json)).toList();
      final summaryData = summary.data;
      state = state.copyWith(
          orders: orders,
          summary: {
            "waiting" : summaryData["createdCount"] ?? 0,
            "ing" : summaryData["acceptedCount"] ?? 0,
            "done" : summaryData["completedCount"]?? 0,
          },
          isLoading: false);
    } catch (e) {
      print("데이터 로드 중 에러 발생: $e"); // 👈 401(인증에러)이나 403이 뜨는지 확인
      state = state.copyWith(isLoading: false);
    }
  }
}

final orderListProvider = StateNotifierProvider<OrderListViewModel, OrderListState>((ref) {
  return OrderListViewModel();
});
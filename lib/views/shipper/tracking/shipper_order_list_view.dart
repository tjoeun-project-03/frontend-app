import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../viewmodels/shipper/order_list_vm.dart';
import './shipperHistoryTrackingView.dart';

class ShipperOrderListView extends ConsumerWidget {
  const ShipperOrderListView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(orderListProvider);
    final viewModel = ref.read(orderListProvider.notifier);

    const Color jimlineNavy = Color(0xFF1A2B88);
    const Color jimlineNavyLight = Color(0xFFD1D5E7);
    const Color borderGrey = Color(0xFFEEEEEE);
    const Color bgGrey = Color(0xFFF5F5F5);
    const Color textGrey = Color(0xFF9E9E9E);

    // --- 필터링 로직 ---
    final filteredOrders = state.orders.where((order) {
      final status = order.currentStatus;
      if (state.selectedTabIndex == 0) {
        // 1. 배차대기 (전체 탭을 배차대기로 변경)
        // 서버 DTO에서 getDescription()이 "주문 생성"을 반환하므로 이를 체크
        return status == "주문 생성";
      }
      else if (state.selectedTabIndex == 1) {
        // 2. 배송중 (주문 생성도 아니고, 완료/취소도 아닌 중간 상태들)
        return status != "주문 생성" && status != "배송 완료";
      }
      else if (state.selectedTabIndex == 2) {
        // 3. 완료
        return status == "배송 완료" || status == "취소됨";
      }
      return true; // 전체
    }).toList();

    if (state.isLoading) return const Center(child: CircularProgressIndicator(color: jimlineNavy));
    final summary = state.summary;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Container(
            height: 48,
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(color: jimlineNavy, borderRadius: BorderRadius.circular(8)),
            child: Row(
              children: [
                _buildTabItem("대기중 ${summary["waiting"].toString()}", state.selectedTabIndex == 0, () => viewModel.changeTab(0)),
                _buildTabItem("배송중 ${summary["ing"].toString()}", state.selectedTabIndex == 1, () => viewModel.changeTab(1)),
                _buildTabItem("완료 ${summary["done"].toString()}", state.selectedTabIndex == 2, () => viewModel.changeTab(2)),
              ],
            ),
          ),
        ),

        // --- 리스트 본문 ---
        Expanded(
          child: RefreshIndicator(
            onRefresh: () => viewModel.fetchMyOrders(),
            child: filteredOrders.isEmpty
                ? const Center(child: Text("내역이 없습니다."))
                : ListView.builder(
              itemCount: filteredOrders.length,
              padding: const EdgeInsets.all(16),
              itemBuilder: (context, index) {
                final order = filteredOrders[index];
                return _buildOrderCard(context, order, jimlineNavy, borderGrey, bgGrey, textGrey);
              },
            ),
          ),
        ),
      ],
    );
  }

  // --- 탭 아이템 빌더 (동일한 디자인 유지) ---
  Widget _buildTabItem(String label, bool isSelected, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? const Color(0xFF1A2B88) : Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
  Widget _buildSummaryBox(String title, String count, Color color, Color borderColor) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: borderColor),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(title, style: const TextStyle(color: Color(0xFF9E9E9E), fontSize: 13)),
            Text(count, style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
  // --- 기존 카드 디자인 래핑 ---
  Widget _buildOrderCard(BuildContext context, order, Color navy, Color bGrey, Color bgGrey, Color tGrey) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ShipperHistoryTrackingView(orderId: order.orderId!)),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: bGrey),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(order.currentStatus ?? "배송중", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  const SizedBox(height: 4),
                  Text("출발지: ${order.departure ?? "오류"}\n도착지: ${order.arrival ?? "오류"}",
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: navy)),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const CircleAvatar(
                        radius: 18,
                        backgroundColor: Color(0xFFEEEEEE),
                        child: Icon(Icons.person, color: Color(0xFF9E9E9E), size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                order.carrier ?? "배차 대기 중",
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                              )
                            ],
                          )
                      ),
                      SizedBox(
                        height: 32,
                        width: 80,
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: navy,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                          ),
                          child: const Text("위치 보기", style: TextStyle(fontSize: 12)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
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
    const Color borderGrey = Color(0xFFEEEEEE);
    const Color bgGrey = Color(0xFFF5F5F5);
    const Color textGrey = Color(0xFF9E9E9E);

    // --- 🚀 백엔드 OrderStatus Enum 기준으로 필터링 로직 수정 ---
    final filteredOrders = state.orders.where((order) {
      final status = order.currentStatus?.toUpperCase() ?? '';

      if (state.selectedTabIndex == 0) {
        // 1. 배차대기 (주문 생성 상태)
        return status == 'CREATED';
      } 
      else if (state.selectedTabIndex == 1) {
        // 2. 배송중 (배차수락, 출발, 도착 상태 모두 포함)
        return ['ACCEPTED', 'DEPARTED', 'ARRIVED'].contains(status);
      } 
      else if (state.selectedTabIndex == 2) {
        // 3. 완료/취소
        return ['COMPLETED', 'CANCELED'].contains(status);
      }
      return true; // 전체 (현재는 사용되지 않음)
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
                  Text(order.currentStatus ?? "상태 미확인", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  const SizedBox(height: 4),
                  Text("출발지: ${order.departure ?? "-"}\n도착지: ${order.arrival ?? "-"}",
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

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart'; // 🚀 임포트 추가
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

    // --- 🚀 필터링 로직 보강 (Enum명과 한글명 모두 대응) ---
    final filteredOrders = state.orders.where((order) {
      final status = (order.currentStatus ?? '').toUpperCase().trim();

      if (state.selectedTabIndex == 0) {
        // 1. 배차대기
        return status == 'CREATED' || status == '주문 생성' || status == '주문생성';
      } 
      else if (state.selectedTabIndex == 1) {
        // 2. 배송중 (중간 단계 모두 포함)
        return ['ACCEPTED', 'DEPARTED', 'ARRIVED', 'PICKUP', '배차 완료', '배차완료', '출발', '도착', '상차 완료', '상차완료']
            .contains(status);
      } 
      else if (state.selectedTabIndex == 2) {
        // 3. 완료/취소
        return ['COMPLETED', 'CANCELED', 'CANCELLED', '배송 완료', '배송완료', '취소됨', '취소'].contains(status);
      }
      return true;
    }).toList();

    if (state.isLoading) return const Center(child: CircularProgressIndicator(color: jimlineNavy));
    
    final summary = state.summary;

    return Column(
      children: [
        // 탭 바 영역
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Container(
            height: 48,
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(color: jimlineNavy, borderRadius: BorderRadius.circular(8)),
            child: Row(
              children: [
                _buildTabItem("대기중 ${summary["waiting"]}", state.selectedTabIndex == 0, () => viewModel.changeTab(0)),
                _buildTabItem("배송중 ${summary["ing"]}", state.selectedTabIndex == 1, () => viewModel.changeTab(1)),
              ],
            ),
          ),
        ),

        Expanded(
          child: RefreshIndicator(
            onRefresh: () => viewModel.fetchMyOrders(),
            child: filteredOrders.isEmpty
                ? ListView( // Empty state에서도 스크롤 가능하게 하여 pull-to-refresh 유지
                    children: const [
                      SizedBox(height: 100),
                      Center(child: Text("해당하는 내역이 없습니다.", style: TextStyle(color: Colors.grey))),
                    ],
                  )
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
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOrderCard(BuildContext context, dynamic order, Color navy, Color bGrey, Color bgGrey, Color tGrey) {
    return GestureDetector(
      onTap: () {
        // 상세 추적 페이지로 이동
        context.push('/shipper-tracking/${order.orderId}');
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: bGrey),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    order.currentStatus ?? "상태 미확인", 
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: navy)
                  ),
                  const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.circle, size: 8, color: Colors.blue),
                  const SizedBox(width: 12),
                  Expanded(child: Text(order.departure ?? "-", style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500))),
                ],
              ),
              const Padding(
                padding: EdgeInsets.only(left: 3, top: 4, bottom: 4),
                child: Icon(Icons.more_vert, size: 12, color: Colors.grey),
              ),
              Row(
                children: [
                  const Icon(Icons.location_on, size: 10, color: Colors.red),
                  const SizedBox(width: 12),
                  Expanded(child: Text(order.arrival ?? "-", style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500))),
                ],
              ),
              const Divider(height: 32),
              Row(
                children: [
                  const CircleAvatar(
                    radius: 16,
                    backgroundColor: Color(0xFFF5F5F5),
                    child: Icon(Icons.person, color: Colors.grey, size: 18),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      order.carrier ?? "배차 대기 중",
                      style: const TextStyle(fontSize: 14, color: Colors.black87),
                    ),
                  ),
                  if (order.carrier != null)
                    TextButton(
                      onPressed: () => context.push('/shipper-tracking/${order.orderId}'),
                      child: const Text("실시간 위치", style: TextStyle(color: Color(0xFF1A2B88), fontWeight: FontWeight.bold)),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

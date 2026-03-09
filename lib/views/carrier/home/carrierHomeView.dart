import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'orderBoardView.dart';
import '../mypage/carrierMyPageView.dart';
import '../../../viewmodels/carrier/profile_vm.dart';
import '../../../models/carrier/order_model.dart';

class CarrierHomeView extends ConsumerStatefulWidget {
  const CarrierHomeView({super.key});
  @override
  ConsumerState<CarrierHomeView> createState() => _CarrierHomeViewState();
}

class _CarrierHomeViewState extends ConsumerState<CarrierHomeView> {
  int _selectedIndex = 0;
  final Color primaryNavy = const Color(0xFF1A2B88);

  @override
  void initState() {
    super.initState();
    // 메모: 진입 시 데이터 로드
    Future.microtask(() => ref.read(carrierProfileProvider.notifier).fetchProfile());
  }

  List<Widget> get _screens => [
    const OrderBoardView(),
    _buildDeliveryHistoryTab(),
    const Center(child: Text("정산 내역")),
    const CarrierMyPageView(),
  ];

  Widget _buildDeliveryHistoryTab() {
    final profile = ref.watch(carrierProfileProvider);
    
    // 메모: '완료' 글자가 포함된 것(예약완료 등)이 아니라 정확히 'COMPLETED' 또는 '운송완료'인 것만 필터링
    final completedOrders = profile.allOrders.where((order) {
      final status = order.status.toUpperCase();
      return order.statusText == '배송 완료';
    }).toList();

    if (profile.isLoading) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFF1A2B88)));
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(carrierProfileProvider.notifier).fetchProfile(),
      color: primaryNavy,
      child: completedOrders.isEmpty
          ? ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: const [
                SizedBox(height: 100),
                Center(child: Text("완료된 배송 내역이 없습니다.", style: TextStyle(color: Colors.grey))),
              ],
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: completedOrders.length,
              itemBuilder: (context, index) {
                final order = completedOrders[index];
                return _buildOrderCard(order);
              },
            ),
    );
  }

  Widget _buildOrderCard(OrderResponse order) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Order ID: ${order.orderId}", 
                style: TextStyle(fontWeight: FontWeight.bold, color: primaryNavy, fontSize: 14)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: primaryNavy.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(order.statusText, 
                  style: TextStyle(color: primaryNavy, fontSize: 11, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const Divider(height: 20),
          _buildInfoRow("송장번호", order.invoiceNo),
          _buildInfoRow("화주 ID", order.shipperId),
          _buildInfoRow("차주 ID", order.carrierId),
          _buildInfoRow("결제 금액", "${_formatPrice(order.price)}원"),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.circle, size: 8, color: Colors.blue),
              const SizedBox(width: 8),
              Expanded(child: Text(order.departure, style: const TextStyle(fontSize: 14))),
            ],
          ),
          const Padding(
            padding: EdgeInsets.only(left: 3, top: 2, bottom: 2),
            child: Icon(Icons.more_vert, size: 12, color: Colors.grey),
          ),
          Row(
            children: [
              const Icon(Icons.circle, size: 8, color: Colors.red),
              const SizedBox(width: 8),
              Expanded(child: Text(order.arrival, style: const TextStyle(fontSize: 14))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          SizedBox(width: 70, child: Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13))),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }

  String _formatPrice(int price) {
    return price.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},'
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          ["오더 보드", "내 운송", "정산 내역", "마이 페이지"][_selectedIndex],
          style: TextStyle(color: primaryNavy, fontWeight: FontWeight.bold),
        ),
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          if (index == 1) {
            ref.read(carrierProfileProvider.notifier).fetchProfile();
          }
          setState(() => _selectedIndex = index);
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: primaryNavy,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: "오더보드"),
          BottomNavigationBarItem(icon: Icon(Icons.local_shipping_outlined), label: "내 운송"),
          BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet_outlined), label: "정산내역"),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: "마이페이지"),
        ],
      ),
    );
  }
}

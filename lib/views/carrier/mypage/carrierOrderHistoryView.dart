import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../viewmodels/carrier/profile_vm.dart';
import '../../../models/carrier/order_model.dart';

class CarrierOrderHistoryView extends ConsumerStatefulWidget {
  const CarrierOrderHistoryView({super.key});

  @override
  ConsumerState<CarrierOrderHistoryView> createState() => _CarrierOrderHistoryViewState();
}

class _CarrierOrderHistoryViewState extends ConsumerState<CarrierOrderHistoryView> {
  @override
  void initState() {
    super.initState();
    // 메모: 페이지 진입 시 데이터를 최신화하기 위해 API 호출
    Future.microtask(() => ref.read(carrierProfileProvider.notifier).fetchProfile());
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(carrierProfileProvider);
    final orders = profile.allOrders;

    const Color jimlineNavy = Color(0xFF1A2B88);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text("전체 배송 내역", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
      ),
      body: profile.isLoading
          ? const Center(child: CircularProgressIndicator(color: jimlineNavy))
          : orders.isEmpty
              ? const Center(child: Text("배송 내역이 없습니다.", style: TextStyle(color: Colors.grey)))
              : RefreshIndicator(
                  onRefresh: () => ref.read(carrierProfileProvider.notifier).fetchProfile(),
                  color: jimlineNavy,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: orders.length,
                    itemBuilder: (context, index) {
                      final order = orders[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 10,
                              offset: const Offset(0, 4)
                            )
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("Order ID: ${order.orderId}", 
                                  style: const TextStyle(fontWeight: FontWeight.bold, color: jimlineNavy, fontSize: 14)),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: jimlineNavy.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(order.statusText, 
                                    style: const TextStyle(color: jimlineNavy, fontSize: 11, fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                            const Divider(height: 24),
                            _buildInfoRow("송장번호", order.invoiceNo),
                            _buildInfoRow("화주 ID", order.shipperId),
                            _buildInfoRow("차주 ID", order.carrierId),
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
                    },
                  ),
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
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../viewmodels/carrier/profile_vm.dart';
import '../../../models/carrier/order_model.dart';

class CarrierOrderHistoryView extends ConsumerWidget {
  const CarrierOrderHistoryView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(carrierProfileProvider);
    final orders = profile.allOrders;

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
      body: orders.isEmpty
          ? const Center(child: Text("배송 내역이 없습니다.", style: TextStyle(color: Colors.grey)))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final order = orders[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
                  ),
                  child: ExpansionTile(
                    shape: const Border(),
                    collapsedShape: const Border(),
                    title: Text(
                      "${order.departure} ➔ ${order.arrival}",
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF1A2B88)),
                    ),
                    subtitle: Text(
                      "${order.formattedDate} | ${order.price}원 | ${order.statusText}",
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        child: Column(
                          children: [
                            const Divider(height: 1, color: Color(0xFFEEEEEE)),
                            const SizedBox(height: 12),
                            _buildDetailRow("송장번호", order.invoiceNo),
                            _buildDetailRow("운송물품", order.content),
                            _buildDetailRow("차량종류", order.carType),
                            _buildDetailRow("중량", "${order.weight}톤"),
                            _buildDetailRow("운송거리", "${order.distance}km"),
                            _buildDetailRow("소요시간", "${order.duration}분"),
                            _buildDetailRow("수하인", order.consigneeName),
                            _buildDetailRow("연락처", order.consigneeContact),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 80, child: Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13))),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import '../../../models/carrier/order_model.dart';
import '../../../viewmodels/carrier/available_order_vm.dart';
import '../../../viewmodels/carrier/active_order_vm.dart';

class OrderBoardView extends ConsumerStatefulWidget {
  const OrderBoardView({super.key});
  @override
  ConsumerState<OrderBoardView> createState() => _OrderBoardViewState();
}

class _OrderBoardViewState extends ConsumerState<OrderBoardView> {
  final Color primaryNavy = const Color(0xFF1A2B88);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(availableOrderProvider.notifier).fetchAvailableOrders();
    });
  }

  @override
  Widget build(BuildContext context) {
    final ordersAsync = ref.watch(availableOrderProvider);

    return Material(
      color: Colors.white,
      child: Column(
        children: [
          const SizedBox(height: 12),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => ref.read(availableOrderProvider.notifier).fetchAvailableOrders(),
              child: ordersAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, _) => ListView(children: [Center(child: Text("에러: $err"))]),
                data: (orders) {
                  if (orders.isEmpty) {
                    return ListView(children: const [
                      SizedBox(height: 100),
                      Center(child: Text("현재 가능한 오더가 없습니다.")),
                    ]);
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: orders.length,
                    itemBuilder: (context, index) => _buildOrderCard(orders[index]),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, {bool isFirst = false}) => Container(
    margin: const EdgeInsets.only(right: 8),
    child: ActionChip(
      label: Text(label, style: TextStyle(color: isFirst ? Colors.white : Colors.black87, fontSize: 13)),
      backgroundColor: isFirst ? primaryNavy : Colors.white,
      shape: StadiumBorder(side: BorderSide(color: Colors.grey[300]!)),
      onPressed: () {},
    ),
  );

  Widget _buildOrderCard(OrderResponse order) => Container(
    margin: const EdgeInsets.only(bottom: 16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24),
      border: Border.all(color: Colors.grey[200]!),
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
    ),
    child: InkWell(
      onTap: () => context.push('/carrier-order-detail', extra: order),
      borderRadius: BorderRadius.circular(24),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("${order.carType} | ${order.distance.toStringAsFixed(1)}km",
                    style: const TextStyle(color: Colors.grey, fontSize: 13)),
                const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
              ],
            ),
            const SizedBox(height: 8),
            Text("${order.departure} ➔ ${order.arrival}",
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: primaryNavy)),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("ESTIMATED FEE", style: TextStyle(color: Colors.grey, fontSize: 10)),
                      Text("${NumberFormat('#,###').format(order.price)}원",
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, overflow: TextOverflow.ellipsis)),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                // 🚀 레이아웃 에러 해결을 위해 스타일 직접 지정
                ElevatedButton(
                  onPressed: () => _showQuickAcceptDialog(order),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryNavy,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    minimumSize: const Size(0, 40), // 너비는 내용에 맞게, 높이는 40 고정
                    elevation: 0,
                  ),
                  child: const Text("수락하기", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                ),
              ],
            ),
            const Divider(height: 32),
            Row(
              children: [
                const Icon(Icons.access_time, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Text("${_formatShortTime(order.created)} 등록 | ${_formatDuration(order.duration)} 소요",
                    style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ],
        ),
      ),
    ),
  );

  void _showQuickAcceptDialog(OrderResponse order) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("운송 즉시 수락"),
        content: Text("${order.departure} → ${order.arrival}\n\n상세 정보 확인 없이 바로 수락하시겠습니까?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("취소", style: TextStyle(color: Colors.grey))),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final success = await ref.read(availableOrderProvider.notifier).acceptOrder(order.orderId);
              if (success && mounted) {
                ref.read(activeOrderProvider.notifier).setActiveOrder(order);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("배차가 수락되었습니다.")));
              }
            },
            child: Text("수락", style: TextStyle(color: primaryNavy, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  String _formatDuration(int min) {
    if (min < 60) return "$min분";
    final h = min ~/ 60;
    final m = min % 60;
    return m == 0 ? "$h시간" : "$h시간 ${m.toString().padLeft(2, '0')}분";
  }

  String _formatShortTime(String date) {
    try {
      return DateFormat('MM/dd HH:mm').format(DateTime.parse(date));
    } catch (_) {
      return "정보 없음";
    }
  }
}

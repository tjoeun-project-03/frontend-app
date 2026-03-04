// lib/views/carrier/home/orderBoardView.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../models/carrier/order_model.dart';
import '../../../viewmodels/carrier/available_order_vm.dart';

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
          // 1. 필터 바 (상단 탭 제거됨)
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(left: 16, bottom: 12),
            child: Row(
              children: [
                _buildFilterChip("필터", isFirst: true),
                _buildFilterChip("거리순"),
                _buildFilterChip("차량 종류"),
                _buildFilterChip("상하차방식"),
              ],
            ),
          ),
          // 2. 오더 리스트
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
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24),
      border: Border.all(color: Colors.grey[200]!),
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("${order.carType} | ${order.distance.toStringAsFixed(1)}km",
            style: const TextStyle(color: Colors.grey, fontSize: 13)),
        const SizedBox(height: 6),
        Text("${order.departure} ➔ ${order.arrival}",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryNavy)),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("ESTIMATED FEE", style: TextStyle(color: Colors.grey, fontSize: 10)),
                Text("${NumberFormat('#,###').format(order.price)}원",
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
              ],
            ),
            SizedBox(
              width: 70,
              height: 28,
              child: ElevatedButton(
                onPressed: () => _showAcceptDialog(order),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryNavy,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  elevation: 0,
                ),
                child: const Text("선택하기", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              ),
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
  );

  // 🚀 주문 수락 확인창
  void _showAcceptDialog(OrderResponse order) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("운송 수락", style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text("정말로 이 운송을 수락하시겠습니까?\n수락 후에는 취소가 어려울 수 있습니다."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("취소", style: TextStyle(color: Colors.grey))),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final success = await ref.read(availableOrderProvider.notifier).acceptOrder(order.orderId);
              if (success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("운송이 수락되었습니다."))
                );
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
      // '15:06' -> '2026-03-02 15:06' 형식으로 변경
      return DateFormat('yyyy-MM-dd HH:mm').format(DateTime.parse(date));
    }
    catch (_) {
      return "정보 없음";
    }
  }
}
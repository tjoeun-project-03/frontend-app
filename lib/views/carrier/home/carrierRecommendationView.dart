import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import '../../../viewmodels/carrier/recommendation_vm.dart';
import '../../../models/carrier/recommendation_model.dart';
import '../../../models/carrier/order_model.dart';
import '../../../services/common/api_service.dart';

class CarrierRecommendationView extends ConsumerStatefulWidget {
  final double currentLat;
  final double currentLng;

  const CarrierRecommendationView({
    super.key,
    required this.currentLat,
    required this.currentLng,
  });

  @override
  ConsumerState<CarrierRecommendationView> createState() => _CarrierRecommendationViewState();
}

class _CarrierRecommendationViewState extends ConsumerState<CarrierRecommendationView> {
  final Color primaryNavy = const Color(0xFF1A2B88);

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(recommendationProvider.notifier).fetchBackHomeTop3(
        currentLat: widget.currentLat,
        currentLng: widget.currentLng,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(recommendationProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text("복귀 추천 오더 (AI)", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => context.go('/carrier-home'),
        ),
      ),
      body: state.isLoading 
        ? const Center(child: CircularProgressIndicator(color: Color(0xFF1A2B88)))
        : state.error != null
          ? Center(child: Text(state.error!))
          : Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: state.recommendations.isEmpty 
                    ? const Center(child: Text("조건에 맞는 추천 오더가 없습니다."))
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        itemCount: state.recommendations.length,
                        itemBuilder: (context, index) => _buildRecommendationCard(state.recommendations[index]),
                      ),
                ),
              ],
            ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("집으로 가는 가장 효율적인 길,", style: TextStyle(fontSize: 14, color: Colors.grey)),
          const SizedBox(height: 4),
          Row(
            children: [
              Text("복귀 추천 TOP 3", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: primaryNavy)),
              const SizedBox(width: 8),
              const Icon(Icons.auto_awesome, color: Colors.amber, size: 24),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationCard(RecommendedOrder order) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(color: primaryNavy, borderRadius: BorderRadius.circular(8)),
                      child: Text("추천 순위 ${order.rank}위", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                    ),
                    Text("매칭 점수 ${order.finalScore.toStringAsFixed(1)}점", style: TextStyle(color: primaryNavy, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 16),
                
                // 🚀 출발지 -> 목적지 명시
                Row(
                  children: [
                    const Icon(Icons.circle, size: 8, color: Colors.blue),
                    const SizedBox(width: 8),
                    Expanded(child: Text(order.departure, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15), overflow: TextOverflow.ellipsis)),
                  ],
                ),
                Container(height: 12, margin: const EdgeInsets.only(left: 3), decoration: const BoxDecoration(border: Border(left: BorderSide(color: Colors.grey, width: 1)))),
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 10, color: Colors.red),
                    const SizedBox(width: 8),
                    Expanded(child: Text(order.arrival, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15), overflow: TextOverflow.ellipsis)),
                  ],
                ),
                
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("운송 거리: ${order.distance}km", style: const TextStyle(color: Colors.grey, fontSize: 13)),
                    Text("${NumberFormat('#,###').format(order.totalPrice)}원", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  ],
                ),
                
                const Divider(height: 32),
                Row(
                  children: [
                    _buildDistInfo("상차지까지", "${order.pickupDist.toStringAsFixed(1)}km", Icons.location_on_outlined, Colors.blue),
                    Container(width: 1, height: 30, color: Colors.grey[200], margin: const EdgeInsets.symmetric(horizontal: 16)),
                    _buildDistInfo("하차후 귀가", "${order.returnDist.toStringAsFixed(1)}km", Icons.home_outlined, Colors.green),
                  ],
                ),
              ],
            ),
          ),
          InkWell(
            onTap: () => _navigateToDetail(order),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: primaryNavy.withOpacity(0.05),
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
              ),
              child: Center(child: Text("오더 상세 확인", style: TextStyle(color: primaryNavy, fontWeight: FontWeight.bold))),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _navigateToDetail(RecommendedOrder ro) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final api = ApiService();
      final response = await api.dio.get("/api/orders/id/${ro.orderId}");

      if (mounted) {
        Navigator.pop(context);
        if (response.statusCode == 200) {
          final realOrder = OrderResponse.fromJson(response.data);
          context.push('/carrier-order-detail', extra: realOrder);
        } else {
          _showError("오더 정보를 찾을 수 없습니다.");
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        _showError("오더 정보 조회 중 오류가 발생했습니다.");
      }
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));
  }

  Widget _buildDistInfo(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
              Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            ],
          ),
        ],
      ),
    );
  }
}
